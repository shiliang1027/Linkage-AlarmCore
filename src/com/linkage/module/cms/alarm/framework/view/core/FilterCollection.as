package com.linkage.module.cms.alarm.framework.view.core
{
	import com.adobe.utils.ArrayUtil;
	import com.linkage.module.cms.alarm.framework.AlarmContainer;
	import com.linkage.module.cms.alarm.framework.common.event.AlarmViewEvent;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.linkage.module.cms.alarm.framework.module.server.source.ListCollectionView;
	import com.linkage.module.cms.alarm.framework.view.AlarmView;
	import com.linkage.module.cms.alarm.framework.view.filter.AbstractChainAlarmFilter;
	import com.linkage.module.cms.alarm.framework.view.filter.AlarmFilterFactory;
	import com.linkage.module.cms.alarm.framework.view.filter.AndChainAlarmFilter;
	import com.linkage.module.cms.alarm.framework.view.filter.IAlarmFilter;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.system.structure.map.Map;

	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;

	/**
	 *视图核心过滤
	 * @author mengqiang
	 *
	 */
	public class FilterCollection extends ListCollectionView
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.core.ViewFilterCollection");
		/**
		 *告警控制类
		 */
		private var _alarmAction:AlarmAction = null;
		/**
		 *告警视图
		 */
		private var _alarmView:BaseAlarmView = null;
		/**
		 *窗口ID
		 */
		private var _windowId:String = null;
		/**
		 *窗口类型 1:活动告警 0:清除告警
		 */
		private var _windowType:int = 1;
		/**
		 * 告警等级统计数:一级告警
		 */
		private var _level1Num:int = 0;
		/**
		 * 告警等级统计数:二级告警
		 */
		private var _level2Num:int = 0;
		/**
		 * 告警等级统计数:三级告警
		 */
		private var _level3Num:int = 0;
		/**
		 * 告警等级统计数:四级告警
		 */
		private var _level4Num:int = 0;
		/**
		 * 告警统计数:未清除
		 */
		private var _notCleNum:int = 0;
		/**
		 * 告警统计数:未确认
		 */
		private var _notAckNum:int = 0;
		/**
		 *告警唯一序列号和告警之前关系
		 */
		protected var _alarmMap:Map = new Map();
		[Bindable]
		/**
		 *数据源用来存储告警信息
		 */
		private var _dataArray:Array = new Array();
		/**
		 * 动态过滤告警过滤器
		 */
		private var _filterFunction:Function = null;
		/**
		 * 告警过滤器
		 */
		private var _andAlarmFilter:AbstractChainAlarmFilter = new AndChainAlarmFilter();

		public function FilterCollection(windowId:String, windowType:int, alarmAction:AlarmAction, alarmView:BaseAlarmView)
		{
			super();

			//1.初始化告警参数
			_windowId = windowId;
			_alarmView = alarmView;
			_windowType = windowType;
			_alarmAction = alarmAction;
			list = new ArrayList(dataArray);
			numberCols = ColumnConstants.NUMBER_COLUMNS;
			groupCols = ColumnConstants.GROUP_COLUMNS;
			defaultSort = AlarmUtil.initDefaultSort();

			//2.初始化视图监听器
			_alarmAction.addEventListener(_windowId + _windowType + AlarmViewEvent.VIEW_ALARM_ADD, viewAlarmAdd);
			_alarmAction.addEventListener(_windowId + _windowType + AlarmViewEvent.VIEW_ALARM_REMOVE, viewAlarmRemove);
			_alarmAction.addEventListener(_windowId + _windowType + AlarmViewEvent.VIEW_ALARM_UPDATE, viewAlarmUpdate);
			_alarmAction.addEventListener(_windowId + _windowType + AlarmViewEvent.VIEW_ALARM_RELATION, viewAlarmRelation);
		}

		//视图告警新增
		private function viewAlarmAdd(event:AlarmViewEvent):void
		{
			if (event.alarm != null && _filterFunction.call(null, event.alarm))
			{
				//1.添加告警
				var cloneAlarm:Object = AlarmUtil.cloneObject(event.alarm);
				dataArray.push(cloneAlarm);
				addAlarmMap(cloneAlarm);
				statAlarmNumAdd(cloneAlarm);

				//2.刷新视图
				_alarmView.showFilterAlarm();
			}
		}

		//视图告警移除
		private function viewAlarmRemove(event:AlarmViewEvent):void
		{
			if (event.isDispatch && event.alarm != null)
			{
				//1.删除告警
				if (event.alarm is Array)
				{
					var alarmArray:Array = event.alarm as Array;
					for each (var alarm:Object in alarmArray)
					{
						alarmRemove(alarm);
					}
				}
				else
				{
					alarmRemove(event.alarm);
				}

				//2.刷新视图
				_alarmView.showFilterAlarm();
			}
		}

		//视图告警更新
		private function viewAlarmUpdate(event:AlarmViewEvent):void
		{
			var updateAlarm:Object = event.alarm;
			var alarmId:String = updateAlarm[ColumnConstants.KEY_AlarmUniqueId];
			var curAlarm:Object = _alarmMap.get(alarmId);
			if (curAlarm != null)
			{
				//1.更新数据
				if (curAlarm is Array)
				{
					var array:Array = curAlarm as Array;
					for each (var alarm:Object in array)
					{
						for (var key:String in updateAlarm)
						{
							alarm[key] = updateAlarm[key];
						}
					}
				}
				else
				{
					for (var key1:String in updateAlarm)
					{
						curAlarm[key1] = updateAlarm[key1];
					}
				}

				//2.刷新视图
				_alarmView.showFilterAlarm();
			}
		}

		//添加关联关系
		private function viewAlarmRelation(event:AlarmViewEvent):void
		{

		}

		//添加告警容器
		private function addAlarmMap(alarm:Object):void
		{
			var alarmId:String = alarm[ColumnConstants.KEY_AlarmUniqueId];
			var curAlarm:Object = _alarmMap.get(alarmId);
			if (curAlarm == null)
			{
				_alarmMap.put(alarmId, alarm);
			}
			else
			{
				if (curAlarm is Array)
				{
					(curAlarm as Array).push(alarm);
				}
				else
				{
					_alarmMap.put(alarmId, [curAlarm, alarm]);
				}
			}
		}

		//移除告警
		private function removeAlarmMap(alarm:Object):void
		{
			var alarmId:String = alarm[ColumnConstants.KEY_AlarmUniqueId];
			var curAlarm:Object = _alarmMap.get(alarmId);
			if (curAlarm != null)
			{
				if (curAlarm is Array)
				{
					ArrayUtil.removeValueFromArray(curAlarm as Array, alarm);
				}
				else
				{
					_alarmMap.remove(alarmId);
				}
			}
		}

		//告警移除
		private function alarmRemove(alarm:Object):void
		{
			if (alarm != null)
			{
				var alarmId:String = alarm[ColumnConstants.KEY_AlarmUniqueId];
				//删除展示Array中的告警信息
				var len:uint = dataArray.length;
				for (var index:uint; index < len; index++)
				{
					var curAlarm:Object = dataArray[index];
					var curAlarmId:Object = curAlarm[ColumnConstants.KEY_AlarmUniqueId];
					if (curAlarmId == alarmId)
					{
						//移除统计和Map容器
						removeAlarmStatAndMap(curAlarm);
						//移除容器中告警信息
						dataArray.splice(index, 1);
						break;
					}
					else
					{
						var children:ArrayCollection = curAlarm.children;
						if (children != null)
						{
							var cLen:uint = children.length;
							for (var cindex:uint; cindex < cLen; cindex++)
							{
								curAlarmId = children[cindex][ColumnConstants.KEY_AlarmUniqueId];
								if (curAlarmId == alarmId)
								{
									//移除统计和Map容器
									removeAlarmStatAndMap(children[cindex]);
									//移除容器中告警信息
									children.removeItemAt(cindex);
									break;
								}
							}
						}
					}
				}
			}
		}

		//移除统计和Map容器
		private function removeAlarmStatAndMap(alarm:Object):void
		{
			var children:ArrayCollection = AlarmUtil.findAllChildAlarmList(alarm);
			for each (var child:Object in children)
			{
				statAlarmNumRemove(child);
				removeAlarmMap(child);
			}
		}

		//过滤告警
		public function filterAlarm(ruleStr:String):void
		{
			//1.清空告警容器
			clearWindowSource();

			//2.设置过滤规则
			var ruleArray:Array = ruleStr.split("&");
			var alarmFilter:IAlarmFilter = null;
			_andAlarmFilter.clear();
			ruleArray.forEach(function(rule:String, index:int, array:Array):void
				{
					alarmFilter = AlarmFilterFactory.buildAlarmFilter(rule);
					_andAlarmFilter.addAlarmFilter(alarmFilter);
				});
			_filterFunction = _andAlarmFilter.accept;

			//3.开始过滤告警
			startFilterAlarm();
		}

		//开始过滤告警
		private function startFilterAlarm():void
		{
			_alarmView.alarmsAC.dataArray.forEach(function(alarm:Object, index:int, array:Array):void
				{
					filterChildAlarm(alarm);
				});
		}

		//过滤告警，如果父告警不符合过滤条件把子告警取出直接放到容器中
		public function filterChildAlarm(alarm:Object):void
		{
			var cloneAlarm:Object = AlarmUtil.cloneAlarmMinusProperty(alarm, "children");
			var children:ArrayCollection = alarm.children;
			if (children == null || children.length == 0)
			{
				if (_filterFunction.call(null, cloneAlarm)) //直接将自身加入列表
				{
					statAlarmNumAdd(cloneAlarm);
					dataArray.push(cloneAlarm);
					addAlarmMap(cloneAlarm);
				}
			}
			else
			{
				if (_filterFunction.call(null, cloneAlarm))
				{
					statAlarmNumAdd(cloneAlarm);
					dataArray.push(cloneAlarm);
					addAlarmMap(cloneAlarm);
					var cloneChildren:Array = [];
					for each (var childAlarm:Object in children)
					{
						filterChild(childAlarm, cloneAlarm, cloneChildren);
					}
					cloneAlarm.children = new ArrayCollection(cloneChildren);
				}
				else
				{
					for each (var childObject:Object in children)
					{
						filterChild(childObject, null, dataArray);
					}
				}
			}
		}

		//过滤子告警告警，如果父告警不符合过滤条件把子告警取出直接放到容器中
		public function filterChild(alarm:Object, ptAlarm:Object, array:Array):void
		{
			var cloneAlarm:Object = AlarmUtil.cloneAlarmMinusProperty(alarm, "children");
			var children:ArrayCollection = alarm.children;
			if (children == null || children.length == 0)
			{
				if (_filterFunction.call(null, cloneAlarm)) //克隆告警加入列表
				{
					//1.添加告警到容器
					statAlarmNumAdd(cloneAlarm);
					array.push(cloneAlarm);
					addAlarmMap(cloneAlarm);
					//2.构建父子关系
					if (ptAlarm != null)
					{
						cloneAlarm.parent = ptAlarm;
					}
					else
					{
						delete cloneAlarm.parent;
					}
				}
			}
			else
			{
				if (_filterFunction.call(null, cloneAlarm))
				{
					//1.添加告警到容器
					statAlarmNumAdd(cloneAlarm);
					array.push(cloneAlarm);
					addAlarmMap(cloneAlarm);
					//2.构建父子关系
					if (ptAlarm != null)
					{
						cloneAlarm.parent = ptAlarm;
					}
					else
					{
						delete cloneAlarm.parent;
					}
					//3.添加子告警
					var cloneChildren:Array = [];
					for each (var childAlarm:Object in children)
					{
						filterChild(childAlarm, cloneAlarm, cloneChildren);
					}
					cloneAlarm.children = new ArrayCollection(cloneChildren);
				}
				else
				{
					for each (var childObject:Object in children)
					{
						filterChild(childObject, null, array);
					}
				}
			}
		}

		//统计告警数量
		private function statAlarmNumAdd(alarm:Object):void
		{
			//未确认
			if (AlarmUtil.checkUnack(alarm))
			{
				_notAckNum++;
			}
			//未清除
			if (AlarmUtil.checkActive(alarm))
			{
				_notCleNum++;
			}
			//告警等级
			switch (alarm[ColumnConstants.KEY_AlarmSeverity])
			{
				case AlarmContainer.PROPERTY_LEVEL1: //一级告警
					_level1Num++;
					break;
				case AlarmContainer.PROPERTY_LEVEL2: //二级告警
					_level2Num++;
					break;
				case AlarmContainer.PROPERTY_LEVEL3: //三级告警
					_level3Num++;
					break;
				case AlarmContainer.PROPERTY_LEVEL4: //四级告警
					_level4Num++;
					break;
			}
		}

		//统计告警数量
		private function statAlarmNumRemove(alarm:Object):void
		{
			//未确认
			if (AlarmUtil.checkUnack(alarm))
			{
				_notAckNum--;
			}
			//未清除
			if (AlarmUtil.checkActive(alarm))
			{
				_notCleNum--;
			}
			//告警等级
			switch (alarm[ColumnConstants.KEY_AlarmSeverity])
			{
				case AlarmContainer.PROPERTY_LEVEL1: //一级告警
					_level1Num--;
					break;
				case AlarmContainer.PROPERTY_LEVEL2: //二级告警
					_level2Num--;
					break;
				case AlarmContainer.PROPERTY_LEVEL3: //三级告警
					_level3Num--;
					break;
				case AlarmContainer.PROPERTY_LEVEL4: //四级告警
					_level4Num--;
					break;
			}
		}

		//重置告警统计数据
		public function clearWindowSource():void
		{
			_level1Num = 0;
			_level2Num = 0;
			_level3Num = 0;
			_level4Num = 0;
			_notAckNum = 0;
			_notCleNum = 0;
			_alarmMap.clear();
			dataArray.length = 0;
		}

		//刷新数据
		override public function refresh():Boolean
		{
			return super.refresh();
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