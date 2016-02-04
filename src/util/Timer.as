package util {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Timer extends EventDispatcher {
		
		public static const TRIGGED:String = "trigged";
		
		private var _isPaused:Boolean = false;
		private var _timeElapsed:Number = 0;
		private var _triggingTime:Number; 
		
		public var data:Object = {};
		
		public function Timer(time:Number) {
			_triggingTime = time;
		}
		
		public function Update():void { 
			if (_isPaused) return;
			
			_timeElapsed += 1 / 30;
			if (_timeElapsed >= _triggingTime) { 
				dispatchEvent(new Event(TRIGGED));
				_timeElapsed = 0;
			}
		}
		
		public function GetRemainingTime():int {
			return _triggingTime - _timeElapsed; 
		}
		
		public function Reset(setTime:int = 0):void {
			_timeElapsed = 0;
			_isPaused = true;
		}
		public function set isPaused(value:Boolean):void { _isPaused = value; }
		public function get isPaused():Boolean { return _isPaused; }
		
	}
}