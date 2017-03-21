package com.jlq.game.objects
{
	import com.jlq.game.events.DividedEvent;
	import starling.events.EnterFrameEvent;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.events.Event;
	
	public class Block extends Sprite
	{
		private static const SPEED:Number = 2;
		
		public static const BLOCK_STOPPED:String = "block_stopped";
		
		public static const CLAY:uint = 1;	//土块
		public static const STONE:uint = 2;	//石块
		public static const SEND:uint = 3;	//沙块
		public static const BOMB:uint = 4;	//炸弹
		
		private var atlas:TextureAtlas = Assets.getAtlas();
		private var textures:Vector.<Texture>;
		
		private var _block:Image;
		private var _kind:uint;
		private var _flagArray:Array;
		private var _effectedFlagArr:Array;
		public var isStopped:Boolean = false;	//标志Block是否停止下落
		private var _isDown:Boolean = true;	//标志Block是否能够继续下落,False表示不能继续下落,true表示可以继续下落
		private var _targetY:Number=Const.GRID_MARGIN_BOTTOM;			//Block的目标下落Y位置
		private var _isDivided:Boolean = false;	//判断Block是否能够拆分下落
		private var _dividedDirection:uint;		//如果能够拆分下落，标志左边还是右边能够拆分下落
		
		public function Block()
		{
			super();
			
			textures = Const.blockTextures;
			
			switchCustom(genNum());
			
		}
		
		/**
		 * 产生指定范围的随机数
		 * @return
		 */
		private function genNum():int {
			var num:int = Math.floor(Math.random() * (textures.length - 1));
			while (num == BlockConst.BOMBBANG || num == BlockConst.CLAY_MIDDLE || num == BlockConst.CLAY_MIDDLE2 || num == BlockConst.SEND_LOW || num == BlockConst.STONE_MIDDLE || num == BlockConst.STONE_MIDDLE2) {
				num = Math.floor(Math.random()*(textures.length-1));
			}
			
			return num;
		}
		
		/**
		 * 改变Block外观
		 * @param	num
		 */
		public function switchCustom(num:uint):void
		{
			if (_block != null) {
				_block.removeFromParent(true);
			}
			
			switch(num){
				case BlockConst.BOMB:
					_block = new Image(textures[BlockConst.BOMB] as Texture);
					_kind = BOMB;
					flagArray = [[1, 0], [0, 0]];
					break;
				case BlockConst.BOMBBANG:
					_block = new Image(textures[BlockConst.BOMBBANG] as Texture);
					break;
				case BlockConst.CLAY_LEFT:
					_block = new Image(textures[BlockConst.CLAY_LEFT] as Texture);
					_kind = CLAY;
					flagArray = [[1, 0], [1, 1]];
					break;
				case BlockConst.CLAY_MIDDLE:
					_block = new Image(textures[BlockConst.CLAY_MIDDLE] as Texture);
					_kind = CLAY;
					flagArray = [[1, 0], [1, 0]];
					break;
				case BlockConst.CLAY_MIDDLE2:
					_kind = CLAY;
					_block = new Image(textures[BlockConst.CLAY_MIDDLE2] as Texture);
					flagArray = [[1, 1], [0, 0]];
					break;
				case BlockConst.CLAY_RIGHT:
					_block = new Image(textures[BlockConst.CLAY_RIGHT] as Texture);
					_kind = CLAY;
					flagArray = [[0, 1], [1, 1]];
					break;
				case BlockConst.CLAY_SINGLE:
					_block = new Image(textures[BlockConst.CLAY_SINGLE] as Texture);
					_kind = CLAY;
					flagArray = [[1, 0], [0, 0]];
					break;
				case BlockConst.SEND_HIGH:
					_block = new Image(textures[BlockConst.SEND_HIGH] as Texture);
					_kind = SEND;
					flagArray = [[1, 0], [1, 0]];
					break;
				case BlockConst.SEND_LOW:
					_block = new Image(textures[BlockConst.SEND_LOW] as Texture);
					_kind = SEND;
					flagArray = [[1, 1], [0, 0]];
					break;
				case BlockConst.SEND_SINGLE:
					_block = new Image(textures[BlockConst.SEND_SINGLE] as Texture);
					_kind = SEND;
					flagArray = [[1, 0], [0, 0]];
					break;
				case BlockConst.STONE_LEFT:
					_block = new Image(textures[BlockConst.STONE_LEFT] as Texture);
					_kind = STONE;
					flagArray = [[1, 0], [1, 1]];
					break;
				case BlockConst.STONE_MIDDLE:
					_block = new Image(textures[BlockConst.STONE_MIDDLE] as Texture);
					_kind = STONE;
					flagArray = [[1, 0], [1, 0]];
					break;
				case BlockConst.STONE_MIDDLE2:
					_block = new Image(textures[BlockConst.STONE_MIDDLE2] as Texture);
					_kind = STONE;
					flagArray = [[1, 1], [0, 0]];
					break;
				case BlockConst.STONE_RIGHT:
					_block = new Image(textures[BlockConst.STONE_RIGHT] as Texture);
					_kind = STONE;
					flagArray = [[0, 1], [1, 1]];
					break;
				case BlockConst.STONE_SINGLE:
					_block = new Image(textures[BlockConst.STONE_SINGLE] as Texture);
					_kind = STONE;
					flagArray = [[1, 0], [0, 0]];
					break;
			}
			
			addChild(_block);
		}
		
		/**
		 * block开始自行下落
		 * */
		public function startDown():void
		{
			isStopped = false;
			addEventListener(Event.ENTER_FRAME, moveBlockHandler);
		}
		
		/**
		 * block停止运动
		 */
		private function stopMove():void
		{
			isStopped = true;
			if (!_isDivided) {//如果既不能拆分下落又不能继续下落则派发停止下落事件
				dispatchEvent(new Event(BLOCK_STOPPED, true));
			}
			removeEventListener(Event.ENTER_FRAME, moveBlockHandler);
		}
		
		/**
		 * 暂停运动
		 */
		public function pauseMove():void
		{
			removeEventListener(Event.ENTER_FRAME, moveBlockHandler);
		}
		
		/**
		 * 重新开始运动
		 */
		public function restartMove():void
		{
			addEventListener(EnterFrameEvent.ENTER_FRAME, moveBlockHandler);
		}
		
		private function moveBlockHandler(e:EnterFrameEvent):void
		{
			//判断block正要下落时候X位置是否正确
			var col:uint = (this.x - Const.GRID_MARGIN_LEFT) / Const.GRID_ITEM_WIDTH;
			if (this.x != Const.GRID_ITEM_WIDTH * col + Const.GRID_MARGIN_LEFT) {
				this.x = Const.GRID_ITEM_WIDTH * col + Const.GRID_MARGIN_LEFT;
				return;
			}
			
			//判断block是否进入游戏有效界面里
			if (this.y < Const.GRID_MARGIN_TOP) {
				this.y += SPEED;
				return;
			}
			
			//检测是否可以下落
			if (_isDown) {
				checkDown();
			}
			
			//可以下落或者不可以下落但是并没有超过目标Y位置
			if (_isDown || (this.y + SPEED <= _targetY && !_isDown)) {
				this.y += SPEED;
			}
			//不可以继续下落并且已经超过目标Y位置
			if (!_isDown && this.y + SPEED > _targetY) {
				this.y = _targetY;
			}
			
			//判断到达targetY位置时是否能够拆分下落
			if (this.y == _targetY) {
				if (!checkDivided()) {	//如果不能拆分下落就停止下落
					stopMove();
				}
				else {	//如果能拆分下落则派发拆分下落事件
					dispatchEvent(new DividedEvent(DividedEvent.DIVIDED, _dividedDirection, true));
				}
			}
		}
		
		/**
		 * 检测Block能够拆分下落
		 * @return
		 */
		private function checkDivided():Boolean
		{
			var flag:int = 0;
			var col:uint = (this.x - Const.GRID_MARGIN_LEFT) / Const.GRID_ITEM_WIDTH;
			var row:uint = (this.y - Const.GRID_MARGIN_TOP) / Const.GRID_ITEM_WIDTH;
			var preX:Number = this.x;
			var preY:Number = this.y;
			
			//一个item组成则不存在拆分下落
			if (flagArray[0][0] == 1 && flagArray[0][1] == 0 && flagArray[1][0] == 0 && flagArray[1][1] == 0) {
				_isDivided = false;
				return _isDivided;
			}
			
			switch(_kind) {
				case SEND:
					if (flagArray[1][0] == 1) {//竖着
						switch(col) {
							case 0:
								if(Const.blankArray[row+1][col+1]!=1){
									switchCustom(BlockConst.SEND_LOW);
									this.x=preX;
									this.y=preY+Const.GRID_ITEM_WIDTH;
									_targetY += Const.GRID_ITEM_WIDTH;
									col = (this.x - Const.GRID_MARGIN_LEFT) / Const.GRID_ITEM_WIDTH;
									row = (this.y - Const.GRID_MARGIN_TOP) / Const.GRID_ITEM_WIDTH;
								}
								else {
									flag = 0;
								}
								break;
							case 7:
								if(Const.blankArray[row+1][col-1]!=1){
									switchCustom(BlockConst.SEND_LOW);
									this.x=preX-Const.GRID_ITEM_WIDTH;
									this.y=preY+Const.GRID_ITEM_WIDTH;
									_targetY += Const.GRID_ITEM_WIDTH;
									col = (this.x - Const.GRID_MARGIN_LEFT) / Const.GRID_ITEM_WIDTH;
									row = (this.y - Const.GRID_MARGIN_TOP) / Const.GRID_ITEM_WIDTH;
								}
								else{
									flag=0;
								}
								break;
							default:
								if(Const.blankArray[row+1][col-1]==0&&Const.blankArray[row+1][col+1]==0){//两边都能移动
									var i:int=Math.round(Math.random());
									switchCustom(BlockConst.SEND_LOW);
									if(i==0){
										this.x=preX-Const.GRID_ITEM_WIDTH;
										this.y=preY+Const.GRID_ITEM_WIDTH;
									}else{
										this.x=preX;
										this.y=preY+Const.GRID_ITEM_WIDTH;
									}
									col = (this.x - Const.GRID_MARGIN_LEFT) / Const.GRID_ITEM_WIDTH;
									row = (this.y - Const.GRID_MARGIN_TOP) / Const.GRID_ITEM_WIDTH;
									_targetY += Const.GRID_ITEM_WIDTH;
								}
								else if(Const.blankArray[row+1][col-1]==1&&Const.blankArray[row+1][col+1]==0){//左边不能走,往右边走
									switchCustom(BlockConst.SEND_LOW);
									this.x=preX;
									this.y = preY + Const.GRID_ITEM_WIDTH;
									col = (this.x - Const.GRID_MARGIN_LEFT) / Const.GRID_ITEM_WIDTH;
									row = (this.y - Const.GRID_MARGIN_TOP) / Const.GRID_ITEM_WIDTH;
								}
								else if(Const.blankArray[row+1][col+1]==1&&Const.blankArray[row+1][col-1]==0){//右边不能走，往左边走
									switchCustom(BlockConst.SEND_LOW);
									this.x=preX-Const.GRID_ITEM_WIDTH;
									this.y=preY+Const.GRID_ITEM_WIDTH;
									_targetY += Const.GRID_ITEM_WIDTH;
									col = (this.x - Const.GRID_MARGIN_LEFT) / Const.GRID_ITEM_WIDTH;
									row = (this.y - Const.GRID_MARGIN_TOP) / Const.GRID_ITEM_WIDTH;
								}
								else{//两边都不能移
									flag = 0;
								}
								break;
						}
					}
					
					if(flagArray[0][0]==1&&flagArray[0][1]==1) {	//横着
						if(Const.blankArray[row+1][col]==1&&Const.blankArray[row+1][col+1]==1){//都不能下落
							flag=0;
						}
						else if(Const.blankArray[row+1][col]!=1&&Const.blankArray[row+1][col+1]!=0){//向左边分割，左边小块下落
							flag = 1;
							_dividedDirection=Const.DIR_LEFT;
								
						}
						else{//向右边分割，右边小块下落
							flag = 1;
							_dividedDirection=Const.DIR_RIGHT;
						}
					}
					break;
				case STONE:
					flag = 0;
					break;
				case CLAY:
					if ((flagArray[0][0] == 1 || flagArray[0][1] == 1 )&& flagArray[1][0] == 1 && flagArray[1][1] == 1) {
						//能够拆分下落的Clay必然是三个Item组成的,所以直接对三个Item组成的Clay做出判断
						if (Const.blankArray[row + 2][col] == 1 && Const.blankArray[row + 2][col + 1] == 1) {//都不能下落
							flag = 0;
							_dividedDirection = Const.DIR_INIT;	//拆分方向回到初始状态
						}
						else if (Const.blankArray[row + 2][col] == 0 && Const.blankArray[row + 2][col + 1] == 1) {//左边能够下落
							flag = 1;
							_dividedDirection = Const.DIR_LEFT;
						}
						else {	//右边能够下落
							flag = 1;
							_dividedDirection = Const.DIR_RIGHT;
						}
					}
					break;
			}
			
			_isDivided = flag == 1?true:false;
			return _isDivided;
			
		}
		
		/**
		 * 检测石块是否能够正常下落
		 * @return
		 */
		private function checkDown():Boolean
		{
			var flag:int = 1;
			var col:uint = (this.x - Const.GRID_MARGIN_LEFT) / Const.GRID_ITEM_WIDTH;
			var row:uint = (this.y - Const.GRID_MARGIN_TOP) / Const.GRID_ITEM_WIDTH;
			
			//一个Item组成
			if (flagArray[0][0] == 1 && (flagArray[0][1] == 0 && flagArray[1][0] == 0 && flagArray[1][1] == 0)) {
				if (Const.blankArray[row + 2][col] != 0) {
					flag = 0;
					_targetY = Const.GRID_MARGIN_TOP + (row + 1) * Const.GRID_ITEM_WIDTH;
				}
			}
			
			//两个Item组成
			//两个Item组成的横着的Block不会自己运动，所以不需要做出判断，只需要对个类型的block的竖着做出判断，
			//因为可能因为被炸弹炸成竖着的Block,这是又能运动，所以需要做出判断
			else if (flagArray[0][0] == 1 && flagArray[1][1] == 0 && (flagArray[0][1] != 0 || flagArray[1][0] != 0)) {
				if (flagArray[1][0] == 1) {	//竖着
					if (Const.blankArray[row + 3][col] != 0) {	//不能继续下落
						flag = 0;
						_targetY = Const.GRID_MARGIN_TOP + (row + 1) * Const.GRID_ITEM_WIDTH;
					}
				}
			}
			
			//三个Item组成
			else {
				if (Const.blankArray[row + 3][col] != 0 || Const.blankArray[row + 3][col + 1] != 0) {
					flag = 0;
					_targetY = Const.GRID_MARGIN_TOP + (row + 1) * Const.GRID_ITEM_WIDTH;
				}
			}
			
			_isDown = flag == 0?false:true;
			return _isDown;
			
		}
		
		/**
		 * 更新blockImage
		 * */
		public function updateBlockImage():void
		{
			var preX:Number = this.x;
			var preY:Number = this.y;
			var index:int = 0;
			
			//trace("effectedFlagArr=", effectedFlagArr);
			
			if (effectedFlagArr == flagArray) {	//如果没有变化则返回
				return;
			}
			
			//判断Item个数
			if (flagArray[0][0] == 1 && flagArray[0][1] == 0 && flagArray[1][0] == 0) {
				index=Const.blockArray.indexOf(this);
				Const.blockArray.splice(index,1);
				this.removeFromParent(true);
			}
			//两个Item组成
			else if (flagArray[0][0] == 1 && flagArray[1][1] == 0 && (flagArray[0][1] != 0 || flagArray[1][0] != 0)) {
				//横着
				if (flagArray[0][0] == 1 && flagArray[1][1] == 0 && flagArray[0][1] == 1) {
					if (effectedFlagArr[0][0] == 0 && effectedFlagArr[0][1] == 1) {//左边没了
						switch(_kind) {
							case SEND:
								switchCustom(BlockConst.SEND_SINGLE);
							break;
							case CLAY:
								switchCustom(BlockConst.CLAY_SINGLE);
							break;
							case STONE:
								switchCustom(BlockConst.STONE_SINGLE);
							break;
						}
						this.x=preX+Const.GRID_ITEM_WIDTH;
						this.y=preY;
						trace("两个横着左边没了");
					}
					else if (effectedFlagArr[0][0] == 1 && effectedFlagArr[0][1] == 0) {//右边没了
						switch(_kind){
							case SEND:
								switchCustom(BlockConst.SEND_SINGLE);
								break;
							case CLAY:
								switchCustom(BlockConst.CLAY_SINGLE);
								break;
							case STONE:
								switchCustom(BlockConst.STONE_SINGLE);
								break;
						}
						this.x=preX;
						this.y=preY;
						trace("两个横着右边没了");
					}
					else if(effectedFlagArr[0][0]==0&&effectedFlagArr[0][1]==0&&effectedFlagArr[1][0]==0&&effectedFlagArr[0][1]==0){	//都没了
						index=Const.blockArray.indexOf(this);
						Const.blockArray.splice(index,1);
						this.removeFromParent(true);
						trace("两个横着都没了");
					}
				}
				else {	//竖着
					if(effectedFlagArr[0][0]==0&&effectedFlagArr[1][0]==1){//上边没了
						switch(_kind){
							case SEND:
								switchCustom(BlockConst.SEND_SINGLE);
								break;
							case CLAY:
								switchCustom(BlockConst.CLAY_SINGLE);
								break;
							case STONE:
								switchCustom(BlockConst.STONE_SINGLE);
								break;
						}
						
						this.x=preX;
						this.y=preY+Const.GRID_ITEM_WIDTH;
						trace("两个竖着上边没了");
					}
					else if(effectedFlagArr[0][0]==1&&effectedFlagArr[1][0]==0){//下边没了
						switch(_kind){
							case SEND:
								switchCustom(BlockConst.SEND_SINGLE);
								break;
							case CLAY:
								switchCustom(BlockConst.CLAY_SINGLE);
								break;
							case STONE:
								switchCustom(BlockConst.STONE_SINGLE);
								break;
						}
						this.x=preX;
						this.y=preY;
						trace("两个竖着下边没了");
					}
					else if(effectedFlagArr[0][0]==0&&effectedFlagArr[0][1]==0&&effectedFlagArr[1][0]==0&&effectedFlagArr[0][1]==0){	//都没了
						index=Const.blockArray.indexOf(this);
						Const.blockArray.splice(index,1);
						this.removeFromParent(true);
						trace("两个竖着都没了");
					}
				}
			}
			//三个Item组成
			else {
				//判断形状
				if(flagArray[0][0]==0){//左1右2形
					if(effectedFlagArr[1][0]==0&&effectedFlagArr[0][1]==1&&effectedFlagArr[1][1]==1){//左边没有了
						switch(_kind){
							case CLAY:
								switchCustom(BlockConst.CLAY_MIDDLE);
								break;
							case STONE:
								switchCustom(BlockConst.STONE_MIDDLE);
								break;
						}
						this.x=preX+Const.GRID_ITEM_WIDTH;
						this.y=preY;
						trace("三个左1右2形左边没有了");
					}
					else if(effectedFlagArr[0][1]==0&&effectedFlagArr[1][0]==1&&effectedFlagArr[1][1]==1){//右上边没有了
						switch(_kind){
							case CLAY:
								switchCustom(BlockConst.CLAY_MIDDLE2);
								break;
							case STONE:
								switchCustom(BlockConst.STONE_MIDDLE2);
								break;
						}
						this.x=preX;
						this.y=preY+Const.GRID_ITEM_WIDTH;
						trace("三个左1右2形右上边没有了");
					}
					else if(effectedFlagArr[1][0]==1&&effectedFlagArr[0][1]==1&&effectedFlagArr[1][1]==0){//右下边没有了
						////////////////
						trace("三个左1右2形右下边没有了");
					}
					else if(effectedFlagArr[1][0]==1&&effectedFlagArr[0][1]==0&&effectedFlagArr[1][1]==0){//右边两个都没了
						switch(_kind){
							case CLAY:
								switchCustom(BlockConst.CLAY_SINGLE);
								break;
							case STONE:
								switchCustom(BlockConst.STONE_SINGLE);
								break;
						}
						this.x=preX;
						this.y=preY+Const.GRID_ITEM_WIDTH;
						trace("三个左1右2形右边都没有了");
					}
					else if(effectedFlagArr[0][0]==0&&effectedFlagArr[0][1]==0&&effectedFlagArr[1][0]==0&&effectedFlagArr[0][1]==0){//都没了
						index=Const.blockArray.indexOf(this);
						Const.blockArray.splice(index,1);
						this.removeFromParent(true);
						trace("三个左1右2形都没有了");
					}
				}
				//左二右一形
				else{
					if(effectedFlagArr[0][0]==0&&effectedFlagArr[1][0]==1&&effectedFlagArr[1][1]==1){//左上没有了
						switch(_kind){
							case CLAY:
								switchCustom(BlockConst.CLAY_MIDDLE2);
								break;
							case STONE:
								switchCustom(BlockConst.STONE_MIDDLE2);
								break;
						}
						this.x=preX;
						this.y=preY+Const.GRID_ITEM_WIDTH;
						trace("三个左2右1形左上边没有了");
					}
					else if(effectedFlagArr[0][0]==1&&effectedFlagArr[1][0]==1&&effectedFlagArr[1][1]==0){//右下没有了
						switch(_kind){
							case CLAY:
								switchCustom(BlockConst.CLAY_MIDDLE);
								break;
							case STONE:
								switchCustom(BlockConst.STONE_MIDDLE);
								break;
						}
						this.x=preX;
						this.y=preY;
						trace("三个左2右1形右下边没有了");
					}
					else if(effectedFlagArr[0][0]==1&&effectedFlagArr[1][0]==0&&effectedFlagArr[1][1]==1){//左下没有了
						////////////
						trace("三个左2右1形左下边没有了");
					}
					else if(effectedFlagArr[0][0]==0&&effectedFlagArr[1][0]==0&&effectedFlagArr[1][1]==1){//左边两个没有了
						switch(_kind){
							case CLAY:
								switchCustom(BlockConst.CLAY_SINGLE);
								break;
							case STONE:
								switchCustom(BlockConst.STONE_SINGLE);
								break;
						}
						this.x=preX+Const.GRID_ITEM_WIDTH;
						this.y=preY+Const.GRID_ITEM_WIDTH;
						trace("三个左2右1形左边都没有了");
					}
					else if(effectedFlagArr[0][0]==0&&effectedFlagArr[0][1]==0&&effectedFlagArr[1][0]==0&&effectedFlagArr[0][1]==0){//都没了
						index=Const.blockArray.indexOf(this);
						Const.blockArray.splice(index,1);
						this.removeFromParent(true);
						trace("三个左2右1形都没有了");
					}
				}
			}
		}
		
		override public function dispose():void
		{
			removeEventListener(Event.ENTER_FRAME, moveBlockHandler);
			super.dispose();
		}
		
		/**
		 * _kind setter
		 */
		public function set kind(value:uint):void
		{
			_kind = value;
		}
		
		/**
		 * _kind getter
		 */
		public function get kind():uint
		{
			return _kind;
		}
		
		/**
		 * _flagArray getter
		 */
		public function get flagArray():Array
		{
			return _flagArray;
		}
		
		/**
		 * _flagArray setter
		 */
		public function set flagArray(value:Array):void
		{
			if (value != null) {
				_flagArray = value;
			}
		}
		
		/**
		 * _effectedFlagArr getter
		 */
		public function get effectedFlagArr():Array
		{
			return _effectedFlagArr;
		}
		
		/**
		 * _effectedFlagArr setter
		 */
		public function set effectedFlagArr(value:Array):void
		{
			if (value != null) {
				_effectedFlagArr = value;
			}
		}
		
	}
}