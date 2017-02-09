package com.linkage.module.cms.alarm.framework.view.filter
{


	public class AndChainAlarmFilter extends AbstractChainAlarmFilter
	{
		override public function accept(alarm:Object):Boolean
		{
			return existFilters() ? _filters.every(function(item:IAlarmFilter, index:int, array:Array):Boolean
				{
					return item.accept(alarm);
				}) : true;
		}
	}
}