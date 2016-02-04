package UI {
	import com.gskinner.motion.GTween;
	
	import flash.display.Sprite;
	
	//Indicator class that shows after all waves had been arrived

	public class AirplaneTimeLeftIndicator extends Sprite {
		private var _indicator:reinforcement_mc;
		private var _indicatorTween:GTween;
		
		public function AirplaneTimeLeftIndicator(time:Number) {
			_indicator = new reinforcement_mc();
			_indicatorTween = new GTween(_indicator.line, time, {x:_indicator.line.x + _indicator.line.width});
			addChild(_indicator);
		}
		
		public function Remove():void {
			_indicatorTween.paused = true;
			_indicatorTween.deleteValue("x");
		}
		
		public function onGameStateChanged(isPaused:Boolean):void {
			if (_indicatorTween) isPaused ? _indicatorTween.paused = true : _indicatorTween.paused = false;
		}
	}
}