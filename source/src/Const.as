package
{
	import starling.textures.Texture;

	public class Const
	{
		public static const GameWidth:int=480;
		public static const GameHeight:int=800;
		
		public static const CenterX:int=GameWidth/2;
		public static const CenterY:int=GameHeight/2;
		
		//Grid
		public static const GRID_ITEM_WIDTH:Number=45;
		public static const GRID_MARGIN_LEFT:Number=58;
		public static const GRID_MARGIN_TOP:Number=113;
		public static const GRID_MARGIN_BOTTOM:Number=742;
		public static const GRID_MARGIN_RIGHT:Number=418;
		
		//存储界面中已经停止下落的Block对象
		public static var blockArray:Array=[];
		
		//界面空格数组
		public static var blankArray:Array=[
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[1,1,1,1,1,1,1,1]
		];
		
		//音量设置
		public static var soundMetu:Boolean=false;
		
		//关卡选择
		public static var selectedLevel:int=1;	
		
		//帮助提示
		public static var ishelped:Boolean = false;
		
		//Player
		public static var PLAYER_CUSTOM_NAME:Vector.<String> = new <String>["role_standing","role_standingleft","role_standingright","role_movingleft","role_movingright","role_dyingleft","role_dyingright","role_diedbombleft","role_diedbombright"];
		public static var FPS:int=30;		//帧频
		public static var DIR_INIT:uint=0;	//初始方向
		public static var DIR_LEFT:uint=1;	//左方向
		public static var DIR_RIGHT:uint=2;	//右方向
		
		//Boss
		public static var BOSS2_CUSTOM_NAME:Vector.<String> = new <String>["boss01_downleft","boss01_upleft","boss01_downright","boss01_upright"];
		public static var BOSS1_CUSTOM_NAME:Vector.<String> = new <String>["boss02_downleft","boss02_upleft","boss02_downright","boss02_upright"];
		
		//Block
		public static var blockTextures:Vector.<Texture>=Assets.getAtlas().getTextures("item_");
		
		public static function reset():void
		{
			blankArray=[
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[1,1,1,1,1,1,1,1]
			];
			
			blockArray.splice(0,blockArray.length-1);
		}
	}
}