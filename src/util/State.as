package util {	
	import flash.display.Sprite;
	import flash.events.Event;
	
	//base class for all states
	public class State extends Sprite {
		
		//strings for dispatching events
		public static const PAUSE:String = "pause";   
		public static const RESUME:String = "resume";
		public static const REMOVED:String = "state_removed";
		
		private var _isPaused:Boolean = false;
		
		public function get isPaused():Boolean { return _isPaused; }
		
		public function State() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
		}		
				
		public function Pause():void {			
			if (_isPaused) return;
			
			_isPaused = true;
			dispatchEvent(new Event(PAUSE));  //dispach message about state pausing
		}		
		
		public function Resume(e:Event = null):void { 
			if (!_isPaused) return;
			
			_isPaused = false; 
			dispatchEvent(new Event(RESUME));  //dispach message about state resuming
		}
		
		public function Remove():void { 
			dispatchEvent(new Event(REMOVED));
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);	
			stage.removeEventListener(Event.MOUSE_LEAVE, onMouseOut);
		}
		
		//abstract function
		protected function Update():void { }
		
		
		
		private function onAddedToStage(e:Event):void {
			stage.focus = stage;
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseOut);
			
		}
		
		private function onEnterFrame(e:Event):void { if (!_isPaused) Update(); }
	
		private function onMouseOut(e:Event):void {	Pause(); }
		
		
		
	}	
}
