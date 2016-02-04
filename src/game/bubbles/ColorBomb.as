package game.bubbles {
	import flash.display.MovieClip;
	
	import game.Bubble;
	import game.BubbleMesh;
	
	import util.Animation;
	
	public class ColorBomb extends Bubble {
		private const EXPLOSION_SCALE:Number = 0.9;
		private var _color:int;
		
		public function ColorBomb(bombColor:int = 0) {
			super(COLOR_BOMB);
			
			bombColor == 0 ? _color = Math.floor(Math.random() * SimpleBubble.COLORS_AMOUNT) + 1 : _color = bombColor;
			SetView();
		}
		
		public function get color():int { return _color; }
		
		override public function onConnected(mesh:BubbleMesh):void {
			super.onConnected(mesh);
			
			Main.SM.PlaySound(new glass_bomb_snd());
			
			var expl:Animation;
			switch(_color) {
				case SimpleBubble.PINK:    expl = new Animation(new bomb_color_pink_expl_mc(), scale * EXPLOSION_SCALE); break;
				case SimpleBubble.YELLOW:  expl = new Animation(new bomb_color_yellow_expl_mc(), scale * EXPLOSION_SCALE); break;
				case SimpleBubble.RED:     expl = new Animation(new bomb_color_expl_red_mc(), scale * EXPLOSION_SCALE); break;
				case SimpleBubble.GREEN:   expl = new Animation(new bomb_green_color_expl_mc(), scale * EXPLOSION_SCALE); break;
				case SimpleBubble.BLUE:    expl = new Animation(new bomb_color_blue_expl_mc(), scale * EXPLOSION_SCALE); break;
				case SimpleBubble.VIOLETT: expl = new Animation(new bomb_color_violet_expl_mc(), scale * EXPLOSION_SCALE); break;
			}
			
			expl.x = view.x;
			expl.y = view.y;
			_mesh.AddEffect(expl);
			
			for each (var bubble:Bubble in _mesh.GetBubblesAround(this)) 
				if (bubble is SimpleBubble && (bubble as SimpleBubble).color != SimpleBubble.UBER_BLACK) {
					_mesh.MinusColor(bubble["color"]);
					_mesh.PlusColor(_color);
					bubble["color"] = _color;
				}
												
			Delete();			
		}
		
		private function SetView():void {
			var sprite:MovieClip = GetBubbleImage();
			
			scale = DIAMETR / sprite.width;
			
			sprite.addChildAt(new bomb_color_shadow_mc(), 0);
			sprite.width *= scale;
			sprite.height *= scale;
			view = sprite;
		}
		
		override public function GetBubbleImage():MovieClip {
			var sprite:MovieClip;
			switch(_color) {
				case SimpleBubble.PINK:
					sprite = new bomb_color_pink_mc();     
					break;
				case SimpleBubble.YELLOW:
					sprite = new bomb_color_yellow_mc();
					break;
				case SimpleBubble.RED:
					sprite = new bomb_color_red_mc();
					break;
				case SimpleBubble.GREEN:
					sprite = new bomb_color_green_mc();
					break;
				case SimpleBubble.BLUE:
					sprite = new bomb_color_blue_mc();
					break;
				case SimpleBubble.VIOLETT:
					sprite = new bomb_color_violet_mc();
					break;
			}
			
			return sprite;
		}
		
	}
}