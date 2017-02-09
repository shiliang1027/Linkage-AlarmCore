package com.linkage.module.cms.alarm.framework
{

	public class AlarmContainer
	{
		/**
		 * 参数KEY: 传入参数信息
		 */
		public static const PARAMKEY_MAPINFO:String="mapInfo";
		/**
		 * 参数KEY: 会话id
		 */
		public static const PARAMKEY_SESSIONID:String="sessionId";
		/**
		 * 参数KEY: UUID
		 */
		public static const PARAMKEY_UUID:String="uuid";
		/**
		 * 参数KEY: 上下文路径
		 */
		public static const PARAMKEY_CONTEXT:String="context";
		/**
		 * 参数KEY: 域id
		 */
		public static const PARAMKEY_AREAID:String="areaId";
		/**
		 * 参数KEY: 模块key
		 */
		public static const PARAMKEY_VIEWID:String="viewId";
		/**
		 * 参数KEY: 模块key
		 */
		public static const PARAMKEY_MODULEKEY:String="moduleKey";
		/**
		 * 参数KEY: 窗口模块key
		 */
		public static const PARAMKEY_WINMODULEKEY:String="winModuleKey";
		/**
		 * 参数KEY: 窗口名称
		 */
		public static const PARAMKEY_WINDOWNAME:String="windowName";
		/**
		 * 参数KEY: 模块规则内容
		 */
		public static const PARAMKEY_RULECONTENT:String="ruleContent";
		/**
		 * 参数KEY: 是否加载规则
		 */
		public static const PARAMKEY_ISLOADRULE:String="isLoadRule";
		/**
		 * 参数KEY: 扩展内容
		 */
		public static const PARAMKEY_EX_INFO:String="ex_info";
		
		/**
		 * 参数KEY: 扩展内容
		 * 全量告警，规则告警
		 */
		public static const PARAMKEY_RULETOPO:String="ruleTopo";
		/**
		 * 参数KEY: 模块规则KEY
		 */
		public static const PARAMKEY_RULE:String="rule";
		/**
		 * 参数KEY: 是否本地调试
		 */
		public static const PARAMKEY_LOCAL:String="local";
		/**
		 * 参数KEY: 默认展示列
		 */
		public static const PARAMKEY_DISPLAYCOLUMN:String="defaultDisplay";
		/**
		 * 参数KEY: 权限内告警状态json
		 */
		public static const PARAMKEY_STATEJSON:String="stateJson";
		/**
		 * 参数KEY: 窗口json
		 */
		public static const PARAMKEY_WINJSON:String="winJson";
		/**
		 * 参数KEY: 视图json
		 */
		public static const PARAMKEY_VIEWJSON:String="viewJson";
		/**
		 * 参数KEY: 权限内告警字段列json
		 */
		public static const PARAMKEY_ALARMCOLUMNJSON:String="alarmColumnJson";
		/**
		 * 参数KEY: 权限工具条json
		 */
		public static const PARAMKEY_TOOLJSON:String="toolJson";
		/**
		 * 参数KEY: 声音配置json
		 */
		public static const PARAMKEY_VOICECONFIG:String="voiceConfigJson";
		/**
		 * 参数KEY: 权限内菜单json
		 */
		public static const PARAMKEY_MENUJSON:String="menuJson";
		/**
		 * Flex内部KEY: 是否锁定的标志 (flex 内部拼装的key)
		 */
		public static const INTERNALKEY_LOCKED:String="_locked";
		/**
		 * 属性: 一级告警
		 */
		public static const PROPERTY_LEVEL1:String="1";
		/**
		 * 属性: 二级告警
		 */
		public static const PROPERTY_LEVEL2:String="2";
		/**
		 * 属性: 三级告警
		 */
		public static const PROPERTY_LEVEL3:String="3";
		/**
		 * 属性: 四级告警
		 */
		public static const PROPERTY_LEVEL4:String="4";
		/**
		 * 告警统计KEY: 一级
		 */
		public static const ALARMSTAT_LEVEL1:String="level1Num";
		/**
		 * 告警统计KEY: 二级
		 */
		public static const ALARMSTAT_LEVEL2:String="level2Num";
		/**
		 * 告警统计KEY: 三级
		 */
		public static const ALARMSTAT_LEVEL3:String="level3Num";
		/**
		 * 告警统计KEY: 四级
		 */
		public static const ALARMSTAT_LEVEL4:String="level4Num";
		/**
		 * 告警统计KEY: 未确认
		 */
		public static const ALARMSTAT_NOTACK:String="notAckNum";
		/**
		 * 告警统计KEY: 未清除
		 */
		public static const ALARMSTAT_NOTCLE:String="notCleNum";
		/**
		 * 菜单类型: 外部事件 URL型:弹出页面
		 */
		public static const MENU_TYPE_URL:String="url";
		/**
		 * 菜单类型: 外部事件 URL型:带param的弹出页面
		 */
		public static const MENU_TYPE_URLWITHPARAM:String="url_param";
		/**
		 * 菜单类型: 外部事件 JS POST提交
		 */
		public static const MENU_TYPE_JSPOST:String="jspost";
		/**
		 * 菜单类型: 外部事件 URL型:自身替换
		 */
		public static const MENU_TYPE_MSG:String="msg";
		/**
		 * 菜单类型: 调用外部JS方法
		 */
		public static const MENU_TYPE_FUNC:String="func";
		/**
		 * 菜单类型: 内部事件 关键字型
		 */
		public static const MENU_TYPE_KEY:String="key";
		/**
		 * 菜单类型: 外部事件 关键字型
		 */
		public static const MENU_TYPE_EVENT:String="event";
	}
}