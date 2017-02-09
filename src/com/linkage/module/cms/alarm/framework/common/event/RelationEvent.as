package com.linkage.module.cms.alarm.framework.common.event
{
	import flash.events.Event;

	/**
	 *告警事件
	 * @author mengqiang
	 *
	 */
	public class RelationEvent extends Event
	{
		/**
		 * 告警事件: 关联告警新增
		 */
		public static const Relation_Alarm_Add:String="relation_alarm_add";
		/**
		 * 告警事件: 关联告警重增
		 */
		public static const Relation_Alarm_ReAdd:String="relation_alarm_readd";
		/**
		 * 告警事件: 关联告警更新
		 */
		public static const Relation_Alarm_Update:String="relation_alarm_update";
		/**
		 * 告警事件: 关联告警移除
		 */
		public static const Relation_Alarm_Remove:String="relation_alarm_remove";
		/**
		 *告警对象
		 */
		private var _alarm:Object=null;
		/**
		 *告警唯一
		 */
		private var _uniqueId:String=null;
		/**
		 *父告警对象
		 */
		private var _pAlarm:Object=null;

		public function RelationEvent(type:String, uniqueId:String, alarm:Object=null, pAlarm:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_alarm=alarm;
			_pAlarm=pAlarm;
			_uniqueId=uniqueId;
		}

		public function get alarm():Object
		{
			return _alarm;
		}

		public function get uniqueId():String
		{
			return _uniqueId;
		}

		public function get pAlarm():Object
		{
			return _pAlarm;
		}
	}
}