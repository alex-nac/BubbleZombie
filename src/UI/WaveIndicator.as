package UI {
	import com.gskinner.motion.GTween;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	//yellow line in left-top corner
	
	public class WaveIndicator extends Sprite {
		private var TWEEN_MOVING_TIME:Number;
		
		private var _xStep:Number;
		private var _indicator:waves_mc;
		private var _indicatorTween:GTween;
		
		public function WaveIndicator(numberOfWaves:int, movingTime:Number) {
			TWEEN_MOVING_TIME = movingTime;
			
			_indicator = new waves_mc();
			_xStep = _indicator.line.width / numberOfWaves;
			
			addChild(_indicator);	
		}
		
		public function NewRow(e:Event):void {
			if (_indicatorTween) _indicatorTween.setValue("x", _indicatorTween.getValue("x") + _xStep);			 
			else _indicatorTween = new GTween(_indicator.line, TWEEN_MOVING_TIME, {x:_indicator.line.x + _xStep});
		}
		
		public function onGameStateChanged(isPaused:Boolean):void {
			if (_indicatorTween) isPaused ? _indicatorTween.paused = true : _indicatorTween.paused = false;
		}
	}
}