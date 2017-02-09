package com.linkage.module.cms.alarm.framework.common.event
{
	import flash.events.Event;

	public class AlarmDataEvent extends Event
	{
		/**
		 *告警风暴开始
		 */
		public static const ALARM_STORMSTART:String = "alarm_storm_start";
		/**
		 *告警风暴结束
		 */
		public static const ALARM_STORMSTOP:String = "alarm_storm_stop";
		/**
		 *告警对象
		 */
		private var _alarm:Object = null;

		public function AlarmDataEvent(type:String, alarm:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_alarm = alarm;
		}

		public function get alarm():Object
		{
			return _alarm;
		}
	}
}