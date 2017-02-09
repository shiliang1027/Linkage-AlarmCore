package com.linkage.module.cms.alarm.framework.view.filter
{
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;

	import mx.utils.StringUtil;

	public class LikeAlarmFilter extends TrueAlarmFilter
	{
		// 告警字段列
		protected var _key:String=null;
		//告警过滤值
		protected var _value:String=null;

		public function LikeAlarmFilter(key:String, value:String)
		{
			super();
			_key=StringUtil.trim(key);
			_value=value;
		}

		override public function accept(alarm:Object):Boolean
		{
			var alarmValue:String=alarm[_key];
			if (!AlarmUtil.checkStrIsNull(alarmValue))
			{
				return false;
			}
			return alarmValue.indexOf(_value) != -1 ? true : false;
		}
	}
}