package com.jlq.game.events
{
	import starling.events.Event;
	
	public class DividedEvent extends Event
	{
		public static const DIVIDED:String="divided";	//可以被拆分
		
		private var _dividedDirection:uint;		//被拆分方向
		
		public function DividedEvent(type:String,_dividedDirection:uint, bubbles:Boolean=false)
		{
			super(type, bubbles);
			this._dividedDirection=_dividedDirection;
		}

		public function get dividedDirection():uint
		{
			return _dividedDirection;
		}

		public function set dividedDirection(value:uint):void
		{
			_dividedDirection = value;
		}

	}
}