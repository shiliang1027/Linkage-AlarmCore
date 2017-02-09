package com.linkage.module.cms.alarm.framework.common.util
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.system.rpc.http.HttpUtil;

	import flash.net.URLVariables;

	import mx.rpc.events.FaultEvent;

	/**
	 * 告警操作的工具类
	 * @author mengqiang
	 *
	 */
	public class AlarmOperator
	{
		/**
		 *日志记录器
		 */
		private static var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.common.util.AlarmOperator");

		/**
		 * 捕获处理告警的事件（正对返回的结果）
		 * <发给AC的模块，没有返回值，无法得知确认的结果，只能返回是否掉通，所以返回的结果集，要么false，要么返回确认结果集>
		 * @param url 远程支持的url
		 * @param selectedNums 选中告警数量
		 * @param sessionId 会话id
		 * @param opetation 操作(中文描述)
		 * @param callback 回调方法
		 *
		 */
		public static function handlerAlarmDealOnNoReturnEvent(url:String, selectedNums:int, sessionId:String, opetation:String, callback:Function):void
		{
			log.warn("【手工操作告警】捕获 {0} 事件  num={1}", opetation, selectedNums);
			var params:URLVariables = AlarmUtil.getUrlVariables(url);
			var urlWithoutVars:String = AlarmUtil.getUrlWithoutVariables(url);
			//log.warn("【手工操作告警】 {0} / {1}", urlWithoutVars, params);
			HttpUtil.httpService(sessionId, urlWithoutVars, function(result:Object):void
			{
				// {data:[{alarmuniqueid:'10191827',result:''}]}  
				// 返回值：有异常:false 否则:({'data':{result:'2'}})
				// 其中result: 1:成功; 2：失败; 3：已经处理过
				var message:String = String(result);
				log.warn("【手工操作告警】[操作成功] {0}", opetation);
				if (message == "false")
				{
					AlarmUtil.showMessage(opetation + "告警失败,请稍候重新尝试.", "消息");
					return;
				}
				log.warn("清除返回结果:" + message);
				// 返回的对象
				var returnObj:Object = AlarmUtil.jsonDecode(message);
				var data:Object = returnObj.data;
				var successNum:int = 0;
				var failureNum:int = 0;
				var dealwithNum:int = 0;
				var alarmArray:Array = new Array();
				if (data != null)
				{
					var msg:String = null;
					switch (int(data.result))
					{
						case 1: // 成功
							msg = opetation + "结果:\n\n已处理数量:" + selectedNums;
							break;
						case 2: // 失败
							msg = opetation + "失败:\n\n失败数量:" + selectedNums;
							break;
						default:
							break;
					};
					AlarmUtil.showMessage(msg, "消息");
				}
				else
				{
					AlarmUtil.showMessage(opetation + "失败.\n\n" + message, "Error");
				}
				callback.call(this, alarmArray);
				
			}, params, function(event:FaultEvent):void
			{
				AlarmUtil.showMessage(opetation + "失败.\n\n" + event.fault.faultString);
			}, "text", "POST");
		}

		/**
		 * 捕获处理告警的事件
		 * @param url 远程支持的url
		 * @param selectedNums 选中告警数量
		 * @param sessionId 会话id
		 * @param opetation 操作(中文描述)
		 * @param callback 回调方法
		 *
		 */
		public static function handlerAlarmDealEvent(url:String, selectedNums:int, sessionId:String, opetation:String, callback:Function):void
		{
			log.warn("【手工操作告警】捕获 {0} 事件  num={1}", opetation, selectedNums);
			var params:URLVariables = AlarmUtil.getUrlVariables(url);
			var urlWithoutVars:String = AlarmUtil.getUrlWithoutVariables(url);
			//log.warn("【手工操作告警】 {0} / {1}", urlWithoutVars, params);
			HttpUtil.httpService(sessionId, urlWithoutVars, function(result:Object):void
				{
					// {data:[{alarmuniqueid:'10191827',result:''}]}  
					// 返回值：有异常:false 否则:({'data':[{alarmuniqueid:'10191827',result:'2'}]})
					// 其中result: 1:成功; -1：失败; 2：已经处理过

					var message:String = String(result);
					log.warn("【手工操作告警】[操作成功] {0}", opetation);
					if (message == "false")
					{
						AlarmUtil.showMessage(opetation + "告警失败,请稍候重新尝试.", "消息");
						return;
					}
					log.warn("清除返回结果:" + message);
					// 返回的对象
					var returnObj:Object = AlarmUtil.jsonDecode(message);
					var data:Array = returnObj.data;
					var successNum:int = 0;
					var failureNum:int = 0;
					var dealwithNum:int = 0;
					var alarmArray:Array = new Array();
					if (data != null)
					{
						var msg:String = null;
						data.forEach(function(item:*, index:int, array:Array):void
							{
								switch (int(item.result))
								{
									case 1: // 成功
										successNum++;
										alarmArray.push(item);
										msg = opetation + "成功.";
										break;
									case 2: // 失败
										failureNum++;
										msg = opetation + "失败.";
										break;
									case 3: // 处理
										dealwithNum++;
										msg = "已经" + opetation + ".";
										break;
									default:
										break;
								}
							});

						if (selectedNums == 1)
						{
							AlarmUtil.showMessage(msg, "消息");
						}
						else
						{
							AlarmUtil.showMessage(opetation + "结果:\n\n成功数量:" + successNum + "\n失败数量:" + failureNum + "\n已处理数量:" + dealwithNum);
						}
					}
					else
					{
						AlarmUtil.showMessage(opetation + "失败.\n\n" + message, "Error");
					}
					callback.call(this, alarmArray);

				}, params, function(event:FaultEvent):void
				{
					AlarmUtil.showMessage(opetation + "失败.\n\n" + event.fault.faultString);
				}, "text", "POST");
		}

		/**
		 * 捕获远程HTTP请求事件
		 * @param url
		 * @param sessionId
		 * @param callback
		 *
		 */
		public static function handlerHTTPEvent(url:String, sessionId:String, callback:Function):void
		{
			log.warn("【远程HTTP请求】捕获远程HTTP事件");
			var params:URLVariables = AlarmUtil.getUrlVariables(url);
			var urlWithoutVars:String = AlarmUtil.getUrlWithoutVariables(url);
			//log.info("【远程HTTP请求】 {0} / {1}", urlWithoutVars, params);
			HttpUtil.httpService(sessionId, urlWithoutVars, function(result:Object):void
				{
					if (callback != null)
					{
						callback.call(null, result);
					}
				}, params, function(event:FaultEvent):void
				{
					AlarmUtil.showMessage("操作失败.\n\n" + event.fault.faultString);
				}, "text", "POST");
		}
	}
}