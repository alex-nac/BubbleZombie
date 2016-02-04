package UI {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import game.events.GunEvent;
	
	//Class for showing which bullet is the next to be shooted
	public class Indicator {
		private var _sizeInPixels:Number;
		private var _view:Sprite = new Sprite();
		
		public function get view():Sprite { return _view; }
		
		public function Indicator(x:int, y:int, sizeInPixels:Number) {
			_sizeInPixels = sizeInPixels;
			_view.x = x;
			_view.y = y;
		}		
		
		public function SetNextSprite(e:GunEvent):void {
			for (var i:int = 0; i < _view.numChildren; i++)
				_view.removeChildAt(i);
			
			var newSprite:MovieClip = e.bulletSprite;			
			var scale:Number= _sizeInPixels / newSprite.width;			
			newSprite.width *= scale;
			newSprite.height *= scale;
			
			_view.addChild(newSprite);
		}
		
	}
}