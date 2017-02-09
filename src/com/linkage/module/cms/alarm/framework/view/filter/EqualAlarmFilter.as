package com.linkage.module.cms.alarm.framework.view.filter
{
	import mx.utils.StringUtil;

	/**
	 *等于告警过滤
	 * @author mengqiang
	 *
	 */
	public class EqualAlarmFilter extends TrueAlarmFilter
	{
		// 告警字段列
		protected var _key:String=null;
		//告警过滤值
		protected var _value:String=null;

		public function EqualAlarmFilter(key:String, value:String)
		{
			super();
			_key=StringUtil.trim(key);
			_value=value;
		}

		override public function accept(alarm:Object):Boolean
		{
			return alarm[_key] == _value;
		}
	}
}