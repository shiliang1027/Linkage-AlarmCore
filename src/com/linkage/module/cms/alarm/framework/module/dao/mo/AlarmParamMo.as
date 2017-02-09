package com.linkage.module.cms.alarm.framework.module.dao.mo
{
	import com.linkage.module.cms.alarm.framework.AlarmContainer;
	import com.linkage.module.cms.alarm.framework.common.param.ParamCache;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.system.structure.map.Map;

	public class AlarmParamMo
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.module.dao.mo.AlarmParamMo");
		/**
		 *展示列数组 {'1':[{id:'',name:''},{id:'',name:''}],'2':[{id:'',name:''},{id:'',name:''}]}
		 */
		private var _displayColumns:Object = {};
		/**
		 *工具条数组 {'1':[{'windowId':'0','sequence':'0','toolbarEnname':'disall','toolbarChname':'显示全部'}],'2':[{'windowId':'0','sequence':'0','toolbarEnname':'disall','toolbarChname':'显示全部'}]}
		 */
		private var _toolStateJsons:Object = {};
		/**
		 *告警声音配置[{'level':'1','path':'','file':''}]
		 */
		private var _voiceConfigArray:Array = [];
		/**
		 *展示窗口 [{windowId:'',windowName:'',childviewname:''}]
		 */
		private var _winJsons:Array = [];
		/**
		 *展示视图 {viewId:'',monitorViewname:'',creator:'',windownum:''}
		 */
		private var _viewJsons:Array = [];
		/**
		 *菜单数组格式
		 */
		private var _menuArray:Array = [];
		/**
		 *视图ID
		 */
		private var _viewId:String = null;
		/**
		 *窗口数量
		 */
		private var _windowNum:int = 2;

		public function AlarmParamMo(params:Object)
		{
			//判断参数是否为空
			if (params == null || !AlarmUtil.checkStrIsNull(params[AlarmContainer.PARAMKEY_WINJSON]))
			{
				log.info("【获取参数为空，不能初始化参数信息】");
				return;
			}
			//告警窗口
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_WINJSON))
			{
				var winJson:String = params[AlarmContainer.PARAMKEY_WINJSON];
				log.info("[参数] 告警窗口: " + winJson);
				_winJsons = AlarmUtil.jsonDecode(winJson) as Array;
				//生成窗口ID和窗口唯一标识对应关系
				for each (var winObj:Object in _winJsons)
				{
					var windowId:String = winObj.windowId;
					var windowKey:String = winObj.windowUniquekey;
					ParamCache.windowMap.put(windowId, windowKey);
				}
			}
			//告警视图
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_VIEWJSON))
			{
				var viewJson:String = params[AlarmContainer.PARAMKEY_VIEWJSON];
				log.info("[参数] 告警视图: " + viewJson);
				_viewJsons = AlarmUtil.jsonDecode(viewJson) as Array;
				if(_viewJsons.length > 0)
				{
					_viewId = _viewJsons[0]["viewId"];
					if (AlarmUtil.checkStrIsNull(_viewJsons[0]["windownum"]))
					{
						_windowNum = _viewJsons[0]["windownum"];
					}
				}
			}
			// 展示列
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_ALARMCOLUMNJSON))
			{
				var columnJson:String = params[AlarmContainer.PARAMKEY_ALARMCOLUMNJSON];
				if (columnJson != null)
				{
					log.info("[参数] 展示列: " + columnJson);
					_displayColumns = AlarmUtil.jsonDecode(columnJson);
					//替换要展示的列
					var coulumnLabelMap:Object = ParamCache.coulumnLabelMap;
					for each (var columnArray:Array in _displayColumns)
					{
						for each (var obj:Object in columnArray)
						{
							if (AlarmUtil.checkStrIsNull(coulumnLabelMap[obj.id]))
							{
								obj.id = coulumnLabelMap[obj.id];
							}
						}
					}
				}
			}
			//权限内工具条
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_TOOLJSON))
			{
				var toolJson:String = params[AlarmContainer.PARAMKEY_TOOLJSON];
				log.info("[参数] 权限内工具条: " + toolJson);
				_toolStateJsons = AlarmUtil.jsonDecode(toolJson);
			}
			//告警声音配置
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_VOICECONFIG))
			{
				var voiceConfig:String = params[AlarmContainer.PARAMKEY_VOICECONFIG];
				log.info("[参数] 告警声音配置: " + voiceConfig);
				_voiceConfigArray = AlarmUtil.jsonDecode(voiceConfig) as Array;
			}
			// 菜单
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_MENUJSON))
			{
				var menuStr:String = params[AlarmContainer.PARAMKEY_MENUJSON];
				log.info("[参数] 菜单资源: " + menuStr);
				_menuArray = AlarmUtil.jsonDecode(menuStr) as Array;
			}
			//状态标示
			if (params.hasOwnProperty(AlarmContainer.PARAMKEY_STATEJSON))
			{
				var stateJson:String = params[AlarmContainer.PARAMKEY_STATEJSON];
				if (stateJson != null)
				{
					log.info("[参数] 状态标示: " + stateJson);
					var stateObject:Object = AlarmUtil.jsonDecode(stateJson);
					var iconMap:Map = new Map();
					for (var windId:String in stateObject)
					{
						var stateMap:Map = null;
						var stateEnname:String = null;
						var stateIconObject:Object = null;
						var stateIconArray:Array = new Array();
						for each (var state:Object in stateObject[windId])
						{
							var curStateEnname:String = state["stateEnname"];
							if (curStateEnname != stateEnname)
							{
								stateEnname = curStateEnname;
								stateMap = new Map();
								stateIconObject = new Object();
								stateIconObject[stateEnname] = stateMap;
								stateIconArray.push(stateIconObject);
							}
							var stateValue:String = state["stateValue"];
							stateMap.put(stateValue, state);
						}
						iconMap.put(windId, stateIconArray);
					}
					ParamCache.stateIconMap = iconMap;
					ParamCache.stateIconObject = stateObject;
				}
			}
		}

		/**
		 *获取展示列数组
		 *
		 */
		public function get displayColumns():Object
		{
			return _displayColumns;
		}

		/**
		 *获取工具条菜单数组
		 *
		 */
		public function get toolStateJsons():Object
		{
			return _toolStateJsons;
		}

		/**
		 *获取告警声音数组
		 *
		 */
		public function get voiceConfigArray():Array
		{
			return _voiceConfigArray;
		}

		/**
		 * 窗口数组
		 */
		public function get winJsons():Array
		{
			return _winJsons;
		}

		/**
		 * 视图数组
		 */
		public function get viewJsons():Array
		{
			return _viewJsons;
		}

		/**
		 * 视图Id
		 */
		public function get viewId():String
		{
			return _viewId;
		}

		/**
		 * 每行展示窗口数
		 */
		public function get windowNum():int
		{
			return _windowNum;
		}

		/**
		 * 菜单数组
		 */
		public function get menuArray():Array
		{
			return _menuArray;
		}
	}
}