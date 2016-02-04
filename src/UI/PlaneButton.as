package UI {
	import com.gskinner.motion.GTween;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import states.GameState;
	
	//class representing recharging airplane button
	
	public class PlaneButton extends Sprite {
		private var _planeBtn:but_plane_mc;
		private var _buttonRechargingTime:Number;		
		private var _planeBtnTween:GTween;
		private var _tutor:tutorial_03_mc;
		private var _isNeedToShowTutorial:Boolean;
		private var _isAirplaneAvalible:Boolean;
		
		public function get isFullCharged():Boolean { return _planeBtnTween.paused; }
		public function set paused(value:Boolean):void { if (_planeBtnTween.ratio != 1.0) _planeBtnTween.paused = value; }
		
		public function get isAirplaneAvalible():Boolean { return _isAirplaneAvalible; }
		public function set isAirplaneAvalible(value:Boolean):void {
			_isAirplaneAvalible = value;		
			if (value) {
				_planeBtn.plane.visible = true;
				_planeBtn.shade.visible = true;
				_planeBtn.na_label.visible = false;
			}
			else {
				_planeBtn.plane.visible = false;
				_planeBtn.shade.visible = false;
				_planeBtn.na_label.visible = true;	
			}
			 
		}
		
		public function PlaneButton(buttonRechargingTime:Number, isNeedToShowTutorial:Boolean) {
			_buttonRechargingTime = buttonRechargingTime;
			
			_planeBtn = new but_plane_mc();	
			_planeBtn.scaleX = 0.9;
			_planeBtn.scaleY = 0.9;
			_planeBtn.addEventListener(MouseEvent.ROLL_OVER, onMouseRoll);
			_planeBtn.addEventListener(MouseEvent.ROLL_OUT, onMouseRoll);
			addChild(_planeBtn);
			
			_isNeedToShowTutorial = isNeedToShowTutorial;
			
			//start recharging
			_planeBtnTween = new GTween(_planeBtn.shade, _buttonRechargingTime, {y:_planeBtn.shade.y - 48});
			if (_isNeedToShowTutorial) 
				_planeBtnTween.onComplete = ShowTutorial;
		}
		
		//controlling recharging state
		public function StopRecharging():void {			
			_planeBtnTween.beginning(); 
			_planeBtnTween.paused = true;
		}
		
		public function RestartRecharging():void {
			_planeBtnTween.beginning();
			_planeBtnTween.paused = false;
		}
				
		//showing corrent cursor when we point on button
		private function onMouseRoll(e:MouseEvent):void {
			if (e.type == MouseEvent.ROLL_OUT) Main.SetPoiner(GameState.aimPointer);
			if (e.type == MouseEvent.ROLL_OVER) Main.SetPoiner(new pointer_mc());
		}
		
		//if we use button firts time we show tutorial for the player
		private function ShowTutorial(g:GTween):void {
			_tutor = new tutorial_03_mc();
			_tutor.x = 130;
			_tutor.y = 169;
			if (parent) parent.addChild(_tutor);
						
			_planeBtnTween.onComplete = null;
			_isNeedToShowTutorial = false;
		}
		
		public function DeleteTutorial():void {
			if (_tutor) {			
				if (_tutor.parent) _tutor.parent.removeChild(_tutor);
				_tutor = null;
			}
		}
	}
}