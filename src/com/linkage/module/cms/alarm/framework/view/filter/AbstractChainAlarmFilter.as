package com.linkage.module.cms.alarm.framework.view.filter
{

	public class AbstractChainAlarmFilter extends TrueAlarmFilter
	{
		/**
		 * 过滤器数组
		 */
		protected var _filters:Array=[];


		override public function accept(alarm:Object):Boolean
		{
			throw new Error("method <accept> must be implements in subclass");
		}

		public function addAlarmFilter(filter:IAlarmFilter):void
		{
			_filters.push(filter);
		}

		/**
		 * 清空过滤链
		 *
		 */
		public function clear():void
		{
			_filters.splice(0, _filters.length);
		}

		/**
		 * 是否存在过滤器
		 * @return
		 *
		 */
		public function existFilters():Boolean
		{
			return _filters.length > 0;
		}
	}
}