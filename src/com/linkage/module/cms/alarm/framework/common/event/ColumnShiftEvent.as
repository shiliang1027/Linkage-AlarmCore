package com.linkage.module.cms.alarm.framework.common.event
{
	import flash.events.Event;

	public class ColumnShiftEvent extends Event
	{
		/**
		 *告警流水列变化事件
		 */
		public static const COLUMN_SHIFT:String="column_shift";
		/**
		 * 窗口类型 1:活动告警 0:清除告警
		 */
		private var _windowType:int=0;
		/**
		 *告警流水列新索引
		 */
		private var _newIndex:int=0;
		/**
		 *告警流水列老索引
		 */
		private var _oldIndex:int=0;

		public function ColumnShiftEvent(type:String, newIndex:int=0, oldIndex:int=0, windowType:int=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_windowType=windowType;
			_newIndex=newIndex;
			_oldIndex=oldIndex;
		}

		public function get windowType():int
		{
			return _windowType;
		}

		public function get newIndex():int
		{
			return _newIndex;
		}

		public function get oldIndex():int
		{
			return _oldIndex;
		}
	}
}