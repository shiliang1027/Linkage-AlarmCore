package com.linkage.module.cms.alarm.framework.view.menu.filter
{

	/**
	 *规则接口
	 * @author mengqiang
	 *
	 */
	public interface Rule
	{
		function accept(alarm:Object):Boolean;
	}
}