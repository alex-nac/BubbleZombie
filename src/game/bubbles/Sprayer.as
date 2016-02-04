package game.bubbles {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.geom.Point;
	
	import game.Bubble;
	import game.BubbleMesh;
	import game.FloatingText;
	import game.Score;
	
	import util.Animation;
	import util.Timer;
	
   /*
	* Sprayer class forces zombie around to become uzer-zombie
	* It have 4 guns, guns numerated [0..3] starting from left gun
	* Amount of active guns are set in constructor, we randomly
	* choose which guns are active
	*/
	
	public class Sprayer extends Bubble {
		private const LEFT:int = 0;
		private const UP:int = 1;
		private const RIGHT:int = 2;
		private const DOWN:int = 3;
		
		private var _timer:Timer;  //timer for steam shooting
		private var _time:Number;  //shooting delay-time
		private var actDir:Vector.<int> = new Vector.<int>(); //active directions
		
		public function Sprayer(activeGuns:int, time:Number) {
			super(Bubble.SPRAYER);
			
			//some random delay to prevent synchronization
			_timer = new Timer(Math.random() * time);
			_timer.addEventListener(Timer.TRIGGED, onTimerComplete);
			_time = time;
			
			//randomly chose directions
			var dir:Vector.<int> = Vector.<int>([0, 1, 2, 3]);
			for (var i:int = 0; i < activeGuns; i++) {
				var pos:int = Math.floor(Math.random() * dir.length);
				actDir.push(dir[pos]);
				dir.splice(pos, 1);
			}
			
			SetView();
		}
		
		public override function Update():void {
			super.Update();
			
			_timer.Update();
		}
		
		private function SetView():void {
			var bubbleMC:MovieClip = new steamMachine_mc();
			scale = DIAMETR / bubbleMC.width;
			bubbleMC.width *= scale;
			bubbleMC.height *= scale;
			
			view = bubbleMC;
		}
		
		override public function Delete(withPlane:Boolean = false):void {			
			//TODO: sparyer will have its own animation, now it is just bomb's animation
			var expl:Animation = new Animation(new bomb_expl_mc(),  scale);			
			expl.x = view.x;
			expl.y = view.y;
			_mesh.AddEffect(expl);
			
			if (withPlane) var score:String = Score.AIRPLANE_SCORE.toString();
			else score = Score.STEAM_SCORE.toString();
			var floatingText:FloatingText = new FloatingText(score , new point_mc(), 13);
			floatingText.x = view.x;
			floatingText.y = view.y - 15;
			if (_mesh) _mesh.AddEffect(floatingText, true);
			
			super.Delete(withPlane);
		}
		
		override public function set isFrozen(value:Boolean):void {
			if (isFrozen == value) return; //if current state is the same as value we do nothing
			
			super.isFrozen = value;
			_timer.isPaused = !_timer.isPaused;
		}
		
		private function onTimerComplete(e:Event):void {
			Main.SM.PlaySound(new steamMachine_snd());
			
			var direction:int = actDir[Math.floor(Math.random() * actDir.length)];
			
			var anim:MovieClip = new steam_run_mc();
			anim.rotation = 90 * direction;
			
			//6 bubbles around sprayer
			var zombies:Vector.<Bubble> = _mesh.GetBubblesAround(this, true);
			
			//bubbles that will be infected
			var infectedZombies:Vector.<Bubble> = new Vector.<Bubble>(); 
			
			//calculation what bubbles need to be infected
			switch (direction) {
				case LEFT:
					anim.x -= DIAMETR / 2;
					//if it is exist and it is zombie and it isn't already black
					if (zombies[0] != null && zombies[0] is Zombie && (zombies[0] as Zombie).color != SimpleBubble.UBER_BLACK)
						infectedZombies.push(zombies[0]);
					break;
				case UP:
					if (zombies[1] != null && zombies[1] is Zombie && (zombies[1] as Zombie).color != SimpleBubble.UBER_BLACK)
						infectedZombies.push(zombies[1]); 
					if (zombies[2] != null && zombies[2] is Zombie && (zombies[2] as Zombie).color != SimpleBubble.UBER_BLACK)
						infectedZombies.push(zombies[2]); 
					anim.y -= DIAMETR / 2;
					break;
				case RIGHT:
					anim.x += DIAMETR / 2;					
					if (zombies[3] != null && zombies[3] is Zombie && (zombies[3] as Zombie).color != SimpleBubble.UBER_BLACK)
						infectedZombies.push(zombies[3]); 
					break;
				case DOWN:
					anim.y += DIAMETR / 2;
					if (zombies[4] != null && zombies[4] is Zombie && (zombies[4] as Zombie).color != SimpleBubble.UBER_BLACK)
						infectedZombies.push(zombies[4]); 
					if (zombies[5] != null && zombies[5] is Zombie && (zombies[5] as Zombie).color != SimpleBubble.UBER_BLACK)
						infectedZombies.push(zombies[5]);					
					break;
			}
			
			
			
			//steam animation
			var steamAnim:Animation = new Animation(anim, scale);			
			//zombie infects
			steamAnim.onComplete = function():void { 
				for each (var zombie:Zombie in infectedZombies) if (zombie.hasBody) zombie.Infect(); 
			};  
			_effects.addChild(steamAnim);
			
			
			_timer = new Timer(_time);
			_timer.addEventListener(Timer.TRIGGED, onTimerComplete);
		}
	}
}