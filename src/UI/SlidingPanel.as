package UI {
	import FGL.GameTracker.GameTracker;
	
	import com.gskinner.motion.GTween;
	
	import flash.display.MovieClip;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import game.Score;
	
	import states.*;
	
	import util.SaveManager;
	
	public class SlidingPanel extends MovieClip {
		private const LEFT_BUTTON_HEIGHT:int = 20;
		private const SLIDING_TIME:Number = 0.15;
		
		private var _slidingPanel_mc:ingame_menu_mc = new ingame_menu_mc();
		private var _isOpen:Boolean;
		private var _tweener:GTween;
		private var _lvlNum:int;
		
		//open and close panel callbacks
		public var onOpened:Function = function():void {};
		public var onClosed:Function = function():void {};
	
		//creating panel
		public function SlidingPanel(x:int, lvlNum:int) {
			addEventListener(Event.ADDED_TO_STAGE, function onAdd(e:Event):void {
				removeEventListener(Event.ADDED_TO_STAGE, onAdd);
				
				_lvlNum = lvlNum;	
				_isOpen = false;		
				
				_slidingPanel_mc.panel.slidingBtn.rotation = 0;
				
				//set it on the right edge of the scene
				_slidingPanel_mc.y = stage.stageHeight - LEFT_BUTTON_HEIGHT / 2 + 2;
				_slidingPanel_mc.x = x;
				addChild(_slidingPanel_mc);
				
				//showing level numer
				_slidingPanel_mc.panel.lvlNum.text = lvlNum.toString();
				_slidingPanel_mc.panel.txt_score.text = "0";
				
											
				_slidingPanel_mc.panel.levelMapBtn.addEventListener(MouseEvent.CLICK, LevelMapBtnCB);
				_slidingPanel_mc.panel.restartBtn.addEventListener(MouseEvent.CLICK, RestartBtnCB);
				_slidingPanel_mc.panel.leftQualityBtn.addEventListener(MouseEvent.CLICK, QualityBtnCB);
				_slidingPanel_mc.panel.rightQualityBtn.addEventListener(MouseEvent.CLICK, QualityBtnCB);
				
				//sound buttons
				_slidingPanel_mc.panel.sndOnBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
				_slidingPanel_mc.panel.sndOffBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
				if (Main.SM.soundEnabled) _slidingPanel_mc.panel.sndOffBtn.visible = false;
				else _slidingPanel_mc.panel.sndOnBtn.visible = false;
				
				//panel movement starts after 1 second
				var t:Timer = new Timer(1000, 1);
				t.addEventListener(TimerEvent.TIMER, StartPanelWork);	
				t.start();
			});			
		}
		
		public function Update(scores:Score, timeRemaining:int):void {			
			_slidingPanel_mc.panel.txt_score.text = scores.score.toString();
		}
		
		//deleting panel
		public function Delete():void {
			_slidingPanel_mc.panel.slidingBtn.removeEventListener(MouseEvent.MOUSE_OVER, MovePanel);
			_slidingPanel_mc.panel.removeEventListener(MouseEvent.CLICK, PreventFromClosing);
			stage.removeEventListener(MouseEvent.CLICK, HidePanel);
			
			_slidingPanel_mc.panel.levelMapBtn.removeEventListener(MouseEvent.CLICK, LevelMapBtnCB);
			_slidingPanel_mc.panel.restartBtn.removeEventListener(MouseEvent.CLICK, RestartBtnCB);
			_slidingPanel_mc.panel.sndOnBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
			_slidingPanel_mc.panel.sndOffBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
			_slidingPanel_mc.panel.leftQualityBtn.removeEventListener(MouseEvent.CLICK, QualityBtnCB);
			_slidingPanel_mc.panel.rightQualityBtn.removeEventListener(MouseEvent.CLICK, QualityBtnCB);
		}
		
		private function MovePanel(e:MouseEvent):void {	
			//if we click on the panel stop event propagation
			if (!_isOpen) {
				Main.SetPoiner(new pointer_mc());
				_slidingPanel_mc.panel.slidingBtn.rotation = 180;
				_tweener = new GTween(_slidingPanel_mc.panel, SLIDING_TIME, {y:_slidingPanel_mc.panel.y - 88});
				if (stage) _slidingPanel_mc.panel.quality.text = stage.quality;
				_tweener.onComplete = onOpened;
				_isOpen = true;				
			}
		}
		
		private function HidePanel(e:MouseEvent):void {
			if (_isOpen) {
				e.stopImmediatePropagation();
				_slidingPanel_mc.panel.slidingBtn.rotation = 0;
				_tweener = new GTween(_slidingPanel_mc.panel, SLIDING_TIME, {y:_tweener.getInitValue("y")});
				_tweener.onComplete = onClosed;
				_isOpen = false;
			}
		}
		
		//when a level starts we pause panel for 1 second, then we start it
		private function StartPanelWork(e:TimerEvent):void {
			
			_slidingPanel_mc.panel.slidingBtn.addEventListener(MouseEvent.MOUSE_OVER, MovePanel);
			_slidingPanel_mc.panel.addEventListener(MouseEvent.CLICK, PreventFromClosing);
			stage.addEventListener(MouseEvent.CLICK, HidePanel);
		}
		
		private function PreventFromClosing (e:MouseEvent):void { 
			e.stopImmediatePropagation(); 
		}
		
		
		//BUTTONS CALLBACKS
		private function LevelMapBtnCB(e:MouseEvent):void {
			//saving zombies killed
			SaveManager.saveSharedData();
			Main.SM.SetBackSongState(false);
			
			Main.GSM.PopState();
			Main.GSM.PushState(new LevelSelectState());
		}
		
		private function RestartBtnCB(e:MouseEvent):void {
			Main.GSM.PopState();
			Main.GSM.PushState(new GameState(_lvlNum));
		}
		
		private function SoundBtnCB(e:MouseEvent):void {
			Main.SM.soundEnabled = !Main.SM.soundEnabled;
			_slidingPanel_mc.panel.sndOffBtn.visible = !_slidingPanel_mc.panel.sndOffBtn.visible;
			_slidingPanel_mc.panel.sndOnBtn.visible = !_slidingPanel_mc.panel.sndOnBtn.visible;
		}
		
		private function QualityBtnCB(e:MouseEvent):void {
			GameTracker.api.customMsg("Quality button pressed"); 
			//plus quality
			if (e.target.name == "leftQualityBtn") {
				switch (stage.quality.toLowerCase()) {
					case StageQuality.MEDIUM: stage.quality = StageQuality.LOW; break;
					case StageQuality.HIGH: stage.quality = StageQuality.MEDIUM; break;
					case StageQuality.BEST: stage.quality = StageQuality.HIGH; break;
				}
			}
			else { //minus quality
				switch (stage.quality.toLowerCase()) {
					case StageQuality.LOW: stage.quality = StageQuality.MEDIUM; break;
					case StageQuality.MEDIUM: stage.quality = StageQuality.HIGH; break;
					case StageQuality.HIGH: stage.quality = StageQuality.BEST; break;
				}
			}
			
			//update text
			_slidingPanel_mc.panel.quality.text = stage.quality;
		}
		
	}
}