package com.linkage.module.cms.alarm.framework.view.menu.filter
{

	/**
	 *或过滤器
	 * @author mengqiang
	 *
	 */
	public class ORChainRule implements Rule
	{
		private var rules:Array=null;

		public function ORChainRule()
		{
			rules=new Array();
		}

		public function accept(alarm:Object):Boolean
		{
			for each (var rule:Rule in rules)
			{
				if (rule.accept(alarm))
				{
					return true;
				}
			}
			return false;
		}

		/**
		 *增加规则
		 * @param rule
		 *
		 */
		public function addRule(rule:Rule):void
		{
			rules.push(rule);
		}
	}
}