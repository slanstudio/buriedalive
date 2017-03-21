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
	
	public class Boss extends Sprite
	{
		public static const UP_RIGHT:uint=1;
		public static const DOWN_RIGHT:uint=2;
		public static const UP_LEFT:uint=3;
		public static const DOWN_LEFT:uint=4;
		public static const THROW_RIGHT:uint=5;
		public static const THROW_LEFT:uint=6;
		
		public static const START_POINT_ARRIVED:String="start_point_arrived";
		
		private static const START_POINT_X:Number = -92;
		private static const START_POINT_Y:Number = 173;
		
		private static const MOVE_DELAY_TIME:Number=0.3;
		
		private var textures:Vector.<Texture>;
		
		public var myBlock:Block;
		
		private var _bossMC:MovieClip;
		private var _direction:uint=Const.DIR_RIGHT;
		public var speed:Number=4;
		public var isHaved:Boolean=false;
		public var isMoving:Boolean=false;
		public var targetX:Number;
		private var _customs:Object;
		private var _state:uint=0;
		private var _juggler:Juggler=new Juggler();
		
		public function Boss()
		{
			super();
			addEventListener(Event.ENTER_FRAME,runBoss);
			
			if(Const.selectedLevel==1){
				Const.BOSS1_CUSTOM_NAME.forEach(function(item:String,index:uint,vec:Vector.<String>):void
				{
					addCustom(item,Assets.getAtlas().getTextures(item));
				});
				
				textures=Assets.getAtlas().getTextures("boss02_");
			}
			else if(Const.selectedLevel==2){
				Const.BOSS2_CUSTOM_NAME.forEach(function(item:String,index:uint,vec:Vector.<String>):void
				{
					addCustom(item,Assets.getAtlas().getTextures(item));
				});
				
				textures=Assets.getAtlas().getTextures("boss01_");
			}
			
			switchState(THROW_RIGHT);
		}
		
		public function reset():void
		{
			myBlock=null;
			switchState(DOWN_LEFT);
			isHaved=false;
			isMoving=true;
			this.targetX = START_POINT_X;
			addEventListener(Event.ENTER_FRAME,runBoss);
		}
		
		/**
		 * 暂停移动
		 * */
		public function pauseMove():void
		{
			removeEventListener(Event.ENTER_FRAME,runBoss);
		}
		
		public function restartMove():void
		{
			addEventListener(Event.ENTER_FRAME,runBoss);
		}
		
		/**
		 * 向左正常移动(拿着Block)
		 * */
		public function moveToLeft(targetX:Number):void
		{
			if(targetX >= Const.GRID_MARGIN_LEFT){
				this.targetX = targetX;
				direction = Const.DIR_LEFT;
			}
		}
		
		/**
		 * 正常接收方向控制移动
		 * */
		private function moveNormal():void
		{
			speed = 2;
			
			if(this.x < this.targetX&&myBlock.x+myBlock.width<Const.GRID_MARGIN_RIGHT)
			{
				if(this.x + speed > this.targetX){
					this.x = this.targetX;
					myBlock.x = this.x;
				}else{
					this.x += speed;
					myBlock.x += speed;
				}
				
			//	if (myBlock != null && this.targetX <= Const.GRID_MARGIN_RIGHT) {
			//			myBlock.x += speed;
			//	}
				
				if(_state != UP_RIGHT)
					switchState(UP_RIGHT);
			}
			else if(this.x > this.targetX&&myBlock.x>Const.GRID_MARGIN_LEFT){
				if(this.x - speed < this.targetX){
					this.x = this.targetX;
					myBlock.x = this.x;
				}else{
					this.x -= speed;
					myBlock.x -= speed;
				}
				
			//	if (myBlock != null && this.targetX >= Const.GRID_MARGIN_LEFT) {
			//			myBlock.x -= speed;
			//	}
				
				if(_state != UP_LEFT)
					switchState(UP_LEFT);
			}
		}
		
		/**
		 * 向右正常移动(拿着Block)
		 * */
		public function moveToRight(targetX:Number):void
		{
			if(targetX < Const.GRID_MARGIN_RIGHT){
				this.targetX = targetX;
				direction = Const.DIR_RIGHT;
			}
		}

		/**
		 * 回去取Block
		 * 供外部访问
		 * */
		public function backToGetBlock():void
		{
			this.targetX = START_POINT_X;
		}
		
		private function backGetBlock():void
		{	
			if(this.x == START_POINT_X)
				dispatchEvent(new(START_POINT_ARRIVED,true));
			
			speed = 5;
			
			if(this.x - speed <= START_POINT_X){
				this.x = START_POINT_X;
			}else{
				this.x -= speed;
			}
			
			if(_state != DOWN_LEFT)
				switchState(DOWN_LEFT);
		}
		
		/**
		 * 返回场景
		 * 供外部访问
		 * */
		public function backToScene(targetX:Number):void
		{
			this.targetX = targetX;
		}
		
		private function backScene():void
		{
			if(this.x == this.targetX)
				isMoving = false;
			
			speed = 5;
			
			if(this.x < this.targetX)
				this.x += speed;
			
			if(this.x > this.targetX)
				moveToLeft(this.targetX);
			
			if(_state != UP_RIGHT)
				switchState(UP_RIGHT);
			
			if(myBlock!=null&&myBlock.x+myBlock.width<=Const.GRID_MARGIN_RIGHT)
				myBlock.x = this.x;
		}
		
		/**
		 * 扔Blcok
		 * */
		public function throwBlock():void
		{
			switch(direction){
				case Const.DIR_LEFT:
					switchState(THROW_LEFT);
					break;
				case Const.DIR_RIGHT:
					switchState(THROW_RIGHT);
					break;
			}
			isHaved = false;
			isMoving = true;
			myBlock=null;
		}
		
		private function addCustom(name:String, textures:Vector.<Texture>):void
		{
			name = name.split("_")[1];
			
			_customs||=new Object();
			_customs[name] = new MovieClip(textures,Const.FPS);
		}
		
		public function switchState(state:uint):void
		{
			switch(state){
				case UP_RIGHT:
					switchCustom("upright");
					break;
				case DOWN_RIGHT:
					switchCustom("downright");
					break;
				case UP_LEFT:
					switchCustom("upleft");
					break;
				case DOWN_LEFT:
					switchCustom("downleft");
					break;
				case THROW_RIGHT:
					switchCustom("throwright");
					break;
				case THROW_LEFT:
					switchCustom("throwleft");
					break;
			}
			
			_bossMC.loop=false;
			_bossMC.play();
			
			_state = state;
		}
		
		private function switchCustom(name:String):MovieClip
		{
			_juggler.remove(_bossMC);
			removeChild(_bossMC);
			
			if(name=="throwleft"){
				var frames1:Vector.<Texture>=new <Texture>[textures[2] as Texture,textures[0] as Texture];
				_bossMC=new MovieClip(frames1,12);
			}
			else if(name=="throwright"){
				var frames2:Vector.<Texture>=new <Texture>[textures[3] as Texture,textures[1] as Texture];
				_bossMC=new MovieClip(frames2,12);
			}
			else{
				_bossMC=_customs[name];
			}
			addChild(_bossMC);
			
			_juggler.add(_bossMC);
			
			return _bossMC;
		}
		
		public function get direction():uint
		{
			return _direction;
		}
		
		public function set direction(value:uint):void
		{
			_direction=value;
		}
		
		/**
		 * 运行Boss影片剪辑
		 * */
		private function runBoss(e:EnterFrameEvent):void
		{
			_juggler.advanceTime(e.passedTime);
			
			applyMove();
		}
		
		private function applyMove():void
		{
			if(isHaved && isMoving){
				//返回场景
				backScene();
			}
			
			if(!isHaved && isMoving){
				//返回拿Block
				backGetBlock();
			}
			
			if(isHaved && !isMoving){
				//正常移动
				moveNormal();
			}
		}
		
		public override function dispose():void
		{
			this.removeEventListeners();
			removeEventListener(Event.ENTER_FRAME,runBoss);
			super.dispose();
		}
		
	}
}