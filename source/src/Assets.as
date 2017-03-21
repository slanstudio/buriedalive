package
{
	import flash.display.Bitmap;
	import flash.media.Sound;
	import flash.text.Font;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class Assets
	{
		//Texture Atlas
		[Embed(source="../build/media/textures/atlas.png")]
		private static const AtlasTexture:Class;
		
		[Embed(source="../build/media/textures/atlas.xml",mimeType="application/octet-stream")]
		private static const AtlasXml:Class;
		
		//Bitmaps
//		[Embed(source="../build/media/sprites/bg/menu.png")]
//		private static const MenuBG:Class;	//主菜单背景
//		
		[Embed(source="../build/media/sprites/bg/bg_help.png")]
		public static const HelpBGClass:Class;	//帮助界面背景
//		
//		[Embed(source="../build/media/sprites/bg/level1.png")]
//		private static const BackgroundLevel1:Class;	//第一关背景
//		
//		[Embed(source="../build/media/sprites/bg/level2.png")]
//		private static const BackgroundLevel2:Class;	//第二关背景
		
		[Embed(source="../build/media/sprites/bg/bg_levelselect.png")]
		public static const LevelSelectBGClass:Class;
		
		[Embed(source="../build/media/sprites/bg/abort.png")]
		public static const AbortBGClass:Class;
		
		//Sounds
		
		[Embed(source="../build/media/audios/bgSoundLevel1.mp3")]
		public static const BgSoundLevel1:Class;	//第一关背景音乐
		
		[Embed(source="../build/media/audios/bgSoundLevel2.mp3")]
		public static const BgSoundLevel2:Class;	//第二关背景音乐
		
		[Embed(source = "../build/media/audios/claySound.mp3")]
		public static const ClaySound:Class;		//土块下落声音
		
		[Embed(source = "../build/media/audios/sendSound.mp3")]
		public static const SendSound:Class;		//沙块下落声音
		
		[Embed(source = "../build/media/audios/stoneSound.mp3")]
		public static const StoneSound:Class;		//石块下落声音
		
		[Embed(source = "../build/media/audios/bomb.mp3")]
		public static const BombSound:Class;		//炸弹爆炸声音
		
		[Embed(source = "../build/media/fonts/desyrel.png")]
		private static const DesyrelTexture:Class;
		
		private static var sTextures:Dictionary=new Dictionary();
		private static var sSounds:Dictionary=new Dictionary();
		private static var isFontsLoaded:Boolean=false;
		
		private static var sTextureAtlas:TextureAtlas;
		
		public static function getAtlas():TextureAtlas
		{
			if(sTextureAtlas==null){
				var texture:Texture = getTexture("AtlasTexture");
				var xml:XML = XML(new AtlasXml());
				sTextureAtlas = new TextureAtlas(texture,xml);
			}
			
			return sTextureAtlas;
		}
		
		/**
		 * 获得指定name的Sound对象
		 * */
		public static function getSound(name:String):Sound
		{
			var sound:Sound=sSounds[name] as Sound;
			if(sound) return sound;
			else throw new ArgumentError("Sound not Found:"+name);
		}
		
		/**
		 * 获得指定Name的Texture
		 * */
		public static function getTexture(name:String):Texture
		{
			if (sTextures[name] == undefined)
			{
				var data:Object = new Assets[name]();
				
				if (data is Bitmap)
					sTextures[name] = Texture.fromBitmap(data as Bitmap);
				else if (data is ByteArray)
					sTextures[name] = Texture.fromAtfData(data as ByteArray);
			}
			
			return sTextures[name];
		}
		
	}
}