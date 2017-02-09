package com.linkage.module.cms.alarm.framework.common.event
{
	import flash.events.Event;

	/**
	 * 
	 *
	 * @author 孟强 (65453)
	 * @version 1.0
	 * @date 2014-3-10
	 * @langversion 3.0
	 * @playerversion Flash 11
	 * @productversion Flex 4
	 * @copyright Ailk NBS-Network Mgt. RD Dept.
	 *
	 */
	public class AlarmLockEvent extends Event
	{
		
		/**
		 *告警视图锁定
		 */
		public static const VIEW_LOCKED:String = "view_locked";
		/**
		 *锁定状态 true：锁定 false：未锁定
		 */
		private var _lockedStatus:Boolean =false;
		/**
		 *窗口类型
		 */
		private var _windowType:int =0;
		
		public function AlarmLockEvent(type:String, windowType:int, lockedStatus:Boolean=false, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_lockedStatus = lockedStatus;
			_windowType = windowType;
		}
		
		public function get lockedStatus():Boolean
		{
			return _lockedStatus;
		}
		
		public function get windowType():int
		{
			return _windowType;
		}
	}
}