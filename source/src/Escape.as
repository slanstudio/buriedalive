package
{
	import com.jlq.game.utils.Stats;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	import starling.core.Starling;
	
	[SWF(width="400", height="300", frameRate="60", backgroundColor="#000000")]
	public class Escape extends Sprite
	{
		private var startLoader:Loader;
		
		private var mStarling:Starling;
		
		public function Escape()
		{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//addChild(new Stats());
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
//			//Starling.multitouchEnabled=true;
//			mStarling=new Starling(Game,stage);
//			mStarling.antiAliasing=1;
//			mStarling.start();
		}
		
		protected function onAdded(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			initApp();
		}

		private function initApp():void
		{
			startLoader=new Loader();
			startLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onProgressing);
			startLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleted);
			startLoader.load(new URLRequest("opening.swf"));
			addChild(startLoader);
		}

		private function onCompleted(event:Event):void
		{
			trace("load complete");
			var mc:MovieClip=event.target.content as MovieClip;
			mc.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			mc.play();
			
			//Starling.multitouchEnabled=true;
			mStarling=new Starling(Game,stage);
			mStarling.antiAliasing=1;
			mStarling.start();
			
		}

		private function enterFrameHandler(event:Event):void
		{
			if(event.target.currentFrame == event.target.totalFrames){
				event.target.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
				startLoader.unloadAndStop(true);
				removeChild(startLoader);
			}
		}

		private function onProgressing(event:ProgressEvent):void
		{
			
		}
	}
}