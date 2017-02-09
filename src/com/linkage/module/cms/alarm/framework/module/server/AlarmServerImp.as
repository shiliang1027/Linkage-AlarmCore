package com.linkage.module.cms.alarm.framework.module.server
{
	import com.linkage.module.cms.alarm.framework.common.event.AlarmDataEvent;
	import com.linkage.module.cms.alarm.framework.common.event.SystemEvent;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.linkage.module.cms.alarm.framework.module.server.core.WindowController;
	import com.linkage.module.cms.alarm.framework.module.server.param.AlarmTransTopic;
	import com.linkage.module.cms.alarm.framework.module.server.source.DefaultCollection;
	import com.linkage.module.cms.alarm.framework.module.server.source.ICollection;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.system.structure.map.Map;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import mx.formatters.DateFormatter;

	/**
	 *告警Server实现类
	 * @author mengqiang
	 *
	 */
	public class AlarmServerImp implements AlarmServer
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.module.server.AlarmServerImp");
		/**
		 *时间格式化
		 */
		private var dft:DateFormatter = new DateFormatter();
		/**
		 *告警控制类
		 */
		protected var _alarmAction:AlarmAction = null;
		/**
		 *初始化各个窗口控制器
		 */
		protected var _windowControllerMap:Map = null;
		/**
		 *告警数据源类
		 */
		protected var _collectClass:Class = null;
		/**
		 *心跳定时器
		 */
		private var _refreshTime:Timer = new Timer(60000);
		/**
		 *网络不通时间间隔
		 */
		private var _noNetworkInterval:uint = 300000;
		/**
		 *UAB停止推送告警时间
		 */
		private var _uabStopPushTime:uint = 120000;
		/**
		 *心跳间隔
		 */
		private var _hearbeatInterval:uint = 60000;
		/**
		 *流水客服端最后发送给UAB的心跳时间
		 */
		private var _sendHearbeatTime:Number = 0;
		/**
		 *接受UAB心跳时间
		 */
		private var _receveHearbeatTime:Number = 0;

		public function AlarmServerImp(alarmAction:AlarmAction, collectClass:Class)
		{
			//1.初始化数据参数
			_alarmAction = alarmAction;
			_collectClass = collectClass;
			_windowControllerMap = new Map();
			dft.formatString = "YYYY-MM-DD (EE) HH:NN:SS.QQQ";

			//2.初始化心跳定时器
			_refreshTime.addEventListener(TimerEvent.TIMER, hearbeat);
		}

		public function initWindowSource():void
		{
			_windowControllerMap.clear();
			_alarmAction.alarmParamMo.winJsons.forEach(function(win:*, index:int, array:Array):void
				{
					_windowControllerMap.put(win.windowId, new WindowController(win.windowId, _alarmAction, _collectClass));
				});
		}

		public function clearWindowSource():void
		{
			_windowControllerMap.forEach(function(key:String, window:WindowController):void
				{
					window.clearWindowSource();
				});
		}

		//数据格式{windowId:[{告警对象体},{告警对象体}]}
		public function handlerAlarm(alarmObj:Object):void
		{
			//1.更新心跳时间为当前时间
			_receveHearbeatTime = new Date().getTime();
			//sendHearbeat(_receveHearbeatTime);

			//2.获取推过来的告警并处理
			_windowControllerMap.forEach(function(windowId:String, window:WindowController):void
				{
					var alarmArray:Array = alarmObj[windowId];
					if (alarmArray != null)
					{
						window.handlerAlarm(alarmArray);
					}
				});

			//3.处理告警风暴
			dealWithAlarmStorm(alarmObj);
		}

		public function getAlarmNumByWindowId(windowId:String):int
		{
			var windowController:WindowController = _windowControllerMap.get(windowId);
			if (windowController == null)
			{
				log.info("【窗口ID有误！获取不到窗口控制器】");
				return 0;
			}
			return windowController.getAlarmNumByWindowId(windowId);
		}

		public function alarmSource(windowId:String, windowType:int):ICollection
		{
			var windowController:WindowController = _windowControllerMap.get(windowId);
			if (windowController == null)
			{
				log.info("【窗口ID有误！获取不到窗口控制器】");
				return new DefaultCollection("0", 1, _alarmAction);
			}
			return windowController.alarmSource(windowType);
		}

		public function startHearbeatTime():void
		{
			_receveHearbeatTime = new Date().getTime();
			_refreshTime.start();
		}

		public function clearHearbeatTime():void
		{
			_refreshTime.stop();
		}

		//向WEB保持心跳
		private function hearbeat(event:TimerEvent):void
		{
			//1.判断向WEB通讯是否超时
			var curTime:Number = new Date().getTime();
			if ((curTime - _receveHearbeatTime) > _uabStopPushTime)
			{
				_alarmAction.dispatchEvent(new SystemEvent(SystemEvent.SYSTEM_ALARMRELOAD, "网络不通,重载告警,最后收到UAB心跳时间:" + dft.format(new Date(_receveHearbeatTime))));
			}
			//2.向WEB保持心跳
			sendHearbeat(curTime);
		}

		//发送心跳给UAB
		private function sendHearbeat(curTime:Number):void
		{
//			if ((curTime - _sendHearbeatTime) > _hearbeatInterval)
//			{
				_alarmAction.hearbeat(function():void
					{
						log.info("【向UAB保持心跳正常】++++++");
						_sendHearbeatTime = new Date().getTime();
					});
//			}
		}

		//处理告警风暴
		private function dealWithAlarmStorm(alarm:Object):void
		{
			switch (alarm[AlarmTransTopic.KEY_OPER_STORMTOPIC])
			{
				case AlarmTransTopic.KEY_OPER_STORMSTART: //告警风暴开始
					alarmStormStart();
					break;
				case AlarmTransTopic.KEY_OPER_STORMSTOP: //告警风暴结束
					alarmStormStop();
					break;
			}
		}

		//设置声音状态
		public function soundEnabled(windowId:String, enabled:Boolean):void
		{
			var windowController:WindowController = _windowControllerMap.get(windowId);
			if (windowController != null)
			{
				windowController.soundEnabled = enabled;
			}
		}
		
		//告警风暴开始
		private function alarmStormStart():void
		{
			log.warn("告警风暴开始+++++++++++++++++++++++");
			_alarmAction.dispatchEvent(new AlarmDataEvent(AlarmDataEvent.ALARM_STORMSTART));
		}

		//告警风暴结束
		private function alarmStormStop():void
		{
			log.warn("告警风暴结束+++++++++++++++++++++++");
			_alarmAction.dispatchEvent(new AlarmDataEvent(AlarmDataEvent.ALARM_STORMSTOP));
		}
	}
}