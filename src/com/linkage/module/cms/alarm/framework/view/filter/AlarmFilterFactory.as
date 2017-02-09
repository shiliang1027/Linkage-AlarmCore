package com.linkage.module.cms.alarm.framework.view.filter
{
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;

	import mx.utils.StringUtil;

	/**
	 *告警过滤工厂
	 * @author mengqiang
	 *
	 */
	public class AlarmFilterFactory
	{
		/**
		 *日志记录器
		 */
		private static var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.filter.AlarmFilterFactory");
		private static var key:String = "undefind";
		private static var oper:String = "undefind";
		private static var value:String = "undefind";

		/**
		 *构建告警过滤器
		 * @param rule
		 * @return
		 *
		 */
		public static function buildAlarmFilter(rule:String):IAlarmFilter
		{
			init(rule);
			var alarmFilter:TrueAlarmFilter = null;
			switch (oper)
			{
				case "=":
					alarmFilter = new EqualAlarmFilter(key, value);
					break;
				case "in(":
					alarmFilter = new InAlarmFilter(key, value);
					break;
				case "$":
					alarmFilter = new TimeAlarmFilter(key, value);
					break;
				case "!=":
					alarmFilter = new NotEqualAlarmFilter(key, value);
					break;
				case "%=":
					alarmFilter = new LikeAlarmFilter(key, value);
					break;
				default:
					alarmFilter = new TrueAlarmFilter();
			}
			return alarmFilter;
		}

		/**
		 *初始化过滤器
		 * @param rule
		 * @return
		 *
		 */
		private static function init(rule:String):void
		{
			log.info("rule=" + rule);
			var ruleArray:Array = null;
			if (rule.indexOf("!=") != -1)
			{
				oper = "!=";
				ruleArray = rule.split(oper);
				key = ruleArray[0];
				value = AlarmUtil.checkStrNull(ruleArray[1]);
			}
			else if (rule.indexOf("%=") != -1)
			{
				oper = "%=";
				ruleArray = rule.split(oper);
				key = ruleArray[0];
				value = StringUtil.trim(ruleArray[1]);
			}
			else if (rule.indexOf("=") != -1)
			{
				oper = "=";
				ruleArray = rule.split(oper);
				key = ruleArray[0];
				value = StringUtil.trim(ruleArray[1]);
			}
			else if (rule.indexOf("in(") != -1)
			{
				oper = "in(";
				ruleArray = rule.split(oper);
				key = ruleArray[0];
				value = StringUtil.trim(ruleArray[1]);
			}
			else if (rule.indexOf("$") != -1)
			{
				oper = "$";
				ruleArray = rule.split(oper);
				key = ruleArray[0];
				value = StringUtil.trim(ruleArray[1]);
			}
		}
	}
}