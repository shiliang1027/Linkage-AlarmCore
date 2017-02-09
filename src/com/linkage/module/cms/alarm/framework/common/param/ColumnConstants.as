package com.linkage.module.cms.alarm.framework.common.param
{

	/**
	 *列属性

	 * @author mengqiang
	 *
	 */
	public class ColumnConstants
	{
		/**
		 * KEY: 告警图标列(配置表中配置的key)
		 */
		public static const KEY_AlarmIcon:String="alarmicon";
		/**
		 * KEY: 告警父子标识
		 */
		public static const KEY_ParentFlag:String="parentflag";
		/**
		 * KEY: 集客信息列表
		 */
		public static const KEY_CustomerList:String="customer_list";
		/**
		 * KEY: 告警关联关系规则名称
		 */
		public static const KEY_RuleName:String="rulename";
		/**
		 * KEY: 告警唯一标识
		 */
		public static const KEY_AlarmUniqueId:String="alarmuniqueid";
		/**
		 * KEY: 告警集客名称
		 */
		public static const KEY_GroupCustomer:String="groupcustomer";
		/**
		 * KEY: 业务系统
		 */
		public static const KEY_BusinessSystem:String="businesssystem";
		/**
		 * KEY: 告警集客编号
		 */
		public static const KEY_GroupCustomerId:String="groupcustomerid";
		/**
		 * KEY: 告警集客业务编号
		 */
		public static const KEY_UniqueCustbussId:String="uniquecusbuss_id";
		/**
		 * KEY: 是否CheckBox的标志 (flex 内部拼装的key)
		 */
		public static const KEY_Internal_Checked:String="checked";
		/**
		 * KEY: 告警集客业务编号
		 */
		public static const KEY_CusBussId:String="cusbuss_id";
		/**
		 * KEY: 告警窗口ID
		 */
		public static const KEY_WindowId:String="window_id";
		/**
		 * KEY: 告警发现时间
		 */
		public static const KEY_DalTime:String="daltime";
		/**
		 * KEY: 告警发生时间
		 */
		public static const KEY_EventTime:String="eventtime";
		/**
		 * KEY: 告警清除时间
		 */
		public static const KEY_CancelTime:String="canceltime";
		/**
		 * KEY: 告警清除时间
		 */
		public static const KEY_CancelTimeLabel:String="canceltime_label";
		/**
		 * KEY: 影响客户数
		 */
		public static const KEY_EffectUser:String="effectuser";
		/**
		 * KEY: 告警确认时间
		 */
		public static const KEY_AckTime:String="acktime";
		/**
		 * KEY: 告警正文
		 */
		public static const KEY_AlarmText:String="alarmtext";
		/**
		 * KEY: 告警未读标识
		 */
		public static const KEY_ReadFlag:String="readflg";
		/**
		 * KEY: 是否是异常告警
		 * 1:是
		 * 2:否
		 */
		public static const KEY_Ifabnormal:String="ifabnormal";
		/**
		 * KEY: 告警对象工程状态
		 * -1：在网
		 * 1：工程
		 * 2：在网
		 * 3：在网
		 */
		public static const KEY_LocateNeStatus:String="locatenestatus";
		/**
		 * KEY: 告警清除状态
		 * 0：网元自动清除
		 * 1：活动告警
		 * 2：同步清除
		 * 3：手工清除
		 */
		public static const KEY_AlarmStatus:String="alarmstatus";
		/**
		 * KEY: 告警基站类型
		 */
		public static const KEY_AlarmBtsType:String="btstype";
		/**
		 * KEY: 告警子类型
		 */
		public static const KEY_AlarmSubType:String="alarmsubtype";
		/**
		 * KEY: 告警确认状态
		 * 0：未确认
		 * 1：自动确认
		 * 2：手工确认
		 */
		public static const KEY_AckFlag:String="ackflag";
		/**
		 * KEY: 告警类别
		 * 1：设备告警
		 * 2：性能告警
		 */
		public static const KEY_NmsAlarmType:String="nmsalarmtype";
		/**
		 * KEY: 是否需要上报集团
		 * 0：不需要上报
		 * 1：需要上报
		 */
		public static const KEY_SendGroupFlag:String="sendgroupflag";
		/**
		 * KEY: 关联标识
		 * 0：无关联告警
		 * 1：有关联告警
		 */
		public static const KEY_RelatedFlag:String="relatedflag";
		/**
		 * KEY: 对告标志
		 * 0：产生告警无对应清除告警；
		 * 1：产生告警有对应清除告警；
		 */
		public static const KEY_CorrelateAlarmFlag:String="correlatealarmflag";
		/**
		 * KEY: 集团客户告警标志
		 * 0：无集客告警
		 * 1：集客告警
		 */
		public static const KEY_CustomerFlag:String="customerflag";
		/**
		 * KEY: 派单状态
		 * 0、未派单
		 * 1、等待派单
		 * 2、人工中止派单（指人为判断不需要派单而中止派单）
		 * 3、系统抑制派单（如通过自动关联分析不对告警派单）
		 * 4、派单失败
		 * 5、自动派单成功
		 * 6、手工派单成功
		 */
		public static const KEY_SheetSendStatus:String="sheetsendstatus";
		/**
		 * KEY: 工单状态
		 * 0．等待处理
		 * 1. 一级处理中
		 * 2. 二级处理中
		 * 3. 三级处理中
		 * 4. 工单确认
		 * 5. 等待审批
		 * 6. 待归档
		 * 7. 已归档
		 */
		public static const KEY_SheetStatus:String="sheetstatus";
		/**
		 * KEY: 智能预处理状态

		 * 0：未匹配规则
		 * 1：待处理
		 * 2：处理中
		 * 3：处理成功
		 * 4：处理失败
		 * 5: 智能预处理抑制
		 */
		public static const KEY_AutoDealState:String="autodealstatus";
		/**
		 * KEY: 智能预处理类型
		 * 0:全自动
		 * 1:交互式
		 */
		public static const KEY_AutoDealType:String="autodealtype";
		/**
		 * KEY: 业务质量级别  (存在于集客告警表中:ta_realalarm_cust)
		 * 1 ：钻石服务
		 * 2 ：金牌服务
		 * 3 ：银牌服务
		 * 4 ：铜牌服务
		 * 5 ：标准服务
		 */
		public static const KEY_BusinessLevel:String="businesslevel";
		/**
		 * KEY: 专业
		 * 对应专业ID
		 */
		public static const KEY_Specialty:String="specialty";
		/**
		 * KEY: 专业中文描述
		 */
		public static const KEY_SpecialtyLabel:String="specialty_label";
		/**
		 * KEY: 网管告警级别
		 */
		public static const KEY_AlarmSeverity:String="alarmseverity";
		/**
		 * KEY: 网管告警级别中文描述
		 */
		public static const KEY_AlarmSeverityLabel:String="alarmseverity_label";
		/**
		 * KEY: 网管告警级别中文描述
		 */
		public static const KEY_JT_AlarmSeverityLabel:String="jt_alarmseverity_label";
		
		/**
		 * KEY: 网管告警级别颜色描述
		 */
		public static const KEY_AlarmSeverityColorLabel:String="alarmseverity_color_label";
		
		/**
		 * KEY: 网管告警级别颜色描述
		 */
		public static const KEY_JT_AlarmSeverityColorLabel:String="jt_alarmseverity_color_label";
		/**
		 * KEY: 自定义告警级别
		 */
		public static const KEY_AlarmEmergency:String="emergency_severity";
		/**
		 * KEY: 自定义告警级别中文描述
		 */
		public static const KEY_AlarmEmergencyLabel:String="emergency_severity_label";
		/**
		 * KEY: 自定义告警级别颜色描述
		 */
		public static const KEY_AlarmEmergencyColorLabel:String="emergency_severity_color_label";
		/**
		 * KEY: 设备类型
		 */
		public static const KEY_EquipmentClass:String="equipmentclass";
		/**
		 * KEY: 省
		 */
		public static const KEY_AlarmProvince:String="alarmprovince";
		/**
		 * KEY: 告警地区
		 */
		public static const KEY_AlarmRegion:String="alarmregion";
		/**
		 * KEY: 县
		 */
		public static const KEY_AlarmCounty:String="alarmcounty";
		/**
		 * KEY: 客户级别  (存在于集客告警表中:ta_realalarm_cust)
		 */
		public static const KEY_CustomerClass:String="customerclass";
		/**
		 * KEY: 关联关系(flex 内部拼装的key)
		 */
		public static const KEY_RelationType:String="relationtype";
		/**
		 * KEY: 告警来源
		 */
		public static const KEY_SystemName:String="systemname";
		/**
		 * KEY: 厂家标识
		 */
		public static const KEY_Vendor:String="vendor";
		/**
		 * 告警字段中数字列
		 */
		public static const NUMBER_COLUMNS:Array=[KEY_EffectUser, KEY_EventTime, KEY_DalTime, KEY_CancelTime, KEY_AckTime, KEY_LocateNeStatus, KEY_AlarmStatus, KEY_AckFlag, KEY_NmsAlarmType, KEY_SendGroupFlag, KEY_RelatedFlag, KEY_CorrelateAlarmFlag, KEY_CustomerFlag, KEY_SheetSendStatus, KEY_SheetStatus, KEY_AutoDealState, KEY_AutoDealType, KEY_BusinessLevel];
		/**
		 * 告警字段中的分组列(字段重复几率非常高的列)
		 */
		public static const GROUP_COLUMNS:Array=[KEY_LocateNeStatus, KEY_AlarmStatus, KEY_AckFlag, KEY_Specialty, KEY_NmsAlarmType, KEY_SendGroupFlag, KEY_RelatedFlag, KEY_AlarmProvince, KEY_AlarmRegion, KEY_AlarmCounty, KEY_CorrelateAlarmFlag, KEY_CustomerFlag, KEY_SheetSendStatus, KEY_SheetStatus, KEY_AutoDealState, KEY_AutoDealType, KEY_CustomerClass, KEY_BusinessLevel, KEY_RelationType, KEY_SystemName, KEY_Vendor];
	}
}