package com.jlq.game.sound 
{
	
	/**
	 * ...
	 * @author JLQ
	 */
	public interface ISoundManager 
	{
		/**
		 * 
		 * @param	music	你要在背景当中播放的音乐文件
		 * @param	volume	默认的背景音乐的音量大小
		 * @return
		 * */
		function playBackgroundMusic(Music:Class, Volume:Number = 1.0):void;
		
		/**
		 * 停止播放背景音乐
		 */
		function stopBackgroundMusic():void;
		
		/**
		 * 
		 * @param	EmbeddedSound	你想要播放的音效		
		 * @param	volume			音效音量大小
		 * @param	isloop			是否循环
		 * @return	DragonSound
		 */
		function play(EmbeddedSound:Class, Volume:Number = 1.0, isloop:Boolean = false):DSound;
		
		/**
		 * 设置静音以关闭音乐
		 * @default false
		 */
		function get mute():Boolean;
		/**
		 * @private
		 */
		function set mute(Mute:Boolean):void;
		/**
		 * 获取静音值以更新soundtransform
		 * @return	uint ----- 0代表未静音,1代表静音
		 */
		function getMuteValue():uint;
		
		/**
		 * 从0-1改变全局音量
		 * @default	0.5
		 */
		function get volume():Number;
		
		/**
		 * @private
		 */
		function set volume(value:Number):void;
		
		/**
		 * 当状态改变时 即使音乐还存在也要销毁音乐
		 * @param	ForceDestroy
		 */
		function destroySound(ForceDestroy:Boolean=false):void;
		
		/**
		 * 在改变之后调节音量大小和声音通道
		 */
		function changeSounds():void;
		
		/**
		 * 暂停音乐播放
		 */
		function pauseSounds():void;
		
		/**
		 * 停止音乐播放
		 */
		function stopSounds():void;
		
		/**
		 * 播放音乐
		 */
		function playSounds():void;
	}
	
}