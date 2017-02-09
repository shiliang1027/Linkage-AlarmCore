package com.linkage.module.cms.alarm.framework.view.menu.filter
{
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;

	/**
	 *数字大于
	 * @author mengqiang
	 *
	 */
	public class NumbGT implements CMP
	{
		public function cmp(src:Object, target:Object):Boolean
		{
			if (!AlarmUtil.checkStrIsNull(src) || !AlarmUtil.checkStrIsNull(target))
			{
				return false;
			}
			else
			{
				return Number(src) > Number(target);
			}
		}
	}
}