package com.linkage.module.cms.alarm.framework.common.event
{
	import flash.events.Event;

	public class ColumnResizeEvent extends Event
	{
		/**
		 *告警流水列变化事件
		 */
		public static const COLUMN_RESIZE:String="column_resize";
		/**
		 *告警流水列名称
		 */
		private var _columnName:String=null;
		/**
		 *告警流水列索引
		 */
		private var _columnIndex:int=0;
		/**
		 *告警流水列宽度
		 */
		private var _columnWidth:int=0;

		public function ColumnResizeEvent(type:String, columnName:String, columnIndex:int=0, columnWidth:int=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_columnName = columnName;
			_columnIndex=columnIndex;
			_columnWidth=columnWidth;
		}

		public function get columnName():String
		{
			return _columnName;
		}
		
		public function get columnIndex():int
		{
			return _columnIndex;
		}

		public function get columnWidth():int
		{
			return _columnWidth;
		}
	}
}