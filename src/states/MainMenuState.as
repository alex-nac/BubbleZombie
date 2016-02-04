package states  {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweenTimeline;
	
	import flash.events.MouseEvent;
	
	import util.State;
	
	public class MainMenuState extends State {
		private var _timeLine:GTweenTimeline;
		private var _mainMenuBGD:win_main_mc;
		private var _creditsTween:GTween;
		private var _isCreditsOpened:Boolean = false;
		
		public function MainMenuState() {
			//setting menu song
			Main.SM.SetBackSong(new menu_snd());				
			
			//initializing menu
			_mainMenuBGD = new win_main_mc();
			
			_mainMenuBGD.glassLayer.mouseEnabled = false; //making transparent layers untouchable
			_mainMenuBGD.glassLayer.mouseChildren = false;
			
			_mainMenuBGD.newGameBtn.addEventListener(MouseEvent.MOUSE_UP, NewGame);
			_mainMenuBGD.newGameBtn.addEventListener(MouseEvent.MOUSE_DOWN, ButtonScale);
			_mainMenuBGD.newGameBtn.addEventListener(MouseEvent.ROLL_OUT, ButtonScale);
			_mainMenuBGD.newGameBtn.addEventListener(MouseEvent.ROLL_OVER, ButtonScale);
			//mainMenuBGD.moreGamesBtn.addEventListener(MouseEvent.CLICK, MoreGamesBtnCB);
			_mainMenuBGD.sndOffBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
			_mainMenuBGD.sndOnBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
			_mainMenuBGD.credits.addEventListener(MouseEvent.ROLL_OUT, CreditsMoving);
			_mainMenuBGD.credits.addEventListener(MouseEvent.MOUSE_OVER, CreditsMoving);	
			
			
			
			_creditsTween = new GTween(_mainMenuBGD.credits, 0.7, {y:_mainMenuBGD.credits.y - _mainMenuBGD.credits.height + 27});
			_creditsTween.paused = true;
			_creditsTween.onComplete = function (e:GTween):void { e.swapValues(); _isCreditsOpened = !_isCreditsOpened; };
			
			
			if (Main.SM.soundEnabled) _mainMenuBGD.sndOffBtn.visible = false;
			else _mainMenuBGD.sndOnBtn.visible = false;
								
			new GTween(_mainMenuBGD.newGameBtn, 1.4, {alpha:0}, {swapValues:true});
			
			addChild(_mainMenuBGD);
		}
			
		private function onTimelineComplete():void {
			_timeLine.paused = true;			
			_timeLine.removeCallback(_timeLine.duration);
			_timeLine = null;
		}
				
		private function NewGame(e:MouseEvent):void {	
			_mainMenuBGD.newGameBtn.scaleX = 1;
			Main.GSM.Switch(new IntroState());
		}	
		
		private function ButtonScale(e:MouseEvent):void {
			var scale:Number;
			e.type == MouseEvent.ROLL_OUT || e.type == MouseEvent.MOUSE_DOWN ? scale = 1 : scale = 1.03;
			_mainMenuBGD.newGameBtn.scaleX = scale;
			_mainMenuBGD.newGameBtn.scaleY = scale;		
		}
		
		private function MoreGamesBtnCB(e:MouseEvent):void {
			//here will be link to sponsor's site
		}
		
		private function SoundBtnCB(e:MouseEvent):void {
			Main.SM.soundEnabled = !Main.SM.soundEnabled;
			_mainMenuBGD.sndOffBtn.visible = !_mainMenuBGD.sndOffBtn.visible;
			_mainMenuBGD.sndOnBtn.visible = !_mainMenuBGD.sndOnBtn.visible;			
		}
		
		public override function Remove():void {
			super.Remove();
			
			_mainMenuBGD.newGameBtn.removeEventListener(MouseEvent.MOUSE_UP, NewGame);
			_mainMenuBGD.newGameBtn.removeEventListener(MouseEvent.MOUSE_DOWN, ButtonScale);
			_mainMenuBGD.newGameBtn.removeEventListener(MouseEvent.ROLL_OUT, ButtonScale);
			_mainMenuBGD.newGameBtn.removeEventListener(MouseEvent.ROLL_OVER, ButtonScale);
			_mainMenuBGD.sndOffBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
			_mainMenuBGD.sndOnBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
			_mainMenuBGD.credits.removeEventListener(MouseEvent.ROLL_OUT, CreditsMoving);
			_mainMenuBGD.credits.removeEventListener(MouseEvent.MOUSE_OVER, CreditsMoving);
			
			if (_timeLine) {
				_timeLine.removeCallback(_timeLine.duration);
				_timeLine = null;
			}
			
			if (_creditsTween) {
				_creditsTween.paused = true;
				_creditsTween.onComplete = null;
				_creditsTween = null;
			}
			
			
			removeChild(_mainMenuBGD);
			_mainMenuBGD = null;
		}
		
		private function CreditsMoving(e:MouseEvent):void {		
			
			//if we in the middle of the moving
			if (!_creditsTween.paused) return;
			if (_isCreditsOpened && e.type == MouseEvent.MOUSE_OVER) return;
			if (!_isCreditsOpened && e.type == MouseEvent.ROLL_OUT) return;
			
			_creditsTween.paused = false;
		}
		
	}
	
}
