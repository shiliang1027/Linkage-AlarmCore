package com.linkage.module.cms.alarm.framework.controller.fo
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.AlarmContainer;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	
	import flash.external.ExternalInterface;
	
	import mx.utils.UIDUtil;

	public class AlarmParamFo
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.controller.fo.AlarmParamFo");
		/**
		 *默认展示列
		 */
		private var _defaultDisplay:String = null;
		/**
		 *会话ID
		 */
		private var _sessionId:String = null;
		/**
		 *UUID
		 */
		private var _uuid:String = null;
		/**
		 *域ID
		 */
		private var _areaId:String = null;
		/**
		 *视图ID
		 */
		private var _viewId:String = null;
		/**
		 *基本URL
		 */
		private var _baseURL:String = null;
		/**
		 *扩展信息
		 */
		private var _exInfo:String = null;
		private var _ruleTopo:Boolean=false;
		/**
		 *用户对象
		 */
		private var _mapInfo:Object = null;
		/**
		 *是否本地调试
		 */
		private var _local:Boolean = false;
		/**
		 *模块Key
		 */
		private var _moduleKey:String = null;

		public function AlarmParamFo(params:Object)
		{
			//判断参数是否为空
			if (params == null)
			{
				log.info("【外部传入参数为空，不能初始化参数信息】");
				return;
			}
			// 提取用户对象
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_MAPINFO))
			{
				var userStr:String = params[AlarmContainer.PARAMKEY_MAPINFO];
				log.info("[参数] 用户对象: " + userStr);
				//1.初始化用户信息
				_mapInfo = AlarmUtil.jsonDecode(userStr);
				_sessionId = _mapInfo[AlarmContainer.PARAMKEY_SESSIONID];
				_areaId = _mapInfo[AlarmContainer.PARAMKEY_AREAID];
				_baseURL = _mapInfo[AlarmContainer.PARAMKEY_CONTEXT];
				//2.初始化UUID
				createUUID();
			}
			//提取模块名称
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_MODULEKEY))
			{
				_moduleKey = params[AlarmContainer.PARAMKEY_MODULEKEY];
				_mapInfo[AlarmContainer.PARAMKEY_MODULEKEY] = moduleKey;
				log.info("[参数] 模块名称: " + _moduleKey);
			}
			//提取扩展信息
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_EX_INFO))
			{
				_exInfo = params[AlarmContainer.PARAMKEY_EX_INFO];
				_mapInfo[AlarmContainer.PARAMKEY_EX_INFO] = _exInfo;
				log.info("[参数] 扩展信息: " + _exInfo);
			}
			//提取扩展信息
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_RULETOPO))
			{
				_ruleTopo = params[AlarmContainer.PARAMKEY_RULETOPO];
				_mapInfo[AlarmContainer.PARAMKEY_RULETOPO] = _ruleTopo;
				log.info("[参数] 扩展信息: " + _ruleTopo);
			}
			//是否本地调试
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_LOCAL))
			{
				var local:String = params[AlarmContainer.PARAMKEY_LOCAL];
				log.info("[参数] 是否本地调试: " + local);
				_local = local == "true" ? true : false;
			}
			//是否默认展示列
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_DISPLAYCOLUMN))
			{
				_defaultDisplay = params[AlarmContainer.PARAMKEY_DISPLAYCOLUMN];
				log.info("[参数] 默认展示列: " + _defaultDisplay);
			}
			//提取视图ID
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_VIEWID))
			{
				_viewId = params[AlarmContainer.PARAMKEY_VIEWID];
				_mapInfo[AlarmContainer.PARAMKEY_VIEWID] = _viewId;
				log.info("[参数] 视图ID: " + _viewId);
			}
		}

		/**
		 *初始化UUID
		 *
		 */
		public function createUUID():void
		{
			//1.初始化UUID
			_uuid = _sessionId + UIDUtil.createUID();
			if (_mapInfo != null)
			{
				_mapInfo[AlarmContainer.PARAMKEY_UUID] = _uuid;
			}

			//2.初始化页面包装器UUID为了注销时用
			ExternalInterface.call("setAlarmUUID", _baseURL, _uuid);
		}

		/**
		 *创建模块关键字
		 * @param moduleKey
		 *
		 */
		public function createModuleKey(moduleKey:String = null):void
		{
			if (moduleKey != null)
			{
				_mapInfo[AlarmContainer.PARAMKEY_WINMODULEKEY] = moduleKey;
			}
			else
			{
				delete _mapInfo[AlarmContainer.PARAMKEY_WINMODULEKEY];
			}
		}

		/**
		 *添加额外参数
		 * @param exInfo
		 *
		 */
		public function addExInfo(exInfo:String = null):void
		{
			if (exInfo != null)
			{
				_mapInfo[AlarmContainer.PARAMKEY_EX_INFO] = exInfo;
			}
		}
		
		/**
		 *添加额外参数,规则告警
		 * @param ruleTopo
		 *
		 */
		public function addRuleTopo(ruleTopo:String = ""):void
		{
//			if (ruleTopo)
//			{
				_mapInfo[AlarmContainer.PARAMKEY_RULETOPO] = ruleTopo;
//			}
		}

		/**
		 *默认展示列
		 *
		 */
		public function get defaultDisplay():String
		{
			return _defaultDisplay;
		}

		/**
		 *获取会话ID
		 *
		 */
		public function get sessionId():String
		{
			return _sessionId;
		}

		/**
		 *获取UUID
		 *
		 */
		public function get uuid():String
		{
			return _uuid;
		}

		/**
		 *获取域ID
		 *
		 */
		public function get areaId():String
		{
			return _areaId;
		}

		/**
		 *获取视图ID
		 *
		 */
		public function get viewId():String
		{
			return _viewId;
		}
		
		/**
		 *获取模块名称
		 *
		 */
		public function get moduleKey():String
		{
			return _moduleKey;
		}

		/**
		 * 基本URL
		 */
		public function get baseURL():String
		{
			return _baseURL;
		}

		/**
		 * 用户对象
		 */
		public function get mapInfo():Object
		{
			return _mapInfo;
		}

		/**
		 *是否本地运行
		 */
		public function get local():Boolean
		{
			return _local;
		}
	}
}