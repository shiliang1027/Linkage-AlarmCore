package com.linkage.module.cms.alarm.framework.module.dao.data
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.AlarmContainer;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.system.rpc.remoting.BlazeDSUtil;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.messaging.ChannelSet;
	import mx.messaging.Consumer;
	import mx.messaging.channels.AMFChannel;
	import mx.messaging.channels.StreamingAMFChannel;
	import mx.messaging.events.ChannelEvent;
	import mx.messaging.events.ChannelFaultEvent;
	import mx.messaging.events.MessageEvent;
	import mx.messaging.events.MessageFaultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.remoting.RemoteObject;

	/**
	 *告警数据实现类
	 * @author mengqiang
	 *
	 */
	public class AlarmDataImp implements AlarmData
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.module.dao.data.AlarmDataImp");
		/**
		 * 发送数据的web目的地
		 */
		private var remoteDestination:String = "flexdestination_cms_alarm_register_service";
		/**
		 * 发送数据的source
		 */
		private var remoteSource:String = "com.linkage.module.cms.alarm.register.FlexCommonServImp";
		/**
		 * 拉取服务的通道
		 */
		public static const CHANNELSET_POLL:String = "my-polling-amf";
		/**
		 * 推送服务的通道
		 */
		public static const CHANNELSET_PUSH:String = "my-streaming-amf";
		/**
		 * 拉取服务的endpoint
		 */
		public static const CHANNELSET_POLL_ENDPONIT:String = "/messagebroker/amfpolling";
		/**
		 * 推送服务的endpoint
		 */
		public static const CHANNELSET_PUSH_ENDPONIT:String = "/messagebroker/streamingamf";
		/**
		 *amf
		 */
		public static const endpoint_SUFFIX:String = "/messagebroker/amf";
		/**
		 * 推送服务的目的地
		 */
		public static const DESTINATION_ALARM:String = "alarm";
		/**
		 *通道重连机制:10s后重连
		 */
		public var connTimer:Timer = new Timer(10000);
		/**
		 * 统计连接次数
		 */
		public var connTime:uint = 0;
		/**
		 *通道
		 */
		private var channelSet:ChannelSet = null;
		/**
		 *上下文
		 */
		protected var context:String = null;
		/**
		 *endpoint
		 */
		protected var endpoint:String = null;
		/**
		 *告警订阅者
		 */
		private var consumer:Consumer = null;
		/**
		 *订阅状态
		 */
		private var subStaue:Boolean=false;
		/**
		 *用户的会话信息(sessionId,areaId,roleId,account,context)
		 */
		private var _mapInfo:Object = null;

		public function AlarmDataImp(mapInfo:Object)
		{
			//1.初始化参数
			_mapInfo = mapInfo;
			context = mapInfo[AlarmContainer.PARAMKEY_CONTEXT];
			context = context.replace(/\//g, "");
			endpoint = "/" + context + endpoint_SUFFIX;

			//2.设置定时通道重连
			connTimer.addEventListener(TimerEvent.TIMER, connecTimerHandler);
		}

		//创建通道
		public function createChannelSet():void
		{
			channelSet = new ChannelSet();

			//1.推的方式
			var epush:String = "http://{server.name}:{server.port}/" + context + CHANNELSET_PUSH_ENDPONIT;
			channelSet.addChannel(new StreamingAMFChannel(CHANNELSET_PUSH, epush));

			//2.拉的方式
			var epoll:String = "http://{server.name}:{server.port}/" + context + CHANNELSET_POLL_ENDPONIT;
			channelSet.addChannel(new AMFChannel(CHANNELSET_POLL, epoll));
		}

		public function subscribeAlarms(success:Function):void
		{
			if (consumer == null)
			{
				consumer = new Consumer();
				consumer.channelSet = channelSet;
				consumer.destination = DESTINATION_ALARM;

				consumer.requestTimeout = 10;
				consumer.addEventListener(ChannelEvent.CONNECT, channelConnectHandler);
				consumer.addEventListener(ChannelEvent.DISCONNECT, channelDisconnectHandler);
				consumer.addEventListener(ChannelFaultEvent.FAULT, channelFaultHandler);
				consumer.addEventListener(MessageFaultEvent.FAULT, faultHandler);
				consumer.addEventListener(MessageEvent.MESSAGE, success);
			}
			consumer.selector = "sessionid in('" + _mapInfo[AlarmContainer.PARAMKEY_UUID] + "')";
			log.warn("订阅告警 selector = " + consumer.selector);
			if(!subStaue)
			{
				consumer.subscribe();
			}
			subStaue=true;
		}

		//通道链接失败
		private function channelFaultHandler(event:ChannelFaultEvent):void
		{
			log.warn("通道链接失败，失败原因:" + event.channelId + "\n" + event.faultCode + "\n" + event.faultDetail);
		}

		//消息失败
		private function faultHandler(event:MessageFaultEvent):void
		{
			log.warn("消息失败，失败原因:" + event.faultDetail);
		}


		//通道断开
		private function channelDisconnectHandler(event:ChannelEvent):void
		{
			log.warn("通道断开+++++++++++++++++++++++++++" + subStaue);
			if (!connTimer.running && subStaue)
			{
				connTimer.start();
			}
		}

		//通道连接
		private function channelConnectHandler(event:ChannelEvent):void
		{
			log.warn("通道连接+++++++++++++++++++++++++++");
			if (connTimer.running)
			{
				connTime = 0;
				connTimer.stop();
			}
		}

		//通道重连
		private function connecTimerHandler(event:TimerEvent):void
		{
			connTime++;
			if (connTime < 20)
			{
				channelSet.connect(consumer);
				consumer.subscribe();
			}
			else
			{
				connTimer.stop();
				log.warn("自动重连超过20次，请检查网络情况++++++++++++");
			}
		}

		public function unsubscribeAlarms():void
		{
			log.warn("取消订阅告警");
			subStaue=false;
			connTimer.stop();
			consumer.unsubscribe();
			consumer.disconnect();
		}

		public function getResourceInfo(success:Function):void
		{
			//1.拼装参数
			var params:Object = AlarmUtil.cloneObject(_mapInfo);

			//2.调用注册方法
			var remoteService:RemoteObject = BlazeDSUtil.newService(remoteDestination, remoteSource, endpoint, function(result:Object):void
				{
					log.info("【向web加载域权限资源】成功");
					success.call(this, result);
				}, function(event:FaultEvent):void
				{
					log.info("【向web加载域权限资源】失败" + event);
				}, true, "getResourceInfo");
			log.info("【向web加载域权限资源】开始");
			remoteService.getResourceInfo(params);
		}

		public function regListenerAlarm(ruleList:ArrayList, defColumn:String, success:Function):void
		{
			//1.拼装参数
			var params:Object = AlarmUtil.cloneObject(_mapInfo);
			params[AlarmContainer.PARAMKEY_RULE] = ruleList;
			if (defColumn != null)
			{
				params[AlarmContainer.PARAMKEY_DISPLAYCOLUMN] = defColumn;
			}

			//2.调用注册方法
			var remoteService:RemoteObject = BlazeDSUtil.newService(remoteDestination, remoteSource, endpoint, function():void
				{
					log.info("【向UAB注册】成功");
					success.call(this);
				}, function(event:FaultEvent):void
				{
					log.info("【向UAB注册】失败" + event);
				}, true, "regListener");
			log.info("【向UAB注册】开始");
			log.info(params);
			remoteService.regListener(params);
		}

		public function reloadAlarm(viewId:String, ruleList:ArrayList, defColumn:String, success:Function):void
		{
			//1.拼装参数
			var params:Object = AlarmUtil.cloneObject(_mapInfo);
			params[AlarmContainer.PARAMKEY_ISLOADRULE] = 0;
			params[AlarmContainer.PARAMKEY_VIEWID] = viewId;
			params[AlarmContainer.PARAMKEY_RULE] = ruleList;
			if (defColumn != null)
			{
				params[AlarmContainer.PARAMKEY_DISPLAYCOLUMN] = defColumn;
			}

			//2.调用重载方法
			var remoteService:RemoteObject = BlazeDSUtil.newService(remoteDestination, remoteSource, endpoint, function():void
				{
					log.info("【向WEB重载告警】成功");
					success.call(this);
				}, function(event:FaultEvent):void
				{
					log.info("【向WEB重载告警】失败" + event);
				}, true, "reloadAlarm");
			log.info("【向WEB重载告警】开始 ");
			log.info(params);
			remoteService.reloadAlarm(params);
		}

		public function hearbeat(success:Function):void
		{
			//1.拼装参数
			var params:Object = new Object();
			params[AlarmContainer.PARAMKEY_UUID] = _mapInfo[AlarmContainer.PARAMKEY_UUID];

			//2.调用心跳方法
			var remoteService:RemoteObject = BlazeDSUtil.newService(remoteDestination, remoteSource, endpoint, function():void
				{
					log.info("【向WEB保持心跳】成功");
					success.call(this);
				}, function(event:FaultEvent):void
				{
					log.info("【向WEB保持心跳】失败" + event);
				}, true, "hearbeat");
			log.info("【向WEB保持心跳】开始 ");
			remoteService.hearbeat(params);
		}

		public function deleteUser():void
		{
			//1.拼装参数
			var params:Object = AlarmUtil.cloneObject(_mapInfo);

			//2.调用删除方法
			var remoteService:RemoteObject = BlazeDSUtil.newService(remoteDestination, remoteSource, endpoint, function():void
				{
					log.info("【向WEB注销通道】成功");
				}, function(event:FaultEvent):void
				{
					log.info("【向WEB注销通道】失败" + event);
				}, true, "deleteUser");
			log.info("【向WEB注销通道】开始 ");
			remoteService.deleteUser(params);
		}

		public function syncAlarm(params:Object, success:Function, fault:Function):void
		{
			var remoteService:RemoteObject = BlazeDSUtil.newService(remoteDestination, remoteSource, endpoint, function():void
				{
					log.info("【向WEB告警同步】成功");
					success.call(this);
				}, function(event:FaultEvent):void
				{
					log.info("【向WEB告警同步】失败" + event);
					fault.call(this);
				}, true, "syncAlarm");
			log.info("【向WEB告警同步】开始 ");
			remoteService.syncAlarm(params);
		}

		public function shutSync(params:Object, success:Function, fault:Function):void
		{
			var remoteService:RemoteObject = BlazeDSUtil.newService(remoteDestination, remoteSource, endpoint, function():void
				{
					log.info("【向WEB中断同步】成功");
					success.call(this);
				}, function(event:FaultEvent):void
				{
					log.info("【向WEB中断同步】失败" + event);
					fault.call(this);
				}, true, "shutSync");
			log.info("【向WEB中断同步】开始 ");
			remoteService.shutSync(params);
		}

		public function saveColumnOrder(params:Object):void
		{
//			var remoteService:RemoteObject = BlazeDSUtil.newService(remoteDestination, remoteSource, endpoint, function():void
//				{
//					log.info("【向WEB保存列顺序】成功");
//				}, function(event:FaultEvent):void
//				{
//					log.info("【向WEB保存列顺序】失败" + event);
//				}, true, "saveColumnOrder");
//			log.info("【向WEB保存列顺序步】开始 ");
//			remoteService.saveColumnOrder(params);
		}
	}
}