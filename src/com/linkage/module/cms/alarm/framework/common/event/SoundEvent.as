package com.linkage.module.cms.alarm.framework.common.event
{
	import flash.events.Event;

	/**
	 * 声音的事件
	 * @author mengqiang
	 *
	 */
	public class SoundEvent extends Event
	{
		/**
		 * 声音事件: 启用声音
		 */
		public static const VOICE_ON:String="voice_on";
		/**
		 * 声音事件: 静音
		 */
		public static const VOICE_OFF:String="voice_off";
		/**
		 * 声音事件: 告警等级
		 */
		public static const VOICE_LEVEL:String="voice_level";
		/**
		 * 声音事件: 告警发声
		 */
		public static const VOICE_SOUND:String="voice_sound";
		/**
		 * 声音事件: 启动声音
		 */
		public static const VOICE_START:String="voice_start";
		/**
		 * 声音事件: 停止声音
		 */
		public static const VOICE_STOP:String="voice_stop";
		/**
		 * 声音事件: 窗口Id
		 */
		private var _windowId:String=null;
		/**
		 * 声音事件: 声音等级
		 */
		private var _level:int=0;

		public function SoundEvent(type:String, windowId:String=null ,level:int=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_windowId = windowId;
			_level=level;
		}

		public function get windowId():String
		{
			return _windowId;
		}
		
		/**
		 * 告警等级
		 */
		public function get level():int
		{
			return _level;
		}
	}
}