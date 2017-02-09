package com.linkage.module.cms.alarm.framework.module.server.source
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.common.event.AlarmViewEvent;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.linkage.system.structure.map.Map;
	
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayList;

	/**
	 *定级集合
	 * @author mengqiang
	 *
	 */
	public class Collection extends ListCollectionView implements ICollection
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.module.server.source.Collection");
		/**
		 *告警控制类
		 */
		protected var _alarmAction:AlarmAction = null;
		/**
		 *窗口ID
		 */
		protected var _windowId:String = null;
		/**
		 *窗口类型 1:活动告警 0:清除告警
		 */
		protected var _windowType:int = 1;
		/**
		 * 告警等级统计数:一级告警
		 */
		protected var _level1Num:int = 0;
		/**
		 * 告警等级统计数:二级告警
		 */
		protected var _level2Num:int = 0;
		/**
		 * 告警等级统计数:三级告警
		 */
		protected var _level3Num:int = 0;
		/**
		 * 告警等级统计数:四级告警
		 */
		protected var _level4Num:int = 0;
		/**
		 * 告警统计数:未清除
		 */
		protected var _notCleNum:int = 0;
		/**
		 * 告警统计数:未确认
		 */
		protected var _notAckNum:int = 0;
		/**
		 * 是否对外广播告警增、删、改
		 */
		protected var _isDispatch:Boolean = false;
		/**
		 *告警唯一序列号和告警之前关系
		 */
		protected var _alarmMap:Map = new Map();
		[Bindable]
		/**
		 *数据源用来存储告警信息
		 */
		protected var _dataArray:Array = new Array();
		/**
		 *告警唯一序列号和告警索引关系
		 */
		protected var _dataArrayIndexMap:Map = new Map();

		public function Collection(windowId:String, windowType:int, alarmAction:AlarmAction)
		{
			super();
			_windowId = windowId;
			_windowType = windowType;
			_alarmAction = alarmAction;
			list = new ArrayList(dataArray);
			numberCols = ColumnConstants.NUMBER_COLUMNS;
			groupCols = ColumnConstants.GROUP_COLUMNS;
			defaultSort = AlarmUtil.initDefaultSort();
		}

		public function addAlarmArray(alarmId:String, alarm:Object):void
		{
			_dataArrayIndexMap.put(alarmId, dataArray.push(alarm) - 1);
		}

		public function removeAlarmArray(alarmId:String):void
		{
			var temp:* = _dataArrayIndexMap.remove(alarmId);
			if (temp != null)
			{
				// 当前对象索引
				var index:int = temp;
				if (index == dataArray.length - 1)
				{
					// 删除尾部
					dataArray.pop();
				}
				else
				{
					// 尾部对象替替换到指定下标位置
					var tailObj:* = dataArray.pop();
					var tailId:String = tailObj[ColumnConstants.KEY_AlarmUniqueId];
					dataArray.splice(index, 1, tailObj);
					_dataArrayIndexMap.put(tailId, index);
				}
			}
		}

		public function checkAlarm():void
		{
			throw new Error("【checkAlarm方法必须在子类中实现】");
		}

		public function addAlarm(alarm:Object):void
		{
			throw new Error("【addAlarm方法必须在子类中实现】");
		}

		public function getAlarmByAlarmId(alarmId:String):Object
		{
			throw new Error("【getAlarmByAlarmId方法必须在子类中实现】");
		}

		public function updateAlarm(updateAlarm:Object):void
		{
			throw new Error("【updateAlarm方法必须在子类中实现】");
		}

		public function removeAlarm(removeAlarm:Object, delMap:Boolean = true):Object
		{
			throw new Error("【removeAlarm方法必须在子类中实现】");
		}

		public function addRelationShip(rsAlarm:Object):void
		{
			throw new Error("【addRelationShip方法必须在子类中实现】");
		}

		public function updateAlarmNum(level1:int, level2:int, level3:int, level4:int, notAck:int, notCle:int):void
		{
			throw new Error("【updateAlarmNum方法必须在子类中实现】");
		}

		public function clearWindowSource():void
		{
			throw new Error("【clearWindowSource方法必须在子类中实现】");
		}

		//通知告警新增
		public function dispatchAlarmAdd(alarm:Object):void
		{
			//广播告警新增
			if (_isDispatch)
			{
				_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + _windowType + AlarmViewEvent.VIEW_ALARM_ADD, alarm));
			}
			//派单失败告警
			if(alarm["sheetsendstatus"]&&alarm["sheetsendstatus"]=="4"&&alarm["sourceflag"]&&alarm["sourceflag"]=="10"){
				ExternalInterface.call("paidanfailure","派单失败",alarm[ColumnConstants.KEY_AlarmUniqueId],alarm["sheetsendfailres"]);
			}
		}

		//通知告警更新
		public function dispatchAlarmUpdate(updateAlarm:Object):void
		{
			//广播告警更新
			if (_isDispatch)
			{
				_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + _windowType + AlarmViewEvent.VIEW_ALARM_UPDATE, updateAlarm));
			}
		}

		//通知告警更新
		public function dispatchAlarmRelation(alarm:Object, ptAlarm:Object):void
		{
			//广播告警关联关系
			if (_isDispatch)
			{
				_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + _windowType + AlarmViewEvent.VIEW_ALARM_RELATION, alarm, ptAlarm));
			}
		}

		//通知告警移除
		public function dispatchAlarmRemove(removeAlarm:Object):void
		{
			var alarmId:String = removeAlarm[ColumnConstants.KEY_AlarmUniqueId]
			var alarm:Object = _alarmMap.get(alarmId);
			if (alarm != null)
			{
				_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + _windowType + AlarmViewEvent.VIEW_ALARM_REMOVE, alarm, null, _isDispatch));
			}
		}

		override public function refresh():Boolean
		{
			return super.refresh();
		}

		public function get dataArraySize():int
		{
			return _alarmMap.size;
		}

		public function set isDispatch(value:Boolean):void
		{
			_isDispatch = value;
		}

		public function get dataArray():Array
		{
			return _dataArray;
		}

		public function get level1Num():int
		{
			return _level1Num;
		}

		public function get level2Num():int
		{
			return _level2Num;
		}

		public function get level3Num():int
		{
			return _level3Num;
		}

		public function get level4Num():int
		{
			return _level4Num;
		}

		public function get notAckNum():int
		{
			return _notAckNum;
		}

		public function get notCleNum():int
		{
			return _notCleNum;
		}
	}
}