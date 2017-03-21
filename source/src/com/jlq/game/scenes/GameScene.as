package com.jlq.game.scenes
{
	import com.greensock.TweenLite;
	import com.jlq.game.events.DividedEvent;
	import com.jlq.game.objects.Block;
	import com.jlq.game.objects.BlockConst;
	import com.jlq.game.objects.Boss;
	import com.jlq.game.objects.Player;
	import com.jlq.game.sound.DSound;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class GameScene extends Scene
	{	
		private static const SPEED:Number=1;
		
		private var atlas:TextureAtlas=Assets.getAtlas();
		
		private var tipImageButton:Button;
		private var helpButton:Button;
		
		private var bombImage:Image;		//炸弹爆炸的效果
		
		private var startButton:Button;		//开始按钮
		private var pauseButton:Button;		//暂停按钮
		private var player:Player;
		private var boss:Boss;
		private var currentBlock:Block;		//当前正在下落的Block
		private var bossBlock:Block;		//Boss手里的Block
		
		private var timer:Timer;		//投放石块的计时器
		private var DELAY_TIME:int = 2000;	//投放石块的计时器延时
		private var bgSound:DSound;		//背景音乐
		private var bossMinX:Number;
		private var bossMaxY:Number;
		
		private var _isLosed:Boolean=false;
		
		public function GameScene()
		{
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}

		/**
		 * 检测
		 * */
		private function checking(event:EnterFrameEvent):void
		{
			//检测currentBlock与Player是否相撞
			if(currentBlock == null)
				return;
			
			//currentBlock压到Player
			if((player.x==currentBlock.x||player.x==currentBlock.x+(currentBlock.width-Const.GRID_ITEM_WIDTH))&&player.y<=currentBlock.y+currentBlock.height){
				if(currentBlock.kind!=Block.BOMB){
					player.deadByYa();
				}
				endGame();
			}
			
			//检测Player是否逃出洞口
			if (player.y <= 175) {
				winGame();
			}
		}
		
		private function winGame():void
		{
			pauseGame();	//暂停游戏
			showGameTip("menu_tip03");
		}
		
		/**
		 * 手指触控屏幕事件处理函数
		 * */
		private function touchHandler(event:TouchEvent):void
		{
			var col:uint=(player.x-Const.GRID_MARGIN_LEFT)/Const.GRID_ITEM_WIDTH;
			var row:uint=(player.y-Const.GRID_MARGIN_TOP)/Const.GRID_ITEM_WIDTH;
			var touch:Touch=event.getTouch(stage);
			var location:Point=touch.getLocation(stage);
			
			//有效触控范围判断
			if(location.y <= Const.GRID_MARGIN_TOP || location.y >= Const.GRID_MARGIN_BOTTOM){
				return;
			}
			
			if(touch.phase==TouchPhase.BEGAN){
				//手指点下去
				if(location.x < player.x){//向左走
					if(player.isStopped&&isBlocked(Const.DIR_LEFT)){
						//判断能否向左上走
						if(Const.blankArray[row+1][col-1]!=0&&Const.blankArray[row][col-1]!=1&&Const.blankArray[row-1][col-1]!=1&&Const.blankArray[row-1][col]!=1){
							player.moveToLeftUp();
						}
						//判断能否向左走
						if(Const.blankArray[row+1][col-1]!=1&&Const.blankArray[row][col-1]!=1){
							if(Const.blankArray[row+2][col-1]!=1){//能否下移
								for(var i:uint=0;i<12;i++){	//遍历Const.blankArray数组，判断能否继续下移
									if(Const.blankArray[row+2+i][col-1]!=0){
										break;
									}
								}
								player.moveToLeftDown(player.y + 45*i);
							}
							else{
								player.moveToLeft(player.targetX - Const.GRID_ITEM_WIDTH);
							}
						}
						boss.targetX = player.targetX;
					}
					if(boss.isHaved)
					{
						boss.moveToLeft(player.targetX);
					}
				}
				else if(location.x > player.x){//向右走
					if(player.isStopped&&isBlocked(Const.DIR_RIGHT))
					{
						//↗走
						if(Const.blankArray[row+1][col+1]!=0&&Const.blankArray[row][col+1]!=1&&Const.blankArray[row-1][col+1]!=1&&Const.blankArray[row-1][col]!=1){
							player.moveToRightUp();
						}
						
						//→方向走
						if(Const.blankArray[row+1][col+1]!=1&&Const.blankArray[row][col+1]!=1){
							
							//看能够继续下移
							if(Const.blankArray[row+2][col+1]!=1){
								for(var j:uint=0;j<12;j++){//遍历Const.blankArray数组，判断能否继续下移
									if(Const.blankArray[row+2+j][col+1]!=0){
										break;
									}
								}
								player.moveToRightDown(player.y + 45*j);
							}
							else{
								player.moveToRight(player.targetX + Const.GRID_ITEM_WIDTH);
							}
						}
						
						boss.targetX = player.targetX;
					}
					if(boss.isHaved)
					{
						boss.moveToRight(player.targetX);
					}
				}
			}	
			else if(touch.phase == TouchPhase.ENDED){
			
			}
		}
		
		/**
		 * Player在左右移动过程中是否被正在下落的Block阻挡
		 * */
		private function isBlocked(direction:uint):Boolean
		{
			//0则没有阻挡,1为阻挡
			var flag:int=0;
			if(currentBlock!=null){
				switch(direction){
					case Const.DIR_LEFT:
						if ((player.x == currentBlock.x + currentBlock.width) && player.y < currentBlock.y + currentBlock.height)
							flag=1;
						break;
					case Const.DIR_RIGHT:
						if ((player.x + Const.GRID_ITEM_WIDTH == currentBlock.x) && player.y < currentBlock.y + currentBlock.height)
							flag=1;
						break;
				}
			}
			
			return flag==0?true:false;
		}
		
		private function onRemoved(event:Event):void
		{
			//关闭背景音乐
			soundManager.stopBackgroundMusic();
			
			//保存GameState
			if(!Const.ishelped){
				gameState.save();
			}
			
			//移除计时器
			if(timer.running){
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,timerCompleteHandler);
				timer = null;
			}
			
			//移除Boss
			boss.removeEventListeners();
			removeChild(boss,true);
			//移除Player
			player.removeEventListeners();
			removeChild(player,true);
			//移除所有石块
			if(currentBlock!=null)
				removeChild(currentBlock);
			if(bossBlock!=null){
				bossBlock.removeEventListeners();
				removeChild(bossBlock,true);
			}
			
			//还原数组
			Const.reset();
		}

		private function onAdded(event:Event):void
		{
			//初始换变量
			initVars();
			
			//初始化场景
			initScene();
			
			//显示StartButton
			showStartButton();
			
		}

		/**
		 * 初始化变量
		 * */
		private function initVars():void
		{	
			bossMinX = -92;
			bossMaxY = Const.GRID_MARGIN_TOP+60;
			
			//初始化计时器
			timer = new Timer(DELAY_TIME);
			timer.addEventListener(TimerEvent.TIMER, timerCompleteHandler);
		}

		private function timerCompleteHandler(event:TimerEvent):void
		{
			if(boss.direction==Const.DIR_LEFT){
				boss.switchState(Boss.THROW_LEFT);
			}
			else if(boss.direction==Const.DIR_RIGHT){
				boss.switchState(Boss.THROW_RIGHT);
			}
			
			//停止计时器
			timer.stop();
			//扔Block
			boss.throwBlock();
			currentBlock = bossBlock;
			currentBlock.addEventListener(Block.BLOCK_STOPPED,blockStopped);
			currentBlock.addEventListener(DividedEvent.DIVIDED,blockDividedHandler);
			//currentBlock.startDown(player.y+(Const.GRID_ITEM_WIDTH*2 - currentBlock.height));
			currentBlock.startDown();
			bossBlock=null;
			
			trace("timeout");
		}

		/**
		 * Block需要Divided
		 * */
		private function blockDividedHandler(event:DividedEvent):void
		{
			var block:Block=event.target as Block;
			var direction:uint=event.dividedDirection;
			var temp1:Block=new Block();
			var temp2:Block=new Block();
			var preX:Number=block.x;
			var preY:Number=block.y;
			
			currentBlock.removeEventListener(Block.BLOCK_STOPPED,blockStopped);
			currentBlock.removeFromParent(true);
			currentBlock=null;
			
			switch(block.kind){
				case Block.CLAY:
					temp1.kind=Block.CLAY;
					temp1.switchCustom(BlockConst.CLAY_MIDDLE);	//长
					temp2.kind=Block.CLAY;
					temp2.switchCustom(BlockConst.CLAY_SINGLE);	//短
					
					if(block.flagArray[0][0]==1){//左二右一型
						temp1.x=preX;
						temp1.y=preY;
						temp2.x=preX+Const.GRID_ITEM_WIDTH;
						temp2.y=preY+Const.GRID_ITEM_WIDTH;
						addChild(temp1);
						addChild(temp2);
						if(direction==Const.DIR_LEFT){
							updateBlankArray(temp2,temp2.flagArray);
							Const.blockArray.push(temp2);
							currentBlock=temp1;
							currentBlock.addEventListener(Block.BLOCK_STOPPED,blockStopped);
							currentBlock.startDown();
						}
						else if(direction==Const.DIR_RIGHT){
							updateBlankArray(temp1,temp1.flagArray);
							Const.blockArray.push(temp1);
							currentBlock=temp2;
							currentBlock.addEventListener(Block.BLOCK_STOPPED,blockStopped);
							currentBlock.startDown();
						}
					}
					else{//左一右二型
						temp1.x=preX+Const.GRID_ITEM_WIDTH;
						temp1.y=preY;
						temp2.x=preX;
						temp2.y=preY+Const.GRID_ITEM_WIDTH;
						addChild(temp1);
						addChild(temp2);
						if(direction==Const.DIR_LEFT){
							updateBlankArray(temp1,temp1.flagArray);
							Const.blockArray.push(temp1);
							currentBlock=temp2;
							currentBlock.addEventListener(Block.BLOCK_STOPPED,blockStopped);
							currentBlock.startDown();
						}
						else if(direction==Const.DIR_RIGHT){
							updateBlankArray(temp2,temp2.flagArray);
							Const.blockArray.push(temp2);
							currentBlock=temp1;
							currentBlock.addEventListener(Block.BLOCK_STOPPED,blockStopped);
							currentBlock.startDown();
						}
					}
					break;
				case Block.SEND:
					temp1.kind=Block.SEND;
					temp1.switchCustom(BlockConst.SEND_SINGLE);//短
					temp2.kind=Block.SEND;
					temp2.switchCustom(BlockConst.SEND_SINGLE);//短
					temp1.x=preX;
					temp1.y=temp2.y=preY;
					temp2.x=preX+Const.GRID_ITEM_WIDTH;
					this.addChild(temp1);
					this.addChild(temp2);
					if(direction==Const.DIR_LEFT){
						updateBlankArray(temp2,temp2.flagArray);
						Const.blockArray.push(temp2);
						currentBlock=temp1;
						currentBlock.addEventListener(Block.BLOCK_STOPPED,blockStopped);
						currentBlock.startDown();
					}
					else if(direction==Const.DIR_RIGHT){
						updateBlankArray(temp1,temp1.flagArray);
						Const.blockArray.push(temp1);
						currentBlock=temp2;
						currentBlock.addEventListener(Block.BLOCK_STOPPED,blockStopped);
						currentBlock.startDown();
					}
					break;
				case Block.STONE:
					break;
			}
			trace("direction",direction);
		}

		/**
		 * 当前Block停止下落
		 * */
		private function blockStopped(event:Event):void
		{
			//判断是不是炸弹
			if (currentBlock.kind == Block.BOMB) {
				soundManager.play(Assets.BombSound);
				fireBomb(currentBlock);
			}
			else {
				//根据不同的石块类型播放不同的音效
				switch(currentBlock.kind) {
					case Block.CLAY:
						soundManager.play(Assets.ClaySound);
						break;
					case Block.SEND:
						soundManager.play(Assets.SendSound);
						break;
					case Block.STONE:
						soundManager.play(Assets.StoneSound);
						break;
				}
				
				//存入blockArray
				Const.blockArray.push(currentBlock);
				//更新Const.blankArray
				updateBlankArray(currentBlock,currentBlock.flagArray);
				trace("blockArray length=",Const.blockArray.length);
			}
			
			//判断play是否被困死,//判断坑是否被填满，即是否有石块坐标超过最高点
			if (isBlockedToDie() || currentBlock.y <= 175) {
				blockedToDie();
			}
			currentBlock=null;
			if(!_isLosed)
			{
				timer.start();
			}
		}

		/**
		 * 玩家被困死
		 * */
		private function blockedToDie():void
		{
			pauseGame();
			endGame();
			showGameTip("menu_tip01");
		}
		
		/**
		 * 检测Player是否被困死
		 * */
		private function isBlockedToDie():Boolean
		{
			var flag:int=0;		//0为假表示没有被阻塞，1为真表示被阻塞
			var col:uint=(player.x-Const.GRID_MARGIN_LEFT)/Const.GRID_ITEM_WIDTH;
			var row:uint=(player.y-Const.GRID_MARGIN_TOP)/Const.GRID_ITEM_WIDTH;
			
			if(col==0&&Const.blankArray[row][1]==1){
				flag=1;
			}
			else if(col==7&&Const.blankArray[row][6]==1){
				flag=1;
			}
			else if(Const.blankArray[row][col-1]==1&&Const.blankArray[row][col+1]==1){
				flag=1;
			}
			
			return flag==0?false:true;
		}
		
		/**
		 * 点燃炸弹
		 * */
		private function fireBomb(bomb:Block):void
		{
			var effectedArray:Array=[];
			
			bombImage=new Image(atlas.getTexture("item_BombBang"));
			bombImage.x=currentBlock.x-(bombImage.width-currentBlock.width)/2;
			bombImage.y=currentBlock.y+(bombImage.height-currentBlock.height)/2;
			bombImage.addEventListener(Event.ADDED_TO_STAGE,bombImageAdded);
			addChild(bombImage);
			
			for each(var block:Block in Const.blockArray){
				var effectedFlagArr:Array=[];
				var tempArr:Array=block.flagArray;
				var index:int;
				
				//判断形状
				//一个Item
				if(tempArr[0][0]==1&&tempArr[0][1]==0&&tempArr[1][0]==0){
					//判断受不受影响
					if(block.x>=bomb.x-45&&block.x<=bomb.x+45&&block.y>=bomb.y-45&&block.y<=bomb.y+45){
						effectedFlagArr=[[0,0],[0,0]];
						block.effectedFlagArr=effectedFlagArr;
						effectedArray.push(block);
					}
				}
				//两个Item
				else if(tempArr[0][0]==1&&(tempArr[0][1]==1||tempArr[1][0]==1)&&tempArr[1][1]==0){
					//判断方向
					if(tempArr[0][1]==1){	//横着
						//判断是不是受影响
						if(block.x>=bomb.x-90&&block.x<=bomb.x+45&&block.y>=bomb.y-45&&block.y<=bomb.y+45){
							switch(block.x){
								case bomb.x-90:
									effectedFlagArr=[[1,0],[0,0]];
									break;
								case bomb.x+45:
									effectedFlagArr=[[0,1],[0,0]];
									break;
								default:
									effectedFlagArr=[[0,0],[0,0]];
									break;
							}
							block.effectedFlagArr=effectedFlagArr;
							effectedArray.push(block);
						}
					}
					else if(tempArr[1][0]==1){//竖着
						//判断是否受影响
						if(block.x>=bomb.x-45&&block.x<=bomb.x+45&&block.y>=bomb.y-90&&block.y<=bomb.y+45){
							switch(block.x){
								case bomb.x-45:
									switch(block.y){
										case bomb.y-90:
											effectedFlagArr=[[1,0],[0,0]];
											break;
										case bomb.y+45:
											effectedFlagArr=[[0,0],[1,0]];
											break;
										default:
											effectedFlagArr=[[0,0],[0,0]];
											break;
										
									}
									break;
								case bomb.x:
									effectedFlagArr=[[0,0],[1,0]];
									break;
								case bomb.x+45:
									switch(block.y){
										case bomb.y-90:
											effectedFlagArr=[[1,0],[0,0]];
											break;
										case bomb.y+45:
											effectedFlagArr=[[0,0],[1,0]];
											break;
										default:
											effectedFlagArr=[[0,0],[0,0]];
											break;
										
									}
									break;
							}
							block.effectedFlagArr=effectedFlagArr;
							effectedArray.push(block);
						}
					}
				}
				//三个Item组成
				else{
					if(tempArr[0][0]==1){//左2右1形
						//判断是否受影响
						if(block.x>=bomb.x-90&&block.x<=bomb.x+45&&block.y>=bomb.y-90&&block.y<=bomb.y+45){
							switch(block.x){
								case bomb.x-90:
									switch(block.y){
										case bomb.y+45:
											effectedFlagArr=block.flagArray;
											break;
										default:
											effectedFlagArr=[[1,0],[1,0]];
											break;
									}
									break;
								case bomb.x-45:
									switch(block.y){
										case bomb.y:
											effectedFlagArr=[[0,0],[0,0]];
											break;
										case bomb.y+45:
											effectedFlagArr=[[0,0],[1,1]];
											break;
									}
									break;
								case bomb.x:
									effectedFlagArr=[[0,0],[1,1]];
									break;
								case bomb.x+45:
									switch(block.y){
										case bomb.y-90:
											effectedFlagArr=[[1,0],[0,1]];
											break;
										case bomb.y+45:
											effectedFlagArr=[[0,0],[1,1]];
											break;
										default:
											effectedFlagArr=[[0,0],[0,1]];
											break;
									}
									break;
							}
							block.effectedFlagArr=effectedFlagArr;
							effectedArray.push(block);
						}
					}
					else
					{//左1右2形
						if(block.x>=bomb.x-90&&block.x<=bomb.x+45&&block.y>=bomb.y-90&&block.y<=bomb.y+45)
						{
							switch(block.x){
								case bomb.x-90:
									switch(block.y){
										case bomb.y-90:
											effectedFlagArr=[[0,1],[1,0]];
											break;
										case bomb.y+45:
											effectedFlagArr=[[0,0],[1,1]];
											break;
										default:
											effectedFlagArr=[[0,0],[1,0]];
											break;
									}
									break;
								case bomb.x-45:
									effectedFlagArr=[[0,0],[1,1]];
									break;
								case bomb.x:
									switch(block.y){
										case bomb.y:
											effectedFlagArr=[[0,0],[0,0]];
											break;
										case bomb.y+45:
											effectedFlagArr=[[0,0],[1,1]];
											break;
									}
									break;
								case bomb.x+45:
									switch(block.y){
										case bomb.y+45:
											effectedFlagArr=block.flagArray;
											break;
										default:
											effectedFlagArr=[[0,1],[0,1]];
											break;
									}
									break;
							}
							block.effectedFlagArr=effectedFlagArr;
							effectedArray.push(block);
						}
					}
				}
			}
			
			//遍历受影响数组
			if(effectedArray!=null&&effectedArray.length>0){
				for(var t:int=0;t<effectedArray.length;t++){
					var temp:Block = effectedArray[t] as Block;
					temp.updateBlockImage();	//更新Image
				}
			}
			
			effectedArray.splice(0,effectedArray.length-1);
			
			//将炸弹影响区域置为0
			removeBombBlank(bomb);
			
			//判断Player是否炸死
			if(player.x>=currentBlock.x-Const.GRID_ITEM_WIDTH&&player.x<=currentBlock.x+Const.GRID_ITEM_WIDTH){
				_isLosed=true;
				player.deadByBombed();
				endGame();
			}
			//移除炸弹
			currentBlock.removeFromParent(true);
		}

		/**
		 * 收到炸弹影响区域置为0
		 * */
		private function removeBombBlank(block:Block):void
		{
			var row:int=(block.y-Const.GRID_MARGIN_TOP)/Const.GRID_ITEM_WIDTH;
			var col:int=(block.x-Const.GRID_MARGIN_LEFT)/Const.GRID_ITEM_WIDTH;
			
			for(var i:uint=0;i<3;i++){
				if(row-1+i<=13){
					for(var j:uint=0;j<3;j++){
						if(col-1+j<=7){
							Const.blankArray[row-1+i][col-1+j]=0;
						}
					}
				}
			}
		}

		/**
		 * bombImage添加到舞台处理函数
		 * */
		private function bombImageAdded(event:Event):void
		{
			TweenLite.to(bombImage,1,{alpha:0});
		}

		/**
		 * 更新blankArray
		 * */
		private function updateBlankArray(block:Block,array:Array):void
		{
			var col:uint=(block.x-Const.GRID_MARGIN_LEFT)/Const.GRID_ITEM_WIDTH;
			var row:uint=(block.y-Const.GRID_MARGIN_TOP)/Const.GRID_ITEM_WIDTH;
			trace("col=",col);
			trace("row=",row);
			
			for(var i:uint=0;i<2;i++){
				//判断索引出界
				if(row+i<=13){
					for(var j:uint=0;j<2;j++){
						if(col+j<=7){
							if(array[i][j]!=0){
								Const.blankArray[row+i][col+j]=array[i][j];
							}
						}
					}
				}
			}
			//打印Const.blankArray
			for(var t:uint=0;t<Const.blankArray.length;t++){
				trace(Const.blankArray[t]);
			}
			
		}
		
		/**
		 * 初始化游戏场景
		 * */
		private function initScene():void
		{
			//添加背景图片
			var bgImage:Image=new Image(getBGTextureByLevel(Const.selectedLevel));
			addChildAt(bgImage,0);
			//添加背景音乐
			switch(Const.selectedLevel) {
				case 1:
					soundManager.playBackgroundMusic(Assets.BgSoundLevel1);
					break;
				case 2:
					soundManager.playBackgroundMusic(Assets.BgSoundLevel2);
					break;
			}
			
			youmiAd.showAd(0, 800-38, 400, 38);
			
			//创建Player
			createPlayer();
			//创建Boss
			createBoss();
		}
		
		/**
		 * 添加Boss
		 * */
		private function createBoss():void
		{
			boss=new Boss();
			boss.pivotX=0;
			boss.pivotY=boss.height;
			boss.x=boss.targetX=bossMinX;
			//boss.x=player.x;
			boss.y=bossMaxY;
			boss.addEventListener(Boss.START_POINT_ARRIVED,backToStartpoint);
			addChild(boss);
		}

		/**
		 * Boss回到起点
		 * */
		private function backToStartpoint(event:Event):void
		{
			createBlock();
		}
		
		/**
		 * 添加Player
		 * */
		private function createPlayer():void
		{
			player = new Player();
			player.width=Const.GRID_ITEM_WIDTH;
			player.height=Const.GRID_ITEM_WIDTH*2;
			player.pivotX=0;
			player.pivotY=0;
			player.targetX=player.x;
			player.addEventListener(Player.DIED_BY_BOMBBED,playerDiedByBombbed);
			player.addEventListener(Player.DIED_BY_YA,playerDiedByYa);
			addChild(player);
		}

		/**
		 * 被炸死
		 * */
		private function playerDiedByBombbed(event:Event):void
		{
			//暂停游戏
			pauseGame();
			//显示提示
			showGameTip("menu_tip02");
		}

		/**
		 * 被压死
		 * */
		private function playerDiedByYa(event:Event):void
		{
			//暂停游戏
			pauseGame();
			//显示提示
			showGameTip("menu_tip02");
		}
		
		private function createBlock():void
		{
			bossBlock=new Block();
			bossBlock.pivotX=0;
			bossBlock.pivotY=0;
			bossBlock.x = boss.x + bossBlock.width/2;
			bossBlock.y = boss.y - boss.height - bossBlock.height + 20;
			bossBlock.addEventListener(Event.ADDED_TO_STAGE,blockAddedHandler);
			addChild(bossBlock);
		}

		private function blockAddedHandler(event:Event):void
		{
			boss.myBlock=bossBlock;
			boss.isHaved=true;
			boss.isMoving=true;
			boss.backToScene(player.targetX);
		}
		
		/**
		 * 根据所选的关卡来选择关卡背景贴图
		 * */
		private function getBGTextureByLevel(currentLevel:int):Texture
		{
			var texture:Texture;
			switch(currentLevel){
				case 1:
					texture=atlas.getTexture("bg_level1");
					break;
				case 2:
					texture=atlas.getTexture("bg_level2");
					break;
			}
			return texture;
		}
		
		/**
		 * 显示开始按钮
		 * */
		private function showStartButton():void
		{
			startButton=new Button(atlas.getTexture("menu_button_start02"),"");
			startButton.pivotX=startButton.width/2;
			startButton.pivotY=startButton.height/2;
			startButton.x=Const.CenterX;
			startButton.y=Const.CenterY;
			startButton.name="start";
			startButton.addEventListener(Event.TRIGGERED,buttonTriggeredHandler);
			addChild(startButton);
		}
		
		/**
		 * 显示暂停按钮
		 * */
		private function showPauseButton():void
		{
			pauseButton = new Button(atlas.getTexture("menu_pause"),"");
			pauseButton.x = 480 - pauseButton.width - 10;
			pauseButton.y = 20;
			pauseButton.name="pause";
			pauseButton.addEventListener(Event.TRIGGERED,buttonTriggeredHandler);
			addChild(pauseButton);
		}
		
		/**
		 * 响应startButton pauseButton按钮的点击事件处理
		 * */
		private function buttonTriggeredHandler(event:Event):void
		{
			var button:Button = event.target as Button;
			switch(button.name){
				case "start":
					trace("start game");
					startButton.removeEventListener(Event.TRIGGERED,buttonTriggeredHandler);
					startButton.removeFromParent(true);
					//显示暂停按钮
					showPauseButton();
					//开始游戏
					beginGame();
					break;
				case "pause":
					trace("pause game");
					pauseButton.removeEventListener(Event.TRIGGERED,buttonTriggeredHandler);
					pauseButton.removeFromParent(true);
					//显示开始按钮
					showStartButton();
					//暂停游戏
					pauseGame();
					break;
			}
		}

		/**
		 * 暂停游戏
		 * */
		private function pauseGame():void
		{
			if(boss!=null){
				boss.pauseMove();
			}
			if(currentBlock!=null){
				currentBlock.pauseMove();
			}
			
			timer.stop();
			
			removeEventListener(Event.ENTER_FRAME,checking);
			this.removeEventListener(TouchEvent.TOUCH,touchHandler);
		}

		/**
		 * 开始游戏
		 * */
		private function beginGame():void
		{	
			if(!boss.isHaved&&currentBlock==null){
				createBlock();
			}
			
			if (!Const.ishelped) {
				gointoTutorials();
				return;
			}
			
			if(boss!=null){
				boss.restartMove();
			}
			
			if(currentBlock!=null){
				currentBlock.restartMove();
			}
			
			if(currentBlock==null){
				timer.start();
			}
			
			addEventListener(Event.ENTER_FRAME,checking);
			this.addEventListener(TouchEvent.TOUCH, touchHandler);	//舞台监听点击事件
		}
		
		/**
		 * 进入教程
		 * */
		private function gointoTutorials():void
		{
			helpButton=new Button(atlas.getTexture("click_help0000"));
			helpButton.x=300;
			helpButton.y=600;
			helpButton.addEventListener(Event.TRIGGERED,helpButtonTriggered);
			addChild(helpButton);		
			
		}

		private function helpButtonTriggered(event:Event):void
		{
			var button:Button = event.target as Button;
			switch(button.x){
				case 100:	
					player.moveToLeft(player.targetX - Const.GRID_ITEM_WIDTH);
					boss.moveToLeft(player.targetX);
					
					helpButton.removeEventListener(Event.TRIGGERED,helpButtonTriggered);
					helpButton.removeFromParent(true);
					helpButton = null;
					
					Const.ishelped=true;
					gameState.ishelped=true;
					
					beginGame();
					
					break;
				case 300:
					helpButton.x -= 200;
					helpButton.y = 600;
					player.moveToRight(player.targetX + Const.GRID_ITEM_WIDTH);
					boss.moveToRight(player.targetX);
					break;
			}
		}
		
		/**
		 * 结束游戏
		 * */
		private function endGame():void
		{
			_isLosed=true;
			pauseButton.enabled=false;
			removeEventListener(TouchEvent.TOUCH,touchHandler);
			removeEventListener(Event.ENTER_FRAME,checking);
		}
	
		private function showGameTip(textureName:String):void
		{
			tipImageButton=new Button(atlas.getTexture(textureName),"");
			tipImageButton.pivotX=tipImageButton.width/2;
			tipImageButton.pivotY=tipImageButton.height/2;
			tipImageButton.x=Const.CenterX;
			tipImageButton.y=Const.CenterY;
			tipImageButton.addEventListener(Event.TRIGGERED,restartGameHandler);
			addChild(tipImageButton);
		}

		private function restartGameHandler(event:Event):void
		{
			tipImageButton.removeEventListener(Event.TRIGGERED,restartGameHandler);
			removeChild(tipImageButton);
			tipImageButton=null;
			
			//restartGame();
			startGame();
		}
		
		public override function dispose():void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			super.dispose();
		}
	}
}