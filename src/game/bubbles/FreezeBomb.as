package game.bubbles {
	import com.gskinner.motion.GTween;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.sendToURL;
	
	import game.Bubble;
	import game.BubbleMesh;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.space.Space;
	
	import states.GameState;
	
	import util.State;
	
	public class FreezeBomb extends Bubble { 
		private const WAVE_VEL:Number = 500;     //pixels in second
		private const MAX_RADIUS:Number = 550;  //pixels
		
		private var _sensorWave:Body;
		private var _sensorShape:Circle;
		private var _sensorListener:InteractionListener;
		private var _sensorCbType:CbType = new CbType();
		private var _sensorTween:GTween;
		
		public function FreezeBomb() {
			super(FREEZE_BOMB);
			
			var bubbleMC:MovieClip = new bomb_ice_mc();
			scale = DIAMETR / bubbleMC.width;
			bubbleMC.addChildAt(new bomb_ice_shadow_mc(), 0);
			bubbleMC.width *= scale;
			bubbleMC.height *= scale;
			view = bubbleMC;
		}
		
		/*
		 * The idea is that: to create a sensor that will increase its size
		 * when it will reach bubbles we will call callback that will freeze them
		 */
		
		override public function onConnected(mesh:BubbleMesh):void {
			super.onConnected(mesh);	
			
						
			Main.SM.PlaySound(new ice_snd());
									
			//freeze wave
			_sensorShape = new Circle(DIAMETR / 2);
			_sensorShape.sensorEnabled = true;			
			_sensorWave= new Body(BodyType.KINEMATIC, position);
			_sensorWave.cbTypes.add(_sensorCbType);			
			_sensorWave.shapes.add(_sensorShape);
			space.bodies.add(_sensorWave);
					
			//setting interaction
			_sensorListener = new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, _sensorCbType, Bubble.ConnectedBubbleCBType, WaveCallback, -1);
			space.listeners.add(_sensorListener);
						
			//increasing radius
			_sensorTween = new GTween(_sensorShape, MAX_RADIUS / WAVE_VEL, {radius:MAX_RADIUS});
			_sensorTween.onComplete = DestroySensor;
			
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.PAUSE, pauseFreezeTween);
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.RESUME, pauseFreezeTween);
			mesh.Freeze();
			
			Delete();
		}
		
		private function WaveCallback(cb:InteractionCallback):void {
			var bubble:Bubble = cb.int2.castBody.userData.ref as Bubble;
			bubble.isFrozen = true;
		}
		
		//removing sensor
		private function DestroySensor(e:GTween):void {
			(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.PAUSE, pauseFreezeTween);
			(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.RESUME, pauseFreezeTween);
			
			_sensorWave.space.listeners.remove(_sensorListener);
			_sensorWave.space = null
			_sensorTween.onComplete = null;
			_sensorTween = null;
		}
		
		override public function GetBubbleImage():MovieClip {
			return new bomb_ice_mc();
		}
		
		private function pauseFreezeTween(e:Event):void {
			if (e.type == State.PAUSE) _sensorTween.paused = true;
			else _sensorTween.paused = false;
		}
	}
}