package com.linkage.module.cms.alarm.framework.module.server.source
{
	import com.linkage.module.cms.alarm.framework.common.event.RelationEvent;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.param.ParamCache;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.system.structure.map.Map;

	import mx.collections.ArrayCollection;

	/**
	 *关联关系集合
	 * @author mengqiang
	 *
	 */
	public class RelationCollection extends DefaultCollection
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.module.server.source.RelationCollection");
		/**
		 *集客告警列表
		 */
		protected var custMap:Map = new Map();

		public function RelationCollection(windowId:String, windowType:int, alarmAction:AlarmAction)
		{
			super(windowId, windowType, alarmAction);
		}

		//添加单个告警
		override public function addAlarm(alarm:Object):void
		{
			//新增告警
			var windwoKey:String = ParamCache.windowMap.get(_windowId);
			//获取告警唯一序列号
			var alarmId:String = alarm[ColumnConstants.KEY_AlarmUniqueId];
			//集客告警
			if (windwoKey == "relationCust")
			{
				//获取集客信息
				var custArray:ArrayCollection = alarm[ColumnConstants.KEY_CustomerList];
				//原始告警对象
				var originalAlarm:Object = AlarmUtil.cloneAlarmMinusProperty(alarm, ColumnConstants.KEY_CustomerList);
				//处理集客信息
				if (custArray != null && custArray.length > 0)
				{
					var alarmArray:Array = [];
					var cloneAlarm:Object = null;
					for each (var custObj:Object in custArray)
					{
						cloneAlarm = AlarmUtil.copySourceToTarget(originalAlarm, custObj);
						//1.加入告警列表
						alarmArray.push(cloneAlarm);
						dispatchAlarmAdd(cloneAlarm);

						//2.加入集客列表，如果属于同一个集客，同一专线形成树形结构
						//获取集客业务编号
						var ruleName:String = cloneAlarm[ColumnConstants.KEY_GroupCustomer] + "(" + cloneAlarm[ColumnConstants.KEY_BusinessSystem] + ")的关联规则";
						var uniqueCustbussId:String = AlarmUtil.buildUniqueCustbussId(cloneAlarm);
						var preAlarm:Object = custMap.get(uniqueCustbussId);
						//没有当前告警的集客告警
						if (preAlarm == null)
						{
							dataArray.push(cloneAlarm);
							custMap.put(uniqueCustbussId, cloneAlarm);
							cloneAlarm[ColumnConstants.KEY_RuleName] = ruleName;
						}
						else
						{
							super.dealRelation(preAlarm, cloneAlarm, ruleName, 3);
						}
						_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Add, uniqueCustbussId, null, cloneAlarm));
					}
					_alarmMap.put(alarmId, alarmArray);
				}
				else
				{
					//1.添加告警
					dataArray.push(originalAlarm);
					_alarmMap.put(alarmId, [originalAlarm]);
					var uniqueBussId:String = alarmId;
					if (AlarmUtil.checkStrIsNull(originalAlarm[ColumnConstants.KEY_GroupCustomerId]))
					{
						uniqueBussId = AlarmUtil.buildUniqueCustbussId(originalAlarm);
					}
					_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Add, uniqueBussId, null, originalAlarm));

					//2.调用父类新增方法
					dispatchAlarmAdd(originalAlarm);
				}
			}
			else if (windwoKey == "relationDataTrans") //集中性能窗口
			{
				//1.调用父类新增方法
				dispatchAlarmAdd(alarm);

				//2.处理新增告警对象
				_alarmMap.put(alarmId, alarm);
				dataArray.push(alarm)

				//3.抛出事件矩阵统计
				if (!AlarmUtil.checkRelationFlag(alarm))
				{
					_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Add, alarmId, null, alarm));
				}
			}
			else
			{
				dispatchAlarmAdd(alarm);
				_alarmMap.put(alarmId, alarm);
			}
		}

		//更新告警
		override public function updateAlarm(updateAlarm:Object):void
		{
			var windwoKey:String = ParamCache.windowMap.get(_windowId);
			var alarmId:String = updateAlarm[ColumnConstants.KEY_AlarmUniqueId];
			//1.集客告警
			if (windwoKey == "relationCust")
			{
				//1.调用父类更新方法
				dispatchAlarmUpdate(updateAlarm);

				//2.更新告警
				var alarms:Array = _alarmMap.get(alarmId);
				if (alarms != null)
				{
					for each (var alarm:Object in alarms)
					{
						for (var key:String in updateAlarm)
						{
							alarm[key] = updateAlarm[key];
						}
						//如果告警没有父告警直接发布矩阵更新
						if (!AlarmUtil.checkStrIsNull(alarm.parent))
						{
							if (AlarmUtil.checkStrIsNull(alarm[ColumnConstants.KEY_GroupCustomerId]))
							{
								alarmId = AlarmUtil.buildUniqueCustbussId(alarm);
							}
							//通知修改
							_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Update, alarmId, null, updateAlarm));
						}
					}
				}
			}
			else
			{
				super.updateAlarm(updateAlarm);
				//通知修改
				_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Update, alarmId, null, updateAlarm));
			}
		}

		//删除告警
		override public function removeAlarm(removeAlarm:Object, delMap:Boolean = true):Object
		{
			//1.调用父类移除方法
			dispatchAlarmRemove(removeAlarm);

			//2.删除告警对象列表
			var windwoKey:String = ParamCache.windowMap.get(_windowId);
			var alarmId:String = removeAlarm[ColumnConstants.KEY_AlarmUniqueId]
			//(1)集客告警
			if (windwoKey == "relationCust")
			{
				var alarms:Array = _alarmMap.get(alarmId);
				if (alarms != null)
				{
					//删除展示Array中的告警信息
					for (var index:uint = 0; index < dataArray.length; index++)
					{
						var curAlarm:Object = dataArray[index];
						var curAlarmId:String = curAlarm[ColumnConstants.KEY_AlarmUniqueId];
						if (curAlarmId == alarmId) //判断父告警是否要删除
						{
							//删除数据
							dataArray.splice(index, 1);
							dealWithCustParentDelete(curAlarm, alarmId);
							//纠正下标和长度
							index--;
						}
						else //判断子告警是否要删除
						{
							var rchildren:ArrayCollection = curAlarm.children;
							if (rchildren != null)
							{
								for (var cindex:uint = 0; cindex < rchildren.length; cindex++)
								{
									curAlarmId = rchildren[cindex][ColumnConstants.KEY_AlarmUniqueId];
									if (curAlarmId == alarmId)
									{
										//删除数据
										rchildren.removeItemAt(cindex);
										dealWithCustChildDelete(curAlarm, alarmId);
										//纠正下标和长度
										cindex--;
									}
								}
							}
						}
					}

					//是否删除Map中告警信息
					if (delMap)
					{
						_alarmMap.remove(alarmId);
					}
				}
				return alarms;
			}

			//(2)普通关联告警
			var rsAlarm:Object = _alarmMap.get(alarmId);
			if (rsAlarm != null)
			{
				//删除展示Array中的告警信息
				var rsLen:uint = dataArray.length;
				for (var rsindex:uint = 0; rsindex < rsLen; rsindex++)
				{
					if (dataArray[rsindex] === rsAlarm)
					{
						dataArray.splice(rsindex, 1);
						break;
					}
				}
				//是否删除Map中告警信息
				if (delMap)
				{
					removeSelfAndChildAlarm(rsAlarm);
				}
				//删除矩阵
				_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Remove, alarmId));
			}
			return rsAlarm;
		}

		//处理集客父告警删除
		private function dealWithCustParentDelete(alarm:Object, ownAlarmId:String):void
		{
			var uniqueBussId:String = ownAlarmId;
			if (AlarmUtil.checkStrIsNull(alarm[ColumnConstants.KEY_GroupCustomerId]))
			{
				uniqueBussId = AlarmUtil.buildUniqueCustbussId(alarm);
			}
			//是否要删除集客数关系容器
			var rscAlarm:Object = custMap.get(uniqueBussId);
			if (rscAlarm === alarm)
			{
				custMap.remove(uniqueBussId);
			}
			//处理和此告警有关系的告警
			var children:ArrayCollection = alarm.children;
			if (children != null && children.length > 0)
			{
				var cAlarm:Object = children.removeItemAt(0);
				delete cAlarm.parent;
				delete alarm.children;
				dataArray.push(cAlarm);
				custMap.put(uniqueBussId, cAlarm);
				if (children.length > 0)
				{
					cAlarm.children = children;
				}
				//重新统计
				_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_ReAdd, uniqueBussId, children, cAlarm));
			}
			else
			{
				//删除矩阵
				_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Remove, uniqueBussId));

			}
		}

		//处理集客子告警删除
		private function dealWithCustChildDelete(alarm:Object, ownAlarmId:String):void
		{
			var uniqueBussId:String = ownAlarmId;
			if (AlarmUtil.checkStrIsNull(alarm[ColumnConstants.KEY_GroupCustomerId]))
			{
				uniqueBussId = AlarmUtil.buildUniqueCustbussId(alarm);
			}
			//处理和此告警有关系的告警
			var children:ArrayCollection = alarm.children;
			//重新统计
			_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_ReAdd, uniqueBussId, children, alarm));
			//删除子告警容器
			if (children == null || children.length == 0)
			{
				delete alarm.children;
			}
		}

		//添加关联关系
		override public function addRelationShip(rsAlarm:Object):void
		{
			// 1. 从显示容器查找父告警
			var pAlarm:Object = _alarmMap.get(rsAlarm.parentalarm);
			if (pAlarm == null)
			{
				return;
			}

			// 2. 从显示容器查找子告警
			var cAlarm:Object = _alarmMap.get(rsAlarm.childalarm);
			if (cAlarm == null)
			{
				return;
			}

			//3.处理关联关系
			dealRelation(pAlarm, cAlarm, rsAlarm.rulename, int(rsAlarm.relationtype));
		}

		//处理关联关系
		override public function dealRelation(pAlarm:Object, cAlarm:Object, ruleName:String, relationType:int):void
		{
			//窗口Key
			var windwoKey:String = ParamCache.windowMap.get(_windowId);
			//发布关联关系
			dispatchAlarmRelation(cAlarm, pAlarm);
			// 构造关联关系
			cAlarm.parent = pAlarm;
			//获取父告警的子告警容器
			var children:ArrayCollection = pAlarm.children;
			//是否广播父告警对象统计
			var dispatchPalarm:Boolean = false;
			//如果父告警的子告警容器为空说明尚未加入
			if (children == null)
			{
				//判断父告警是否为空，如果为空添加到容器中
				if (pAlarm.parent == null)
				{
					dispatchPalarm = true;
					pAlarm[ColumnConstants.KEY_RuleName] = ruleName;
					//如果不是集中性能窗口直接将父告警加入容器
					if (windwoKey != "relationDataTrans")
					{
						dataArray.push(pAlarm);
					}
				}
				children = new ArrayCollection();
				pAlarm.children = children;
			}
			//添加子告警的规则名称
			cAlarm[ColumnConstants.KEY_RuleName] = ruleName;
			//将子告警加入父告警的子告警容器
			children.addItem(cAlarm);
			//删除告警
			removeAlarm(cAlarm, false);
			// 添加关联关系描述
			addFieldRelationType(cAlarm, relationType);
			//广播普通告警
			var topAlarm:Object = AlarmUtil.findTopParentAlarm(cAlarm);
			var uniqueId:String = topAlarm[ColumnConstants.KEY_AlarmUniqueId];
			if (dispatchPalarm)
			{
				_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Add, uniqueId, cAlarm, pAlarm));
			}
			else
			{
				_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Add, uniqueId, cAlarm));
			}
			//判断子告警是否有子告警，如果有从容器中删除
			if (cAlarm.children != null)
			{
				_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Remove, cAlarm[ColumnConstants.KEY_AlarmUniqueId]));
				//重新统计子告警
				for each (var alarm:Object in cAlarm.children)
				{
					_alarmAction.dispatchEvent(new RelationEvent(_windowId + _windowType + RelationEvent.Relation_Alarm_Add, uniqueId, alarm));
				}
			}
		}

		//清空数据源
		override public function clearWindowSource():void
		{
			custMap.clear();
			super.clearWindowSource();
		}
	}
}