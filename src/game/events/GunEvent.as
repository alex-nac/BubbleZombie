package game.events {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import game.Bubble;
	
	public class GunEvent extends Event {
		
		public static var SHOOT:String = "shoot";
		public static var MOVED:String = "moved";
		public var bulletSprite:MovieClip;
		public var bulletType:int;
		public var bulletColor:int = 0;
		public var angle:int;
		
		public function GunEvent(type:String, bubble:Bubble, angle:int = 0, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			if (bubble) {
				this.bulletSprite = bubble.GetBubbleImage();
				this.bulletType = bubble.type;
				if (bulletType == Bubble.SIMPLE || bulletType == Bubble.COLOR_BOMB) bulletColor = bubble["color"];
			}
			
			this.angle = angle;
		}
	}
}