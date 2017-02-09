package com.linkage.module.cms.alarm.framework.view.menu.filter
{

	/**
	 *字符串不等于
	 * @author mengqiang
	 *
	 */
	public class NotEqual extends Equal
	{
		override public function cmp(src:Object, target:Object):Boolean
		{
			return !super.cmp(src, target);
		}
	}
}