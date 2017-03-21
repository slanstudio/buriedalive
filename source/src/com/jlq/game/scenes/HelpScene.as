package com.jlq.game.scenes
{	
	import flash.display.Bitmap;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;

	public class HelpScene extends Scene
	{	
		public function HelpScene()
		{
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}
		
		private function onAdded(e:Event):void
		{
			//添加背景
			var bgClass:Class=Assets.HelpBGClass;
			var bgBitmap:Bitmap=Bitmap(new bgClass()) as Bitmap;
			var bgImage:Image=new Image(Texture.fromBitmap(bgBitmap));
			bgImage.width=480;
			bgImage.height=800;
			addChildAt(bgImage,0);
			
			youmiAd.showAd(0, 0, 400, 38);
			//显示菜单
			enableMenu();
		}
		
		private function onRemoved(e:Event):void
		{
			
		}
		
		public override function dispose():void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			super.dispose();
		}
		
	}
}