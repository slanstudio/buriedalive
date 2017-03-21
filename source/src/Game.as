package
{
	import avmplus.getQualifiedClassName;
	
	import com.jlq.game.scenes.AbortScene;
	import com.jlq.game.scenes.GameScene;
	import com.jlq.game.scenes.HelpScene;
	import com.jlq.game.scenes.LevelScene;
	import com.jlq.game.scenes.Scene;
	import com.jlq.game.utils.DeviceUtil;
	import com.jlq.nativeExtensions.android.nativeAds.youmi.YoumiAd;
	
	import flash.desktop.NativeApplication;
	import flash.utils.getDefinitionByName;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class Game extends Sprite
	{
		private const buttonNames:Vector.<String>=Vector.<String>(["GameScene","LevelScene","HelpScene","AbortScene","Exit"]);
		private const buttonXs:Array=[78,172,225,145,190];
		private const buttonYs:Array=[230,315,400,535,654];
		private const buttonWidths:Array=[105,90,100,58,77];
		private const buttonHeights:Array=[36,36,36,36,36];
		private const scenesToCreate:Array=[
			["GameScene",GameScene],
			["LevelScene",LevelScene],
			["HelpScene",HelpScene],
			["AbortScene",AbortScene]
		];
		
		private var mMainMenu:Sprite;		//主菜单
		private var mCurrentScene:Scene;	//当前场景
		private var ad:YoumiAd;
		
		public function Game()
		{
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded(e:Event):void
		{	
			mMainMenu=new Sprite();
			this.addChild(mMainMenu);
			
			//添加广告
			ad = new YoumiAd();
			ad.initAd("66152340793220e5", "bc2532de40caca5b", 30, false);
			ad.showAd(0, 800 - 38, 400, 38);
			
			//添加菜单背景
			var menuBG:Image=new Image(Assets.getAtlas().getTexture("bg_menu"));
			menuBG.width=480;
			menuBG.height=800;
			mMainMenu.addChild(menuBG);
			
			//创建Buttons
			createButtons();
			
		}
		
		private function createButtons():void
		{
			var textures:Vector.<Texture>=Assets.getAtlas().getTextures("menu_button");
			var len:int=buttonNames.length;
			for each(var sceneToCreate:Array in scenesToCreate){
				var index:int=scenesToCreate.indexOf(sceneToCreate);
				var sceceTitle:String=sceneToCreate[0];
				var sceneClass:Class=sceneToCreate[1];
				var texture:Texture=textures[index] as Texture;
				var button:Button=new Button(texture,"");
				button.x=buttonXs[index];
				button.y=buttonYs[index];
				button.width=buttonWidths[index];
				button.height=buttonHeights[index];
				button.name=getQualifiedClassName(sceneClass);
				button.addEventListener(Event.TRIGGERED,onButtonTriggered);
				mMainMenu.addChild(button);
			}
			
			var exitBtn:Button=new Button(textures[4] as Texture,"");
			exitBtn.x=buttonXs[4];
			exitBtn.y=buttonYs[4];
			exitBtn.width=buttonWidths[4];
			exitBtn.height=buttonHeights[4];
			exitBtn.name="Exit";
			exitBtn.addEventListener(Event.TRIGGERED,onButtonTriggered);
			mMainMenu.addChild(exitBtn);
			
			//监听返回事件
			addEventListener(Scene.CLOSING,onSceneClosing);
			addEventListener(Scene.STARTGAME,startGame);
		}

		private function startGame(event:Event):void
		{
			mCurrentScene.removeFromParent(true);
			mCurrentScene=null;
			
			mCurrentScene=new GameScene() as Scene;
			mMainMenu.visible=false;
			addChild(mCurrentScene);
		}
		
		private function onButtonTriggered(e:Event):void
		{
			var button:Button=e.target as Button;
			if(button.name=="Exit"){
				NativeApplication.nativeApplication.exit();
				return;
			}
			showScene(button.name);
		}
		
		private function showScene(name:String):void
		{
			if(mCurrentScene)return;
			
			var sceneClass:Class= getDefinitionByName(name) as Class;
			mCurrentScene=new sceneClass() as Scene;
			mMainMenu.visible=false;
			addChild(mCurrentScene);
			//隐藏广告
			ad.hideAd();
			
		}
		
		private function onSceneClosing(e:Event):void
		{
			mCurrentScene.removeFromParent(true);
			mCurrentScene=null;
			mMainMenu.visible=true;
			//显示广告
			ad.showAd(0, 800 - 38, 400, 38);
		}
		
	}
}