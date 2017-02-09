package com.linkage.module.cms.alarm.framework.view.toolstate.alarmlock
{
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.view.AlarmView;
	import com.linkage.module.cms.alarm.framework.view.core.BaseAlarmView;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.system.structure.map.Map;

	import mx.collections.ICollectionView;
	import mx.controls.AdvancedDataGrid;
	import mx.utils.ArrayUtil;

	/**
	 *告警锁定
	 * @author mengqiang
	 *
	 */
	public class AlarmLock
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.toolstate.alarmlock.AlarmLock");
		// 表格对象
		private var _dataGrid:AdvancedDataGrid;
		// 数据源
		private var _view:ICollectionView;
		// 被锁定的告警
		private var _lockAlarms:Array = [];

		public function AlarmLock(alarmView:BaseAlarmView)
		{
			_dataGrid = alarmView.getFlowAlarm;
			_view = alarmView.alarmsView;

		}

		/**
		 * 锁定一批告警在屏幕最上方
		 * <pre>
		 * 思路:
		 * 1.修改排序方法,将告警至于最上方
		 * 2.将列表行锁定
		 * </pre>
		 * @param alarms
		 *
		 */
		public function set lockAlarms(alarmsMap:Map):void
		{
			_lockAlarms.length = 0;
			alarmsMap.forEach(function(alarmId:String, alarm:Object):void
				{
					AlarmUtil.addLockField(alarm, true);
					_lockAlarms.push(alarm);
					if (alarm)
					{
						findParents(alarm).forEach(function(item:Object, index1:int, array1:Array):void
							{
								AlarmUtil.addLockField(item, true);
								_lockAlarms.push(item);
							});
					}
				});

			_dataGrid.scrollToIndex(0);
			_view.refresh();
		}

		/**
		 *锁定单个告警
		 * @param alarm
		 *
		 */
		public function lockAlarm(alarm:Object):void
		{
			AlarmUtil.addLockField(alarm, true);
			_lockAlarms.push(alarm);
			if (alarm)
			{
				findParents(alarm).forEach(function(item:Object, index1:int, array1:Array):void
					{
						AlarmUtil.addLockField(item, true);
						_lockAlarms.push(item);
					});
			}
			_view.refresh();
		}

		/**
		 *清除单个锁定
		 * @param alarm
		 *
		 */
		public function clearLock(alarm:Object):void
		{
			var index:int = ArrayUtil.getItemIndex(alarm, _lockAlarms);
			if (index != -1)
			{
				_lockAlarms.splice(index, 1);
				AlarmUtil.addAlarmCheckBox(alarm);
				AlarmUtil.addLockField(alarm, false);
				_view.refresh();
			}
		}

		/**
		 * 清除锁定
		 */
		public function clearLocks(islocked:Boolean):void
		{

			_lockAlarms.forEach(function(alarm:Object, index:int, array:Array):void
				{
					if (islocked)
					{
						AlarmUtil.addAlarmCheckBox(alarm);
						AlarmUtil.addLockField(alarm, false);
					}
				});
			_lockAlarms.length = 0;
			_view.refresh();
		}

		/**
		 * 找到告警对象的全部父对象
		 * @param alarm
		 * @return
		 *
		 */
		private function findParents(alarm:Object, parents:Array = null):Array
		{
			if (parents == null)
			{
				parents = [];
			}
			if (alarm.parent != null)
			{
				parents.push(alarm.parent);
				findParents(alarm.parent, parents);
			}
			return parents;
		}
	}
}