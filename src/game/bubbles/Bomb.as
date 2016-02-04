package game.bubbles {
	import flash.display.MovieClip;
	
	import game.BFS;
	import game.Bubble;
	import game.BubbleDeleter;
	import game.BubbleMesh;
	import game.events.ComboEvent;
	
	import util.Animation;
	
	public class Bomb extends Bubble {
		
		//private var _bfs:BFS
		
		public function Bomb() {
			super(BOMB);
			
			var bubbleMC:MovieClip = new MovieClip();
			bubbleMC.addChild(new bomb_black_shadow_mc());
			bubbleMC.addChild(new bomb_black_mc());
			
			scale = DIAMETR / bubbleMC.width;
			
			
			bubbleMC.width *= scale;
			bubbleMC.height *= scale;
			view = bubbleMC;
		}
		
		override public function onConnected(mesh:BubbleMesh):void {
			super.onConnected(mesh);
			
			var deletedBubbles:Vector.<Bubble> = new Vector.<Bubble>();
			
			for each(var bubble:Bubble in _mesh.GetBubblesAround(this)) {				
				deletedBubbles.push(bubble);
				bubble.mesh = null;
			}
						
			//this bomb will be unrooted so it will be deleted
			for each (bubble in BFS.GetUnrootedBubbles()) {
				deletedBubbles.push(bubble);
				bubble.mesh = null;	
			}
			
			//fixing the problem with bomb at 1-st row
			if (deletedBubbles.indexOf(this) == -1) {
				deletedBubbles.push(this);
				mesh = null;
			}
			
			_mesh.dispatchEvent(new ComboEvent(ComboEvent.COMBO, deletedBubbles));
			
			new BubbleDeleter(position, deletedBubbles, space);		
		}
		
		public override function Delete(withPlane:Boolean=false):void {			
			Main.SM.PlaySound(new explosion_02_snd());
			
			var expl:Animation = new Animation(new bomb_expl_mc(), 1 * scale);			
			expl.x = view.x;
			expl.y = view.y;
			if (_mesh) _mesh.AddEffect(expl);
			else view.parent.addChild(expl); 
			
			super.Delete(withPlane);
		}
		
		override public function GetBubbleImage():MovieClip {
			return new bomb_black_mc();
		}
	}
}