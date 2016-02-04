package game  {
	import com.gskinner.motion.GTween;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import nape.callbacks.CbType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.space.Space;
	
	import states.GameState;
	
	import util.State;
	

		
	
	public class Bubble {
		
		////////////////////
		//STATIC VARIABLES//
		////////////////////
		
		private static const MAX_TIMES_WALL_TOUCHED:int = 2;   //after this the bubble exploding
		private static const LIFE_TIME:int = 4;                //how long does this bubble live in seconds

		public static const DIAMETR:int = 44;          		//diametr of the bubble
		public static const FROZEN_TIME:Number = 0.1;   	//time to give frozen to near bubbles
		public static var MESH_BUBBLE_DIAMETR:Number;
						
		//bubble types
		public static const SIMPLE:int = 1;		    //simple color bubble
		public static const SPRAYER:int = 2;	    //turn simple into uber-zombie		
		public static const BOMB:int = 3;			//delete bubbles around
		public static const FREEZE_BOMB:int = 4;	//stop wave for some time
		public static const COLOR_BOMB:int = 5;     //color all bubbles around
		
		//CallBack Types for physics engine		
		private static var _connectedBubbleCBType:CbType = new CbType();  //assigned when bubble is connected to the mesh		
		public static function get ConnectedBubbleCBType():CbType { return _connectedBubbleCBType; }
		
		private static var _bubbleCBType:CbType = new CbType();           //assigned to all bubbles
		public static function get BubbleCBType():CbType { return _bubbleCBType; }
				
		
		/////////////
		//VARIABLES//
		/////////////		
		
		protected var _mesh:BubbleMesh;                  	//we save ref to the mesh when connect bubble
		protected var _effects:Sprite = new Sprite();    	//here we place all sprites that need to be on top of zombies
		private var _scale:Number;						 	//bubble's movieclip scale								
		private var _view:MovieClip = new MovieClip();   	//bubble's view			
		private var _body:Body = new Body();             	//bubble's body in physics world
		private var _type:int;                           	//bubble's type
		private var _meshPosition:Vec2;		
		private var _isConnected:Boolean = false;		
		private var _wasCallbackCalled:Boolean = false;     //have we called the BubbleHDR function for ths bubble
		private var _lifeTimer:Timer;
		private var _timesWallTouched:int = 0; 				//how many times we have touched the wall
		
		
		private var _frozenMC:MovieClip = new ice_01_mc();	//ice movieclip
		private var _isFrozen:Boolean = false;			    //if bubble is frozened or not		
		private var _iceTween:GTween;
				
		//////////////////
		//GETTES/SETTERS//
		//////////////////
		
		public function get isConnected():Boolean { return _isConnected; }		
		public function get type():int { return _type; }
		public function get space():Space { return _body.space; }
		public function get position():Vec2 { return _body.position.copy(); }	
		public function get mesh():BubbleMesh { return _mesh; }
		public function get meshPosition():Vec2 { return _mesh.GetMeshPos(this); } 
		public function get view():MovieClip { return _view; }
		public function get effects():Sprite { return _effects; }
		public function get x():Number { return _body.position.x; }
		public function get y():Number { return _body.position.y; }
		public function get scale():Number { return _scale; }
		public function get isFrozen():Boolean { return _isFrozen; }		
		public function get hasBody():Boolean { return _body != null; }
		public function get wasCallbackCalled():Boolean { return _wasCallbackCalled; }
		
		public function set wasCallbackCalled(value:Boolean):void { _wasCallbackCalled = value; }
		public function set scale(value:Number):void { _scale = value; }
		public function set space(space:Space):void { _body.space = space; }
		public function set isSensor(value:Boolean):void { _body.shapes.at(0).sensorEnabled = value; }
		public function set isBullet(value:Boolean):void { _body.isBullet = value; } 
		public function set isConnected(value:Boolean):void { 
			_isConnected = value;
			if (!_isConnected) _body.cbTypes.remove(Bubble.ConnectedBubbleCBType);
		}
		
		public function set velocity(vel:Vec2):void {
			_body.allowMovement = true;
			_body.velocity = vel; 
		}
		
		public function set x(value:Number):void { 
			_body.position.x = value; 
			_view.x = value;
			_effects.x = value;
		}
		
		public function set y(value:Number):void { 
			_body.position.y = value; 
			_view.y = value;
			_effects.y = value;
		}
		
		public function set position(pos:Vec2):void { 
			_body.position = pos;
			_view.x = pos.x;
			_view.y = pos.y;
			_effects.x = pos.x;
			_effects.y = pos.y;
		}
		
		public function set view(sprite:MovieClip):void {
			for (var i:int = 0; i < _view.numChildren; i++)
				_view.removeChildAt(i);
			_view.addChild(sprite);		
						
			if (_isFrozen) _effects.addChild(_frozenMC);
		}
		
		public function set isFrozen(value:Boolean):void {
			if (_isFrozen == value || !hasBody) return;
			
			//if bubble now in some trans-state then dispose previous tween
			if (_iceTween) { 
				_iceTween.paused = true;
				_iceTween.onComplete = null;
				_iceTween = null;
			}
			_isFrozen = value;
			if (value) {
				//smoothly put ice
				if (_frozenMC.alpha == 1) _frozenMC.alpha = 0; //we setting alpha 0 only if we have just put ice (preverting flirking)
				_iceTween = new GTween(_frozenMC, 0.2, {alpha:1});
				_effects.addChild(_frozenMC);			
			}
			else {
				//smoothly destroy ice
				_iceTween = new GTween(_frozenMC, 2, {alpha:0});
				_iceTween.onComplete = function (e:GTween):void { _effects.removeChild(_frozenMC); }			
			}
		}
		
		public function set mesh(newMesh:BubbleMesh):void {			
			if (newMesh == null) {
				if (_isConnected) _mesh.Delete(this);
				isConnected = false;
			}
			else
				onConnected(newMesh); 
		}
		
	
		
		/////////////
		//FUNCTIONS//
		/////////////
				
		//saving data and setting the graphics
		public function Bubble(type:int) {
			
			_type = type;		
						
			//creating body
			_body.shapes.add(new Circle(DIAMETR / 2));			
			_body.userData.ref = this;
			_body.allowMovement = false;
			_body.allowRotation = false;
			_body.cbTypes.add(_bubbleCBType);
			_body.isBullet = true;
			
			//ice is a little bit wider than diametr
			var frozenMCScale:Number = 1.2 * DIAMETR / _frozenMC.width;
			_frozenMC.scaleX = frozenMCScale;
			_frozenMC.scaleY = frozenMCScale;
			
			_view.addEventListener(Event.ENTER_FRAME, UpdateGraphics);
			
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.PAUSE, onGameStateChanged);
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.RESUME, onGameStateChanged);
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.REMOVED, function onRemove(e:Event):void {
				(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.REMOVED, onRemove);
				(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.PAUSE, onGameStateChanged);
				(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.RESUME, onGameStateChanged);
			});
		}
				
		public function Update():void {
			
		}
		
		public function StartLifeTimer():void {
			_lifeTimer = new Timer(LIFE_TIME * 1000, 1);			
			_lifeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onLifeEnd);
			_lifeTimer.start();
		}
		
		private function onLifeEnd(e:TimerEvent):void {
			Delete();
		}
		
		public function onConnected(mesh:BubbleMesh):void { 
			_isConnected = true;
			_body.isBullet = false;
			_mesh = mesh; 
			
			_body.shapes.clear();
			_body.shapes.add(new Circle(MESH_BUBBLE_DIAMETR / 2));			
			_body.cbTypes.add(_connectedBubbleCBType);
			_body.type = BodyType.KINEMATIC;
			 
			_body.allowMovement = false;
			
			if (_lifeTimer) {
				_lifeTimer.stop();
				_lifeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onLifeEnd);
			}
		}
		
		//deleting the bubble from mesh and removing view 
	    public function Delete(withPlane:Boolean = false):void {
			mesh = null;
			_mesh = null;
			if (_body) _body.space = null;
			_body = null;			
			
			if (_effects.parent) _effects.parent.removeChild(_effects);
			_effects = null;
			
			_view.parent.removeChild(_view);			
			_view.removeEventListener(Event.ENTER_FRAME, UpdateGraphics);
			_view = null;
			
			if (_iceTween) { 
				_iceTween.paused = true;
				_iceTween.onComplete = null;
				_iceTween = null;
			}
			
			if (_lifeTimer) {
				_lifeTimer.stop();
				_lifeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onLifeEnd);
			}
			if (Main.GSM.GetCurrentState() is GameState) {
				(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.PAUSE, onGameStateChanged);
				(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.RESUME, onGameStateChanged);
			}
		}		
		
		//return bubble's graphics
		public function GetBubbleImage():MovieClip { return null; }
		
		public function AddCBT(cbt:CbType):void {
			_body.cbTypes.add(cbt);
		}
		
		
		private function UpdateGraphics(e:Event):void {
			_view.x = _body.position.x;
			_view.y = _body.position.y;
			
			_effects.x = _body.position.x;
			_effects.y = _body.position.y;
		}
		
		//handling game pause/resume 
		public function onGameStateChanged(e:Event):void {
			if (_lifeTimer) e.type == State.PAUSE ? _lifeTimer.stop() : _lifeTimer.start();
		}		
		
		public function WallTouched():void {
			_timesWallTouched++;
			if (_timesWallTouched == MAX_TIMES_WALL_TOUCHED && mesh == null)
				Delete();
		}
	}	
}
