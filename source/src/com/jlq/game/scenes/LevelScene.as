package com.jlq.game.scenes
{
	import com.jlq.game.views.SetMenuView;
	
	import flash.display.Bitmap;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class LevelScene extends Scene
	{
		private var atlas:TextureAtlas=Assets.getAtlas();
		
		public function LevelScene()
		{
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded(e:Event):void
		{
			//显示菜单
			enableMenu();
			
			var bgClass:Class=Assets.LevelSelectBGClass;
			var bgBitmap:Bitmap=Bitmap(new bgClass()) as Bitmap;
			var bgImage:Image=new Image(Texture.fromBitmap(bgBitmap));
			addChildAt(bgImage,0);
			
			for(var i:int=1;i<=2;i++){
				var button:Button=new Button(Assets.getAtlas().getTexture("menu_button_level_select_up"),"",Assets.getAtlas().getTexture("menu_button_level_select_down"));
				button.name="level"+String(i);
				button.x=18+(button.width+21)*(i-1);
				button.y=142;
				button.addEventListener(Event.TRIGGERED,onTriggered);
				addChild(button);
			}
			
			youmiAd.showAd(0, 0, 400, 38);
		}

		private function onTriggered(event:Event):void
		{
			var button:Button=event.target as Button;
			switch(button.name){
				case "level1":
					Const.selectedLevel=1;
					break;
				case "level2":
					Const.selectedLevel=2;
					break;
			}
			startGame();
		}
		
		public override function dispose():void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			super.dispose();
		}
		
	}
}