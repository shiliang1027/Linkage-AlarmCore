package com.linkage.module.cms.alarm.framework.view.menu
{

	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.view.menu.filter.ChainRule;

	/**
	 * 菜单过滤器,验证告警和菜单是否匹配
	 * @author mengqiang
	 *
	 */
	public class MenuFilter
	{
		/**
		 * 验证菜单是否匹配传入的单个告警
		 * @param menuRes
		 * @param alarm
		 * @return
		 *
		 */
		public static function acceptAlarm(menuRes:MenuResItem, alarm:Object):Boolean
		{
			// 先验收是否是告警
			if (alarm[ColumnConstants.KEY_AlarmUniqueId] == null)
			{
				return false;
			}
			if (menuRes.filter == null || menuRes.filter == "")
			{
				// 过滤规则不存在,直接true
				return true;
			}
			return new ChainRule(menuRes.filter).accept(alarm);
		}

		/**
		 * 验证菜单是否匹配传入的一批告警
		 * @param menuRes
		 * @param alarms
		 * @return
		 *
		 */
		public static function acceptAlarms(menuRes:MenuResItem, alarms:Array):Boolean
		{
			if (alarms == null || alarms.length == 0 || menuRes == null)
			{
				// 没有告警或者菜单,直接false
				return false;
			}
			if (alarms.length > 1 && menuRes.multiple == false)
			{
				// 菜单不支持批量时,直接false
				return false;
			}
			if (alarms.length == 1 && menuRes.multiple == true)
			{
				// 批量菜单,必须是批量告警触发,单个不能触发
				return false;
			}
			for each (var alarm:Object in alarms)
			{
				if (!acceptAlarm(menuRes, alarm))
				{
					return false;
				}
			}
			return true;
		}
	}
}