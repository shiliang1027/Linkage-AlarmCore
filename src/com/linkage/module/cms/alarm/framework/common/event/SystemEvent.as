package com.linkage.module.cms.alarm.framework.common.event
{
	import flash.events.Event;

	/**
	 * 系统事件
	 * @author mengqiang
	 *
	 */
	public class SystemEvent extends Event
	{
		/**
		 * 【告警重载】
		 */
		public static const SYSTEM_ALARMRELOAD:String = "AlarmReload";
		/**
		 *消息对象
		 */
		private var _message:Object = null;


		public function SystemEvent(type:String, message:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_message = message;
		}

		public function get message():Object
		{
			return _message;
		}
	}
}