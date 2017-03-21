package com.jlq.game.utils 
{
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author JLQ
	 */
	public class ClassUtil 
	{
		
		public function ClassUtil() 
		{
			
		}
		
		public static function classToString(target:Class):String
		{
			return String(target).split(" ")[1].substr(0,-1);
		}
		
		public static function className(target:Object):String
		{
			return getQualifiedClassName(target).split("::")[1];
		}
		
	}
}