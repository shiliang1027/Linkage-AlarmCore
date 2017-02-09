package com.linkage.module.cms.alarm.framework
{
	import com.linkage.module.cms.alarm.framework.module.server.AlarmServer;

	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	import mx.collections.ArrayCollection;

	/**
	 *本地测试告警
	 * @author mengqiang
	 *
	 */
	public class LocalTestRlAlarm
	{
		public function LocalTestRlAlarm(alarmServer:AlarmServer)
		{
			//发送故障告警
			sendFaultAlarm(alarmServer);
			//发送关联关系
			sendRelationAlarm(alarmServer);

		}

		//发送故障告警
		private function sendFaultAlarm(alarmServer:AlarmServer):void
		{
			//退出次数
			var outNum:int=3;
			//测试故障告警
			var level1:int=0;
			var level2:int=0;
			var level3:int=0;
			var level4:int=0;
			var alarmaac:int=0;
			var alarmnac:int=0;
			//故障告警
			var countFU:int=0;
			var faultKey:uint=setInterval(function():void
				{
					//1.超过100次退出
					if (countFU > outNum)
					{
						clearInterval(faultKey);
					}
					//2.发送故障告警
					level1+=1;
					level2+=1;
					level3+=1;
					level4+=2;
					alarmaac+=5;
					alarmnac+=5;
					var fault:Object=new Object();
					var stat:Object=new Object();
					stat["a1"]=level1;
					stat["a2"]=level2;
					stat["a3"]=level3;
					stat["a4"]=level4;
					stat["aac"]=alarmaac;
					stat["nac"]=alarmnac;
					stat["msg_topic"]="as";
					var faultArray:Array=getFaultAlarm(countFU);
					faultArray.push(stat);
					fault["4"]=faultArray;
					alarmServer.handlerAlarm(fault);
					countFU++;
				}, 2000);
		}

		//发送关联关系
		private function sendRelationAlarm(alarmServer:AlarmServer):void
		{
			//退出次数
			var outNum:int=3;
			//测试告警关联
			var countRS:int=0;
			var relationShipKey:uint=setInterval(function():void
				{
					//1.超过100次退出
					if (countRS > outNum)
					{
						clearInterval(relationShipKey);
					}
					//2.发送关联告警
					var fault:Object=new Object();
					var faultArray:Array=getRelationShipAlarm(countRS);
					fault["4"]=faultArray;
					alarmServer.handlerAlarm(fault);
					countRS++;
				}, 3000);
		}

		//发送告警
		private function sendCustAlarm(alarmServer:AlarmServer):void
		{
			//退出次数
			var outNum:int=2;
			//测试故障告警
			var level1:int=0;
			var level2:int=0;
			var level3:int=0;
			var level4:int=0;
			var alarmaac:int=0;
			var alarmnac:int=0;
			//集客告警
			var countCU:int=0;
			var faultCustKey:uint=setInterval(function():void
				{
					//1.超过100次退出
					if (countCU > outNum)
					{
						clearInterval(faultCustKey);
					}
					//2.发送故障告警
					level1+=250;
					level2+=250;
					level3+=250;
					level4+=250;
					alarmaac+=1000;
					alarmnac+=1000;
					var fault:Object=new Object();
					var stat:Object=new Object();
					stat["a1"]=level1;
					stat["a2"]=level2;
					stat["a3"]=level3;
					stat["a4"]=level4;
					stat["aac"]=alarmaac;
					stat["nac"]=alarmnac;
					stat["msg_topic"]="as";
					var faultArray:Array=getCustFaultAlarm(countCU);
					faultArray.push(stat);
					fault["2"]=faultArray;
					alarmServer.handlerAlarm(fault);
					countCU++;
				}, 1000);
		}

		//获取集客故障告警
		private function getCustFaultAlarm(count:int):Array
		{
			var array:Array=new Array();
			var custArray:ArrayCollection=new ArrayCollection([{cusbuss_id: 2373100000011398, groupcustomer: '宝应县七巧板玩具有限公司', businesssystem: '语音专线业务', daltime: 1310058915, alarmuniqueid: 'nanjing | 6871207', customerclass: 'C', safelevel: 24, businessLevel: 'businessLevel', groupcustomerid: 2373022015880139, neid: 2373022015880139}]);
			for (var i:int=count * 1000; i < (count + 1) * 1000; i++)
			{
				array.push({msg_topic: 'aa', alarmuniqueid: "szx|" + i, cusbuss_id: i % 3, groupcustomerid: i % 3, alarmseverity: String(int(Math.random() * 4) + 1), sheetstatus: 2, eventtime: int(new Date().getTime() / 1000), alarmstatus: 1, ackflag: int(Math.random() * 3), specialty: i % 2, alarmregion: '广州', gather_id: "szx", nename: 'BTS_' + i, alarmtext: '告警正文', sheetsendstatus: 1, locatenestatus: 2, readflg: 1, daltime: int(new Date().getTime() / 1000), customerflag: 1, customer_list: custArray});
			}
			return array;
		}

		//获取故障告警
		private function getFaultAlarm(count:int):Array
		{
			var array:Array=new Array();
			for (var i:int=count * 5; i < (count + 1) * 5; i++)
			{
				array.push({msg_topic: 'aa', alarmuniqueid: "szx|" + i, alarmseverity: String(int(Math.random() * 4) + 1), alarmseverity_label: '四级告警', sheetstatus: 2, eventtime: int(new Date().getTime() / 1000), alarmstatus: 1, ackflag: int(Math.random() * 3), specialty_label: '2G无线', specialty: String(int(Math.random() * 0) + 1), alarmregion: '广州', gather_id: "szx", nename: 'BTS_' + i, alarmtext: '告警正文', sheetsendstatus: 1, locatenestatus: 2, readflg: 1, daltime_label: '2011-12-12 12:12:12', relatedflag: 0, alarmtitle: '测试'});
			}
			return array;
		}

		//获取移除告警
		private function getRemoveAlarm(count:int):Array
		{
			var array:Array=new Array();
			for (var i:int=count * 3; i < (count + 1) * 3; i++)
			{
				array.push({msg_topic: 'ar', alarmuniqueid: "szx|" + i});
			}
			return array;
		}

		//获取关联关系
		private function getRelationShipAlarm(count:int):Array
		{
			var array:Array=new Array();
			var i:int=count * 5;
			array.push({msg_topic: 'rs', parentalarm: 'szx|0', childalarm: 'szx|' + (i + 1), rulename: '主次关联' + i, relationtype: String(i % 3 + 1)});
			array.push({msg_topic: 'rs', parentalarm: 'szx|' + (i + 1), childalarm: 'szx|' + (i + 2), rulename: '主次关联' + i, relationtype: String(i % 3 + 1)});
			array.push({msg_topic: 'rs', parentalarm: 'szx|' + (i + 1), childalarm: 'szx|' + (i + 3), rulename: '主次关联' + i, relationtype: String(i % 3 + 1)});
			array.push({msg_topic: 'rs', parentalarm: 'szx|' + (i + 1), childalarm: 'szx|' + (i + 4), rulename: '主次关联' + i, relationtype: String(i % 3 + 1)});
			return array;
		}

		//获取关联关系
		private function getRelationShipAlarm1(count:int):Array
		{
			var array:Array=new Array();
			for (var i:int=count * 3; i < (count + 1) * 3; i++)
			{
				array.push({msg_topic: 'rs', parentalarm: 'szx|' + i, childalarm: 'szx|' + (i + 1), rulename: '主次关联' + i, relationtype: String(i % 3 + 1)});
			}
			return array;
		}
	}
}