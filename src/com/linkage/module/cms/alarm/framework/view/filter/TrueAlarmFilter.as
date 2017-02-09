package com.linkage.module.cms.alarm.framework.view.filter
{

	public class TrueAlarmFilter implements IAlarmFilter
	{

		public function accept(alarm:Object):Boolean
		{
			return true;
		}
	}
}