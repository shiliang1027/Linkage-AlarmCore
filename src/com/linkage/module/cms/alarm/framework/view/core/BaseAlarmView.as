package com.linkage.module.cms.alarm.framework.view.core
{
	import com.linkage.module.cms.alarm.framework.common.grid.AlarmDataGrid;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.linkage.module.cms.alarm.framework.module.server.source.ICollection;
	import com.linkage.module.cms.alarm.framework.module.server.source.TreeCollectionView;
	import com.linkage.module.cms.alarm.framework.view.toolstate.ToolBar;
	import com.linkage.system.structure.map.Map;
	
	import flash.display.DisplayObject;
	
	import spark.components.Label;

	public interface BaseAlarmView
	{
		function showFilterAlarm():void;
		function get alarmsAC():ICollection;
		function lockAlarmView(lock:Boolean):void;

		function get getParentApplication():DisplayObject;
		function headerFilterAlarm(value:String):void;
		function clearCheckBoxMap():void;
		function get getToolBar():ToolBar;
		function get refreshViewType():int;
		function refreshFilterView():void;
		function set columns(array:Array):void;
		function set doubleClick(doubleClick:Function):void;

		function refresh():void;
		function showAllAlarm():void;
		function get windowType():int;
		function columnIconShow():void;
		function get windowId():String;
		function get checkAlarmMap():Map;
		function get windowUniquekey():String;
		function get alarmAction():AlarmAction;
		function get getFlowAlarm():AlarmDataGrid;
		function get alarmsView():TreeCollectionView;
		function get getVTitle():Label;
	}
}