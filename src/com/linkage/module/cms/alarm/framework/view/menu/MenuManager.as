package com.linkage.module.cms.alarm.framework.view.menu
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.AlarmContainer;
	import com.linkage.module.cms.alarm.framework.common.event.AlarmViewEvent;
	import com.linkage.module.cms.alarm.framework.common.event.MenuEvent;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.linkage.module.cms.alarm.framework.view.core.BaseAlarmView;
	import com.linkage.system.structure.map.Map;
	
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridItemRenderer;
	import mx.controls.advancedDataGridClasses.MXAdvancedDataGridItemRenderer;
	import mx.controls.listClasses.BaseListData;


	/**
	 * 菜单管理器(默认将action中的 $[item_name] 转义为功能点名称)
	 * @author mengqiang
	 *
	 */
	public class MenuManager
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.menu.MenuManager");
		//窗口ID
		private var _windowId:String = null;
		// 上下文
		protected var _context:String = null;
		//告警控制类
		private var _alarmAction:AlarmAction = null;
		//选中告警数组
		private var _selectedAlarmArray:Array = null;
		// 告警视图
		protected var _alarmView:BaseAlarmView = null;
		// 双击事件菜单资源
		private var _doubleClickMenuResItem:MenuResItem = null;
		// 右键菜单资源集合
		protected var _cMenuResColl:ArrayCollection = new ArrayCollection();
		// 右键菜单资源与菜单节点的映射Map
		protected var _res2CMenuItemMap:Dictionary = new Dictionary();
		// 菜单节点对象与右键菜单资源的映射Map
		protected var _cMenuItem2ResMap:Dictionary = new Dictionary();
		// action中内容关键字 事件类型
		protected const ACTIONKEY_EVENT_TYPE:String = "EventType";
		// action中内容关键字 事件url
		protected const ACTIONKEY_EVENT_URL:String = "EventUrl";
		//外部JS方法名
		protected const ACTIONKEY_EVENT_METHOD:String = "UrlMethod";
		// action中内容关键字 弹出url的参数
		protected const ACTIONKEY_URL_PARAM:String = "UrlParam";
		// 双击事件菜单名称
		private const MENUNAME_DOUBLECLICK:String = "双击事件";

		public function MenuManager(windowId:String, alarmView:BaseAlarmView, alarmAction:AlarmAction)
		{
			_windowId = windowId;
			_alarmView = alarmView;
			_alarmAction = alarmAction;
			_context = _alarmAction.alarmParamFo.mapInfo[AlarmContainer.PARAMKEY_CONTEXT];
			initMenuRes(_alarmAction.alarmParamMo.menuArray);
			gridContextMenu = initNullContextMenu();
		}

		//初始化菜单资源

		private function initMenuRes(menuArray:Array):void
		{
			var menuResItem:MenuResItem = null;
			log.info("提供的菜单列表：");
			log.info(menuArray);
			// 右键菜单资源
			for each (var menu:Object in menuArray)
			{
				menuResItem = new MenuResItem();
				menuResItem.name = AlarmUtil.checkStrNull(menu.name);
				menuResItem.icon = AlarmUtil.checkStrNull(menu.icon);
				menuResItem.filter = AlarmUtil.checkStrNull(menu.filter);
				menuResItem.type = AlarmUtil.checkStrNull(menu.type);
				menuResItem.action = AlarmUtil.checkStrNull(menu.action);
				menuResItem.update = AlarmUtil.checkStrNull(menu.update);
				menuResItem.multiple = ("1" == AlarmUtil.checkStrNull(menu.multiple)) ? true : false;
				// 转义下功能点名称
				var menuItem:ContextMenuItem = new ContextMenuItem(menuResItem.name);
				menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, customCMenuItemHandler);
				_cMenuItem2ResMap[menuItem] = menuResItem;
				_res2CMenuItemMap[menuResItem] = menuItem;

				if (MENUNAME_DOUBLECLICK == menuResItem.name)
				{
					_doubleClickMenuResItem = menuResItem;
				}
				else
				{
					_cMenuResColl.addItem(menuResItem);
				}
			}
		}

		//初始化右键菜单

		protected function initNullContextMenu():ContextMenu
		{
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			menu.addEventListener(ContextMenuEvent.MENU_SELECT, cMenuSelectHandler, false);
			log.info("初始化之后的右键菜单：");
			log.info(menu);
			return menu;
		}

		//右键菜单被触发

		private function cMenuSelectHandler(event:ContextMenuEvent):void
		{
			log.info("右键菜单选中事件 ");

			_selectedAlarmArray = [];
			var checkAlarmMap:Map = _alarmView.checkAlarmMap;
			if (checkAlarmMap.size > 0) //复选框选中告警对象
			{
				checkAlarmMap.forEach(function(alarmId:String, alarm:Object):void
					{
						_selectedAlarmArray.push(alarm);
					});
			}
			else //右键或多选告警对象

			{
				//1.获取告警对象
				var curAlarm:Object = null;
				if (event.mouseTarget is AdvancedDataGridItemRenderer)
				{
					curAlarm = (event.mouseTarget as AdvancedDataGridItemRenderer).data;
				}
				else if (event.mouseTarget is MXAdvancedDataGridItemRenderer)
				{
					curAlarm = (event.mouseTarget as MXAdvancedDataGridItemRenderer).data;
				}
				//2.若不在,清空选中列表,仅把当前对象放入选中列表
				var isSelectedCur:Boolean = true;
				if (curAlarm != null)
				{
					var selected:Boolean = false;
					var curAlarmId:String = curAlarm[ColumnConstants.KEY_AlarmUniqueId];
					if (!gridSelectedItems.some(function(alarm:*, index:int, array:Array):Boolean
						{
							var alarmId:String = alarm[ColumnConstants.KEY_AlarmUniqueId];
							return alarmId == curAlarmId;
						}))
					{
						isSelectedCur = false;
						gridSelectedItems = [curAlarm];
						_selectedAlarmArray.push(curAlarm);
					}
				}
				//3.验证是否选择自身，否则将选中行加入列表

				if (isSelectedCur == true)
				{
					for each (var alarm:Object in gridSelectedItems)
					{
						_selectedAlarmArray.push(alarm);
					}
				}
			}
			buildContextMenu();
		}

		//构造新的右键菜单

		private function buildContextMenu():void
		{
			log.info("构造新的右键菜单 ");
			var menu:ContextMenu = gridContextMenu;
			// 先清空已有的右键菜单
			menu.customItems = [];

			// 遍历菜单资源列表,判断是否可以画此菜单(菜单要符合框选中的全部对象)
			for each (var itemRes:MenuResItem in _cMenuResColl)
			{
				if (MenuFilter.acceptAlarms(itemRes, _selectedAlarmArray))
				{
					menu.customItems.push(_res2CMenuItemMap[itemRes]);
				}
			}
			log.info("右键菜单个数: " + menu.customItems.length);
		}

		//捕获 表格双击事件
		private function doDoubleClickHandler(event:MouseEvent):void
		{
			log.info("表格双击事件");
			if (_doubleClickMenuResItem)
			{
				//1.设置选中告警数组
				_selectedAlarmArray = [];
				for each (var alarm:Object in gridSelectedItems)
				{
					_selectedAlarmArray.push(alarm);
				}

				//2.处理右键菜单
				customEventHandler(_doubleClickMenuResItem);
			}
			else
			{
				log.info("未定义双击事件!");
			}
		}

		//定制右键菜单item选中的捕获逻辑
		private function customCMenuItemHandler(event:ContextMenuEvent):void
		{
			var itemRes:MenuResItem = _cMenuItem2ResMap[event.target];

			if (itemRes == null)
			{
				return;
			}
			//1.获取告警对象
			var alarm:Object = null;
			var listData:BaseListData = null;
			if (event.mouseTarget is AdvancedDataGridItemRenderer)
			{
				alarm = (event.mouseTarget as AdvancedDataGridItemRenderer).data;
				listData = (event.mouseTarget as AdvancedDataGridItemRenderer).listData;
			}
			else if (event.mouseTarget is MXAdvancedDataGridItemRenderer)
			{
				alarm = (event.mouseTarget as MXAdvancedDataGridItemRenderer).data;
				listData = (event.mouseTarget as MXAdvancedDataGridItemRenderer).listData;
			}
			//定制菜单
			customEventHandler(itemRes, alarm, listData);

		}

		//捕获 定制事件
		private function customEventHandler(itemRes:MenuResItem, data:Object = null, listData:BaseListData = null):void
		{
			// 选中的对象数组
			if (_selectedAlarmArray == null || _selectedAlarmArray.length == 0)
			{
				return;
			}
			log.warn("触发菜单事件: " + itemRes);
			//更新告警字段
			AlarmUtil.updateMultAlarm(itemRes.update, _selectedAlarmArray);
			// 通过 [itemRes.multiple] 判断当前是否是多选状态

			var url:String = null;
			var urlParam:String = null;
			switch (itemRes.type)
			{
				case AlarmContainer.MENU_TYPE_EVENT: // 外部定义操作
					doAction_event(getActionContent(ACTIONKEY_EVENT_TYPE, itemRes.action), data, listData);
					break;
				case AlarmContainer.MENU_TYPE_KEY: // 内部定义操作
					var eventType:String = getActionContent(ACTIONKEY_EVENT_TYPE, itemRes.action);
					var eventUrl:String = getActionContent(ACTIONKEY_EVENT_URL, itemRes.action);
					log.info("itemRes.multiple={0}",itemRes.multiple);
					if (itemRes.multiple)
					{
						url = AlarmUtil.parseMultMacro(eventUrl, _selectedAlarmArray);
					}
					else
					{
						url = AlarmUtil.parseMacro(eventUrl, _selectedAlarmArray[0]);
					}
					url = _context + url.replace(/\$/g, "&");
					doAction_key(eventType, data, listData, _selectedAlarmArray, url);
					break;
				case AlarmContainer.MENU_TYPE_MSG: // 消息通知
					if (itemRes.multiple)
					{
						url = AlarmUtil.parseMultMacro(itemRes.action, _selectedAlarmArray);
					}
					else
					{
						url = AlarmUtil.parseMacro(itemRes.action, _selectedAlarmArray[0]);
					}
					url = _context + url.replace(/\$/g, "&");
					doAction_msgUrl(url);
					break;
				case AlarmContainer.MENU_TYPE_JSPOST: // JS POST提交
					if (itemRes.multiple)
					{
						url = AlarmUtil.parseMultMacro(itemRes.action, _selectedAlarmArray);
					}
					else
					{
						url = AlarmUtil.parseMacro(itemRes.action, _selectedAlarmArray[0]);
					}
					url = _context + url.replace(/\$/g, "&");
					doAction_jsPost(url);
					break;
				case AlarmContainer.MENU_TYPE_URL: // 弹出页面
					log.warn("触发菜单事件-弹出页面: " + itemRes);
					if (itemRes.multiple)
					{
						url = AlarmUtil.parseMultMacro(itemRes.action, _selectedAlarmArray);
					}
					else
					{
						url = AlarmUtil.parseMacro(itemRes.action, _selectedAlarmArray[0]);
					}
					url = _context + url.replace(/\$/g, "&");
					doAction_openUrl(url);
					break;
				case AlarmContainer.MENU_TYPE_URLWITHPARAM: // 带参数弹出页面
					log.warn("触发菜单事件-带参数弹出页面: " + itemRes);
					var openUrl:String = getActionContent(ACTIONKEY_EVENT_URL, itemRes.action);
					urlParam = getActionContent(ACTIONKEY_URL_PARAM, itemRes.action);
					if (itemRes.multiple)
					{
						url = AlarmUtil.parseMultMacro(openUrl, _selectedAlarmArray);
					}
					else
					{
						url = AlarmUtil.parseMacro(openUrl, _selectedAlarmArray[0]);
					}
					url = _context + url.replace(/\$/g, "&");
					doAction_openUrl(url, urlParam);
					break;
				case AlarmContainer.MENU_TYPE_FUNC: // 调用外部JS方法
					log.warn("触发菜单事件-调用外部JS方法: " + itemRes);
					var jsFunc:String = getActionContent(ACTIONKEY_EVENT_METHOD, itemRes.action);
					urlParam = getActionContent(ACTIONKEY_URL_PARAM, itemRes.action);
					url = AlarmUtil.parseMacro(urlParam, _selectedAlarmArray[0]);
					doAction_outJs(jsFunc, url.replace(/\^/g, "\""));
					break;
				default:
					log.info("[" + itemRes.name + "]未知的菜单操作类型 " + itemRes.type);
					break;
			}

		}

		//获取Action中key对应的内容
		private function getActionContent(key:String, action:String):String
		{
			var split:String = key + "(";
			var start:int = action.indexOf(split);
			if (start == -1)
			{
				return "";
			}
			var end:int = action.indexOf(")", start)
			return action.substring(start + split.length, end);
		}

		//右键菜单操作: 执行内部关键字操作
		protected function doAction_key(eventType:String, data:Object, listData:BaseListData, selectedItems:Array, url:String):void
		{
			_alarmAction.dispatchEvent(new MenuEvent(_windowId + eventType, data, listData, selectedItems.length, url));
//			_alarmAction.addEventListener(_windowId + MenuEvent.AlarmMenuEvent_loadTGAlarm, handler_LoadTGAlarm);
			
//			_alarmAction.dispatchEvent(new MenuEvent("wwww", data, listData, selectedItems.length, url));
//			_alarmAction.addEventListener("wwww", handler_LoadTGAlarm);
		}
		
		//右键菜单操作: 执行外部关键字操作
		protected function doAction_event(eventType:String, data:Object, listData:BaseListData):void
		{
			_alarmAction.dispatchEvent(new MenuEvent(_windowId + eventType, data, listData));
		}

		//右键菜单操作: 消息通知url
		protected function doAction_msgUrl(url:String):void
		{

			log.info("MSG URL: " + url);
			navigateToURL(new URLRequest(url), "_self");
		}

		//右键菜单操作: JS POST提交
		protected function doAction_jsPost(url:String):void
		{

			log.info("jsPost URL: " + url);
			ExternalInterface.call("function(){jsPostUrl('" + url + "');}");
		}

		//右键菜单操作: 外部JS
		protected function doAction_outJs(func:String, param:String):void
		{

			log.info("outJs Param: " + param + ",func:" + func);
			ExternalInterface.call("function(){" + func + "(" + param + ");}");
		}

		//右键菜单操作: 弹出url
		protected function doAction_openUrl(url:String, param:String = null):void
		{
			log.warn("OPEN URL: {0} param:{1}", url, param);

			//1.弹出页面
			if (param)
			{
				var params:Array = param.split(",");
				var paramObject:Object = {};
				params.forEach(function(item:String, index:int, array:Array):void
					{
						var temp:Array = item.split("=");
						if (temp.length == 2)
						{
							var key:String = temp[0];
							var value:String = temp[1];
							paramObject[key] = value;
						}
					});

				AlarmUtil.openUrl(url, null, paramObject);
			}
			else
			{
				AlarmUtil.openUrl(url);
			}

			//2.通知视图刷新页面
			_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.REFRESH_VIEW));
		}

		public function get doubleClickHandler():Function
		{
			return doDoubleClickHandler;
		}

		protected function get gridSelectedItems():Array
		{
			return _alarmView.getFlowAlarm.selectedItems;
		}

		protected function set gridSelectedItems(array:Array):void
		{
			_alarmView.getFlowAlarm.selectedItems = array;
		}

		protected function get gridContextMenu():ContextMenu
		{
			return _alarmView.getFlowAlarm.contextMenu;
		}

		protected function set gridContextMenu(contextMenu:ContextMenu):void
		{
			_alarmView.getFlowAlarm.contextMenu = contextMenu;
		}
	}
}