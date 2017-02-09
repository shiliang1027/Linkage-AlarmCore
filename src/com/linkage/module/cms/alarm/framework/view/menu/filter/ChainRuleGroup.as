package com.linkage.module.cms.alarm.framework.view.menu.filter
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;

	/**
	 *判断组
	 * @author mengqiang
	 *
	 */
	public class ChainRuleGroup implements Rule
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.menu.filter.ChainRuleGroup");
		private var toprule:ORChainRule = new ORChainRule();
		private static var LB:String = '(';
		private static var RB:String = ')';
		private static var DQ:String = '"';
		private static var AND:String = '&';
		private static var OR:String = '|';
		private static var DG:String = '\\';

		public function ChainRuleGroup(grule:String)
		{
			grule = grule.substr(1, grule.length - 2);
			var unitrule:ANDChainRule = new ANDChainRule();
			var lg:Array = new Array();
			var tm:Array = new Array();
			var sb:String = "";
			var len:int = grule.length;
			for (var i:int = 0; i < len; i++)
			{
				var char:String = grule.charAt(i);
				if (lg.length != 0 && lg[lg.length - 1] == DQ)
				{
					if (tm.length == 0 && char == DG)
					{
						tm.push(DG);
						continue;
					}
					else if (tm.length != 0)
					{
						if (char == DG)
						{
							sb += DG;
						}
						else if (char == DQ)
						{
							sb += DQ;
						}
						else
						{
							throw new Error("错误的规则格式，字符串内部的特殊字符\\或者\"没有正确转义");
						}
						tm.pop();
						continue;
					}
					else if (char == DQ)
					{
						sb += char;
						lg.pop();
						continue;
					}
					sb += char;
				}
				else if (LB == char || DQ == char)
				{
					lg.push(char);
					sb += char;
					continue;
				}
				else if (lg.length != 0 && lg[lg.length - 1] == LB && char != RB)
				{
					sb += char;
					continue;
				}
				else if (lg.length != 0 && lg[lg.length - 1] == LB && RB == char)
				{
					sb += char;
					lg.pop();
					continue;
				}
				else if (AND == char || OR == char)
				{
					if (sb.charAt(0) == "(" && sb.charAt(sb.length - 1) == ")")
					{
						unitrule.addRule(new ChainRuleGroup(sb));
					}
					else
					{
						unitrule.addRule(new ChainRuleSingle(sb));
					}
					if (OR == char)
					{
						toprule.addRule(unitrule);
						unitrule = new ANDChainRule();
					}
					sb = "";
					continue;
				}
				else
				{
					sb += char;
				}
			}
			if (sb.charAt(0) == "(" && sb.charAt(sb.length - 1) == ")")
			{
				unitrule.addRule(new ChainRuleGroup(sb));
			}
			else
			{
				unitrule.addRule(new ChainRuleSingle(sb));
			}
			toprule.addRule(unitrule);
		}

		public function accept(alarm:Object):Boolean
		{
			return toprule.accept(alarm);
		}
	}
}