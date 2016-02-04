package states {
	import com.gskinner.motion.GTween;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import FGL.GameTracker.GameTracker;
	
	import UI.AchievmentPanel;
	
	import game.AchievmentsManager;
	
	import util.SaveManager;
	import util.State;
	
	public class LevelCompleteState extends State {
		private var _lvlNum:int;
		private var _BGsprite:menu = new menu();
		
		public function LevelCompleteState(isFailed:Boolean, lvlNum:int, scores:int = 0, zombieKilled:int = 0, wasMasterBonusGained:Boolean = false) {
			_lvlNum = lvlNum;
			
			//saving zombies killed
			SaveManager.saveSharedData();
						
			_BGsprite.lvlMapBtn.addEventListener(MouseEvent.CLICK, LevelMapBtnCB);
			_BGsprite.restartBtn.addEventListener(MouseEvent.CLICK, RestartBtnCB);
			_BGsprite.sndOffBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.sndOnBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
			
			_BGsprite.backBtn.visible = false;
			_BGsprite.achievmentsBtn.visible = false;
			_BGsprite.resetBtn.visible = false;
			if (Main.SM.soundEnabled) _BGsprite.sndOffBtn.visible = false;
			else _BGsprite.sndOnBtn.visible = false;
			
			_BGsprite.restartBtn.shade.visible = false;
			
			
			if (!isFailed) {
				GameTracker.api.customMsg("Level " + lvlNum + " passed"); 
				LevelSelectState.LevelCompleted(lvlNum, scores);
				_BGsprite.skipLevelBtn.visible = false;
				_BGsprite.nextLvlBtn.shade.visible = false;
				_BGsprite.nextLvlBtn.addEventListener(MouseEvent.CLICK, NextLvlBtnCB);
				
				//if it is the last level
				if (_lvlNum == LevelSelectState.LEVELS_AMOUNT) {
					GameTracker.api.customMsg("GAME COMPLETED"); 
					var gameEndSprite:g_completed_mc = new g_completed_mc();	
					gameEndSprite.x = 320;
					gameEndSprite.y = 243;
					gameEndSprite.txt_total_score.text = LevelSelectState.GetTotalScores().toString();
					_BGsprite.addChild(gameEndSprite);
				}
				else { //and if not					
					new GTween(_BGsprite.nextLvlBtn.arrow, 0.5, { alpha:0 }, { reflect:true, repeatCount:0, delay:1 });
									
					var wonSprite:level_completed = new level_completed();	
					wonSprite.x = 320;
					wonSprite.y = 223;
					wonSprite.txt_level.text = lvlNum.toString();				
					wonSprite.txt_score.text = scores.toString();
					wonSprite.txt_waves.text = zombieKilled.toString();
					wonSprite.txt_total_score.text = LevelSelectState.GetTotalScores().toString();
					if (wasMasterBonusGained) wonSprite.txt_bonus.text = AchievmentsManager.MASTER_ACH_SCORE_BONUS.toString();
					_BGsprite.addChild(wonSprite);
				}
			}
			else {	
				GameTracker.api.customMsg("Level " + lvlNum + " failed"); 
				LevelSelectState.LevelFailed(_lvlNum);
				
				_BGsprite.nextLvlBtn.visible = false;
				
				new GTween(_BGsprite.restartBtn.arrow, 0.5, { alpha:0 }, { reflect:true, repeatCount:0, delay:1 });
				
				//we can skip level only after 3 loses
				if (LevelSelectState.GetLevelFailsAmount(_lvlNum) >= 3) {					
					_BGsprite.skipLevelBtn.shade.visible = false;
					_BGsprite.skipLevelBtn.addEventListener(MouseEvent.CLICK, SkipLevelBtnCB);
				}
				
				
				var failSprite:l_failed_mc = new l_failed_mc();
				failSprite.x = 320;
				failSprite.y = 228;
				_BGsprite.addChild(failSprite);	
			}
						
			//smooth appearing
			_BGsprite.alpha = 0;
			var alphaTween:GTween = new GTween(_BGsprite, 1, {alpha:1});
			alphaTween.onComplete = CheckForAch;
			addChild(_BGsprite);	
		}
		
		//deleting state 
		public override function Remove():void {
			_BGsprite.lvlMapBtn.removeEventListener(MouseEvent.CLICK, LevelMapBtnCB);
			_BGsprite.restartBtn.removeEventListener(MouseEvent.CLICK, RestartBtnCB);
			_BGsprite.nextLvlBtn.removeEventListener(MouseEvent.CLICK, NextLvlBtnCB);
			_BGsprite.skipLevelBtn.removeEventListener(MouseEvent.CLICK, SkipLevelBtnCB);
			_BGsprite.sndOffBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.sndOnBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.removeEventListener(Event.ADDED_TO_STAGE, CheckForAch);
			
			super.Remove();
		}
		
		private function CheckForAch(g:GTween):void {
			if (!stage) return;
			
			if (AchievmentsManager.CheckForDEFENDER()) 
				_BGsprite.addChild(new AchievmentPanel(AchievmentsManager.DEFENDER, stage.stageWidth, 0));
			if (AchievmentsManager.CheckForVETERAN()) 
				_BGsprite.addChild(new AchievmentPanel(AchievmentsManager.VETERAN, stage.stageWidth, 0));
			if (AchievmentsManager.CheckForRECORDBREAKER())
				_BGsprite.addChild(new AchievmentPanel(AchievmentsManager.RECORDBREAKER, stage.stageWidth, 0));
		}
		
		
		//////////////////////
		//BUTTONS_CALLBACKS///
		//////////////////////
		
		private function LevelMapBtnCB (e:MouseEvent):void {
			Main.GSM.PopState();
			Main.GSM.PushState(new LevelSelectState());
			
			e.stopImmediatePropagation();
		}
				
		private function RestartBtnCB (e:MouseEvent):void {
			GameTracker.api.customMsg("Level " + _lvlNum + " restarted"); 
			Main.GSM.PopState();
			Main.GSM.PushState(new GameState(_lvlNum));
			
			e.stopImmediatePropagation();
		}
		
		private function NextLvlBtnCB (e:MouseEvent):void {
			if (_lvlNum == LevelSelectState.LEVELS_AMOUNT) 
				Main.GSM.Switch(new LevelSelectState());
			else {
				Main.GSM.PopState();
				Main.GSM.PushState(new GameState(_lvlNum + 1));
			
				e.stopImmediatePropagation();
			}
		}
		
		private function SkipLevelBtnCB (e:MouseEvent):void {	
			GameTracker.api.customMsg("Level " + _lvlNum + " skipped"); 
			LevelSelectState.SkipLevel(_lvlNum);
			if (_lvlNum != LevelSelectState.LEVELS_AMOUNT) LevelSelectState.OpenLevel(_lvlNum + 1);
			NextLvlBtnCB(e);			
		}
			
		private function SoundBtnCB(e:MouseEvent):void {
			Main.SM.soundEnabled = !Main.SM.soundEnabled;
			_BGsprite.sndOffBtn.visible = !_BGsprite.sndOffBtn.visible;
			_BGsprite.sndOnBtn.visible = !_BGsprite.sndOnBtn.visible;			
		}
		
	}
}