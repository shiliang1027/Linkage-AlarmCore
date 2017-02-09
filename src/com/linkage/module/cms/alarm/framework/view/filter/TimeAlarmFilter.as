package com.linkage.module.cms.alarm.framework.view.filter
{
	import mx.utils.StringUtil;

	public class TimeAlarmFilter extends TrueAlarmFilter
	{
		// 告警字段列
		protected var _key:String=null;
		//告警过滤开始时间
		protected var _startTime:int=0;
		//告警过滤结束时间
		protected var _endTime:int=0;

		public function TimeAlarmFilter(key:String, value:String)
		{
			super();
			_key=StringUtil.trim(key);
			initFilter(value);
		}

		override public function accept(alarm:Object):Boolean
		{
			return int(alarm[_key]) >= _startTime && int(alarm[_key]) <= _endTime;
		}

		private function initFilter(rule:String):void
		{
			var ruleArray:Array=rule.split("to");
			if (ruleArray == null || ruleArray.length != 2)
			{
				return;
			}
			_startTime=int(ruleArray[0]);
			_endTime=int(ruleArray[1]);
		}
	}
}