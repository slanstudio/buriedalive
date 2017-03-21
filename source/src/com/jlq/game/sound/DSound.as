package com.jlq.game.sound 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	/**
	 * ...
	 * @author JLQ
	 */
	public class DSound 
	{
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _transform:SoundTransform;
		private var _volume:Number;
		private var _AdjustVolume:Number;
		private var manager:ISoundManager;
		private var isloop:Boolean;		//指示当前音乐是否循环播放
		public var playing:Boolean;		//当前是否正在播放
		public var active:Boolean;		//当前是否激活
		public var survive:Boolean;		//当切换游戏状态时该音乐是否自动销毁
		private var _position:Number;	//音乐播放位置
		public function DSound(manager:SoundManager) 
		{
			super();
			
			this.manager = manager;
			_transform = new SoundTransform();
			init();
		}
		
		private function init():void
		{
			_transform.pan = 0;
			_AdjustVolume = 1.0;
			_volume = 1.0;
			_transform.volume = _volume;
			_position = 0;
			_sound = null;
			active = false;
			playing = false;
			isloop = false;
		}
		
		
		public function loadEmbedded(EmbbedSound:Class,isloop:Boolean=false):DSound
		{
			stop();
			init();
			_sound = new EmbbedSound();
			this.isloop = isloop;
			updateTransform();
			active = true;
			return this;
		}
		
		public function play():void
		{
			/*
			if (_position == 0) {
				return;
			}*/
			//判断音乐是否循环
			if (isloop) {
				//判断音乐播放位置
				if (_position == 0) {	//音乐第一次播放
					if(_channel==null)
					_channel = _sound.play(0, 9999, _transform);
					active = true;	//设置音乐激活状态
				}else {	//音乐被暂停后又重新播放
					_channel = _sound.play(_position, 0, _transform);
					if (_channel == null)
						active = false;
					else
						_channel.addEventListener(Event.SOUND_COMPLETE, looped);
				}
			}else {
				if (_position == 0) {
					if (_channel == null) {
						_channel = _sound.play(0, 0, _transform);
						if (_channel == null)
							active = false;
						else
							_channel.addEventListener(Event.SOUND_COMPLETE, stoppped);
					}	
				}else {
					_channel = _sound.play(_position, 0, _transform);
					if (_channel == null)
						active = false;
				}
			}
			//指示音乐正在播放
			playing = (_channel != null);
			_position = 0;
		}
		
		/**
		 * 暂停播放音乐
		 */
		public function pause():void
		{
			if (_channel == null)
				_position = -1;
				return;
			_position = _channel.position;
			_channel.stop();
			
			if (isloop) {
				while (_position >= _sound.length) {
					_position -= _sound.length;
				}
			}
			_channel = null;
			playing = false;
		}
		
		/**
		 * 停止播放音乐
		 */
		public function stop():void
		{
			_position = 0;
			if (_channel != null) {
				_channel.stop();
				stoppped();
			}
		}
		
		public function get volume():Number
		{
			return this._volume;
		}
		
		public function set volume(value:Number):void
		{
			this._volume = value;
			if (_volume > 1) {
				_volume = 1;
			}else if (_volume < 0) {
				_volume = 0;
			}
			updateTransform();
		}
		
		/**
		 * @param	e
		 */
		protected function looped(e:Event=null):void
		{
			if (_channel == null) {
				return;
			}
			
			_channel.removeEventListener(Event.SOUND_COMPLETE, looped);
			_channel = null;
			play();
		}
		
		/**
		 * @param	e
		 */
		protected function stoppped(e:Event=null):void
		{
			if (_channel == null) {
				return;
			}
			
			if (isloop) {
				_channel.removeEventListener(Event.SOUND_COMPLETE, looped);
			}else {
				_channel.removeEventListener(Event.SOUND_COMPLETE, stoppped);
			}
			
			_channel = null;
			playing = false;
			active = false;
		}
		
		/**
		 * 更新SoundTransform
		 */
		public function updateTransform():void
		{
			if (manager) {
				_transform.volume = manager.getMuteValue() * manager.volume * _volume * _AdjustVolume;
				if (_channel != null) {
					_channel.soundTransform = _transform;
				}
			}
		}
		
		public function destroy():void
		{
			if (active)
				stop();
			manager = null;
		}
	}

}