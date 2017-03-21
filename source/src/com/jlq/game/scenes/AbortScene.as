package com.jlq.game.scenes
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;

	public class AbortScene extends Scene
	{	
		private var _abortImage:Image;
		
		public function AbortScene()
		{
			super();
			//youmiAd.showAd(0, 0, 400, 38);
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}

		private function onRemoved(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			
			removeChild(_abortImage);
			
		}

		private function onAdded(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			
			var abortBGClass:Class=Assets.AbortBGClass;
			var _abortBitmap:Bitmap = Bitmap(new abortBGClass()) as Bitmap;
			_abortImage=new Image(Texture.fromBitmap(_abortBitmap));
			_abortImage.alpha=0;
			addChild(_abortImage);
			TweenLite.to(_abortImage,2,{alpha:1});
		}
		
		public override function dispose():void
		{
			removeEventListeners();
			super.dispose();
		}
	}
}