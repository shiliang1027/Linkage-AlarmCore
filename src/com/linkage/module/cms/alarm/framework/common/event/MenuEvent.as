package com.linkage.module.cms.alarm.framework.common.event
{
	import flash.events.Event;

	import mx.controls.listClasses.BaseListData;

	/**
	 * 菜单事件
	 * @author mengqiang
	 *
	 */
	public class MenuEvent extends Event
	{
		/**
		 * 菜单事件: AlarmMenuEvent_loadTGAlarm
		 */
		public static const AlarmMenuEvent_LoadTGAlarm:String = "AlarmMenuEvent_LoadTGAlarm";
		
		/**
		 * 菜单事件: 告警DEBUG事件
		 */
		public static const AlarmMenuEvent_DEBUG:String = "AlarmMenuEvent_DEBUG";
		/**
		 * 菜单事件: 拷贝表格CELL内容
		 */
		public static const AlarmMenuEvent_COPYCELL:String = "AlarmMenuEvent_COPYCELL";
		/**
		 * 菜单事件: HTTP请求并提示
		 */
		public static const AlarmMenuEvent_HttpTips:String = "AlarmMenuEvent_HttpTips";
		/**
		 * 菜单事件: 确认告警
		 */
		public static const AlarmMenuEvent_AckAlarm:String = "AlarmMenuEvent_AckAlarm";
		/**
		 * 菜单事件: 确认督办
		 */
		public static const AlarmMenuEvent_InspectAlarm:String = "AlarmMenuEvent_InspectAlarm";
		/**
		 * 菜单事件: 清除告警
		 */
		public static const AlarmMenuEvent_ClearAlarm:String = "AlarmMenuEvent_ClearAlarm";
		/**
		 * 菜单事件: 手工派单
		 */
		public static const AlarmMenuEvent_HandTransfer:String = "AlarmMenuEvent_HandTransfer";
		/**
		 * 菜单事件: HTTP请求并弹出
		 */
		public static const AlarmMenuEvent_HandlerHttpOpen:String = "AlarmMenuEvent_HandlerHttpOpen";
		/**
		 * 菜单事件：手工派单
		 */
		public static const AlarmMenuEvent_HandSendSheet:String = "AlarmMenuEvent_HandSendSheet";
		/**
		 * 菜单事件: 工程详情
		 */
		public static const AlarmMenuEvent_WORKSTATUS_DETAIL:String = "AlarmMenuEvent_WORKSTATUS_DETAIL";
		/**
		 * 菜单事件: 手工工程标注
		 */
		public static const AlarmMenuEvent_WORKSTATUS_HANDCHANGE:String = "AlarmMenuEvent_WORKSTATUS_HANDCHANGE";
		//告警追加至指定工单
		public static const AlarmMenuEvent_HandSendSheed_Append:String = "AlarmMenuEvent_HandSendSheed_Append";
		/**
		 *告警列对象
		 */
		private var _listData:BaseListData = null;
		/**
		 *选中数

		 */
		private var _selectedNums:int = 0;
		/**
		 *告警对象
		 */
		private var _data:Object = null;
		/**
		 *请求URL
		 */
		private var _url:String = null;

		public function MenuEvent(type:String, data:Object = null, listData:BaseListData = null, selectedNums:int = 0, url:String = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_selectedNums = selectedNums;
			_listData = listData;
			_data = data;
			_url = url;
		}

		//告警列对象

		public function get listData():BaseListData
		{
			return _listData;
		}

		//选中的数
		public function get selectedNums():int
		{
			return _selectedNums;
		}

		//告警对象
		public function get data():Object
		{
			return _data;
		}

		//URL
		public function get url():String
		{
			return _url;
		}
	}
}