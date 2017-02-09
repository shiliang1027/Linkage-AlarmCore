package com.linkage.module.cms.alarm.framework.common.event
{
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;

	/**
	 *注册系统监听事件
	 * @author mengqiang
	 *
	 */
	public class RegisterEvent
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.common.event.RegisterEvent");

		public function RegisterEvent(alarmAction:AlarmAction)
		{
			registerSystemEvent(alarmAction);
		}

		//注册监控系统事件
		private function registerSystemEvent(alarmAction:AlarmAction):void
		{
			//------------------------------------系统信息------------------------------------
			//监听重载告警
			alarmAction.addEventListener(SystemEvent.SYSTEM_ALARMRELOAD, function(event:SystemEvent):void
				{
					log.warn("【重载告警】" + event.message);
					alarmAction.reload(alarmAction.reloadRuleList,false);
				});
			//------------------------------------告警声音------------------------------------
			//监听声音打开
			alarmAction.addEventListener(SoundEvent.VOICE_ON, function(event:SoundEvent):void
				{
					alarmAction.soundEnabled(event.windowId, true);
				});
			//监听声音关闭
			alarmAction.addEventListener(SoundEvent.VOICE_OFF, function(event:SoundEvent):void
				{
					log.warn("监听声音关闭:" + event.windowId);
					alarmAction.soundEnabled(event.windowId, false);
					alarmAction.soundStorage.stop(event.windowId);
				});
			//监听声音启动
			alarmAction.addEventListener(SoundEvent.VOICE_START, function(event:SoundEvent):void
				{
					alarmAction.soundStorage.statue = true;
				});
			//监听声音停止
			alarmAction.addEventListener(SoundEvent.VOICE_STOP, function(event:SoundEvent):void
				{
					log.warn("监听声音停止:" + event.windowId);
					alarmAction.soundStorage.statue = false;
				});
			//监听告警等级
			alarmAction.addEventListener(SoundEvent.VOICE_LEVEL, function(event:SoundEvent):void
				{
					//加入告警等级
					log.warn("监听告警等级:" + event.windowId);
					alarmAction.soundStorage.pushAlarmLevel(event.windowId, event.level);
				});
			//监听告警发声
			alarmAction.addEventListener(SoundEvent.VOICE_SOUND, function(event:SoundEvent):void
				{
					//播放声音
					log.warn("播放声音:" + event.windowId);
					alarmAction.soundStorage.flush(event.windowId);
				});
		}
	}
}