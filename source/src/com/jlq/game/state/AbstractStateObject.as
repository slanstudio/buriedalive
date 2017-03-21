/*
 * 抽象状态对象类
 * 
 * 保存游戏当中的不同状态
 * 
 * 
 * */

package com.jlq.game.state
{
	import flash.net.SharedObject;
	/**
	 * 抽象状态对象
	 * @author JLQ
	 */
	public class AbstractStateObject implements IStateObject 
	{
		protected var sharedObject:SharedObject;
		protected var _dataObject:Object;
		protected var id:String;
		public function AbstractStateObject(self:AbstractStateObject,id:String) 
		{
			this.id = id;
			if (!(self is AbstractStateObject)) {
				throw Error("This is an Abstract Class");
			}
		}
		
		/* INTERFACE com.jlq.dragon.state.IStateObject */
		
		public function load():void
		{
			try {
				sharedObject = SharedObject.getLocal(id);
				_dataObject = sharedObject.data;
			}catch(error:Error) {
				throw Error("Could not load shared object");
			}
		}
		
		public function save() :String
		{
			var success:String = sharedObject.flush();
			trace("Shared Object ", this.id, "Size:", sharedObject.size / 1024, "k");
			return success;
		}
		
		public function clear():void 
		{
			sharedObject.clear();
			_dataObject = sharedObject.data;
		}
		
		public function get dataObject():Object
		{
			return _dataObject;
		}
		
	}

}