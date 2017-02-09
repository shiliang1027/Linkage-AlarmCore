package com.linkage.module.cms.alarm.framework.view.toolstate.sound
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;

	/**
	 * 声音播放器
	 * @author mengqiang
	 *
	 */
	public class SoundPlayer extends EventDispatcher
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.toolstate.sound.SoundPlayer");
		[Bindable]
		private var _songName:String = "Loading";
		private var _sound:Sound = null;
		private var _soundChannel:SoundChannel = null;
		private var _currentPosition:Number = 0;

		public function SoundPlayer(url:String)
		{
			log.info("SoundPlayer<init> url = " + url);
			try
			{
				_sound = new Sound(new URLRequest(url));
				_sound.addEventListener(Event.ID3, id3Handler);
				_sound.addEventListener(IOErrorEvent.IO_ERROR, soundError);
			}
			catch (e:Error)
			{
				log.error("声音文件有误！请检查文件路劲是否正确");
			}
		}

		private function soundError(event:IOErrorEvent):void
		{
			log.error("声音文件有误！请检查文件路劲是否正确" + event.text);
		}

		/**
		 * 声音文件的文件名
		 */
		public function get songName():String
		{
			return _songName;
		}

		[Bindable]
		public function set songName(value:String):void
		{
			_songName = value;
		}

		/**
		 * 停止播放声音
		 *
		 */
		public function stop():void
		{
			if (_soundChannel != null)
			{
				_soundChannel.stop();
			}
			_currentPosition = 0;
		}

		/**
		 * 暂停播放声音,下次播放时继续
		 *
		 */
		public function pause():void
		{
			if (_soundChannel != null)
			{
				_currentPosition = _soundChannel.position;
				_soundChannel.stop();
			}
		}

		/**
		 * 播放声音
		 * @param loops 重复发声次数,默认不重复
		 *
		 */
		public function play(loops:int = 0):void
		{
			if (_soundChannel != null)
			{
				_soundChannel.stop();
			}
			try
			{
				_soundChannel = _sound.play(_currentPosition, loops);
				_soundChannel.soundTransform.volume = .7;
			}
			catch (e:Error)
			{
				log.error("声音对象有误！请检查是否初始化");
			}
		}


		private function id3Handler(id3Event:Event):void
		{
			try
			{
				songName = _sound.id3.songName;
			}
			catch (e:Error)
			{
				log.error("声音对象有误！请检查是否初始化");
			}
			dispatchEvent(new Event("songNameChanged"));
		}
	}
}