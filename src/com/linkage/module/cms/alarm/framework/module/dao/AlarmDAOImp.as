package com.linkage.module.cms.alarm.framework.module.dao
{
	import com.linkage.module.cms.alarm.framework.module.dao.data.AlarmData;
	import com.linkage.module.cms.alarm.framework.module.dao.data.AlarmDataImp;

	import mx.collections.ArrayList;
	import mx.messaging.events.MessageEvent;

	/**
	 *告警DAO实现类
	 * @author mengqiang
	 *
	 */
	public class AlarmDAOImp implements AlarmDAO
	{
		/**
		 *告警数据对象
		 */
		private var _alarmData:AlarmData=null;

		public function AlarmDAOImp(mapInfo:Object)
		{
			_alarmData=new AlarmDataImp(mapInfo);
		}

		public function createChannelSet():void
		{
			_alarmData.createChannelSet();
		}

		public function subscribeAlarms(success:Function):void
		{
			_alarmData.subscribeAlarms(function(event:MessageEvent):void
				{
					var result:Object=event.message.body;
					success.call(this, result);
				});
		}

		public function unsubscribeAlarms():void
		{
			_alarmData.unsubscribeAlarms();
		}

		public function deleteUser():void
		{
			_alarmData.deleteUser();
		}

		public function hearbeat(success:Function):void
		{
			_alarmData.hearbeat(success);
		}

		public function saveColumnOrder(params:Object):void
		{
			_alarmData.saveColumnOrder(params);
		}

		public function getResourceInfo(success:Function):void
		{
			_alarmData.getResourceInfo(success);
		}

		public function regListenerAlarm(ruleList:ArrayList, defColumn:String, success:Function):void
		{
			_alarmData.regListenerAlarm(ruleList, defColumn, success);
		}

		public function syncAlarm(params:Object, success:Function, fault:Function):void
		{
			_alarmData.syncAlarm(params, success, fault);
		}

		public function shutSync(params:Object, success:Function, fault:Function):void
		{
			_alarmData.shutSync(params, success, fault);
		}

		public function reloadAlarm(viewId:String, ruleList:ArrayList, defColumn:String, success:Function):void
		{
			_alarmData.reloadAlarm(viewId, ruleList, defColumn, success);
		}
	}
}