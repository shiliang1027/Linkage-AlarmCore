package com.linkage.module.cms.alarm.framework.view.toolstate.sound
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	import com.linkage.system.structure.map.Map;

	/**
	 * 声音存储器
	 * <pre>
	 * 参数的格式为:
	 * [{'level':'1','path':'','file':''}]
	 *
	 * 可以同时发出不同专业的声音,但是同一专业只发出最高等级的声音
	 * </pre>
	 * @author mengqiang
	 *
	 */
	public class SoundStorage
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.toolstate.sound.SoundStorage");
		// 告警的最高等
		private var _alarmMaxLevelMap:Map = new Map();
		// 当前正在播放的声音
		private var _playingCache:Map = new Map();
		// 发生器存储容器 (level -> SoundPlayer)
		private var levelMap:Map = new Map();
		//声音状态(true:发声 false:不发声)
		private var _statue:Boolean = true;

		/**
		 * 构造方法
		 * @param baseUrl 工程名
		 * @param params 声音配置数组
		 *
		 */
		public function SoundStorage(baseUrl:String, params:Array = null)
		{
			if (params != null)
			{
				init(baseUrl, params);
			}
		}

		/**
		 * 初始化声音对象  [{'level':'1','file':''}]
		 * @param params
		 *
		 */
		public function init(baseUrl:String, params:Array):void
		{
			if (params != null)
			{
				params.forEach(function(item:*, index:int, array:Array):void
					{
						var level:int = item.level;
						var file:String = item.file;
						levelMap.put(level, new SoundPlayer(baseUrl + file));
					});
			}
		}

		/**
		 * 播放指定专业+等级的声音,若没有对应的声音配置,不播放声音
		 * @param specId
		 * @param level
		 * @param loops
		 * @return
		 *
		 */
		public function play(level:int, windowId:String, loops:int = 0):Boolean
		{
			if (!statue)
			{
				return false;
			}
			var player:SoundPlayer = levelMap.get(level);
			if (player == null)
			{
				return false;
			}
			log.info("播放声音(level:" + level + ",loops:" + loops + "):" + player.songName);
			player.play(loops);
			var windowArray:Array = _playingCache.get(windowId);
			if(windowArray == null)
			{
				windowArray = [];
				_playingCache.put(windowId, windowArray);
			}
			windowArray.push(player);
			return true;
		}

		/**
		 * 压入告警等级
		 * @param level 告警等级
		 *
		 */
		public function pushAlarmLevel(windowId:String, level:int):void
		{
			log.debug("压入告警等级level=" + level);
			if(_alarmMaxLevelMap.get(windowId) == null)
			{
				_alarmMaxLevelMap.put(windowId, level);
			}
			else
			{
				var _alarmMaxLevel:int = _alarmMaxLevelMap.get(windowId);
				_alarmMaxLevel = AlarmUtil.maxAlarmLevel(_alarmMaxLevel, level);
				_alarmMaxLevelMap.put(windowId, _alarmMaxLevel);
			}
		}

		/**
		 * 根据缓存各专业告警的最高等级播放声音,并且清空缓存中的告警
		 *
		 */
		public function flush(windowId:String):void
		{
			log.info("播放最高等级声音，并清空缓存中的告警等级+++");
			if(_alarmMaxLevelMap.get(windowId) != null)
			{
				var _alarmMaxLevel:int = _alarmMaxLevelMap.get(windowId);
				// 播放最高等级声音
				play(_alarmMaxLevel, windowId, 1);
			}
			// 清空专业对应最高等级声音,重新累计
			_alarmMaxLevelMap.put(windowId, 0);
		}

		/**
		 * 停止发声
		 *
		 */
		public function stop(windowId:String):void
		{
			var windowArray:Array = _playingCache.get(windowId);
			if(windowArray != null)
			{
				windowArray.forEach(function(item:SoundPlayer, index:int, array:Array):void
				{
					item.stop();
				});
				windowArray.length = 0;
				_alarmMaxLevelMap.put(windowId, 0);
			}
		}

		public function set statue(value:Boolean):void
		{
			_statue = value;
			if (_statue == false)
			{
				for(var windowId:String in _playingCache)
				{
					stop(windowId);
				}
			}
		}

		public function get statue():Boolean
		{
			return _statue;
		}
	}
}