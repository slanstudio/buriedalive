package com.jlq.game.utils
{
	import flash.display.Stage;
	import flash.system.Capabilities;
	
	public class DeviceUtil
	{
		public static const ANDROID:String="AND";
		public static const IOS:String="IOS";
		public static const PLAYBOOK:String="QNX";
		
		private static var mobileDeviceIDs:Array=[ANDROID,IOS,PLAYBOOK];
		
		/**
		 * 返回应用运行的操作系统,可能的值有:OSX,WIN,AND,IOS,QNX
		 * */
		public static function get os():String
		{
			return Capabilities.version.substring(0,3);
		}
		
		/**
		 * 获取舞台全屏宽度
		 * */
		public static function getScreenWidth(stage:Stage):int
		{
			return isMobile()?stage.fullScreenWidth:stage.fullScreenWidth;
		}
		
		/**
		 * 获取舞台全屏高度
		 * */
		public static function getScreenHeight(stage:Stage):int
		{
			return isMobile()?stage.fullScreenHeight:stage.fullScreenHeight;
		}
		
		/**
		 * 判断是不是手机应用程序
		 * */
		public static function isMobile():Boolean
		{
			return (mobileDeviceIDs.indexOf(os) !=-1);
		}
	}
}