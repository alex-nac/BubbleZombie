package UI {
	import com.gskinner.motion.GTween;
	
	import flash.display.Sprite;

	public class MasterPopup extends Sprite {
		public var onPopupComplete:Function;
		
		private var _movingTween:GTween;
		private var _alphaTween:GTween;
		
		public function MasterPopup() {
			var bonusPopup:master_pop_mc = new master_pop_mc();
			addChild(bonusPopup);
			
			bonusPopup.alpha = 0;
			_alphaTween = new GTween(bonusPopup, 0.3, {alpha:1});
			
			_movingTween = new GTween(bonusPopup, 2.5, {y:bonusPopup.y - 50});
			_movingTween.onComplete = function (g:GTween):void {
				_movingTween.deleteValue("y");
				_movingTween.onComplete = null;
				onPopupComplete();	
			};
		}
		
		public function Remove():void {
			if (_movingTween) {
				_movingTween.deleteValue("y");
				_movingTween.onComplete = null;	
			}
			
			if (_alphaTween) _alphaTween.deleteValue("alpha");
		}
	}
}