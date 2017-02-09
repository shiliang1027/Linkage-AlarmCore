package com.linkage.module.cms.alarm.framework.module.server.core
{
	
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.common.event.AlarmViewEvent;
	import com.linkage.module.cms.alarm.framework.common.event.MenuEvent;
	import com.linkage.module.cms.alarm.framework.common.event.SoundEvent;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmOperator;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.module.cms.alarm.framework.controller.AlarmAction;
	import com.linkage.module.cms.alarm.framework.controller.fo.AlarmParamFo;
	import com.linkage.module.cms.alarm.framework.module.server.param.AlarmTransTopic;
	import com.linkage.module.cms.alarm.framework.module.server.source.ICollection;
	import com.linkage.system.rpc.http.HttpUtil;
	
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.events.FaultEvent;

	/**
	 *窗口控制器
	 * @author mengqiang
	 *
	 */
	public class WindowController
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.module.server.core.WindowController");
		/**
		 *活动窗口类型：1
		 */
		protected var _windowTypeAct:int = 1;
		/**
		 *清除窗口类型：0
		 */
		protected var _windowTypeCle:int = 0;
		/**
		 *当前窗口ID
		 */
		protected var _windowId:String = null;
		/**
		 *视图创建验证次数
		 */
		protected var _viewCreatedCheckNum:int = 0;
		/**
		 *声音状态
		 */
		protected var _soundEnabled:Boolean = true;
		/**
		 * 告警临时缓存
		 */
		protected var _cacheAlarmArray:Array = null;
		/**
		 *是否刷新试图
		 */
		protected var _isRefreshView:Boolean = false;
		/**
		 *视图创建完成
		 */
		protected var _isViewCreated:Boolean = false;
		/**
		 *告警控制类
		 */
		protected var _alarmAction:AlarmAction = null;
		/**
		 *定时处理告警
		 */
		private var _dealTimer:Timer = new Timer(700);
		/**
		 *告警初始化参数
		 */
		protected var _alarmParamFo:AlarmParamFo = null;
		[Bindable]
		/**
		 *活动告警容器
		 */
		protected var _activeAlarmSource:ICollection = null;
		[Bindable]
		/**
		 *清除告警容器
		 */
		protected var _clearAlarmSource:ICollection = null;

		public function WindowController(windowId:String, alarmAction:AlarmAction, collectClass:Class)
		{
			//1.初始化告警参数
			_windowId = windowId;
			_alarmAction = alarmAction;
			_cacheAlarmArray = new Array();
			_alarmParamFo = alarmAction.alarmParamFo;
			_dealTimer.addEventListener(TimerEvent.TIMER, dealAlarmTimer);
			_dealTimer.start();

			//2.初始化告警容器
			initAlarmSource(collectClass);

			//3.初始化菜单事件
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_LoadTGAlarm, handler_LoadTGAlarm);
			alarmAction.addEventListener(windowId + AlarmViewEvent.VIEW_LOCKED, checkAlarm);
			alarmAction.addEventListener(windowId + AlarmViewEvent.VIEW_CREATED, viewCreated);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_DEBUG, alarmDebug);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_COPYCELL, handler_CopyCell);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_HttpTips, handlerAlarmMenuEventTips);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_AckAlarm, handlerAlarmMenuEventAckAlarm);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_InspectAlarm, handlerAlarmMenuEventInspectAlarm);
			//alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_HandTransfer, handlerAlarmHandTransfer);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_HandSendSheet, AlarmMenuEvent_HandSendSheet);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_ClearAlarm, handlerAlarmMenuEventClearAlarm);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_HandTransfer, handTransferMenuEventAckAlarm);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_HandlerHttpOpen, handlerAlarmMenuEventHttpOpen);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_WORKSTATUS_DETAIL, handlerAlarmMenuEventWorkStatusDetail);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_WORKSTATUS_HANDCHANGE, handlerAlarmMenuEventWorkStatusHandChange);
			alarmAction.addEventListener(windowId + MenuEvent.AlarmMenuEvent_HandSendSheed_Append,handSendSheedAppend);
		}
		
		protected function handSendSheedAppend(event:MenuEvent):void
		{
			var alarmuniqueids:String = event.url.substring(event.url.indexOf("=")+1,event.url.length);
			ExternalInterface.call('sheetHandAppend1Window', alarmuniqueids);
		}
		
		//验证告警
		protected function checkAlarm(event:AlarmViewEvent):void
		{
			_activeAlarmSource.checkAlarm();
		}

		//告警DEBUG事件
		private function alarmDebug(event:MenuEvent):void
		{
			var alarm:Object = event.data;
			if (alarm != null)
			{
				var msg:String = "";
				for (var key:String in alarm)
				{
					msg += key + ":" + alarm[key] + "\n";
				}
				AlarmUtil.showMessage(msg);
			}
		}

		//初始化告警容器
		public function initAlarmSource(collectClass:Class):void
		{
			_activeAlarmSource = new collectClass(_windowId, _windowTypeAct, _alarmAction);
			_clearAlarmSource = new collectClass(_windowId, _windowTypeCle, _alarmAction);
		}

		//捕获 cell拷贝
		public function handler_CopyCell(event:MenuEvent):void
		{
			log.info("[内部菜单操作] CopyCell");
			if (event.listData)
			{
				System.setClipboard(event.listData.label);
			}
			else
			{
				System.setClipboard("请先选择CELL");
			}
		}

		public function handler_LoadTGAlarm(event:MenuEvent):void
		{
			//AlarmUtil.showMessage("操作成功", "消息");
			log.warn(event.url);
			var urlWithoutVars:String = AlarmUtil.getUrlWithoutVariables(event.url);
			var params:URLVariables = AlarmUtil.getUrlVariables(event.url);
			log.warn("urlWithoutVars=" + urlWithoutVars + ",params=" + params);
			HttpUtil.httpService(_alarmParamFo.sessionId, urlWithoutVars, function(result:Object):void
			{
				log.warn("....");
				AlarmUtil.showMessage("操作成功", "消息");
			}, params, function(event:FaultEvent):void
			{
				AlarmUtil.showMessage("操作失败.\n\n" + event.fault.faultString);
			}, "text", "POST");
		}
		public function handlerAlarmHandTransfer(event:MenuEvent):void
		{
			log.warn("工单手工移交...");
			log.warn(event.url);
			var urlWithoutVars:String = AlarmUtil.getUrlWithoutVariables(event.url);
			var params:URLVariables = AlarmUtil.getUrlVariables(event.url);
			log.warn("urlWithoutVars=" + urlWithoutVars + ",params=" + params);
			HttpUtil.httpService(_alarmParamFo.sessionId, urlWithoutVars, function(result:Object):void
			{
				log.warn("....");
				AlarmUtil.showMessage("操作成功", "消息");
			}, params, function(event:FaultEvent):void
			{
				AlarmUtil.showMessage("工单手工移交失败.\n\n" + event.fault.faultString);
			}, "text", "POST");
		}
		
		//手工派单
		public function AlarmMenuEvent_HandSendSheet(event:MenuEvent):void
		{
			log.warn("手工派单...");
			log.warn(event.url);
			var urlWithoutVars:String = AlarmUtil.getUrlWithoutVariables(event.url);
			var params:URLVariables = AlarmUtil.getUrlVariables(event.url);
			log.warn("urlWithoutVars=" + urlWithoutVars + ",params=" + params);
			HttpUtil.httpService(_alarmParamFo.sessionId, urlWithoutVars, function(result:Object):void
			{
				log.warn("....");
				AlarmUtil.showMessage("操作成功", "消息");
			}, params, function(event:FaultEvent):void
			{
				AlarmUtil.showMessage("手工派单失败.\n\n" + event.fault.faultString);
			}, "text", "POST");
		}

		//捕获菜单事件 确认督办
		public function handlerAlarmMenuEventInspectAlarm(event:MenuEvent):void
		{
			AlarmOperator.handlerAlarmDealOnNoReturnEvent(event.url, event.selectedNums, _alarmParamFo.sessionId, "确认督办", function(alarmArray:Array):void
			{
				log.warn("捕获菜单事件 确认督办");
				//dealWitchHandlerAckAlarm(alarmArray);
			});
		}

		//捕获菜单事件 确认告警
		public function handlerAlarmMenuEventAckAlarm(event:MenuEvent):void
		{
			AlarmOperator.handlerAlarmDealEvent(event.url, event.selectedNums, _alarmParamFo.sessionId, "确认告警", function(alarmArray:Array):void
				{
					log.warn("捕获菜单事件 确认告警");
				//dealWitchHandlerAckAlarm(alarmArray);
				});
		}

		//处理手工确认告警
		private function dealWitchHandlerAckAlarm(alarmArray:Array):void
		{
			//1.更新告警确认字段
			alarmArray.forEach(function(alarm:Object, index:int, array:Array):void
				{
					updateAlarm(alarm);
				});

			//2.通知视图刷新页面
			_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.REFRESH_VIEW));
		}

		//捕获菜单事件 手工派单
		public function handTransferMenuEventAckAlarm(event:MenuEvent):void
		{
			var alarmuniqueids:String = event.url.substring(event.url.indexOf("=")+1,event.url.length);
			var length:Number = alarmuniqueids.split(";").length;
			//山东单条告警不提示
			if(length<=1)
			{
				handlerSheet("逐条派单",event.url,_alarmParamFo.sessionId,alarmuniqueids);
				return;
			}			
			AlarmUtil.showMessage("您是否对"+(length>1?(length-1):length)+"条告警逐条派单！", "提示", Alert.OK | Alert.CANCEL, null, function(ce:CloseEvent):void
			{
				if (ce.detail == Alert.OK)
				{
					handlerSheet("逐条派单",event.url,_alarmParamFo.sessionId,alarmuniqueids);
				}
			});
		}
		
		//捕获菜单事件 清除告警
		public function handlerAlarmMenuEventClearAlarm(event:MenuEvent):void
		{
			AlarmUtil.showMessage("您是否确定清除告警！", "提示", Alert.OK | Alert.CANCEL, null, function(ce:CloseEvent):void
				{
					if (ce.detail == Alert.OK)
					{
						AlarmOperator.handlerAlarmDealEvent(event.url, event.selectedNums, _alarmParamFo.sessionId, "清除告警", function(alarmArray:Array):void
							{
								log.warn("捕获菜单事件 清除告警长度:" + alarmArray.length);
//								//1.处理告警
//								alarmArray.forEach(function(alarm:Object, index:int, array:Array):void
//									{
//										dealWitchHandlerClearAlarmTest(alarm);
//									});
//								//2.通知视图刷新页面
//								_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.REFRESH_VIEW));
							});
					}
				});
		}

		//处理手工清除告警
		private function dealWitchHandlerClearAlarmTest(alarm:Object):void
		{
			//1.更新告警清除字段
			updateAlarm(alarm);

			//2.移除活动告警到清除告警
			moveActiveToClearAlarm(alarm);
		}

		//处理手工清除告警
		private function dealWitchHandlerClearAlarm(alarm:Object):void
		{
			//1.更新告警清除字段
			updateAlarm(alarm);

			//2.移除活动告警到清除告警
			var udAlarm:Object = _activeAlarmSource.getAlarmByAlarmId(alarm[ColumnConstants.KEY_AlarmUniqueId]);
			if (udAlarm != null)
			{
				if (udAlarm is Array)
				{
					var alarmArray:Array = udAlarm as Array;
					for each (var malarm:Object in alarmArray)
					{
						if (AlarmUtil.checkTreeAllClearAlarm(malarm))
						{
							var topAlarm:Object = AlarmUtil.findTopParentAlarm(malarm);
							moveActiveToClearAlarm(topAlarm);
						}
					}
				}
				else
				{
					if (AlarmUtil.checkTreeAllClearAlarm(udAlarm))
					{
						var tpAlarm:Object = AlarmUtil.findTopParentAlarm(udAlarm);
						moveActiveToClearAlarm(tpAlarm);
					}
				}
			}

			//3.通知视图刷新页面
			_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.REFRESH_VIEW));
		}

		//捕获菜单事件 手工工程标注
		private function handlerAlarmMenuEventWorkStatusHandChange(event:MenuEvent):void
		{
			AlarmOperator.handlerAlarmDealEvent(event.url, event.selectedNums, _alarmParamFo.sessionId, "手工工程标注", function(alarmArray:Array):void
				{
					log.warn("捕获菜单事件 手工工程标注");
					//1.更新告警清除字段
					alarmArray.forEach(function(alarm:Object, index:int, array:Array):void
						{
							updateAlarm(alarm);
						});

					//2.通知视图刷新页面
					_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.REFRESH_VIEW));
				});
		}

		// 捕获菜单事件 工程查看
		private function handlerAlarmMenuEventWorkStatusDetail(event:MenuEvent):void
		{
			AlarmOperator.handlerHTTPEvent(event.url, _alarmParamFo.sessionId, function(result:Object):void
				{
					var message:String = String(result);
					log.warn("捕获菜单事件 工程查看 {0}", message);
					// {'alarmuniqueid':'nanjing|126848945','msg':'手工工程标注失败','result':'2','url':''}
					// 返回的对象
					var returnObj:Object = AlarmUtil.jsonDecode(message);
					// 1:成功; 2:失败
					if (int(returnObj.result) == 1)
					{
						// 成功
						AlarmUtil.openUrl(returnObj.url);
					}
					else
					{
						// 失败
						if (System.useCodePage)
						{
							AlarmUtil.showMessage(returnObj.msg, "消息");
						}
						else
						{
							AlarmUtil.showMessage(AlarmUtil.encodeUtf8(returnObj.msg), "消息");
						}
					}
				});
		}

		// 捕获菜单事件 http请求并直接弹出
		private function handlerAlarmMenuEventHttpOpen(event:MenuEvent):void
		{
			AlarmOperator.handlerHTTPEvent(event.url, _alarmParamFo.sessionId, function(result:Object):void
				{
					var message:String = String(result);
					log.warn("捕获菜单事件 HTTP请求并直接弹出 {0}", message);
					// {'alarmuniqueid':'nanjing|126848945','msg':'','result':'2','url':''}
					// 返回的对象
					var returnObj:Object = AlarmUtil.jsonDecode(message);
					// 1:成功; 2:失败
					if (int(returnObj.result) == 1)
					{
						// 成功
						AlarmUtil.openUrl(_alarmParamFo.baseURL + returnObj.url);
					}
					else
					{
						// 失败
						if (System.useCodePage)
						{
							AlarmUtil.showMessage(returnObj.msg, "消息");
						}
						else
						{
							AlarmUtil.showMessage(AlarmUtil.encodeUtf8(returnObj.msg), "消息");
						}
					}
				});
		}

		// 捕获菜单事件 http请求并提示
		private function handlerAlarmMenuEventTips(event:MenuEvent):void
		{
			var alarmuniqueids:String = event.url.substring(event.url.indexOf("=")+1,event.url.length);
			var length:Number = alarmuniqueids.split(";").length;
			handlerSheet("合并派单",event.url,_alarmParamFo.sessionId,alarmuniqueids);
		}
		
		private function handlerSheet(action:String,url:String,sessionId:String,alarmuniqueids:String):void
		{
			AlarmOperator.handlerHTTPEvent(url, sessionId, function(result:Object):void
			{
				var message:String = String(result);
				var returnObj:Object = AlarmUtil.jsonDecode(message);
				// 1:成功; 2:失败
				if (int(returnObj.result) == 1)
				{
					// 成功
					getSendSheetResult(action,alarmuniqueids);
				}
				else
				{
					// 失败
					if (System.useCodePage)
					{
						AlarmUtil.showMessage(returnObj.msg, "消息");
					}
					else
					{
						AlarmUtil.showMessage(AlarmUtil.encodeUtf8(returnObj.msg), "消息");
					}
				}
				
			});
		}
		
		//处理告警
		public function handlerAlarm(alarmArray:Array):void
		{
			//log.warn("【开始处理】--------^v^----------" + int(new Date().getTime() / 1000));
			_cacheAlarmArray.push(alarmArray);
		}

		//定时处理告警数组
		private function dealAlarmTimer(event:TimerEvent):void
		{
			if (_cacheAlarmArray.length > 0)
			{
				//1.处理告警
				dealWithAlarmArray();

				//2.通知刷新试图并发声(小于一万立即刷新否则间隔(告警数除以一万倍数刷新))
				refreshViewAndSoundByTime();
			}
		}

		//处理告警数组
		private function dealWithAlarmArray(dealSize:int = 0):void
		{
			//如果处理长度小于700继续处理
			if (dealSize >= 700 || _cacheAlarmArray.length == 0)
			{
				//log.warn("窗口ID：" + _windowId + ",临时缓存剩余长度:" + _cacheAlarmArray.length + ",当前间隔处理数组长度:" + dealSize);
				return;
			}
			var alarmArray:Array = _cacheAlarmArray.shift();
			dealSize += alarmArray.length;
			alarmArray.forEach(function(alarm:Object, index:int, array:Array):void
				{
					handlerAlarmDeal(alarm);
				});
			dealWithAlarmArray(dealSize);
		}

		//定时刷新页面策略(小于2万实时刷新，大于两万多一万增加一秒刷新)
		private function refreshViewAndSoundByTime():void
		{
			var interTime:int = getRefreshIntervalTime(8000);
			if (interTime < 1)
			{
				refreshViewAndSound();
			}
			else if (!_isRefreshView)
			{
				_isRefreshView = true;
				setTimeout(refreshViewAndSound, interTime * 1000);
			}
		}

		//通知刷新试图并发声
		private function refreshViewAndSound():void
		{
			//1.更新刷新为false
			_isRefreshView = false;

			//2.通知发声
			if(_soundEnabled)
			{
				_alarmAction.dispatchEvent(new SoundEvent(SoundEvent.VOICE_SOUND, _windowId));
			}

			//3.刷新试图
			_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.REFRESH_VIEW));
		}

		//处理告警
		public function handlerAlarmDeal(alarm:Object):void
		{
			//log.info("接受告警主题和信息=" + alarm[AlarmTransTopic.KEY_MSG_TOPIC] + "/" + alarm[ColumnConstants.KEY_AlarmUniqueId]);
			switch (alarm[AlarmTransTopic.KEY_MSG_TOPIC])
			{
				case AlarmTransTopic.KEY_OPER_AA: //活动告警新增
					addActiveAlarm(alarm);
					break;
				case AlarmTransTopic.KEY_OPER_RS: //活动告警关联关系
					addRelationShip(alarm);
					break;
				case AlarmTransTopic.KEY_OPER_AU: //告警更新
					updateAlarm(alarm);
					break;
				case AlarmTransTopic.KEY_OPER_AR: //活动告警移除
					removeActiveAlarm(alarm);
					break;
				case AlarmTransTopic.KEY_OPER_CR: //清除告警移除
					removeClearAlarm(alarm);
					break;
				case AlarmTransTopic.KEY_OPER_MT: //活动容器-->清除容器
					moveActiveToClearAlarm(alarm);
					break;
				case AlarmTransTopic.KEY_AS: //告警统计
					statisticsAlarm(alarm);
					break;
				case AlarmTransTopic.KEY_OPER_STARTREV: //告警开始接受
					alarmStartRev();
					break;
				case AlarmTransTopic.KEY_ELH: //告警同步结束
					alarmSyncEndNodify();
					break;
				case AlarmTransTopic.KEY_LHE: //告警同步异常
					alarmSyncErrorNodify();
					break;
				case AlarmTransTopic.KEY_PLE: //告警预装结束
					alarmLoadEndNodify();
					break;
				case AlarmTransTopic.KEY_EPL: //告警预装异常
					alarmLoadErrorNodify();
					break;
			}
		}

		//活动告警新增
		private function addActiveAlarm(alarm:Object):void
		{
			//log.warn("新增活动告警=" + alarm[ColumnConstants.KEY_AlarmUniqueId] + "," + _windowId);

			log.info(alarm);
			//1.增加告警未读标识
			alarm[ColumnConstants.KEY_ReadFlag] = 0;
			//2.增加活动告警
			_activeAlarmSource.addAlarm(alarm);
		}

		//关联关系新增
		private function addRelationShip(alarm:Object):void
		{
			//log.warn("关联关系新增=" + alarm.parentalarm + "," + alarm.childalarm + "," + _windowId);
			_activeAlarmSource.addRelationShip(alarm);
		}

		//告警更新
		private function updateAlarm(alarm:Object):void
		{
			//log.warn("告警信息变更=" + alarm[ColumnConstants.KEY_AlarmUniqueId]);
			_activeAlarmSource.updateAlarm(alarm);
			_clearAlarmSource.updateAlarm(alarm);
		}

		//活动告警移除
		private function removeActiveAlarm(alarm:Object):void
		{
			//log.warn("活动告警移除=" + alarm[ColumnConstants.KEY_AlarmUniqueId] + "," + _windowId);
			_activeAlarmSource.removeAlarm(alarm);
		}

		//清除告警移除
		private function removeClearAlarm(alarm:Object):void
		{
			//log.debug("清除告警移除=" + alarm[ColumnConstants.KEY_AlarmUniqueId]);
			_clearAlarmSource.removeAlarm(alarm);
		}

		//活动容器-->清除容器
		private function moveActiveToClearAlarm(alarm:Object):void
		{
			//log.warn("活动容器-->清除容器=" + alarm[ColumnConstants.KEY_AlarmUniqueId] + "," + _windowId);
			//1.删除活动告警
			var mtAlarm:Object = _activeAlarmSource.removeAlarm(alarm);

			//2.增加清除告警
			if (mtAlarm != null)
			{
				if (mtAlarm is Array)
				{
					var alarmArray:Array = mtAlarm as Array;
					for each (var mvalarm:Object in alarmArray)
					{
						_clearAlarmSource.addAlarm(mvalarm);
					}
				}
				else
				{
					_clearAlarmSource.addAlarm(mtAlarm);
				}
			}
		}

		//告警统计
		private function statisticsAlarm(alarm:Object):void
		{
			//1.更新告警统计数量
			var aa:int = alarm[AlarmTransTopic.KEY_AA];
			var na:int = alarm[AlarmTransTopic.KEY_NA];
			var a1:int = alarm[AlarmTransTopic.KEY_A1];
			var a2:int = alarm[AlarmTransTopic.KEY_A2];
			var a3:int = alarm[AlarmTransTopic.KEY_A3];
			var a4:int = alarm[AlarmTransTopic.KEY_A4];
			var c1:int = alarm[AlarmTransTopic.KEY_C1];
			var c2:int = alarm[AlarmTransTopic.KEY_C2];
			var c3:int = alarm[AlarmTransTopic.KEY_C3];
			var c4:int = alarm[AlarmTransTopic.KEY_C4];
			var sl:int = alarm[AlarmTransTopic.KEY_SL];

			//2.告警最高等级发声
			//log.warn("获取最大等级【level】=" + sl);
			//2.通知发声
			if(_soundEnabled)
			{
				_alarmAction.dispatchEvent(new SoundEvent(SoundEvent.VOICE_LEVEL, _windowId, sl));
			}

			//3.更新告警等级和未确认、未清除数量
			_activeAlarmSource.updateAlarmNum(a1, a2, a3, a4, na, aa);
			_clearAlarmSource.updateAlarmNum(c1, c2, c3, c4, na, aa);
		}

		//开始接受告警
		public function alarmStartRev():void
		{
			log.warn("开始接受告警-----------------------windowId=" + _windowId);
			clearWindowSource(false);
			_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.VIEW_REVSTART));
		}

		//告警同步结束通知
		public function alarmSyncEndNodify():void
		{
			log.info("告警同步正常结束+++++++++++++++++++++++windowId=" + _windowId);
			_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + _windowTypeAct + AlarmViewEvent.ALARM_SYNC_ELH));
		}

		//告警同步异常通知
		public function alarmSyncErrorNodify():void
		{
			log.info("告警同步出现异常-----------------------windowId=" + _windowId);
			_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + _windowTypeAct + AlarmViewEvent.ALARM_SYNC_LHE));
		}

		//告警预装正常结束
		public function alarmLoadEndNodify():void
		{
			log.warn("告警预装正常结束+++++++++++++++++++++++windowId=" + _windowId);
			if (_isViewCreated)
			{
				_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.ALARM_LOAD_PLE));
			}
			else
			{
				//如果视图一分钟还没有创建算失败
				if (++_viewCreatedCheckNum > 30)
				{
					_isViewCreated = true;
				}
				setTimeout(alarmLoadEndNodify, 2000);
			}
		}

		//告警预装出现异常
		public function alarmLoadErrorNodify():void
		{
			log.warn("告警预装出现异常-----------------------windowId=" + _windowId);
			if (_isViewCreated)
			{
				_alarmAction.dispatchEvent(new AlarmViewEvent(_windowId + AlarmViewEvent.ALARM_LOAD_EPL));
			}
			else
			{
				//如果视图一分钟还没有创建算失败
				if (++_viewCreatedCheckNum > 30)
				{
					_isViewCreated = true;
				}
				setTimeout(alarmLoadErrorNodify, 2000);
			}
		}

		//获取刷新时间间隔
		private function getRefreshIntervalTime(num:int = 10000):int
		{
			return _activeAlarmSource.dataArraySize / num;
		}

		//创建创建完成
		public function viewCreated(event:AlarmViewEvent):void
		{
			_isViewCreated = true;
		}

		//清空窗口告警容器
		public function clearWindowSource(clearCache:Boolean = true):void
		{
			//清空缓存
			if (clearCache)
			{
				_cacheAlarmArray = new Array();
			}
			//清空容器
			_activeAlarmSource.clearWindowSource();
			_clearAlarmSource.clearWindowSource();
		}

		//通过窗口ID获取告警数
		public function getAlarmNumByWindowId(windowId:String):int
		{
			return _activeAlarmSource.dataArray.length + _clearAlarmSource.dataArray.length;
		}

		//设置声音状态
		public function set soundEnabled(enabled:Boolean):void
		{
			_soundEnabled = enabled;
		}
		
		//获取告警数据源
		public function alarmSource(windowType:int):ICollection
		{
			//活动窗口数据源
			if (windowType == 1 || windowType == 3 || windowType == 5)
			{
				return _activeAlarmSource;
			}
			return _clearAlarmSource;
		}
		
		private function getSendSheetResult(action:String,alarmuniqueid:String):void
		{
			ExternalInterface.call("getSendSheetResult",action,alarmuniqueid);
		}
	}
}