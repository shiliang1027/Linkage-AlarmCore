package com.linkage.module.cms.alarm.framework.view.menu.filter
{

	/**
	 *字符串等于
	 * @author mengqiang
	 *
	 */
	public class Equal implements CMP
	{
		public function cmp(src:Object, target:Object):Boolean
		{
			return src == target;
		}
	}
}