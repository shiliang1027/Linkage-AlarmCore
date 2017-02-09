package com.linkage.module.cms.alarm.framework.view.menu.filter
{
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;

	public class ChainRuleSingle implements Rule
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.menu.filter.ChainRuleSingle");

		private static var EQ:String = "=";
		private static var NEQ:String = "!=";
		private static var Like:String = "%=";
		private static var GT:String = ">";
		private static var LT:String = "<";
		private static var GET:String = ">=";
		private static var LET:String = "<=";

		private var cmpKey:String = null; // 对比的key
		private var cmpOpr:CMP = null; // 操作符号
		private var cmpValue:String = null; // 对比的值

		public function ChainRuleSingle(rule:String)
		{
			log.info("解析单个过滤规则=" + rule);
			if (rule == null)
			{
				throw new Error("规则内容为空");
			}
			var array:Array = null;
			if (rule.indexOf(NEQ) != -1)
			{
				cmpOpr = new NotEqual();
				array = rule.split(NEQ);
				if (array.length != 2)
				{
					throw new Error("规则配置出错");
				}
				cmpKey = array[0];
				cmpValue = AlarmUtil.checkStrNull(array[1]);
			}
			else if (rule.indexOf(Like) != -1)
			{
				cmpOpr = new StrLike();
				array = rule.split(Like);
				if (array.length != 2)
				{
					throw new Error("规则配置出错");
				}
				cmpKey = array[0];
				cmpValue = AlarmUtil.checkStrNull(array[1]);
			}
			else if (rule.indexOf(EQ) != -1)
			{
				cmpOpr = new Equal();
				array = rule.split(EQ);
				if (array.length != 2)
				{
					throw new Error("规则配置出错");
				}
				cmpKey = array[0];
				cmpValue = AlarmUtil.checkStrNull(array[1]);
			}
			else if (rule.indexOf(GT) != -1)
			{
				cmpOpr = new NumbGT();
				array = rule.split(GT);
				if (array.length != 2)
				{
					throw new Error("规则配置出错");
				}
				cmpKey = array[0];
				cmpValue = AlarmUtil.checkStrNull(array[1]);
			}
			else if (rule.indexOf(LT) != -1)
			{
				cmpOpr = new NumbLT();
				array = rule.split(LT);
				if (array.length != 2)
				{
					throw new Error("规则配置出错");
				}
				cmpKey = array[0];
				cmpValue = AlarmUtil.checkStrNull(array[1]);
			}
			else if (rule.indexOf(GET) != -1)
			{
				cmpOpr = new NumbGE();
				array = rule.split(GET);
				if (array.length != 2)
				{
					throw new Error("规则配置出错");
				}
				cmpKey = array[0];
				cmpValue = AlarmUtil.checkStrNull(array[1]);
			}
			else if (rule.indexOf(LET) != -1)
			{
				cmpOpr = new NumbLE();
				array = rule.split(LET);
				if (array.length != 2)
				{
					throw new Error("规则配置出错");
				}
				cmpKey = array[0];
				cmpValue = AlarmUtil.checkStrNull(array[1]);
			}
		}

		public function accept(alarm:Object):Boolean
		{
			return cmpOpr.cmp(alarm[cmpKey], cmpValue);
		}
	}
}