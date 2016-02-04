package game {
	import com.gskinner.motion.GTween;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import game.bubbles.Bomb;
	import game.bubbles.Bullet;
	import game.bubbles.ColorBomb;
	import game.bubbles.FreezeBomb;
	import game.bubbles.SimpleBubble;
	import game.events.GunEvent;
	
	import nape.dynamics.Arbiter;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import util.GameConfig;
	import util.Timer;
	
	/*
	 * Class for SWAT gun-machine
	 * We always have 2 bullet - one in a basket 
	 * and one in the gun 
	 */

	public class Gun extends EventDispatcher {
		
		//private const GUN_LENGTH:int = 34;
		private const SHOOTING_VEL:int = 300;
		private const BULLET_DIAMETR:Number = 27;
		private const SHOOTING_DELAY:Number = 0.2;

		private var _view:Sprite = new Sprite;
		private var _gun:gun_mc = new gun_mc();
		private var _gunBody:Body;
		private var _angle:Number = 0;   //angle of gun's rotation
		private var _nextBulletSprite:Sprite;
		private var _cfg:GameConfig;
		private var _space:Space;
		private var _canShoot:Boolean = true;
		private var _canShootTimer:Timer; //timer for delay in shooting
		private var _repeatBulletsEnabled:Boolean;
		private var _mesh:BubbleMesh;
		
		//2 bullets
		private var _nextBullet:Bubble;
		private var _basketBullet:Bubble;
		
		public function get view():Sprite { return _view; }
		public function set canShoot(value:Boolean):void { 
			_canShoot = value;
			_canShootTimer.Reset();
		}		

		public function Gun(cfg:GameConfig, space:Space, repeateBulletsEnabled:Boolean, mesh:BubbleMesh) {
			_view.addEventListener(Event.ADDED_TO_STAGE, function f(e:Event):void {
				_view.removeEventListener(Event.ADDED_TO_STAGE, f);
				
				_mesh = mesh;
				
				_repeatBulletsEnabled = repeateBulletsEnabled;
				_space = space;
				
				_gun.x = 13;
				_gun.y = -32;
				_view.addChild(_gun);
				
				_cfg = cfg;
				_view.x = _view.stage.stageWidth / 2;
				_view.y = _view.stage.stageHeight + 13;	
								
				_gunBody = new Body(BodyType.KINEMATIC, new Vec2(_view.x + _gun.x + 1, _view.y + _gun.y)); 
				_gunBody.shapes.add(new Polygon(Polygon.box(_gun.width * 2, _gun.height / 4)));
				_gunBody.shapes.at(0).sensorEnabled = true;
				_gunBody.space = space;
				
				//bullet in a basket
				PutBullet();
				
				//bullet in a gun
				_nextBullet = GetNextBullet();
				_nextBullet.view.alpha = 0;				
				_gun.downgun.addChild(_nextBullet.view);
				var scale:Number = BULLET_DIAMETR / Bubble.DIAMETR;
				_nextBullet.view.scaleX = scale;
				_nextBullet.view.scaleY = scale;
				_nextBullet.x = -4;				
				new GTween(_nextBullet.view, 0.4, {alpha:1});
				
				//pause shooting timer
				_canShootTimer = new Timer(SHOOTING_DELAY);
				_canShootTimer.isPaused = true;
				_canShootTimer.addEventListener(Timer.TRIGGED, function (e:Event):void { _canShoot = true; _canShootTimer.Reset();});
											
				dispatchEvent( new GunEvent(GunEvent.SHOOT, _nextBullet));
			});			
		}


		//rotate gun
		public function Update():void {
			_angle = Math.atan2(_view.stage.mouseY - _view.y + 36, _view.stage.mouseX - _view.x - 13);
			_gun.rotation = _angle * 180 / Math.PI;
			dispatchEvent(new GunEvent(GunEvent.MOVED, null, _angle * 180 / Math.PI));
			_gunBody.rotation = _angle; 
			_canShootTimer.Update();
		}

		//shoot a bubble
		public function Shoot():void {
			if (!_canShoot) return;			
			if (CheckForTouchingMesh()) {
				Main.SM.PlaySound(new block_snd());
				return;	
			}
						
			Main.SM.PlaySound(new shot_01_snd());
			
			//shooting the bubble which is in a gun
			var bullet:Bubble = _nextBullet;
			var topTween:GTween = new GTween(bullet, (80 + bullet.view.width / 2) / SHOOTING_VEL, {x:80 + bullet.view.width / 2});
			topTween.onComplete = function ():void {
				if (CheckForTouchingMesh()) {
					bullet.Delete();
					bullet = null;
					return;
				}
				
				_view.parent.addChild(bullet.view);
				_view.parent.addChild(bullet.effects);
				bullet.space = _space;
				var worldPos:Point = _gun.localToGlobal(bullet.position.toPoint());
				bullet.position = Vec2.fromPoint(worldPos);
				bullet.velocity = new Vec2(SHOOTING_VEL * Math.cos(-_angle), - SHOOTING_VEL * Math.sin(-_angle));				
				new GTween(bullet.view, 0.1, {scaleX:1, scaleY:1}); //scale it to normal size
			}
			if (!bullet) return;
			bullet.StartLifeTimer();
			bullet.isBullet = true;
			
			//moving basket bullet
			_nextBullet = _basketBullet;
			var rightTween:GTween = new GTween(_nextBullet, 0.3, {y:0});
			
			//dispatching event about new bubble
			dispatchEvent( new GunEvent(GunEvent.SHOOT, _nextBullet) );
			
			//and add new bullet to the basket
			PutBullet();		
			
			//set delay
			_canShootTimer.isPaused = false;
			_canShoot = false;
		}
				
		private function GetNextBullet():Bubble {
			var bullet:Bubble;	

			if (Math.random() * 100 <= _cfg.superBulletPercent) {
				var n:int = Math.random() * 100;
				if (n < _cfg.bombPercent) { bullet = new Bomb(); }
				else if (n > _cfg.bombPercent && n < _cfg.bombPercent + _cfg.freezeBombPercent) { bullet = new FreezeBomb(); }
				else if (n > _cfg.bombPercent + _cfg.freezeBombPercent) { bullet = new ColorBomb(); } 
				else bullet = new Bullet();
			}
			else { bullet = new Bullet(); }
			
			//checking if there are two bubbles with the same type or with the same color
			if (_nextBullet && !_repeatBulletsEnabled) {
				if (bullet.type == _nextBullet.type) {
					if (bullet.type == Bubble.BOMB || bullet.type == Bubble.FREEZE_BOMB) return GetNextBullet();
					if (bullet.type == Bubble.COLOR_BOMB && bullet["color"] == _nextBullet["color"]) return GetNextBullet();
				}
			}
			
			if (bullet is SimpleBubble && _mesh.GetRemainingBubblesByColor(bullet["color"]) <= 0) return GetNextBullet();
			
			return bullet;
		}
		
		//putting new bullet to the basket
		private function PutBullet():void {
			_basketBullet = GetNextBullet();
			_basketBullet.view.alpha = 0;
			
			_gun.downgun.addChild(_basketBullet.view);
			var scale:Number = BULLET_DIAMETR / Bubble.DIAMETR;			
			_basketBullet.view.scaleX = scale;
			_basketBullet.view.scaleY = scale;
			_basketBullet.x = -4;
			_basketBullet.y = -28;
			
			new GTween(_basketBullet.view, 0.4, {alpha:1});
		}
		
		//checking if we touching the mesh with gun sensor
		private function CheckForTouchingMesh():Boolean {
			var meshTouched:Boolean = false;
			_gunBody.arbiters.foreach(function (obj:Arbiter):void { 
				if ((obj.body2.userData.ref is Bubble && (obj.body2.userData.ref as Bubble).isConnected) || (obj.body1.userData.ref is Bubble&& (obj.body1.userData.ref as Bubble).isConnected)) 
					meshTouched = true;			
			});
			
			return meshTouched;
		}

	}

}