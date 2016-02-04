package game {
	import flash.display.Sprite;
	
	import game.bubbles.SimpleBubble;
	import game.events.GunEvent;

	public class AimPointer extends Sprite {
		private var _pointer:aim_3_mc;
		private var _x:Number = 0;
		private var _y:Number = 0;
		
		public override function set x(value:Number):void { _x = value; }
		public override function set y(value:Number):void { _y = value; }
		
		public function AimPointer() {
			_pointer = new aim_3_mc()
			_pointer.scaleX = _pointer.scaleY = 0.7;
			addChild(_pointer);
		}
		
		public function onNewBullet(e:GunEvent):void {
			if (e.bulletType == Bubble.BOMB) _pointer.gotoAndStop("bomb");
			if (e.bulletType == Bubble.FREEZE_BOMB) _pointer.gotoAndStop("ice");
			
			switch (e.bulletColor) {
				case SimpleBubble.PINK:
					_pointer.gotoAndStop("brown");     
					break;
				case SimpleBubble.YELLOW:
					_pointer.gotoAndStop("yellow");
					break;
				case SimpleBubble.RED:
					_pointer.gotoAndStop("red");
					break;
				case SimpleBubble.GREEN:
					_pointer.gotoAndStop("green");
					break;
				case SimpleBubble.BLUE:
					_pointer.gotoAndStop("blue");
					break;
				case SimpleBubble.VIOLETT:
					_pointer.gotoAndStop("violett");
					break;
			}
		}
		
		public function onGunMoved(e:GunEvent):void {
			_pointer.rotation = e.angle + 90;
			var dx:Number = x - _x;
			var dy:Number = y - _y;
			super.x = super.x - dx / 2.5;
			super.y = super.y - dy / 2.5;
		}
	}
}