package com.linkage.module.cms.alarm.framework.module.server.source
{

	public interface ICollection
	{

		/**
		 *验证告警
		 *
		 */
		function checkAlarm():void;
		/**
		 *添加单个告警
		 * @param alarm 告警对象
		 *
		 */
		function addAlarm(alarm:Object):void;
		/**
		 *更新告警
		 * @param updateAlarm 更新告警对象
		 *
		 */
		function updateAlarm(updateAlarm:Object):void;
		/**
		 *通过告警ID获取告警
		 * @param alarmId 告警ID
		 * @param windowId 窗口ID
		 * @return
		 *
		 */
		function getAlarmByAlarmId(alarmId:String):Object;
		/**
		 *删除告警
		 * @param removeAlarm 删除告警对象
		 * @param delMap 是否删除Map中告警对象
		 * @return
		 *
		 */
		function removeAlarm(removeAlarm:Object, delMap:Boolean=true):Object;
		/**
		 *添加关联关系
		 * @param rsAlarm 关联关系告警
		 *
		 */
		function addRelationShip(rsAlarm:Object):void;
		/**
		 *更新告警数量
		 * @param level1 告警等级一数量
		 * @param level2 告警等级二数量
		 * @param level3 告警等级三数量
		 * @param level4 告警等级四数量
		 * @param notAck 告警未确认数量
		 * @param notCle 告警未清除数量
		 *
		 */
		function updateAlarmNum(level1:int, level2:int, level3:int, level4:int, notAck:int, notCle:int):void;
		/**
		 *清空窗口数据源
		 *
		 */
		function clearWindowSource():void;
		/**
		 *获取容器数据大小
		 * @return
		 *
		 */
		function get dataArraySize():int;
		/**
		 * 刷新视图
		 * @return
		 *
		 */
		function refresh():Boolean;
		/**
		 *是否对外广播告警增、删、改
		 * @param value
		 *
		 */
		function set isDispatch(value:Boolean):void;
		/**
		 *告警列表
		 * @return
		 *
		 */
		function get dataArray():Array;
		/**
		 *告警等级一数量
		 * @return
		 *
		 */
		function get level1Num():int;
		/**
		 *告警等级二数量
		 * @return
		 *
		 */
		function get level2Num():int;
		/**
		 *告警等级三数量
		 * @return
		 *
		 */
		function get level3Num():int;
		/**
		 *告警等级四数量
		 * @return
		 *
		 */
		function get level4Num():int;
		/**
		 *告警未确认数量
		 * @return
		 *
		 */
		function get notAckNum():int;
		/**
		 *告警未清除数量
		 * @return
		 *
		 */
		function get notCleNum():int;
	}
}