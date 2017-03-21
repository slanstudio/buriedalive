package com.jlq.game.state
{
	public class GameState extends AbstractStateObject
	{
		private static const ESCAPE:String="escape";
		
		public function GameState()
		{
			super(this, ESCAPE);
		}
		
		public function get ishelped():Boolean
		{
			return _dataObject.ishelped ? _dataObject.ishelped : false;
		}
		
		public function set ishelped(value:Boolean):void
		{
			_dataObject.ishelped = value;
		}
	}
}