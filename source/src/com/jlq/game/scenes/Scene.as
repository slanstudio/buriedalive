package com.jlq.game.scenes
{
	
	import com.jlq.game.sound.ISoundManager;
	import com.jlq.game.sound.SoundManager;
	import com.jlq.game.state.GameState;
	import com.jlq.game.views.SetMenuView;
	import com.jlq.nativeExtensions.android.nativeAds.youmi.YoumiAd;
	
	import flash.desktop.NativeApplication;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Scene extends Sprite
	{
		public static const CLOSING:String = "closing";
		public static const STARTGAME:String="start_game";
		
		protected var gameState:GameState=new GameState();
		protected var setMenuView:SetMenuView;
		protected var soundManager:ISoundManager;
		protected var youmiAd:YoumiAd;
		
		public function Scene()
		{
			gameState.load();	//加载游戏存储配置
			Const.ishelped=gameState.ishelped;
			
			youmiAd=new YoumiAd();
			youmiAd.initAd("66152340793220e5", "bc2532de40caca5b", 30, false);
			youmiAd.showAd(0, 0, 400, 38);
			
			setMenuView=new SetMenuView();
			setMenuView.visible = false;
			setMenuView.width = 240;
			setMenuView.height = 42;
			setMenuView.x=(480-setMenuView.width)/2 - 20;
			setMenuView.y=800-setMenuView.height - 50;
			addChild(setMenuView);
			
			soundManager = new SoundManager();
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);
		}
		
		protected function enableMenu():void
		{
			setMenuView.visible=true;
			setMenuView.addEventListener(SetMenuView.BACK_TO_MENU,backToMenu);
			setMenuView.addEventListener(SetMenuView.START_GAME,startGame);
		}

		private function backToMenu(event:Event):void
		{
			dispatchEvent(new Event(CLOSING,true));
		}

		protected function startGame(event:Event=null):void
		{
			dispatchEvent(new Event(STARTGAME,true));
		}
		
		private function keyDown(e:KeyboardEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(KeyboardEvent.KEY_DOWN,keyDown);
			switch(e.keyCode){
				case Keyboard.BACK:
					e.preventDefault();
					dispatchEvent(new Event(CLOSING,true));
					break;
				case Keyboard.MENU:
					e.preventDefault();
					break;
				case Keyboard.SEARCH:
					e.preventDefault();
					break;
			}
		}
		
		override public function dispose():void
		{
			youmiAd.hideAd();
			this.removeEventListeners();
			super.dispose();
		}
	}
}