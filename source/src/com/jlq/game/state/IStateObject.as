package com.jlq.game.state
{
	
	/**
	 * ...
	 * @author JLQ
	 */
	public interface IStateObject 
	{
		function load():void;
		
		function save():String;
		
		function clear():void;
	}
	
}