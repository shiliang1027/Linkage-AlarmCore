package com.linkage.module.cms.alarm.framework.view.menu.filter
{

	/**
	 *字符串包含 :src 包含 target
	 * @author mengqiang
	 *
	 */
	public class StrLike implements CMP
	{
		public function cmp(src:Object, target:Object):Boolean
		{
			if (src == null || target == null)
			{
				return false;
			}
			else
			{
				return String(src).indexOf(String(target)) != -1;
			}
		}
	}
}