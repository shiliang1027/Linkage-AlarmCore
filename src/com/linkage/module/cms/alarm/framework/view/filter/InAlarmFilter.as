package com.linkage.module.cms.alarm.framework.view.filter
{
	import com.linkage.system.structure.map.Map;
	import mx.utils.StringUtil;

	public class InAlarmFilter extends TrueAlarmFilter
	{
		// 告警字段列
		protected var _key:String=null;
		//告警过滤值
		protected var _value:Map=null;

		public function InAlarmFilter(key:String, value:String)
		{
			super();
			_key=StringUtil.trim(key);
			_value=new Map();
			initFilter(value);
		}

		override public function accept(alarm:Object):Boolean
		{
			var alarmValue:String=alarm[_key];
			return _value.get(alarmValue) != null;
		}

		private function initFilter(rule:String):void
		{
			if (rule.indexOf(")") == -1)
			{
				throw new Error("传入过滤器规则出错!");
			}
			rule=rule.substring(0, rule.length - 1);
			var ruleArray:Array=rule.split(",");
			ruleArray.forEach(function(info:String, index:int, array:Array):void
				{
					_value.put(info, info);
				});
		}
	}
}