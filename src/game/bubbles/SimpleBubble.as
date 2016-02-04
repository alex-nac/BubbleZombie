package game.bubbles {
	import game.Bubble;

	public class SimpleBubble extends Bubble {
		//amount of SimpleBubble's colors
		public static var COLORS_AMOUNT:int;
		
		//bubble's colors
		public static const PINK:int = 1;
		public static const YELLOW:int = 2;
		public static const RED:int = 3;
		public static const GREEN:int = 4;
		public static const BLUE:int = 5;
		public static const VIOLETT:int = 6;
		public static const UBER_BLACK:int = 7;
		
		protected var _color:int;
		
		public function set color(newColor:int):void {}
		
		public function get color():int { return _color; }
		
		public function SimpleBubble(color:int = 0) {
			super(SIMPLE);
			
			if (color == 0) _color = Math.floor(Math.random() * SimpleBubble.COLORS_AMOUNT) + 1;
			else _color = color;					
		}
		
		public override function Delete(withPlane:Boolean = false):void {		
			super.Delete();	
		}
		
		
						
	}
}