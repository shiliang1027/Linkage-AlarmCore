package com.linkage.module.cms.alarm.framework.controller
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.Version;
	import com.linkage.module.cms.alarm.framework.LocalTestAlarm;
	import com.linkage.module.cms.alarm.framework.LocalTestParam;
	import com.linkage.module.cms.alarm.framework.LocalTestRlAlarm;
	import com.linkage.module.cms.alarm.framework.LocalTestSpAlarm;
	import com.linkage.module.cms.alarm.framework.common.event.AlarmViewEvent;
	import com.linkage.module.cms.alarm.framework.common.event.RegisterEvent;
	import com.linkage.module.cms.alarm.framework.common.param.ParamCache;
	import com.linkage.module.cms.alarm.framework.controller.fo.AlarmParamFo;
	import com.linkage.module.cms.alarm.framework.module.dao.AlarmDAO;
	import com.linkage.module.cms.alarm.framework.module.dao.AlarmDAOImp;
	import com.linkage.module.cms.alarm.framework.module.dao.mo.AlarmParamMo;
	import com.linkage.module.cms.alarm.framework.module.server.AlarmServer;
	import com.linkage.module.cms.alarm.framework.module.server.AlarmServerImp;
	import com.linkage.module.cms.alarm.framework.module.server.source.ICollection;
	import com.linkage.module.cms.alarm.framework.view.toolstate.sound.SoundStorage;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;

	public class AlarmAction extends EventDispatcher implements IEventDispatcher
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.controller.AlarmAction");
		/**
		 *外部传入参数
		 */
		private var _alarmParamFo:AlarmParamFo = null;
		/**
		 *初始化视图参数
		 */
		private var _alarmParamMo:AlarmParamMo = null;
		/**
		 *声音存储器
		 */
		private var _soundStorage:SoundStorage = null;
		/**
		 *告警Server
		 */
		protected var _alarmServer:AlarmServer = null;
		/**
		 *重载告警过滤规则
		 */
		protected var _reloadRuleList:ArrayList = null;
		/**
		 *告警DAO
		 */
		private var _alarmDao:AlarmDAO = null;
		/**
		 *开始状态
		 */
		private var _startStatus:Boolean = true;
		
		private var _time:Timer = new Timer(1000);

		private var _param:Object;
		private var _collectClass:Class;
		public function AlarmAction(param:Object, collectClass:Class)
		{
			log.warn("ParamCache：{0}" ,ParamCache.coulumnLabelMap);
			//1.初始化外部传入参数FO
			_alarmParamFo = new AlarmParamFo(param);
			//2.初始化告警DAO
			_alarmDao = new AlarmDAOImp(alarmParamFo.mapInfo);
			//3.初始化告警Server
			initAlarmServer(collectClass);
			//4.注册系统监听
			new RegisterEvent(this);
			//5.创建通道
			createChannelSet();
			//6.开始向WEB订阅告警
			subscribeAlarms();
			//7.初始化重载规则列表
			_reloadRuleList = new ArrayList();
			//8.打印版本信息
			printVersionInfo();
			_time.addEventListener(TimerEvent.TIMER,_onTimeHander);
			_time.start();
		}
		
		private function _onTimeHander(event:TimerEvent):void{
			if(Boolean(ParamCache.coulumnLabelMap)){
				log.warn("ParamCache 初始化成功:" + ParamCache.coulumnLabelMap);
				_time.stop();
			}
		}

		//初始化告警服务类
		public function initAlarmServer(collectClass:Class):void
		{
			_alarmServer = new AlarmServerImp(this, collectClass);
		}

		//创建通道
		private function createChannelSet():void
		{
			_alarmDao.createChannelSet();
		}

		//打印版本信息
		private function printVersionInfo():void
		{
			log.warn("当前版本号:" + Version.versionInfo);
		}

		//订阅告警信息
		private function subscribeAlarms():void
		{
			_alarmDao.subscribeAlarms(function(result:Object):void
				{
					log.info("【^v^接受消息成功^v^】");
					log.info(result);
					_alarmServer.handlerAlarm(result);
				});
		}

		//注册告警信息
		private function regListenerAlarm(ruleList:ArrayList):void
		{
			log.info("【开始向UAB注册告警信息】++++++");
			reloadRuleList = ruleList;
			_alarmDao.regListenerAlarm(reloadRuleList, _alarmParamFo.defaultDisplay, function():void
				{
					log.info("【向UAB注册告警成功】++++++");
				});
		}

		//获取资源信息
		public function regListener(ruleList:ArrayList, success:Function, isReg:int = 1):void
		{
			log.info("【获取资源信息】++++++");
			_alarmDao.getResourceInfo(function(result:Object):void
				{
					_alarmParamMo = new AlarmParamMo(result);
					initInfoByMoParam(ruleList, isReg == 1 ? true : false);
					success.call(this);
				});
		}


		//停止所有告警操作
		public function stopAction(isUnsub:Boolean = true):void
		{
			log.warn("停止所有告警操作");
			_startStatus = false;
			//1.删除用户传输通道
			_alarmDao.deleteUser();

			//2.取消订阅
			if(isUnsub)
			{
				_alarmDao.unsubscribeAlarms();
			}

			//3.取消心跳定时器
			_alarmServer.clearHearbeatTime();
		}

		//开始心跳
		public function startHearbeat():void
		{
			_alarmServer.startHearbeatTime();
		}

		//通过过滤规则重新加载:最大上限为告警容量
		public function statReload(ruleList:ArrayList = null, moduleKey:String = null, isClear:Boolean = true):void
		{
			log.info("总流水统计开始调用重载方法-------------^v^---^v^-------------");
			//1.取消用户订阅告警和心跳定时器
			if (_startStatus)
			{
				stopAction();
			}

			//2.开始状态
			_startStatus = true;

			//3.开始心跳
			startHearbeat();

			//4.清空告警存储容器
			if (isClear)
			{
				_alarmServer.clearWindowSource();
			}

			//5.重新初始化参数
			_alarmParamFo.createUUID();
			_alarmParamFo.createModuleKey(moduleKey);

			//6.重新订阅告警
			subscribeAlarms();

			//7.重载告警
			reloadRuleList = ruleList;
			var viewId:String = alarmParamMo.viewId;
			_alarmDao.reloadAlarm(viewId, reloadRuleList, _alarmParamFo.defaultDisplay, function():void
				{
					//通知显示全部告警
					dispatchEvent(new AlarmViewEvent(AlarmViewEvent.VIEW_ALARM_RELOAD));
					log.info("总流水统计重载告警成功-------------^v^---^v^-------------viewId=" + viewId);
				});
		}

		//通过过滤规则重新加载:最大上限为预装容量
		public function reload(ruleList:ArrayList = null, isClear:Boolean = true, callback:Function = null):void
		{
			log.info("开始调用重载方法-------------^v^+++++^v^-------------");
			//1.取消用户订阅告警和定时器
			if (_startStatus)
			{
				stopAction(false);
			}

			//2.清空告警存储容器
			if (isClear)
			{
				_alarmServer.clearWindowSource();
			}

			if(!_startStatus)
			{
				//3.启动心跳定时器
				startHearbeat();
			}

			//4.重新初始化参数
			_alarmParamFo.createUUID();
			_alarmParamFo.createModuleKey();
			
			//5重新订阅告警
			subscribeAlarms();
			
			//6.开始状态
			_startStatus = true;
			//7.重载告警
			reloadRuleList = ruleList;
			_alarmDao.regListenerAlarm(reloadRuleList, _alarmParamFo.defaultDisplay, function():void
				{
					//通知显示全部告警
					dispatchEvent(new AlarmViewEvent(AlarmViewEvent.VIEW_ALARM_RELOAD));
					//是否回调
					if (callback != null)
					{
						callback.call(this);
					}
					log.warn("重载告警成功-------------^v^---^v^-------------");
				});
		}

		//清空窗口数据
		public function clearWindowSource():void
		{
			_alarmServer.clearWindowSource();
		}
		
		//停止加载告警
		public function stopLoad(isClear:Boolean = false):void
		{
			log.info("开始调用停止加载告警-------------^v^---^v^-------------");
			//1.取消用户订阅告警和定时器
			if (_startStatus)
			{
				stopAction();
			}

			//2.停止状态
			_startStatus = false;

			//3.清空告警存储容器
			if (isClear)
			{
				_alarmServer.clearWindowSource();
			}
		}

		//设置声音状态
		public function soundEnabled(windowId:String, enabled:Boolean):void
		{
			_alarmServer.soundEnabled(windowId, enabled);
		}
		
		//向WEB保持心跳
		public function hearbeat(success:Function):void
		{
			_alarmDao.hearbeat(success);
		}

		//同步指令告警
		public function syncAlarm(params:Object, success:Function, fault:Function):void
		{
			if (_alarmParamFo.local)
			{
				success.call(this);
				return;
			}
			_alarmDao.syncAlarm(params, success, fault);
		}

		//中断指令告警
		public function shutSync(params:Object, success:Function, fault:Function):void
		{
			if (_alarmParamFo.local)
			{
				success.call(this);
				return;
			}
			_alarmDao.shutSync(params, success, fault);
		}

		//初始化信息通过Mo参数
		public function initInfoByMoParam(ruleList:ArrayList, isReg:Boolean):void
		{
			//1.初始化视图各个窗口
			_alarmServer.initWindowSource();
			//2.向UAB注册告警
			if (isReg)
			{
				startHearbeat();
				regListenerAlarm(ruleList);
			}
			//3.初始化声音容器
			var baseUrl:String = _alarmParamFo.baseURL;
			var voiceArray:Array = _alarmParamMo.voiceConfigArray;
			_soundStorage = new SoundStorage(baseUrl, voiceArray);
		}

		//保存列顺序
		public function saveColumnOrder(params:Object):void
		{
			_alarmDao.saveColumnOrder(params);
		}

		//获取数据源
		public function alarmSource(windowId:String, windowType:int):ICollection
		{
			return _alarmServer.alarmSource(windowId, windowType);
		}

		//通过告警ID获取告警数量
		public function getAlarmNumByWindowId(windowId:String):int
		{
			return _alarmServer.getAlarmNumByWindowId(windowId);
		}

		//本地测试默认注册告警信息
		public function regListenerDefaultTest():void
		{
			log.info("【本地测试默认注册告警信息】++++++");
			var result:Object = LocalTestParam.getDefaultTestParam();
			_alarmParamMo = new AlarmParamMo(result);
			initInfoByMoParam(new ArrayList(), false);
		}

		//本地测试当班人员注册告警信息
		public function regCustomDefaultTest():void
		{
			log.info("【本地测试当班人员注册告警信息】++++++");
			var result:Object = LocalTestParam.getCustomTestParam();
			_alarmParamMo = new AlarmParamMo(result);
			initInfoByMoParam(new ArrayList(), false);
		}

		//本地测试当班人员注册告警信息
		public function regSpecialDefaultTest():void
		{
			log.info("【本地测试当班人员注册告警信息】++++++");
			var result:Object = LocalTestParam.getSpecialTestParam();
			_alarmParamMo = new AlarmParamMo(result);
			initInfoByMoParam(new ArrayList(), false);
		}

		//本地测试当班人员注册告警信息
		public function regPreprocessDefaultTest():void
		{
			log.info("【本地测试预处理流水注册告警信息】++++++");
			var result:Object = LocalTestParam.getPreprocessTestParam();
			_alarmParamMo = new AlarmParamMo(result);
			initInfoByMoParam(new ArrayList(), false);
		}

		//本地测试关联关系注册告警信息
		public function regListenerRelationTest():void
		{
			log.info("【本地测试关联关系注册告警信息】++++++");
			var result:Object = LocalTestParam.getRelationTestParam();
			_alarmParamMo = new AlarmParamMo(result);
			initInfoByMoParam(new ArrayList(), false);
		}

		//本地测试集中性能监控注册告警信息
		public function regListenerPerfMonitorTest():void
		{
			log.info("【本地测试集中性能监控注册告警信息】++++++");
			var result:Object = LocalTestParam.getPerfMonitorTestParam();
			_alarmParamMo = new AlarmParamMo(result);
			initInfoByMoParam(new ArrayList(), false);
		}

		//本地测试发送测试数据
		public function sendAlarmTest():void
		{
			new LocalTestAlarm(_alarmServer);
		}

		//本地测试发送测试数据
		public function sendSpAlarmTest():void
		{
			new LocalTestSpAlarm(_alarmServer);
		}

		//本地测试发送关联关系测试数据
		public function sendRlAlarmTest():void
		{
			new LocalTestRlAlarm(_alarmServer);
		}

		public function get soundStorage():SoundStorage
		{
			return _soundStorage;
		}

		public function get reloadRuleList():ArrayList
		{
			return _reloadRuleList;
		}

		public function set reloadRuleList(ruleList:ArrayList):void
		{
			if (ruleList != null)
			{
				_reloadRuleList = ruleList;
			}
		}

		public function get alarmParamFo():AlarmParamFo
		{
			return _alarmParamFo;
		}

		public function get alarmParamMo():AlarmParamMo
		{
			return _alarmParamMo;
		}
	}
}