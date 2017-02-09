package com.linkage.module.cms.alarm.framework.common.event
{
	import flash.events.Event;

	/**
	 * 告警视图事件
	 * @author mengqiang
	 *
	 */
	public class AlarmViewEvent extends Event
	{
		/**
		 *告警视图锁定
		 */
		public static const VIEW_LOCKED:String="viewLocked";
		/**
		 *告警视图接受
		 */
		public static const VIEW_REVSTART:String="startRev";
		/**
		 * 刷新视图
		 */
		public static const REFRESH_VIEW:String="refresh_view";
		/**
		 * 视图创建完成
		 */
		public static const VIEW_CREATED:String="view_created";
		/**
		 *告警同步结束
		 */
		public static const ALARM_SYNC_ELH:String="alarm_sync_elh";
		/**
		 *告警同步异常
		 */
		public static const ALARM_SYNC_LHE:String="alarm_sync_lhe";
		/**
		 *告警预装结束
		 */
		public static const ALARM_LOAD_PLE:String="alarm_load_ple";
		/**
		 *告警预装异常
		 */
		public static const ALARM_LOAD_EPL:String="alarm_load_epl";
		/**
		 * 视图告警新增
		 */
		public static const VIEW_ALARM_ADD:String="view_alarm_add";
		/**
		 * 视图告警移除
		 */
		public static const VIEW_ALARM_REMOVE:String="view_alarm_remove";
		/**
		 * 视图告警更新
		 */
		public static const VIEW_ALARM_UPDATE:String="view_alarm_update";
		/**
		 * 视图告警重载
		 */
		public static const VIEW_ALARM_RELOAD:String="view_alarm_reload";
		/**
		 * 视图关联关系
		 */
		public static const VIEW_ALARM_RELATION:String="view_alarm_relation";
		/**
		 *是否通知
		 */
		private var _isDispatch:Boolean=false;
		/**
		 *告警父对象
		 */
		private var _ptAlarm:Object=null;
		/**
		 *告警对象
		 */
		private var _alarm:Object=null;

		public function AlarmViewEvent(type:String, alarm:Object=null, ptAlarm:Object=null, isDispatch:Boolean=false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_isDispatch=isDispatch;
			_ptAlarm=ptAlarm;
			_alarm=alarm;
		}

		public function get isDispatch():Boolean
		{
			return _isDispatch;
		}

		public function get ptAlarm():Object
		{
			return _ptAlarm;
		}

		public function get alarm():Object
		{
			return _alarm;
		}
	}
}