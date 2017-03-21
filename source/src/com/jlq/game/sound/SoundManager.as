package com.jlq.game.sound 
{
	import com.jlq.game.utils.ClassUtil;
	/**
	 * ...
	 * @author JLQ
	 */
	public class SoundManager implements ISoundManager 
	{
		
		private var music:DSound;	//背景音乐
		private var _sounds:Array = [];		//音效数组
		private var _mute:Boolean = false;	//是否静音
		private var _volume:Number=1;			//音量
		private var activeMusic:String;		//正在播放的背景音乐名
		
		public function SoundManager() 
		{
			
		}
		
		/* INTERFACE com.jlq.dragon.sound.ISoundManager */
		/**
		 * 播放背景音乐
		 * @param	Music
		 * @param	Volume
		 */
		public function playBackgroundMusic(Music:Class, Volume:Number = 1.0):void 
		{
			var soundMusicClass:String = ClassUtil.classToString(Music);
			
			//播放的是同一首背景音乐
//			if (activeMusic == soundMusicClass) {
//				return;
//			}
			
			if (music == null) {
				music = new DSound(this);
			}else if(music.active){
				music.stop();
			}
			
			music.loadEmbedded(Music, true);
			music.volume = Volume;
			music.survive = true;
			music.play();
			activeMusic = soundMusicClass;
		}
		
		/**
		 * 停止播放背景音乐
		 */
		public function stopBackgroundMusic():void 
		{
			if (music == null) {
				return;
			}
			music.stop();
			music.active = false;
		}
		
		/**
		 * 播放音效
		 * @param	EmbeddedSound
		 * @param	Volume
		 * @param	isloop
		 * @return
		 */
		public function play(EmbeddedSound:Class, Volume:Number = 1.0, isloop:Boolean = false):DSound 
		{
			var len:uint = _sounds.length;
			for (var i:uint = 0; i < len; i++)
				if (!(_sounds[i] as DSound).active) 
					break;
			if (_sounds[i] == null)
				_sounds[i] = new DSound(this);
			var s:DSound = _sounds[i];
			s.loadEmbedded(EmbeddedSound, isloop);
			s.volume = Volume;
			s.play();
			return s;
		}
		
		/**
		 * 设置Mute
		 */
		public function get mute():Boolean 
		{
			return _mute;
		}
		
		public function set mute(value:Boolean):void 
		{
			_mute = value;
			changeSounds();
		}
		
		/**
		 * 获取Mute的数值
		 * @return
		 */
		public function getMuteValue():uint 
		{
			if (!_mute) {
				return 1;
			}else {
				return 0;
			}
		}
		
		/**
		 * 设置Volume
		 */
		public function get volume():Number 
		{
			return _volume;
		}
		
		public function set volume(value:Number):void 
		{
			_volume = value;
			if (_volume > 1) {
				_volume = 1;
			}else if(_volume<0) {
				_volume = 0;
			}
			changeSounds();
		}
		
		/**
		 * 销毁音乐
		 * @param	ForceDestroy
		 */
		public function destroySound(ForceDestroy:Boolean = false):void 
		{
			if (_sounds == null) {
				return;
			}
			//销毁背景音乐
			if ((music != null) && (!music.survive || ForceDestroy)) {
				music.destroy();
			}
			
			var s:DSound;
			var len:uint = _sounds.length;
			for (var i:uint = 0; i < len; i++) {
				s = _sounds[i] as DSound;
                if ((s != null) && (ForceDestroy || !s.survive))
                    s.destroy();
			}
			
			activeMusic = null;
		}
		
		/**
		 * 改变音乐,当改变音量和静音时调用
		 */
		public function changeSounds():void 
		{
			if (music != null&&music.active) {
				music.updateTransform();
			}
			var len:uint = _sounds.length;
			var s:DSound;
			for (var i:uint = 0; i < len; i++) {
				s = _sounds[i] as DSound;
				if ((s != null) && s.active) {
					s.updateTransform();
				}
			}
		}
		
		/**
		 * 暂停播放音效
		 */
		public function pauseSounds():void 
		{
			if (music != null&&music.active) {
				music.pause();
			}
			var len:uint = _sounds.length;
			var s:DSound;
			for (var i:uint = 0; i < len; i++) {
				s = _sounds[i] as DSound;
				if ((s != null) && s.active) {
					s.pause();
				}
			}
		}
		
		/**
		 * 停止播放音效
		 */
		public function stopSounds():void 
		{
			if (music != null&&music.active) {
				music.stop();
			}
			var len:uint = _sounds.length;
			var s:DSound;
			for (var i:uint = 0; i < len; i++) {
				s = _sounds[i] as DSound;
				if ((s != null) && s.active) {
					s.stop();
				}
			}
		}
		
		public function playSounds():void
		{
			
		}
		
	}

}