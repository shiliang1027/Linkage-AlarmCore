package com.linkage.module.cms.alarm.framework.view.core
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.common.event.AlarmViewEvent;
	import com.linkage.module.cms.alarm.framework.common.event.ColumnResizeEvent;
	import com.linkage.module.cms.alarm.framework.common.event.ColumnShiftEvent;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.linkage.module.cms.alarm.framework.module.dao.mo.AlarmParamMo;
	import com.linkage.module.cms.alarm.framework.view.menu.MenuManager;
	
	import mx.collections.ArrayCollection;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;

	/**
	 *视图管理类
	 * @author mengqiang
	 *
	 */
	public class ViewManager
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.core.ViewManager");
		/**
		 * 窗口类型 1:活动告警 0:清除告警
		 */
		private var _windowType:int = 0;
		/**
		 *窗口ID
		 */
		private var _windowId:String = null;
		/**
		 *视图管理类
		 */
		private var _alarmView:BaseAlarmView = null;
		/**
		 *菜单管理
		 */
		private var _menuManager:MenuManager = null;
		/**
		 * 数据源控制类
		 */
		private var _alarmAction:AlarmAction = null;

		public function ViewManager(alarmView:BaseAlarmView, alarmAction:AlarmAction)
		{
			//1.初始化参数
			_alarmView = alarmView;
			_alarmAction = alarmAction;
			_windowId = alarmView.windowId;
			_windowType = alarmView.windowType;

			//2.初始化表格的展示列
			initDataGridColumns();

			//3.菜单管理
			_menuManager = new MenuManager(_windowId, alarmView, alarmAction);
			alarmView.doubleClick = _menuManager.doubleClickHandler;

			//4.监听告警预装
			_alarmAction.addEventListener(AlarmViewEvent.VIEW_ALARM_RELOAD, alarmShowAll);
			_alarmAction.addEventListener(_windowId + AlarmViewEvent.REFRESH_VIEW, notifyRefreshView);
			_alarmAction.addEventListener(_windowId + ColumnShiftEvent.COLUMN_SHIFT, flowColumnShift);
			_alarmAction.addEventListener(_windowId + ColumnResizeEvent.COLUMN_RESIZE, flowColumnResize);
			_alarmAction.addEventListener(_windowId + _windowType + AlarmViewEvent.VIEW_ALARM_REMOVE, alarmReMoveHandler);


		}

		//显示所有告警事件
		private function alarmShowAll(event:AlarmViewEvent):void
		{
			_alarmView.showAllAlarm();
			_alarmView.clearCheckBoxMap();
		}

		//告警移除事件
		private function alarmReMoveHandler(event:AlarmViewEvent):void
		{
			if (event.alarm is Array)
			{
				var alarmArray:Array = event.alarm as Array;
				for each (var alarm:Object in alarmArray)
				{
					viewAlarmRemove(alarm);
				}
			}
			else
			{
				viewAlarmRemove(event.alarm);
			}
			if (_alarmView.checkAlarmMap.isEmpty() && _alarmView.getToolBar.lockStatus && !_alarmView.getToolBar.isLockScreen)
			{
				_alarmView.getToolBar.toolAlarmLock(null, false);
			}
		}

		//视图告警移除
		private function viewAlarmRemove(alarm:Object):void
		{
			var alarmArray:ArrayCollection = AlarmUtil.findAllChildAlarmList(alarm);
			for each (var alarm:Object in alarmArray)
			{
				var alarmId:String = alarm[ColumnConstants.KEY_AlarmUniqueId];
				AlarmUtil.addAlarmCheckBox(alarm, false);
				_alarmView.checkAlarmMap.remove(alarmId);
			}
		}

		//通知刷新视图
		private function notifyRefreshView(event:AlarmViewEvent):void
		{
			//刷新视图
			if (_alarmView.refreshViewType == 0) //刷新全部告警视图
			{
				_alarmView.refresh();
			}
			else //刷新过滤告警视图
			{
				_alarmView.refreshFilterView();
			}
		}


		//流水列拖动事件
		private function flowColumnShift(event:ColumnShiftEvent):void
		{
			var columns:Array = _alarmView.getFlowAlarm.columns;
			if (columns && event.windowType != _windowType)
			{
				columns.splice(event.newIndex, 0, columns.splice(event.oldIndex, 1)[0]);
				_alarmView.getFlowAlarm.columns = columns;
			}
		}

		//流水列变化事件
		private function flowColumnResize(event:ColumnResizeEvent):void
		{
			var columns:Array = _alarmView.getFlowAlarm.columns;
			if (columns && event.columnIndex < columns.length)
			{
				var column:AdvancedDataGridColumn = columns[event.columnIndex];
				if(column.dataField == event.columnName)
				{
					column.width = event.columnWidth;
				}
				else
				{
					for each(column  in columns)
					{
						if(column.dataField == event.columnName)
						{
							column.width = event.columnWidth;
						}
					}
				}
			}
		}

		//初始化表格的展示列
		private function initDataGridColumns():void
		{
			log.warn("【初始化表格的展示列】windowId=" + _windowId);
			var alarmParamMo:AlarmParamMo = _alarmAction.alarmParamMo;
			var displayColumns:Array = alarmParamMo.displayColumns[_windowId];
			if (displayColumns != null)
			{
				_alarmView.columns = displayColumns;
			}
			else
			{
				log.info("【窗口配置有误，未匹配到展示列！】");
				_alarmView.columns = new Array();
			}
		}

		//保存列顺序
		public function saveColumnOrder():void
		{
			//拼接参数
			var params:Object = new Object();
			params["window_id"] = _windowId;
			params["view_id"] = _alarmAction.alarmParamMo.viewId;
			params["module_key"] = _alarmAction.alarmParamFo.moduleKey;
			//获取列顺序
			var columns:Array = _alarmView.getFlowAlarm.columns;
			var columnList:ArrayCollection = new ArrayCollection();
			for each (var gridColumn:AdvancedDataGridColumn in columns)
			{
				columnList.addItem(gridColumn.dataField);
			}
			params["column_list"] = columnList;
			//保存列顺序
			_alarmAction.saveColumnOrder(params);
		}
	}
}