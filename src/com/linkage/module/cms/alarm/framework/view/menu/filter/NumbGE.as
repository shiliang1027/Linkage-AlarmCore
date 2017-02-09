package com.linkage.module.cms.alarm.framework.view.menu.filter
{
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;

	/**
	 *大于等于
	 * @author mengqiang
	 *
	 */
	public class NumbGE extends NumbLT
	{
		override public function cmp(src:Object, target:Object):Boolean
		{
			if (!AlarmUtil.checkStrIsNull(src) || !AlarmUtil.checkStrIsNull(target))
			{
				return false;
			}
			else
			{
				return !super.cmp(src, target);
			}
		}
	}
}