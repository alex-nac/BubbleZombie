package game.bubbles {
	import flash.display.MovieClip;
	
	import game.BFS;
	import game.Bubble;
	import game.BubbleDeleter;
	import game.BubbleMesh;
	import game.events.ComboEvent;
	
	import util.Animation;
	
	public class Bullet extends SimpleBubble {	
			
		public function Bullet(color:int=0) {
			super(color);
			SetView();
		}
		
		public override function set color(newColor:int):void {
			_color = newColor;
			SetView();
		}
				
		private function SetView():void {
			var bubbleMC:MovieClip;
						
			bubbleMC = GetBubbleImage();
				
			scale = DIAMETR / bubbleMC.width;
			bubbleMC.addChildAt(new bomb_normal_shadow_mc(), 0);
			
			bubbleMC.width *= scale;
			bubbleMC.height *= scale;
			view = bubbleMC;			
		}
		
		public override function onConnected(mesh:BubbleMesh):void {
			super.onConnected(mesh);
			
			Main.SM.PlaySound(new bomb_touch_snd());
				
			var deletedBubbles:Vector.<Bubble> = BFS.GetSameColorBubbles(meshPosition, false);
			
			
			if(deletedBubbles.length >= 3) {
				deletedBubbles = BFS.GetSameColorBubbles(meshPosition, true);
				for each (var bbl:Bubble in deletedBubbles) bbl.mesh = null;
				deletedBubbles = deletedBubbles.concat(BFS.GetUnrootedBubbles());
				for each (bbl in deletedBubbles) bbl.mesh = null;
								
				_mesh.dispatchEvent(new ComboEvent(ComboEvent.COMBO, deletedBubbles));
								
				new BubbleDeleter(position, deletedBubbles, space);					
			}
			
		}
		
		override public function GetBubbleImage():MovieClip {
			var bubbleMC:MovieClip;
			switch(_color) {
				case PINK:
					bubbleMC = new bomb_normal_pink_mc();
					break;
				case YELLOW:
					bubbleMC = new bomb_normal_yellow_mc();
					break;
				case RED:
					bubbleMC = new bomb_normal_red_mc();
					break;
				case GREEN:
					bubbleMC = new bomb_normal_green_mc();
					break;
				case BLUE:
					bubbleMC = new bomb_normal_blue_mc();
					break;
				case VIOLETT:
					bubbleMC = new bomb_normal_violett_mc();
					break;
			}
			
			return bubbleMC;
		}
		
		override public function Delete(withPlane:Boolean = false):void {	
			Main.SM.PlaySound(new shot_04_snd());
			var expl:Animation = new Animation(new bomb_expl_mc(), 0.9 * scale);			
			expl.x = view.x;
			expl.y = view.y;
			if (_mesh) _mesh.AddEffect(expl);
			else view.parent.addChild(expl);
			
			super.Delete(withPlane);
		}
		
	}
}