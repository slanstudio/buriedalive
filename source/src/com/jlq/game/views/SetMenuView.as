package com.jlq.game.views
{
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	
	public class SetMenuView extends Sprite
	{
		private var atlas:TextureAtlas=Assets.getAtlas();
		private var soundBtn:Button;
		public static const BACK_TO_MENU:String="back_to_menu";
		public static const START_GAME:String="start_game";
		
		public function SetMenuView()
		{
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}

		private function onRemoved(event:Event):void
		{
			
		}

		private function onAdded(event:Event):void
		{
			var backmenuBtn:Button=new Button(atlas.getTexture("menu_button_backMenu"),"");
			backmenuBtn.name="backmenu";
			backmenuBtn.addEventListener(Event.TRIGGERED,onButtonTriggered);
			addChild(backmenuBtn);
			
			soundBtn=new Button(atlas.getTexture("menu_soundOn"));
			soundBtn.name="sound";
			soundBtn.x=backmenuBtn.width+20;
			soundBtn.addEventListener(Event.TRIGGERED,onButtonTriggered);
			addChild(soundBtn);
			
			var startBtn:Button=new Button(atlas.getTexture("menu_button_start01"));
			startBtn.name="start";
			startBtn.x = soundBtn.x + soundBtn.width + 20;
			startBtn.addEventListener(Event.TRIGGERED,onButtonTriggered);
			addChild(startBtn);
			
		}

		private function onButtonTriggered(event:Event):void
		{
			var current:Button=event.target as Button;
			switch(current.name){
				case "backmenu":
					dispatchEvent(new Event(BACK_TO_MENU,true));
					break;
				case "sound":
					if(Const.soundMetu){
						soundBtn.upState=atlas.getTexture("menu_soundOn");
						Const.soundMetu=!Const.soundMetu;
					}
					else{
						soundBtn.upState=atlas.getTexture("menu_soundOff");
						Const.soundMetu=!Const.soundMetu;
					}
					break;
				case "start":
					dispatchEvent(new Event(START_GAME,true));
					break;
			}
		}
		
		public override function dispose():void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			super.dispose();
		}
		
	}
}