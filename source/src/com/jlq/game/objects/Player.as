package com.jlq.game.objects
{
	import flash.geom.Point;
	
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.textures.Texture;

	public class Player extends Sprite
	{
		//Events
		public static const DIED_BY_YA:String="died_by_ya";				//被压死
		public static const DIED_BY_BOMBBED:String="died_by_bombbed";	//被炸死
		
		//States
		private static const STANDING_NORMAL:uint=1;	//正常站立状态
		private static const STANDING_LEFT:uint=2;		//向左站立状态
		private static const STANDING_RIGHT:uint=3;		//向右站立状态
		private static const MOVING_LEFT:uint=4;		//向左行走状态
		private static const MOVING_RIGHT:uint=5;		//向右行走状态
		private static const DYING_LEFT:uint=6;			//左压死状态
		private static const DYING_RIGHT:uint=7;		//右压死状态
		private static const DIED_BOMB_LEFT:uint=8;		//左被炸死状态
		private static const DIED_BOMB_RIGHT:uint=9;	//右被炸死状态
		
		private static const MOVE_DELAY_TIME:Number=0.3;
		private static const SPEED:Number=4;
		
		private var _playerMC:MovieClip;
		private var _direction:uint=Const.DIR_RIGHT;		//Player方向，0为初始方向，1为左方向，2为右方向
		private var _speed:Number;			//玩家移动速度
		private var _state:uint=0;			//玩家当前状态
		private var _customs:Object;
		public var targetX:Number;
		public var deadKind:String="";
		public var isStopped:Boolean=true;
		private var _isDead:Boolean=false;
		private var _juggler:Juggler=new Juggler();
		
		public function Player()
		{
			super();
			
			this.x=Const.GRID_MARGIN_LEFT+Const.GRID_ITEM_WIDTH*4;
			this.y=Const.GRID_MARGIN_TOP+Const.GRID_ITEM_WIDTH*12;
			
			addEventListener(Event.ENTER_FRAME,runPlayer);
			
			//将player所有状态添加进_customs里
			Const.PLAYER_CUSTOM_NAME.forEach(function(item:String,index:uint,vec:Vector.<String>):void{
				addCustom(item,Assets.getAtlas().getTextures(item));
			},this);
			
			switchState(STANDING_NORMAL);
		}
		
		private function addCustom(name:String, textures:Vector.<Texture>):void
		{
			name = name.split("_")[1];
			
			_customs||=new Object();
			_customs[name] = new MovieClip(textures,Const.FPS);
		}

		/**
		 * 播放Player的MovieClip
		 * */
		private function runPlayer(event:EnterFrameEvent):void
		{
			_juggler.advanceTime(event.passedTime);	//播放动画
			
			//应用移动
			if(!_isDead)
			{
				applyMove();
			}
			else
			{
				switch(_state){
					case DYING_LEFT:
					case DYING_RIGHT:
						if(_playerMC.height<=1){
							_playerMC.height=0;
							dispatchEvent(new Event(DIED_BY_YA,true));
							removeEventListener(Event.ENTER_FRAME,runPlayer);
						}
						else
						{
							_playerMC.y += 2.5;
							_playerMC.height -= 2.5;
						}
						break;
					case DIED_BOMB_LEFT:
					case DIED_BOMB_RIGHT:
						dispatchEvent(new Event(DIED_BY_BOMBBED,true));
						removeEventListener(Event.ENTER_FRAME,runPlayer);
						break;
				}
			}
		}
		
		private function applyMove():void
		{
			//移动
			if(this.x<targetX && !isStopped){
				if(this.x + SPEED > targetX){
					this.x = targetX;
				}else{
					this.x += SPEED;
				}
			}
			else if(this.x>targetX && !isStopped){
				if(this.x - SPEED < targetX){
					this.x = targetX;
				}else{
					this.x -= SPEED;
				}
			}else{
				stopMove();
			}
		}
		
		private function switchState(state:uint):void
		{
			switch(state){
				case STANDING_NORMAL:
					switchCustom("standing");
					_playerMC.loop=false;
					_playerMC.play();
					break;
				case STANDING_LEFT:
					switchCustom("standingleft");
					break;
				case STANDING_RIGHT:
					switchCustom("standingright");
					break;
				case MOVING_LEFT:
					switchCustom("movingleft");
					_playerMC.loop=true;
					_playerMC.setFrameDuration(0,0.1);
					_playerMC.setFrameDuration(1,0.1);
					_playerMC.play();
					break;
				case MOVING_RIGHT:
					switchCustom("movingright");
					_playerMC.loop=true;
					_playerMC.setFrameDuration(0,0.1);
					_playerMC.setFrameDuration(1,0.1);
					_playerMC.play();
					break;
				case DYING_LEFT:
					//switchCustom("dyingleft");
					//_playerMC.loop=false;
					//_playerMC.play();
					break;
				case DYING_RIGHT:
					///switchCustom("dyingright");
					//_playerMC.loop=false;
					//_playerMC.play();
					break;
				case DIED_BOMB_LEFT:
					switchCustom("diedbombleft");
					_playerMC.loop=false;
					_playerMC.play();
					break;
				case DIED_BOMB_RIGHT:
					switchCustom("diedbombright");
					_playerMC.loop=false;
					_playerMC.play();
					break;
			}
			
			_state = state;
			
		}

		private function switchCustom(name:String):MovieClip
		{
			_juggler.remove(_playerMC);
			removeChild(_playerMC);
			
			_playerMC = _customs[name];
			addChild(_playerMC);
			//启动播放动画
			_juggler.add(_playerMC);
			
			return _playerMC;
		}
		
		public function reset():void
		{
			switchState(STANDING_RIGHT);
			this.x=Const.GRID_MARGIN_LEFT+Const.GRID_ITEM_WIDTH*4;
			this.y=Const.GRID_MARGIN_TOP+Const.GRID_ITEM_WIDTH*12;
			isStopped=true;
			_isDead=false;
			this.targetX=this.x;
			addEventListener(Event.ENTER_FRAME,runPlayer);
		}
		
		/**
		 * 向右移动
		 * */
		public function moveToRight(targetX:Number):void
		{
			if(this.x +this.width < Const.GRID_MARGIN_RIGHT)
			{
				this.targetX=targetX;
				direction=Const.DIR_RIGHT;
				isStopped=false;
			}
			
			if(_state == MOVING_RIGHT)return;
			
			switchState(MOVING_RIGHT);
			
		}
		
		/**
		 * 向左移动
		 * */
		public function moveToLeft(targetX:Number):void
		{
			if(this.x > Const.GRID_MARGIN_LEFT)
			{
				this.targetX=targetX;
				direction=Const.DIR_LEFT;
				isStopped=false;
			}
			
			if(_state == MOVING_LEFT)return;
			
			switchState(MOVING_LEFT);
		}
		
		public function moveToRightUp():void
		{
			if (this.x + this.width < Const.GRID_MARGIN_RIGHT) {
				this.x += 45;
				this.y -= 45;
				this.targetX=this.x;
			
			}
			
			direction=Const.DIR_RIGHT;
			
		}
		
		public function moveToRightDown(targetY:Number):void
		{
			if (this.x + this.width < Const.GRID_MARGIN_RIGHT) {
				this.x += 45;
				this.y = targetY;
				this.targetX=this.x;
			}
			
			direction=Const.DIR_RIGHT;
		}
		
		public function moveToLeftUp():void
		{
			if (this.x > Const.GRID_MARGIN_LEFT) {
				this.x -= 45;
				this.y -= 45;
				this.targetX=this.x;
			}
			
			direction=Const.DIR_LEFT;
		}
		
		public function moveToLeftDown(targetY:Number):void
		{
			if (this.x > Const.GRID_MARGIN_LEFT) {
				this.x -= 45;
				this.y = targetY;
				this.targetX=this.x;
			}
			
			direction=Const.DIR_LEFT;
		}
		
		/**
		 * 被炸死
		 * */
		public function deadByBombed():void
		{
			//被炸死
			_isDead = true;
			deadKind=DIED_BY_BOMBBED;
			switch(_direction){
				case Const.DIR_LEFT:
					switchState(DIED_BOMB_LEFT);
					break;
				case Const.DIR_RIGHT:
					switchState(DIED_BOMB_RIGHT);
					break;
			}
		}
		
		/**
		 * 被压死
		 * */
		public function deadByYa():void
		{
			_isDead=true;
			deadKind=DIED_BY_YA;
			switch(_direction){
				case Const.DIR_LEFT:
					switchState(DYING_LEFT);
					break;
				case Const.DIR_RIGHT:
					switchState(DYING_RIGHT);
					break;
			}
		}
		
		/**
		 * 停止移动
		 * */
		public function stopMove():void
		{
			switch(direction){
				case Const.DIR_LEFT:
					switchState(STANDING_LEFT);
					break;
				case Const.DIR_RIGHT:
					switchState(STANDING_RIGHT);
					break;
			}
			isStopped=true;
		}
		
		public override function dispose():void
		{
			this.removeEventListeners();
			super.dispose();
		}

		public function get direction():uint
		{
			return _direction;
		}

		public function set direction(value:uint):void
		{
			_direction = value;
		}

	}
}