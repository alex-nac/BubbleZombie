package game.popups {
	import com.gskinner.motion.GTween;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import states.GameState;
	
	import util.State;
	
	public class Popup extends Sprite {		
		public static const LEFT:int = 1;
		public static const RIGHT:int = 2;
		
		private static const OPEN_TIME:Number = 0.3;
		
		private var _timer:Timer;
		private var _speachTween:GTween;
		
		public function Popup(direction:int, phrase:String, lifeTime:Number) {
			var speach:Sprite;
			
			//choosing the correct sprite
			if (direction == LEFT) speach = new bubble_speach_left_mc();				
			else speach = new bubble_speach_right_mc();			
			speach["txt"].text = phrase;
			speach["txt"].y += (speach["txt"].height - speach["txt"].textHeight) / 2;
			
			//setting speach cloud life time - 2 * OPEN_TIME because we need to close and open the dialog
			_timer = new Timer((lifeTime - 2 * OPEN_TIME) * 1000, 1);
			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, CloseCloud);
			
			//smooth opening with tween			
			scaleX = 0; scaleY = 0; alpha = 0;
			_speachTween = new GTween(this, OPEN_TIME, {alpha:1, scaleX:1, scaleY:1});
			addChild(speach);
			
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.PAUSE, onGameStateChanged);
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.RESUME, onGameStateChanged);
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.REMOVED, onStateRemoved);
		}
		
		//delete timer & start backward tween
		private function CloseCloud(e:TimerEvent):void {			
			_timer.removeEventListener(TimerEvent.TIMER, CloseCloud);
			_timer = null;
					
			_speachTween.setValues({alpha:0, scaleX:0, scaleY:0});
			_speachTween.onComplete = DisposePopup;
		}
				
		//delete popup
		private function DisposePopup(g:GTween):void {
			for (var i:int = 0; i < numChildren; i++) removeChildAt(i);
			parent.removeChild(this);
			
			_speachTween.onComplete = null;
			_speachTween.paused = true;
			_speachTween.target = null;
			_speachTween = null;
			
			if (_timer) {
				_timer.removeEventListener(TimerEvent.TIMER, CloseCloud);
				_timer = null;
			}
			
			(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.PAUSE, onGameStateChanged);
			(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.RESUME, onGameStateChanged);
			(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.REMOVED, onStateRemoved);
		}
		
		private function onGameStateChanged(e:Event):void {
			if (e.type == State.PAUSE) {
				_speachTween.paused = true;
				if (_timer) _timer.stop();
			}
			else {
				_speachTween.paused = false;
				if (_timer) _timer.start();
			}
		}
		
		private function onStateRemoved(e:Event):void {
			DisposePopup(null);
		}
		
	}
}