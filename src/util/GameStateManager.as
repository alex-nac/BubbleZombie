package util  {	
	import com.gskinner.motion.GTween;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class GameStateManager  {
		
		//all the state keeping here
		private var _stateContainer:Vector.<State> = new Vector.<State>();		
		//sprite that we use to place here graphics part of the state
		private var _stateSprite:Sprite;
		
		public function GameStateManager(stateSprite:Sprite) {
			_stateSprite = stateSprite;
		}
				
		//add new state
		public function PushState(state:State):void {					
			_stateContainer.push(state);
			_stateSprite.addChild(state);			
		}
		
		//remove current state
		public function PopState():State {			
			if (_stateContainer.length != 0) {
				_stateContainer[_stateContainer.length - 1].Remove();
				_stateSprite.removeChild(_stateContainer[_stateContainer.length - 1]);
				_stateContainer[_stateContainer.length - 1] = null;
				return _stateContainer.pop();
				
			}
			else {
				throw new Error("There are no states in state container");
				return null;
			}
		}
		
		//switch current state to newState
		public function Switch(newState:State):void {
			PopState();
			PushState(newState); 
		}
		
		public function GetCurrentState():State {
			return _stateContainer[_stateContainer.length - 1];
		}
	}	
}
