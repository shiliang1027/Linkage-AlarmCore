package com.linkage.module.cms.alarm.framework.module.server
{
	import com.linkage.module.cms.alarm.framework.module.server.source.ICollection;

	/**
	 *告警Server
	 * @author mengqiang
	 *
	 */
	public interface AlarmServer
	{
		/**
		 *初始化窗口数据池
		 *
		 */
		function initWindowSource():void;
		/**
		 *清空窗口数据源
		 *
		 */
		function clearWindowSource():void;
		/**
		 *开始心跳定时器
		 *
		 */
		function startHearbeatTime():void;
		/**
		 *取消心跳定时器
		 *
		 */
		function clearHearbeatTime():void;
		/**
		 *处理告警信息
		 * @param alarmObj 告警对象
		 */
		function handlerAlarm(alarmObj:Object):void;
		/**
		 *通过窗口ID获取告警数
		 * @param windowId 窗口ID
		 * @return
		 *
		 */
		function getAlarmNumByWindowId(windowId:String):int;
		/**
		 * 设置声音状态
		 * @param windowId 窗口ID
		 * @param enabled 窗口状态
		 * @return
		 */
		function soundEnabled(windowId:String, enabled:Boolean):void;
		/**
		 * 获取数据源
		 * @param windowId 窗口ID
		 * @param windowType 窗口类型 1:活动窗口 0:清除窗口
		 * @return
		 *
		 */
		function alarmSource(windowId:String, windowType:int):ICollection;
	}
}