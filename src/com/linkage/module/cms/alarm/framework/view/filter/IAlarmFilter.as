package com.linkage.module.cms.alarm.framework.view.filter
{

	public interface IAlarmFilter
	{
		/**
		 * 验证告警是否可以显示
		 * @param alarm
		 * @return
		 *
		 */
		function accept(alarm:Object):Boolean;
	}
}