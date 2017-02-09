package com.linkage.module.cms.alarm.framework.module.server.param
{

	public class AlarmTransTopic
	{
		/**
		 * KEY: 告警TOPIC
		 */
		public static const KEY_MSG_TOPIC:String="msg_topic";
		/**
		 * KEY: 告警同步结束TOPIC
		 */
		public static const KEY_ELH:String="elh";
		/**
		 * KEY: 告警同步异常TOPIC
		 */
		public static const KEY_LHE:String="lhe";
		/**
		 * KEY: 告警预装结束TOPIC
		 */
		public static const KEY_PLE:String="ple";
		/**
		 * KEY: 告警预装出错TOPIC
		 */
		public static const KEY_EPL:String="epl";
		/**
		 * KEY: 告警统计数据TOPIC
		 */
		public static const KEY_AS:String="as";
		/**
		 * KEY: 告警最高等级TOPIC
		 */
		public static const KEY_SL:String="sl";
		/**
		 * KEY: 活动告警:一级告警数量
		 */
		public static const KEY_A1:String="a1";
		/**
		 * KEY: 活动告警:二级告警数量
		 */
		public static const KEY_A2:String="a2";
		/**
		 * KEY: 活动告警:三级告警数量
		 */
		public static const KEY_A3:String="a3";
		/**
		 * KEY: 活动告警:四级告警数量
		 */
		public static const KEY_A4:String="a4";
		/**
		 * KEY: 清除告警:一级告警数量
		 */
		public static const KEY_C1:String="c1";
		/**
		 * KEY: 清除告警:二级告警数量
		 */
		public static const KEY_C2:String="c2";
		/**
		 * KEY: 清除告警:三级告警数量
		 */
		public static const KEY_C3:String="c3";
		/**
		 * KEY: 清除告警:四级告警数量
		 */
		public static const KEY_C4:String="c4";
		/**
		 * KEY: 告警状态:未清除数量
		 */
		public static const KEY_AA:String="aac";
		/**
		 * KEY: 告警状态:未确认数量
		 */
		public static const KEY_NA:String="nac";
		/**
		 * KEY: 操作状态:活动告警增加
		 */
		public static const KEY_OPER_AA:String="aa";
		/**
		 * KEY: 操作状态:活动告警移除
		 */
		public static const KEY_OPER_AR:String="ar";
		/**
		 * KEY: 操作状态:活动告警更新
		 */
		public static const KEY_OPER_AU:String="au";
		/**
		 * KEY: 操作状态:活动告警关联关系
		 */
		public static const KEY_OPER_RS:String="rs";
		/**
		 * KEY: 操作状态:活动告警移动到清除告警
		 */
		public static const KEY_OPER_MT:String="mt";
		/**
		 * KEY: 操作状态:清除告警移除
		 */
		public static const KEY_OPER_CR:String="cr";
		/**
		 * KEY: 操作状态:告警风暴TOPIC
		 */
		public static const KEY_OPER_STORMTOPIC:String="AlarmStorm";
		/**
		 * KEY: 操作状态:告警风暴开始
		 */
		public static const KEY_OPER_STORMSTART:String="start";
		/**
		 * KEY: 操作状态:告警风暴结束
		 */
		public static const KEY_OPER_STORMSTOP:String="stop";
		/**
		 * KEY: 操作状态:开始接受告警
		 */
		public static const KEY_OPER_STARTREV:String="startRev";
	}
}