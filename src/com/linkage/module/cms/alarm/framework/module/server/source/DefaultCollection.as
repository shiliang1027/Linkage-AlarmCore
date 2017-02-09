package com.linkage.module.cms.alarm.framework.module.server.source
{
	import com.linkage.module.cms.alarm.framework.common.event.AlarmViewEvent;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.param.ParamCache;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;

	import mx.collections.ArrayCollection;

	/**
	 *默认集合
	 * @author mengqiang
	 *
	 */
	public class DefaultCollection extends Collection
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.module.server.source.DefaultCollection");

		public function DefaultCollection(windowId:String, windowType:int, alarmAction:AlarmAction)
		{
			super(windowId, windowType, alarmAction);
		}

		//添加单个告警
		override public function addAlarm(alarm:Object):void
		{
			//1.调用父类新增方法
			dispatchAlarmAdd(alarm);

			//2.处理新增告警对象
			var alarmId:String = alarm[ColumnConstants.KEY_AlarmUniqueId];
			_alarmMap.put(alarmId, alarm);
			addAlarmArray(alarmId, alarm);
		}

		//通过告警ID获取告警
		override public function getAlarmByAlarmId(alarmId:String):Object
		{
			return _alarmMap.get(alarmId);
		}

		//更新告警
		override public function updateAlarm(updateAlarm:Object):void
		{
			//1.调用父类更新方法
			dispatchAlarmUpdate(updateAlarm);

			//2.更新告警
			var alarmId:String = updateAlarm[ColumnConstants.KEY_AlarmUniqueId]
			var alarm:Object = _alarmMap.get(alarmId);
			if (alarm != null)
			{
				for (var key:String in updateAlarm)
				{
					alarm[key] = updateAlarm[key];
				}
			}
		}

		//删除告警
		override public function removeAlarm(removeAlarm:Object, delMap:Boolean = true):Object
		{
			//1.调用父类移除方法
			dispatchAlarmRemove(removeAlarm);

			//2.删除告警对象列表
			var alarmId:String = removeAlarm[ColumnConstants.KEY_AlarmUniqueId];
			var alarm:Object = _alarmMap.get(alarmId);
			if (alarm != null)
			{
				//删除展示Array中的告警信息
				removeAlarmArray(alarmId);
				//是否删除Map中告警信息
				if (delMap)
				{
					removeSelfAndChildAlarm(alarm);
				}
			}
			return alarm;
		}

		//删除自己和子孙告警对象
		public function removeSelfAndChildAlarm(alarm:Object, level:int = 1):void
		{
			//1.删除自己
			var alarmId:String = alarm[ColumnConstants.KEY_AlarmUniqueId];
			_alarmMap.remove(alarmId);
			//2.删除子孙
			var children:ArrayCollection = alarm.children;
			//如果没有子告警、层次大于等于5直接退出
			if (level++ >= 5 || children == null || children.length == 0)
			{
				return;
			}
			for each (var child:Object in children)
			{
				removeSelfAndChildAlarm(child, level);
			}
		}

		//添加关联关系
		override public function addRelationShip(rsAlarm:Object):void
		{
			//获取关联关系告警信息
			var pid:String = rsAlarm.parentalarm;
			var cid:String = rsAlarm.childalarm;
			var ruleName:String = rsAlarm.rulename;
			var relationType:int = int(rsAlarm.relationtype);
			// 1. 从显示容器查找父告警
			var pAlarm:Object = _alarmMap.get(pid);
			if (pAlarm == null)
			{
				return;
			}

			// 2. 从显示容器查找子告警
			var cAlarm:Object = _alarmMap.get(cid);
			if (cAlarm == null)
			{
				return;
			}

			//3.处理关联关系
			dealRelation(pAlarm, cAlarm, ruleName, relationType);
		}

		// 处理关联关系
		public function dealRelation(pAlarm:Object, cAlarm:Object, ruleName:String, relationType:int):void
		{
			//发布关联关系
			dispatchAlarmRelation(cAlarm, pAlarm);
			// 子不存在其他的父,从显示列表中移除
			removeAlarm(cAlarm, false);
			// 构造关联关系
			cAlarm.parent = pAlarm;
			var children:ArrayCollection = pAlarm.children;
			if (children == null)
			{
				children = new ArrayCollection();
				pAlarm.children = children;
			}
			children.addItem(cAlarm);
			//添加规则名称
			cAlarm[ColumnConstants.KEY_RuleName] = ruleName;
			// 添加关联关系描述
			addFieldRelationType(cAlarm, relationType);
		}

		//给告警增加关联关系属性
		public function addFieldRelationType(alarm:Object, relationType:int):void
		{
			var relationTypeLabel:String = AlarmUtil.getMapValue(ParamCache.relationTypeLabelMap, relationType);
			var array:Array = alarm[ColumnConstants.KEY_RelationType] as Array;
			if (array == null)
			{
				array = [];
				alarm[ColumnConstants.KEY_RelationType] = array;
			}
			if (array.indexOf(relationTypeLabel) == -1)
			{
				array.push(relationTypeLabel);
			}
		}

		//更新告警数量
		override public function updateAlarmNum(level1:int, level2:int, level3:int, level4:int, notAck:int, notCle:int):void
		{
			_level1Num = level1;
			_level2Num = level2;
			_level3Num = level3;
			_level4Num = level4;
			_notAckNum = notAck;
			_notCleNum = notCle;
		}

		//验证告警
		override public function checkAlarm():void
		{
			var alarm:Object = null;
			var alarmId:String = null;
			//删除告警
			if (_level3Num == 0)
			{
				var len3:int = _dataArray.length;
				for (var index3:int = 0; index3 < len3; index3++)
				{
					alarm = _dataArray[index3];
					if (alarm[ColumnConstants.KEY_AlarmSeverity] == 3)
					{
						alarmId = alarm[ColumnConstants.KEY_AlarmUniqueId];
						_dataArrayIndexMap.remove(alarmId);
						_dataArray.splice(index3, 1);
						_alarmMap.remove(alarmId);
						index3--;
						len3--;
					}
				}
			}
			if (_level2Num == 0)
			{
				var len2:int = _dataArray.length;
				for (var index2:int = 0; index2 < len2; index2++)
				{
					alarm = _dataArray[index2];
					if (alarm[ColumnConstants.KEY_AlarmSeverity] == 3)
					{
						alarmId = alarm[ColumnConstants.KEY_AlarmUniqueId];
						_dataArrayIndexMap.remove(alarmId);
						_dataArray.splice(index2, 1);
						_alarmMap.remove(alarmId);
						index2--;
						len2--;
					}
				}
			}
		}

		//清空数据源
		override public function clearWindowSource():void
		{
			//1.清空数据
			_alarmMap.clear();
			dataArray.length = 0;
			updateAlarmNum(0, 0, 0, 0, 0, 0);

			//2.通知视图刷新页面
			_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.REFRESH_VIEW));
		}
	}
}