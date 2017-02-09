package com.linkage.module.cms.alarm.framework.view.menu
{
	import mx.collections.ArrayCollection;

	/**
	 * 菜单节点(资源对象)
	 * @author mengqiang
	 *
	 */
	public class MenuResItem
	{

		// 菜单名称
		private var _name:String=null;
		// 是否允许匹配出现
		private var _multiple:Boolean=false;
		// 菜单图标
		private var _icon:String=null;
		// 菜单过滤字符串
		private var _filter:String=null;
		// 菜单的类型 (url|msg|key)
		private var _type:String=null;
		// 菜单操作
		private var _action:String=null;
		// 更新信息
		private var _update:String=null;
		// 子菜单
		private var _submenu:ArrayCollection=null;

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name=value;
		}

		public function get icon():String
		{
			return _icon;
		}

		public function set icon(value:String):void
		{
			_icon=value;
		}

		public function get action():String
		{
			return _action;
		}

		public function set action(value:String):void
		{
			_action=value;
		}

		public function get update():String
		{
			return _update;
		}

		public function set update(value:String):void
		{
			_update=value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type=value;
		}

		public function get filter():String
		{
			return _filter;
		}

		public function set filter(value:String):void
		{
			_filter=value;
		}

		public function get multiple():Boolean
		{
			return _multiple;
		}

		public function set multiple(value:Boolean):void
		{
			_multiple=value;
		}

		public function toString():String
		{
			return "MenuResItem(" + name + " / " + type + ") " + action;
		}
	}
}