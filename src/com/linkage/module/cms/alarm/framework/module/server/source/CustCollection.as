package com.linkage.module.cms.alarm.framework.module.server.source
{
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.system.structure.map.Map;

	import mx.collections.ArrayCollection;

	/**
	 *集客集合
	 * @author mengqiang
	 *
	 */
	public class CustCollection extends DefaultCollection
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.module.server.source.CustCollection");
		/**
		 *集客告警列表
		 */
		protected var custMap:Map = new Map();

		public function CustCollection(windowId:String, windowType:int, alarmAction:AlarmAction)
		{
			super(windowId, windowType, alarmAction);
		}

		//添加单个告警
		override public function addAlarm(alarm:Object):void
		{
			//新增告警
			//获取告警序列号
			var alarmId:String = alarm[ColumnConstants.KEY_AlarmUniqueId];
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
					var ruleName:String = cloneAlarm[ColumnConstants.KEY_GroupCustomer] + "(" + cloneAlarm[ColumnConstants.KEY_BusinessSystem] + ")";
					var uniqueCustbussId:String = AlarmUtil.buildUniqueCustbussId(cloneAlarm);
					var preAlarm:Object = custMap.get(uniqueCustbussId);

					//没有当前告警的集客告警
					if (preAlarm == null)
					{
						custMap.put(uniqueCustbussId, cloneAlarm);
						dataArray.push(cloneAlarm);
					}
					else
					{
						//作为子告警挂在此告警下面
						super.dealRelation(preAlarm, cloneAlarm, ruleName, 3)
					}

				}
				_alarmMap.put(alarmId, alarmArray);
			}
			else
			{
				//1.添加告警
				dataArray.push(originalAlarm);
				_alarmMap.put(alarmId, [originalAlarm]);

				//2.调用父类新增方法
				dispatchAlarmAdd(originalAlarm);
			}
		}

		//更新告警
		override public function updateAlarm(updateAlarm:Object):void
		{
			//1.调用父类更新方法
			dispatchAlarmUpdate(updateAlarm);

			//2.更新告警
			var alarmId:String = updateAlarm[ColumnConstants.KEY_AlarmUniqueId]
			var alarmArray:Array = _alarmMap.get(alarmId);
			if (alarmArray != null && alarmArray.length > 0)
			{
				for each (var alarm:Object in alarmArray)
				{
					for (var key:String in updateAlarm)
					{
						alarm[key] = updateAlarm[key];
					}
				}
			}
		}

		//删除告警
		override public function removeAlarm(removeAlarm:Object, delMap:Boolean = true):Object
		{
			//1.调用父类移除方法
			dispatchAlarmRemove(removeAlarm);

			//2.删除告警对象列表
			var alarmId:String = removeAlarm[ColumnConstants.KEY_AlarmUniqueId]
			var alarmArray:Array = _alarmMap.get(alarmId);
			if (alarmArray != null && alarmArray.length > 0)
			{
				//1.删除展示Array中的告警信息
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
						var children:ArrayCollection = curAlarm.children;
						if (children != null)
						{
							for (var cindex:uint = 0; cindex < children.length; cindex++)
							{
								curAlarmId = children[cindex][ColumnConstants.KEY_AlarmUniqueId];
								if (curAlarmId == alarmId)
								{
									//删除数据
									children.removeItemAt(cindex);
									dealWithCustChildDelete(curAlarm, alarmId);
									//纠正下标和长度
									cindex--;
								}
							}
						}
					}
				}

				//2.是否删除Map中告警信息
				if (delMap)
				{
					_alarmMap.remove(alarmId);
				}
			}
			return alarmArray;
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
			//删除子告警容器
			if (children == null || children.length == 0)
			{
				delete alarm.children;
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