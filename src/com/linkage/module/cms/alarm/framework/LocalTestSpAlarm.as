package com.linkage.module.cms.alarm.framework
{
	import com.linkage.module.cms.alarm.framework.module.server.AlarmServer;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;

	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	/**
	 *本地测试告警
	 * @author mengqiang
	 *
	 */
	public class LocalTestSpAlarm
	{
		
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.LocalTestAlarm");
		/**
		 *一级告警
		 */
		private var level1:int = 0;
		/**
		 *二级告警
		 */
		private var level2:int = 0;
		/**
		 *三级告警
		 */
		private var level3:int = 0;
		/**
		 *四级告警
		 */
		private var level4:int = 0;
		/**
		 *未清除告警
		 */
		private var alarmaac:int = 0;
		/**
		 *未确认告警
		 */
		private var alarmnac:int = 0;

		public function LocalTestSpAlarm(alarmServer:AlarmServer)
		{
			//发送故障告警
			sendFaultAlarm(alarmServer, 10);

			//发送关联关系
			//sendRelationShipAlarm(alarmServer);
		}

		//发送故障告警
		private function sendFaultAlarm(alarmServer:AlarmServer, sendNum:int = -1):void
		{
			var countFU:int = 0;

			var key:uint = setInterval(function():void
				{
					if (sendNum > 0 && countFU == sendNum)
					{
						clearInterval(key);
						return;
					}
					//发送故障告警
					level1 += 250;
					level2 += 250;
					level3 += 250;
					level4 += 250;
					alarmaac += 1000;
					alarmnac += 1000;
					var fault:Object = new Object();
					var stat:Object = new Object();
					stat["a1"] = level1;
					stat["a2"] = level2;
					stat["a3"] = level3;
					stat["a4"] = level4;
					stat["aac"] = alarmaac;
					stat["nac"] = alarmnac;
					stat["msg_topic"] = "asn";
					var faultArray:Array = getFaultAlarm(countFU);
					faultArray.push(stat);
					fault["91"] = faultArray;
					alarmServer.handlerAlarm(fault);
					countFU++;
				}, 500)
		}

		//发送关联关系
		private function sendRelationShipAlarm(alarmServer:AlarmServer, sendNum:int = -1):void
		{
			var countRS:int = 0;
			var key:uint = setInterval(function():void
				{
					if (sendNum > 0 && countRS == sendNum)
					{
						clearInterval(key);
						return;
					}
					//发送故障告警
					var fault:Object = new Object();
					var stat:Object = new Object();
					stat["a1"] = level1;
					stat["a2"] = level2;
					stat["a3"] = level3;
					stat["a4"] = level4;
					stat["aac"] = alarmaac;
					stat["nac"] = alarmnac;
					stat["msg_topic"] = "asn";
					var faultArray:Array = getRelationShipAlarm(countRS);
					faultArray.push(stat);
					fault["91"] = faultArray;
					alarmServer.handlerAlarm(fault);
					countRS++;
				}, 500);
		}

		//获取故障告警
		private function getFaultAlarm(count:int):Array
		{
			var num:int = 2;
			var array:Array = new Array();
			for (var i:int = count * num; i < (count + 1) * num; i++)
			{
				var severity:String = String(int(Math.random() * 4) + 1);
				var ackflag:int = int(Math.random() * 3);
//				if (i % 10 == 1)
//				{
//					array.push({msg_topic: 'nsnk', alarmuniqueid: "szx|" + i, alarmseverity: severity, effectuser: null, alarmseverity_label: getSeverityLabel(severity), alarmseverity_color_label: getSeverityColor(severity), sheetstatus: 2, eventtime: int(new Date().getTime() / 1000), alarmstatus: 1, ackflag: ackflag, ackflag_label: ackflag, specialty: String(int(Math.random() * 3) + 1), alarmregion: '广州', gather_id: "szx", nename: 'BTS_' + i, alarmtext: '+++ 设备告警流水号 = 4952 网络流水号 = 74742691 网元标识 = .3221229568.3221233664.3221282995 网元名称 = NJGS17 网元类型 = MSCServer 告警ID = 1817 告警名称 = M3UA目的实体不可达告警种类 = 故障告警级别 = 紧急告警状态 = 未确认 - 未恢复告警类型 = 信令系统发生时间 = 2011-07-27 00:08:28 定位信息 = 局向名称=NJG3BSC57_1(84), 目的实体名称=NJG3BSC57_1(85), 本地实体名称=NJGS17B(1), 网络指示=国内备用网, 源信令点编码=H001221, 目的信令点编码=H003578 --- Specialty:1 AlarmLogicClass:信令与IP AlarmLogicSubClass:目的信令点不可达 EffectOnEquipment:4 EffectOnBusiness:2 NmsAlarmType:1 SendGroupFlag: RelatedFlag:1 AlarmProvince: AlarmRegion:南京 AlarmCounty: Site: AlarmActCount: CorrelateAlarmFlag: BusinessSystem: GroupCustomer: CustomerClass: BusinessLevel: SheetSendStatus:-1 SheetStatus:-1 SheetNo: AlarmMemo:梳理表查询正常 CircuitId: <AlarmEnd>', nmsalarmtype: String(int(Math.random() * 2) + 1), sheetsendstatus: 1, locatenestatus: 2, readflg: 1, alarmtitle: 'MO业务响应成功率超门限告警' + i, daltime: int(new Date().getTime() / 1000)});
//					continue;
//				}
				array.push({msg_topic: 'nsnk', ifabnormal: '2', alarmuniqueid: "szx|" + i, alarmseverity: severity, effectuser: i, alarmseverity_label: getSeverityLabel(severity), alarmseverity_color_label: getSeverityColor(severity), sheetstatus: 2, eventtime: int(new Date().getTime() / 1000), alarmstatus: 1, ackflag: ackflag, ackflag_label: ackflag, specialty: String(int(Math.random() * 3) + 1), alarmregion: '南京', gather_id: "szx", nename: 'BTS_' + i, alarmtext: '+++ 设备告警流水号 = 4952 网络流水号 = 74742691 网元标识 = .3221229568.3221233664.3221282995 网元名称 = NJGS17 网元类型 = MSCServer 告警ID = 1817 告警名称 = M3UA目的实体不可达告警种类 = 故障告警级别 = 紧急告警状态 = 未确认 - 未恢复告警类型 = 信令系统发生时间 = 2011-07-27 00:08:28 定位信息 = 局向名称=NJG3BSC57_1(84), 目的实体名称=NJG3BSC57_1(85), 本地实体名称=NJGS17B(1), 网络指示=国内备用网, 源信令点编码=H001221, 目的信令点编码=H003578 --- Specialty:1 AlarmLogicClass:信令与IP AlarmLogicSubClass:目的信令点不可达 EffectOnEquipment:4 EffectOnBusiness:2 NmsAlarmType:1 SendGroupFlag: RelatedFlag:1 AlarmProvince: AlarmRegion:南京 AlarmCounty: Site: AlarmActCount: CorrelateAlarmFlag: BusinessSystem: GroupCustomer: CustomerClass: BusinessLevel: SheetSendStatus:-1 SheetStatus:-1 SheetNo: AlarmMemo:梳理表查询正常 CircuitId: <AlarmEnd>', nmsalarmtype: String(int(Math.random() * 2) + 1), sheetsendstatus: 5, locatenestatus: 2, readflg: 1, alarmtitle: 'MO业务响应成功率超门限告警', daltime: int(new Date().getTime() / 1000)});
			}
			return array;
		}

		//获取关联关系
		private function getRelationShipAlarm(count:int):Array
		{
			var num:int = 2;
			var array:Array = new Array();
			for (var i:int = count * num; i < (count + 1) * num; i += 2)
			{
				array.push({msg_topic: 'rsnsnk', parentalarm: 'szx|' + i, childalarm: 'szx|' + (i + 1), rulename: '主次关联' + i, relationtype: String(i % 3 + 1)});
			}
			return array;
		}

		//确认描述
		private function getAckFlagLabel(ackflag:int):String
		{
			var result:String = null;
			switch (ackflag)
			{
				case 0:
					result = "未确认";
					break;
				case 1:
					result = "已确认";
					break;
				case 2:
				default:
					result = "手工确认";
			}
			return result;
		}

		//等级描述
		private function getSeverityLabel(severity:String):String
		{
			var result:String = null;
			switch (severity)
			{
				case "1":
					result = "一级告警";
					break;
				case "2":
					result = "二级告警";
					break;
				case "3":
					result = "三级告警";
					break;
				case "4":
				default:
					result = "四级告警";
			}
			return result;
		}

		//等级颜色
		private function getSeverityColor(severity:String):String
		{
			var result:String = null;
			switch (severity)
			{
				case "1":
					result = "0xff0000";
					break;
				case "2":
					result = "0xffa500";
					break;
				case "3":
					result = "0xfff000";
					break;
				case "4":
				default:
					result = "0x4169e1";
			}
			return result;
		}
	}
}