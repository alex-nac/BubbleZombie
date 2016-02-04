package states {
	import com.gskinner.motion.GTween;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import game.AchievmentsManager;
	
	import util.SaveManager;
	import util.State;
	
	public class LevelSelectState extends State {
		//used for game designer		
		private const ALL_LEVELS_OPENED:Boolean = true;
		
		private const STARTX:int = 160;
		private const STARTY:int = 148;
		private const SCALE:Number = 0.8;
		private const X_SPACE:int = 80;
		private const Y_SPACE:int = 46;
		
		public static const LEVELS_AMOUNT:int = 25;
		
		private var _BGsprite:menu = new menu(); 
		private var _content:levelmap_content_mc = new levelmap_content_mc();
		private var _buttonsLayer:Sprite = new Sprite();
		private var _achLayer:Sprite = new Sprite();
		private var _resetLayer:Sprite = new Sprite();
		
		//////////////////////
		///STATIC_FUNCTIONS///
		//////////////////////
		
		//saving current state of the game progress
		public static function LevelCompleted(number:int, scores:int):void {
			OpenLevel(number + 1);
			var key:String = "level" + number + "_scores";
			
			//we are interested in best scores
			if (SaveManager.getSharedData(key) < scores)
				SaveManager.setSharedData({key:key, value:scores});
			
			SaveManager.saveSharedData();
		}
		
		
		//saving the amount of loses for this level
		public static function LevelFailed(number:int):void {
			var key:String = "level" + number + "_failed";
			var numberOfLoses:int = GetLevelFailsAmount(number);			
			numberOfLoses++;
			SaveManager.setSharedData({key:key, value:numberOfLoses});
			
			SaveManager.saveSharedData();
		}
		
		//setting level opened
		public static function OpenLevel(number:int):void {
			var key:String = "level" + number + "_opened";
			SaveManager.setSharedData({key:key, value:true});
			
			SaveManager.saveSharedData();
		}	
		
		//mark the level as skipped level 
		public static function SkipLevel(number:int):void {
			var key:String = "level" + number + "_skipped";
			SaveManager.setSharedData({key:key, value:true});
			
			SaveManager.saveSharedData();
		}
		
		//getting how many times we lose this level
		public static function GetLevelFailsAmount(number:int):int {
			var key:String = "level" + number + "_failed";
			var numberOfLoses:int = 0;
			if(SaveManager.getSharedData(key))
				numberOfLoses = SaveManager.getSharedData(key);
			
			return numberOfLoses;
		}
		
		//checking if we have passed this level
		public static function GetLevelPassed(number:int):Boolean {
			var key:String = "level" + number + "_scores";
			return Boolean(SaveManager.getSharedData(key));
		}
		
		
		//getting total amount of scores for all the levels
		public static function GetTotalScores():int {
			var totalScores:int = 0;
			for (var lvlNum:int = 1; lvlNum <= LEVELS_AMOUNT; lvlNum++) {
				var key:String = "level" + lvlNum + "_scores";
				if (SaveManager.getSharedData(key))
					totalScores += SaveManager.getSharedData(key);
			}
			
			return totalScores;
		}
		
		
		
		
		
		
		
		
		public function LevelSelectState() {
			//BubbleZombie.SM.SetBackSong(new menu_snd());
			new GTween(_BGsprite.backBtn.arrow, 0.3, { alpha:0 }, { reflect:true, repeatCount:0, delay:1 });
			
			_BGsprite.restartBtn.visible = false;
			_BGsprite.skipLevelBtn.visible = false;
			_BGsprite.nextLvlBtn.visible = false;			
			_BGsprite.backBtn.shade.visible = false;
			_BGsprite.backBtn.visible = false;
			if (Main.SM.soundEnabled) _BGsprite.sndOffBtn.visible = false;
			else _BGsprite.sndOnBtn.visible = false;
			
			_BGsprite.achievmentsBtn.shade.visible = false;
			_BGsprite.resetBtn.shade.visible = false;
			
			addChild(_BGsprite);
			
			_BGsprite.backBtn.addEventListener(MouseEvent.CLICK, BackBtnCB);
			_BGsprite.lvlMapBtn.addEventListener(MouseEvent.CLICK, MenuBtnCB);
			_BGsprite.achievmentsBtn.addEventListener(MouseEvent.CLICK, AchievmentsBtnCB);
			_BGsprite.sndOnBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.sndOffBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.resetBtn.addEventListener(MouseEvent.CLICK, ResetBtnCB);
									
			SaveManager.setSharedData({key:"level1_opened", value:true});
			
			//open all levels if we hacve this cheat
			if (ALL_LEVELS_OPENED) 
				for (var k:int = 2; k <= LEVELS_AMOUNT; k++) SaveManager.setSharedData({key:String("level" + k + "_opened"), value:true});
			
			CreateLevelButtonsScreen();
			CreateResetScreen();
			CreateAchivmetsScreen();
			
			_resetLayer.visible = false;
			_achLayer.visible = false;
			
			_BGsprite.addChild(_buttonsLayer);
			_BGsprite.addChild(_resetLayer);
			_BGsprite.addChild(_achLayer);
			
			//smooth appearing
			new GTween(_BGsprite, 0.3, {alpha:0}, {swapValues:true});
			
		}	
		
		public override function Remove():void {
			_BGsprite.backBtn.removeEventListener(MouseEvent.CLICK, BackBtnCB);
			_BGsprite.lvlMapBtn.removeEventListener(MouseEvent.CLICK, MenuBtnCB);
			_BGsprite.achievmentsBtn.removeEventListener(MouseEvent.CLICK, AchievmentsBtnCB);
			_BGsprite.sndOnBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.sndOffBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.resetBtn.removeEventListener(MouseEvent.CLICK, ResetBtnCB);
			
			super.Remove();
		}
		
		private function CreateLevelButtonsScreen():void {
			//firstly remove all previous buttons
			for each (var button:but_level_num_mc in _buttonsLayer) {
				button.removeEventListener(MouseEvent.CLICK, LevelSelectedCB);
				button.removeEventListener(MouseEvent.ROLL_OVER, ShowBestScoresCB);
				button.removeEventListener(MouseEvent.ROLL_OUT, ShowBestScoresCB);
			}

			_buttonsLayer.removeChildren();
			
			//setting total scores
			_content.total_score.text = "TOTAL: " + GetTotalScores();
			
			_content.x = 320;
			_content.y = 240;
			_buttonsLayer.addChild(_content);
			
			//then create new ones
			for (var i:int = 0; i < 5; i++)
				for (var j:int = 0; j < 5; j++) {
					var levelNum:int = i * 5 + j + 1;
					var key:String = "level" + levelNum + "_opened";
					var levelbtn:MovieClip;
					
					//if we can play this level
					if (SaveManager.getSharedData(key)) {
						levelbtn = new but_level_num_mc();
						(levelbtn as but_level_num_mc).lvlNum.text = (i * 5 + j + 1).toString();
						levelbtn.addEventListener(MouseEvent.CLICK, LevelSelectedCB);
						levelbtn.addEventListener(MouseEvent.ROLL_OVER, ShowBestScoresCB);
						levelbtn.addEventListener(MouseEvent.ROLL_OUT, ShowBestScoresCB);
						levelbtn.white_border.visible = false;
						
						//if player skipped the level mark it
						if (SaveManager.getSharedData("level" + levelNum + "_skipped") && !GetLevelPassed(levelNum)) {
							levelbtn.white_border.visible = true;
							/*
							var colorTransform:ColorTransform = levelbtn.transform.colorTransform;
						
							colorTransform.redMultiplier *= 0.8;
							colorTransform.greenMultiplier *= 0.8;
							colorTransform.blueMultiplier *= 0.8;				
						
						
							levelbtn.transform.colorTransform = colorTransform;
							*/
						}
						
					}
					else 
						levelbtn = new but_level_locked_mc();
					
					levelbtn.x = STARTX + j * X_SPACE;
					levelbtn.y = STARTY + i * Y_SPACE;	
					levelbtn.scaleX = levelbtn.scaleY = SCALE;
					_buttonsLayer.addChild(levelbtn);
				}
		}
		
		private function CreateAchivmetsScreen():void {
			for (var i:int = 0; i < _achLayer.numChildren; i++)
				_achLayer.removeChildAt(i);
			
			var ach:pop_ach_mc = new pop_ach_mc();
			ach.x = 320;
			ach.y = 250;	
			
			for (i = 0; i <= 4; i++) {
				if (AchievmentsManager.IsAchievmentPassed(i))
					ach.getChildByName("but_locked_" + i).visible = false;
				else 
					ach.getChildByName("but_tip_" + i).visible = false;
			}
			
			_achLayer.addChild(ach);
		}
		
		private function CreateResetScreen():void {
			var reset:reset_progress_mc = new reset_progress_mc(); 
			reset.x = 320;
			reset.y = 240;
			reset.noBtn.addEventListener(MouseEvent.CLICK, BackBtnCB);
			reset.yesBtn.addEventListener(MouseEvent.CLICK, YesBtnCB);
			_resetLayer.addChild(reset);
		}
		
		///////////////////////
		///BUTTONS_CALLBACKS///
		///////////////////////
		
		private function LevelSelectedCB(e:MouseEvent):void {
			Main.SM.PlaySound(new level_but_snd());
			
			var levelNum:int = int(but_level_num_mc(e.currentTarget).lvlNum.text);
			Main.GSM.PopState();
			Main.GSM.PushState(new GameState(levelNum));
			
			e.stopImmediatePropagation();
		}
				
		private function BackBtnCB (e:MouseEvent):void {
			_BGsprite.backBtn.visible = false;
			_BGsprite.lvlMapBtn.visible = true;
			_resetLayer.visible = false;
			_achLayer.visible = false;
			_buttonsLayer.visible = true;
			_BGsprite.achievmentsBtn.shade.visible = false;
			_BGsprite.resetBtn.shade.visible = false;
			CreateLevelButtonsScreen();
			new GTween(_buttonsLayer, 0.3, {alpha:0}, {swapValues:true});			
		}
		
		private function SoundBtnCB(e:MouseEvent):void {
			Main.SM.soundEnabled = !Main.SM.soundEnabled;
			_BGsprite.sndOffBtn.visible = !_BGsprite.sndOffBtn.visible;
			_BGsprite.sndOnBtn.visible = !_BGsprite.sndOnBtn.visible;
		}
		
		private function AchievmentsBtnCB(e:MouseEvent):void {
			//if button isn't active return
			if (_BGsprite.achievmentsBtn.shade.visible) return;
						
			_BGsprite.backBtn.visible = true;
			_BGsprite.lvlMapBtn.visible = false;
			_achLayer.visible = true;
			_buttonsLayer.visible = false;
			_BGsprite.achievmentsBtn.shade.visible = true;
			_BGsprite.resetBtn.shade.visible = true;
			new GTween(_achLayer, 0.3, {alpha:0}, {swapValues:true});
		}
						
		private function ResetBtnCB(e:MouseEvent):void {
			//if button isn't active return
			if (_BGsprite.resetBtn.shade.visible) return;
			
			_BGsprite.backBtn.visible = true;
			_BGsprite.lvlMapBtn.visible = false;
			_resetLayer.visible = true;
			_buttonsLayer.visible = false;
			_BGsprite.achievmentsBtn.shade.visible = true;
			_BGsprite.resetBtn.shade.visible = true;
			new GTween(_resetLayer, 0.3, {alpha:0}, {swapValues:true});
		}
				
		private function YesBtnCB(e:MouseEvent):void {
			SaveManager.clearData();
			SaveManager.setSharedData({key:"level1_opened", value:true});
			
			//open all levels if we hacve this cheat
			if (ALL_LEVELS_OPENED) 
				for (var k:int = 2; k <= LEVELS_AMOUNT; k++) SaveManager.setSharedData({key:String("level" + k + "_opened"), value:true});
			BackBtnCB(e);
		}
	
		private function ShowBestScoresCB(e:MouseEvent):void {
			//show best scores
			if (e.type == MouseEvent.ROLL_OVER) {
				var number:int = int(but_level_num_mc(e.currentTarget).lvlNum.text);
				if (SaveManager.getSharedData("level" + number + "_skipped") && !GetLevelPassed(number)) {
					_content.best_score.text = "SKIPPED";
					_content.best_score.textColor = 0xFFFFFF;
					return;
				}
				
				var key:String = "level" + number + "_scores";				
				if (SaveManager.getSharedData(key)) {
					_content.best_score.textColor = 13696840;
					_content.best_score.text = "BEST: " + String(SaveManager.getSharedData(key));
				}
			}
			
			//hide best scores
			if (e.type == MouseEvent.ROLL_OUT) 
				_content.best_score.text = "";				
		}
		
		private function MenuBtnCB(e:MouseEvent):void {
			Main.GSM.Switch(new MainMenuState());
			e.stopImmediatePropagation();
		}
		
	}
	
}
