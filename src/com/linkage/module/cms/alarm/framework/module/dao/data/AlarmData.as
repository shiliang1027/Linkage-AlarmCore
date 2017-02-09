package com.linkage.module.cms.alarm.framework.module.dao.data
{
	import mx.collections.ArrayList;

	/**
	 *告警数据DATE
	 * @author mengqiang
	 *
	 */
	public interface AlarmData
	{
		/**
		 * 创建通道
		 *
		 */
		function createChannelSet():void;
		/**
		 * 向WEB订阅告警
		 * @param success 成功时执行方法
		 *
		 */
		function subscribeAlarms(success:Function):void;
		/**
		 *向WEB取消订阅
		 *
		 */
		function unsubscribeAlarms():void;
		/**
		 *注销用户
		 *
		 */
		function deleteUser():void;
		/**
		 *向WEB保持心跳信息
		 * @param success 成功时执行方法
		 *
		 */
		function hearbeat(success:Function):void;
		/**
		 * 保存列顺序
		 * @param params 参数参数
		 */
		function saveColumnOrder(params:Object):void;
		/**
		 *获取资源信息
		 * @param success 成功时执行方法
		 *
		 */
		function getResourceInfo(success:Function):void;
		/**
		 *向WEB注册监听器
		 * @param ruleList 规则列表
		 * @param defColumn 默认展示列
		 * @param success 成功时执行方法
		 *
		 */
		function regListenerAlarm(ruleList:ArrayList, defColumn:String, success:Function):void;
		/**
		 *告警同步
		 * @param params 参数
		 * @param success 成功时执行方法
		 * @param fault 失败时执行方法
		 *
		 */
		function syncAlarm(params:Object, success:Function, fault:Function):void;
		/**
		 *中断同步
		 * @param params 参数
		 * @param success 成功时执行方法
		 * @param fault 失败时执行方法
		 *
		 */
		function shutSync(params:Object, success:Function, fault:Function):void;
		/**
		 *向WEB重载告警
		 * @param viewId 视图ID
		 * @param ruleList 规则列表
		 * @param defColumn 默认展示列
		 * @param success 成功时执行方法
		 *
		 */
		function reloadAlarm(viewId:String, ruleList:ArrayList, defColumn:String, success:Function):void;
	}
}