package com.linkage.module.cms.alarm.framework.view.toolstate
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.common.event.AlarmViewEvent;
	import com.linkage.module.cms.alarm.framework.common.event.SoundEvent;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.controller.fo.AlarmParamFo;
	import com.linkage.module.cms.alarm.framework.module.dao.mo.AlarmParamMo;
	import com.linkage.module.cms.alarm.framework.view.AlarmView;
	import com.linkage.module.cms.alarm.framework.view.core.BaseAlarmView;
	import com.linkage.module.cms.alarm.framework.view.resource.imagesclass.IconParam;
	import com.linkage.module.cms.alarm.framework.view.toolstate.alarmlock.AlarmLock;
	import com.linkage.module.cms.alarm.framework.view.toolstate.syncalarm.SyncAlarmWindow;
	import com.linkage.system.structure.map.Map;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	import spark.components.Button;
	import spark.components.HGroup;

	/**
	 *工具栏
	 * @author mengqiang
	 *
	 */
	public class ToolBar extends HGroup
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.toolstate.ToolBar");
		/**
		 *窗口类型
		 */
		private var _windowType:int = 0;
		/**
		 *告警视图对象
		 */
		private var _alarmView:BaseAlarmView = null;
		/**
		 *视图参数MO
		 */
		private var _alarmParamMo:AlarmParamMo = null;
		/**
		 *视图参数FO
		 */
		private var _alarmParamFo:AlarmParamFo = null;
		/**
		 *未清除统计数
		 */
		private var _notCleLabel:Label = new Label();
		/**
		 *未确认统计数
		 */
		private var _notAckLabel:Label = new Label();
		/**
		 *告警导出按钮
		 */
		private var _exportButton:Image = null;
		/**
		 *告警设置按钮
		 */
		private var _setButton:Image = null;
		/**
		 *告警图标说明
		 */
		private var _helpButton:Image = null;
		//********************告警锁定*********************
		/**
		 *告警锁定对象
		 */
		private var _alarmLock:AlarmLock = null;
		/**
		 *告警锁定状态
		 */
		private var _lockStatus:Boolean = false;
		/**
		 *告警锁定按钮
		 */
		private var _lockButton:Image = null;
		/**
		 *是否锁定全屏
		 */
		private var _isLockScreen:Boolean = false;
		//********************告警发声*********************
		/**
		 *告警声音状态
		 */
		private var _soundEnable:Boolean = true;
		/**
		 *告警声音按钮
		 */
		private var _voicesButton:Image = null;
		//********************告警同步*********************
		/**
		 *告警同步面板
		 */
		private var _syncAlarmWin:SyncAlarmWindow = null;

		//********************告警冻结*********************
		/**
		 *告警首行冻结状态
		 */
		private var _lockRowEnable:Boolean = true;
		/**
		 *告警首行冻结按钮
		 */
		private var _lockRowButton:Image = null;
		/**
		 *告警首列冻结状态
		 */
		private var _lockColumnEnable:Boolean = true;
		/**
		 *告警首列冻结按钮
		 */
		private var _lockColumnButton:Image = null;
		
		//********************打开收缩*********************
		/**
		 *是否打开
		 */
		private var _openEnable:Boolean = true;
		
		/**
		 *打开关闭按钮
		 */
		private var _opencloseButton:Image = null;

		//初始化工具栏
		public function initTool(alarmView:BaseAlarmView):void
		{
			log.info("【初始化工具栏】");
			//1.初始化工具栏参数
			_alarmView = alarmView;
			_windowType = alarmView.windowType;
			_alarmParamMo = alarmView.alarmAction.alarmParamMo;
			_alarmParamFo = alarmView.alarmAction.alarmParamFo;
			//2.初始化工具栏图标
			initToolImage();
			//3.初始化告警锁定对象
			_alarmLock = new AlarmLock(alarmView);
			//4.初始化告警同步
			_syncAlarmWin = new SyncAlarmWindow();
			_syncAlarmWin.initPanel(alarmView.alarmAction, _windowType, alarmView.windowId);
		}

		//初始化工具栏图标
		private function initToolImage():void
		{
			//增加打开收缩按钮
			addElement(openCloseButton("收缩")); 
//			if(-1 != _alarmView.getVTitle.text.indexOf("已确认")){
//				// 收缩
//				_openEnable = false;
//				_opencloseButton.source = IconParam.expandIcon;
//				_opencloseButton.toolTip = "打开";
//				log.warn("打开窗口:" + _alarmView.windowId);
//				_alarmView.getFlowAlarm.visible = false;
//				_alarmView.getFlowAlarm.includeInLayout=false;
//				AlarmView(_alarmView).percentHeight=0;
//			}
			//1.默认添加取消过滤按钮
			addElement(showAllButton());
			addElement(lockFirstColumnButton());
			//2.添加其他工具栏工具
			var toolArr:Array = _alarmParamMo.toolStateJsons[_alarmView.windowId];
			if (toolArr != null)
			{
				for each (var tool:Object in toolArr)
				{
					var toolId:String = tool.toolbarEnname;
					var toolName:String = tool.toolbarChname;
					var uiTool:UIComponent = getTool(toolId, toolName);
					if (uiTool != null)
					{
						addElement(uiTool);
					}
				}
			}
			else
			{
				log.info("【窗口ID配置有误，未能初始化工具栏!】");
			}
		}

		//获取工具对象
		private function getTool(toolId:String, toolName:String):UIComponent
		{
			var tool:UIComponent = null;
			switch (toolId)
			{
//				case "disall":
//					tool=showAllButton(toolName);
//					break;
				case "syn":
					tool = syncAlarmButton(toolName);
					break;
				case "clearstate":
					tool = noClearButton(toolName);
					break;
				case "ackstate":
					tool = noAckButton(toolName);
					break;
				case "voiceswitch":
					tool = voicesButton(toolName);
					break;
				case "lock":
					tool = lockIconButton(toolName);
					break;
				case "showIcon":
					tool = showIconColumnButton(toolName);
					break;
				case "export":
					tool = exportAlarmButton(toolName);
					break;
				case "help":
					tool = iconHelpButton(toolName);
					break;
				case "tool":
					tool = iconDefindButton(toolName);
			}
			return tool;
		}

		//工具栏图标:显隐状态标识列
		public function showIconColumnButton(tipName:String = null):UIComponent
		{
			var button:Image = new Image();
			button.source = IconParam.stateflagIcon;
			button.buttonMode = true;
			button.toolTip = "隐藏状态标识列";
			button.addEventListener(MouseEvent.CLICK, iconColumnShow);
			return button;
		}

		//工具栏操作:显隐状态标识列
		private function iconColumnShow(event:MouseEvent):void
		{
			Image(event.target).toolTip = Image(event.target).toolTip == "隐藏状态标识列" ? "显示状态标识列" : "隐藏状态标识列";
			_alarmView.columnIconShow();
		}

		//工具栏图标:显示全部
		public function showAllButton(tipName:String = null):UIComponent
		{
			var button:Image = new Image();
			button.source = IconParam.iconFilter;
			button.buttonMode = true;
			button.toolTip = "取消过滤";
			button.addEventListener(MouseEvent.CLICK, alarmAllShow);
			return button
		}

		//工具栏操作:显示全部
		private function alarmAllShow(event:MouseEvent):void
		{
			_alarmView.showAllAlarm();
		}

		//工具栏图标:冻结首行
		public function lockFirstRowButton(tipName:String = null):UIComponent
		{
			_lockRowButton = new Image();
			_lockRowButton.source = IconParam.lockRow;
			_lockRowButton.buttonMode = true;
			_lockRowButton.toolTip = "冻结首行";
			_lockRowButton.addEventListener(MouseEvent.CLICK, lockFirstRow);
			return _lockRowButton
		}

		//工具栏操作:冻结首行
		private function lockFirstRow(event:MouseEvent):void
		{
			if (_lockRowEnable)
			{
				_lockRowEnable = false;
				_lockRowButton.toolTip = "解冻首行";
				_alarmView.getFlowAlarm.lockedRowCount = 1;
			}
			else
			{
				_lockRowEnable = true;
				_lockRowButton.toolTip = "冻结首行";
				_alarmView.getFlowAlarm.lockedRowCount = 0;
			}

		}

		//工具栏图标:冻结首列
		public function lockFirstColumnButton(tipName:String = null):UIComponent
		{
			_lockColumnButton = new Image();
			_lockColumnButton.source = IconParam.lockColumn;
			_lockColumnButton.buttonMode = true;
			_lockColumnButton.toolTip = "冻结首列";
			_lockColumnButton.addEventListener(MouseEvent.CLICK, lockFirstColumn);
			return _lockColumnButton
		}

		//工具栏操作:冻结首列
		private function lockFirstColumn(event:MouseEvent):void
		{
			if (_lockColumnEnable)
			{
				_lockColumnEnable = false;
				_lockColumnButton.toolTip = "解冻首列";
				_alarmView.getFlowAlarm.lockedColumnCount = 2;
			}
			else
			{
				_lockColumnEnable = true;
				_lockColumnButton.toolTip = "冻结首列";
				_alarmView.getFlowAlarm.lockedColumnCount = 0;
			}

		}

		//工具栏图标:同步告警
		public function syncAlarmButton(tipName:String):UIComponent
		{
			var button:Image = new Image();
			button.source = IconParam.iconAlarmSyn;
			button.buttonMode = true;
			button.toolTip = tipName;
			button.enabled = AlarmUtil.checkWindowType(_windowType);
			button.addEventListener(MouseEvent.CLICK, alarmSync);
			return button
		}

		//工具栏操作:同步告警
		private function alarmSync(event:MouseEvent):void
		{
			_syncAlarmWin.showHideWindow(parentApplication as DisplayObject);
		}

		//工具栏图标:未清除
		public function noClearButton(tipName:String):UIComponent
		{
			//1.未清除图片
			var button:Image = new Image();
			button.source = IconParam.iconClearNo;
			button.buttonMode = true;
			button.toolTip = tipName;
			//2.未清除数字
			_notCleLabel.text = "0";
			_notCleLabel.styleName = "label";
			//3.包装容器
			var hGroup:HGroup = new HGroup();
			hGroup.gap = 0;
			hGroup.addElement(button);
			hGroup.addElement(_notCleLabel);
			return hGroup
		}

		//工具栏图标:未确认
		public function noAckButton(tipName:String):UIComponent
		{
			//1.未确认图片
			var button:Image = new Image();
			button.source = IconParam.iconAckNo;
			button.buttonMode = true;
			button.toolTip = tipName;
			//2.未确认数字
			_notAckLabel.text = "0";
			_notAckLabel.styleName = "label";
			//3.包装容器
			var hGroup:HGroup = new HGroup();
			hGroup.gap = 0;
			hGroup.addElement(button);
			hGroup.addElement(_notAckLabel);
			return hGroup
		}

		//工具栏图标:告警声音
		public function voicesButton(tipName:String):UIComponent
		{
			_voicesButton = new Image();
			_voicesButton.source = IconParam.iconSoundOpen;
			_voicesButton.buttonMode = true;
			_voicesButton.toolTip = "关闭声音";
			_voicesButton.enabled = AlarmUtil.checkWindowType(_windowType);
			_voicesButton.addEventListener(MouseEvent.CLICK, alarmVoices);
			return _voicesButton
		}

		//工具栏操作:告警声音
		private function alarmVoices(event:MouseEvent):void
		{
			if (_soundEnable)
			{
				// 静音
				_soundEnable = false;
				_voicesButton.source = IconParam.iconSoundClose;
				_voicesButton.toolTip = "开启声音";
				log.warn("开启声音:" + _alarmView.windowId);
				_alarmView.alarmAction.dispatchEvent(new SoundEvent(SoundEvent.VOICE_OFF, _alarmView.windowId));
			}
			else
			{
				// 开启声音
				_soundEnable = true;
				_voicesButton.source = IconParam.iconSoundOpen;
				_voicesButton.toolTip = "关闭声音";
				log.warn("关闭声音" + _alarmView.windowId);
				_alarmView.alarmAction.dispatchEvent(new SoundEvent(SoundEvent.VOICE_ON, _alarmView.windowId));
			}
		}
		//窗口打开或者收缩
		public function openCloseButton(tipName:String = null):Image
		{
			log.warn("打开窗口:" + _alarmView.windowId);
			_opencloseButton = new Image();
			_opencloseButton.source = IconParam.collapseIcon;
			_opencloseButton.buttonMode = true;
			//_opencloseButton.label = "收缩";
			_opencloseButton.toolTip = "收缩";
			//_opencloseButton.enabled = AlarmUtil.checkWindowType(_windowType);
			_opencloseButton.addEventListener(MouseEvent.CLICK, alarmOpenClose);
			return _opencloseButton
		}
		
		//工具栏操作:收缩好打开按钮事件
		private function alarmOpenClose(event:MouseEvent):void
		{
			if (_openEnable)
			{
				// 收缩
				_openEnable = false;
				_opencloseButton.source = IconParam.expandIcon;
				//_opencloseButton.label = "打开";
				_opencloseButton.toolTip = "打开";
				log.warn("打开窗口:" + _alarmView.windowId);
				_alarmView.getFlowAlarm.visible = false;
				_alarmView.getFlowAlarm.includeInLayout=false;
				AlarmView(_alarmView).percentHeight=0;
			}
			else
			{
				// 打开
				_openEnable = true;
				_opencloseButton.source = IconParam.collapseIcon;
				//_opencloseButton.label = "收缩";
				_opencloseButton.toolTip = "收缩";
				log.warn("收缩窗口" + _alarmView.windowId);
				_alarmView.getFlowAlarm.visible = true;
				_alarmView.getFlowAlarm.includeInLayout=true;
				AlarmView(_alarmView).percentHeight=100;
			}
		}
		//工具栏图标:告警锁定
		public function lockIconButton(tipName:String):UIComponent
		{
			_lockButton = new Image();
			_lockButton.source = IconParam.iconLockNo;
			_lockButton.buttonMode = true;
			_lockButton.toolTip = "告警锁定解除";
			_lockButton.addEventListener(MouseEvent.CLICK, toolAlarmLock);
			return _lockButton
		}

		//工具栏操作:告警锁定
		public function toolAlarmLock(event:MouseEvent = null, islocked:Boolean = true):void
		{
			if (_lockStatus) // 解锁
			{
				_alarmLock.clearLocks(islocked);
				_alarmView.lockAlarmView(false);
				_alarmView.refresh();
				_lockButton.source = IconParam.iconLockNo;
				_lockButton.toolTip = "告警锁定解除";
				_isLockScreen = false;
				_lockStatus = false;

				_alarmView.checkAlarmMap.clear();

			}
			else // 锁定
			{
				if (_alarmView.checkAlarmMap.size == 0)
				{
					_isLockScreen = true;
					_alarmView.lockAlarmView(true);
				}
				else
				{
					_isLockScreen = false;
					_alarmView.lockAlarmView(false);
					_alarmLock.lockAlarms = _alarmView.checkAlarmMap;
				}
				_lockButton.source = IconParam.iconLockOk;
				_lockButton.toolTip = "告警锁定";
				_lockStatus = true;

				_alarmView.alarmAction.dispatchEvent(new AlarmViewEvent(_alarmView.windowId + AlarmViewEvent.VIEW_LOCKED));
			}
		}

		//工具栏图标:告警导出
		public function exportAlarmButton(tipName:String):UIComponent
		{
			_exportButton = new Image();
			_exportButton.source = IconParam.iconExport;
			_exportButton.buttonMode = true;
			_exportButton.toolTip = tipName;
			_exportButton.addEventListener(MouseEvent.CLICK, alarmExport);
			return _exportButton
		}

		//工具栏操作:告警导出
		protected function alarmExport(event:MouseEvent):void
		{
			//1.验证是否选中
			if (_alarmView.checkAlarmMap.size <= 0 && getSelectArrays().length <= 0)
			{
				AlarmUtil.showMessage("请选择要导出的告警!");
				return;
			}
			//2.验证最大导出支持
			if (_alarmView.checkAlarmMap.size >= 1000 || getSelectArrays().length >= 1000)
			{
				AlarmUtil.showMessage("最大支持导出不超过1000条，请重选后再试!");
				return;
			}
			//3.展示列
			var columnStr:String = "";
			var columnTitle:String = "";
			var displayColumns:Array = _alarmParamMo.displayColumns[_alarmView.windowId];
			if (displayColumns != null)
			{
				var culumnIdx:Boolean = true;
				for each (var obj:Object in displayColumns)
				{
					if (!culumnIdx)
					{
						columnStr += "#";
						columnTitle += "#";
					}
					columnStr += obj.id;
					columnTitle += obj.name;
					culumnIdx = false;
				}
			}
			//4.展示数据
			//把导出数据排序
			var exportMap:Map = new Map();
			var exportArray:Array = new Array();
			if (_alarmView.checkAlarmMap.size > 0)
			{
				_alarmView.checkAlarmMap.forEach(function(alarmId:String, alarm:Object):void
					{
						var palarm:Object = alarm.parent;
						if (palarm == null)
						{
							exportArray.push(alarm);
						}
						else
						{
							var index:int = exportArray.indexOf(palarm);
							if (index != -1)
							{
								exportArray.splice((index + 1), 0, alarm);
							}
							else
							{
								exportMap.put(alarmId, alarm);
							}
						}
					});
				//生成其他子树
				addChildrenAlarms(exportMap, exportArray, 1);
			}
			else
			{
				getSelectArrays().reverse().forEach(function(alarm:Object, index:int, array:Array):void
					{
						var palarm:Object = alarm.parent;
						if (palarm == null)
						{
							exportArray.push(alarm);
						}
						else
						{
							var index:int = exportArray.indexOf(palarm);
							if (index != -1)
							{
								exportArray.splice((index + 1), 0, alarm);
							}
							else
							{
								exportMap.put(alarm[ColumnConstants.KEY_AlarmUniqueId], alarm);
							}
						}
					});
				//生成其他子树
				addChildrenAlarms(exportMap, exportArray, 1);
			}

			var dataStr:String = "";
			var dataIdx:Boolean = true;
			for each (var alarm:Object in exportArray)
			{
				if (!dataIdx)
				{
					dataStr += "[#]";
				}
				if (displayColumns != null)
				{
					var palarmId:String = (alarm.parent != null) ? alarm.parent[ColumnConstants.KEY_AlarmUniqueId] : null;
					var columnIdx:Boolean = true;
					for each (var column:Object in displayColumns)
					{
						if (!columnIdx)
						{
							dataStr += "[@]" + column.id + "[_]" + alarm[column.id];
						}
						else
						{
							if (palarmId != null && _alarmView.checkAlarmMap.get(palarmId) != null)
							{
								dataStr += column.id + "[_]" + AlarmUtil.exportAlarmPreInfo(alarm) + alarm[column.id];
							}
							else
							{
								dataStr += column.id + "[_]" + alarm[column.id];
							}
						}
						columnIdx = false;
					}
				}
				dataIdx = false;
			}
			//5.导出数据
			var baseUrl:String = _alarmParamFo.baseURL;
			var moduleKey:String = _alarmParamFo.moduleKey;
			var url:String = baseUrl + "/cms/alarm/util/alarmUtil.action";
			ExternalInterface.call("exportExcel", url, columnStr, columnTitle, encodeURIComponent(dataStr), moduleKey);
		}

		//获取选中告警数组
		private function getSelectArrays():Array
		{
			return _alarmView.getFlowAlarm.selectedItems;
		}

		//添加子告警到父告警后面
		private function addChildrenAlarms(map:Map, array:Array, level:int):void
		{
			//如果为空直接返回
			if (map.isEmpty())
			{
				return;
			}
			//添加子告警到父告警后面
			var childMap:Map = new Map();
			map.forEach(function(alarmId:String, alarm:Object):void
				{
					var index:int = array.indexOf(alarm);
					if (index != -1)
					{
						array.splice((index + 1), 0, alarm);
					}
					else
					{
						if (level > 3)
						{
							array.push(alarm);
						}
						else
						{
							childMap.put(alarmId, alarm);
						}
					}
				});
			map.clear();
			addChildrenAlarms(childMap, array, ++level);
		}

		//工具栏图标:图片说明
		public function iconHelpButton(tipName:String):UIComponent
		{
			_helpButton = new Image();
			_helpButton.source = IconParam.iconHelp;
			_helpButton.buttonMode = true;
			_helpButton.toolTip = tipName;
			_helpButton.addEventListener(MouseEvent.CLICK, alarmHelp);
			return _helpButton
		}

		//工具栏操作:图标说明
		protected function alarmHelp(event:MouseEvent):void
		{
			var baseUrl:String = _alarmParamFo.baseURL;
			var url:String = baseUrl + "/warn/rule/config/warnIconConfigAction.action";
			ExternalInterface.call("function(){window.open('" + url + "','','resizable=yes,toolbar=no')}");
		}

		//工具栏图标:告警设置
		public function iconDefindButton(tipName:String):UIComponent
		{
			_setButton = new Image();
			_setButton.source = IconParam.iconDefind;
			_setButton.buttonMode = true;
			_setButton.toolTip = tipName;
			_setButton.addEventListener(MouseEvent.CLICK, alarmSet);
			return _setButton
		}

		//工具栏操作:告警设置
		protected function alarmSet(event:MouseEvent):void
		{
			var baseUrl:String = _alarmParamFo.baseURL;
			var viewId:String = _alarmParamMo.viewId;
			var moduleKey:String = _alarmParamFo.moduleKey;
			var creator:String = _alarmParamFo.mapInfo.account;
			var uniquekey:String = _alarmView.windowUniquekey;
			var windowId:String = _alarmView.windowId;
			var url:String = null;
			if (moduleKey == "relationalarm")
			{
				url = baseUrl + "/warn/view/set/alarmSetAction!initViewSet.action?hangToolBar=yes&monitor_viewname="+moduleKey+"&window_uniquekey=" + uniquekey;
			}
			else if (moduleKey == "dutyalarm" || moduleKey == "customrulealarm" || moduleKey == "speccustomrulealarm" || moduleKey == "sheetprealarm" || moduleKey == "inspectalarm")
			{
				url = baseUrl + "/warn/view/set/alarmSetAction!initViewSet.action?hangToolBar=yes&monitor_viewname="+moduleKey+"&view_id="+viewId+"&window_id=" + windowId;
			}
			else
			{
				url = baseUrl + "/warn/view/set/alarmSetAction!initViewSet.action?hangToolBar=yes&monitor_viewname="+moduleKey;
			}
			ExternalInterface.call("function(){window.open('" + url + "','','resizable=yes,toolbar=no,width=800,height=700')}");
		}

		public function set notCleNum(notCleNum:int):void
		{
			_notCleLabel.text = String(notCleNum);
		}

		public function set notAckNum(notAckNum:int):void
		{
			_notAckLabel.text = String(notAckNum);
		}

		public function get lockStatus():Boolean
		{
			return _lockStatus;
		}

		public function get alarmLock():AlarmLock
		{
			return _alarmLock;
		}

		public function get isLockScreen():Boolean
		{
			return _isLockScreen;
		}
		public function get opencloseButton():Image
		{
			return _opencloseButton;
		}
	}
}