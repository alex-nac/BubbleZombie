package game {
	import com.gskinner.motion.GTween;
	
	import flash.events.Event;
	
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
	
	public class BubbleDeleter {
		private const WAVE_VEL:Number = 400;     //pixels in second
		private const MAX_RADIUS:Number = 550;   //pixels
		
		private var _deleterCBT:CbType = new CbType();	
		private var _deletingCBT:CbType = new CbType();
		private var _sensorWave:Body;
		private var _sensorShape:Circle;
		private var _sensorListener:InteractionListener;		
		private var _sensorTween:GTween;
		
		public function BubbleDeleter(startPos:Vec2, bubblesToDelete:Vector.<Bubble>, space:Space) {
			//preparing bubbles for deleting
			for each (var bbl:Bubble in bubblesToDelete) { 
				bbl.isSensor = true;
				bbl.AddCBT(_deletingCBT);
			}
			
			//deleting wave
			_sensorShape = new Circle(Bubble.DIAMETR / 2);
			_sensorShape.sensorEnabled = true;			
			_sensorWave= new Body(BodyType.KINEMATIC, startPos);
			_sensorWave.cbTypes.add(_deleterCBT);			
			_sensorWave.shapes.add(_sensorShape);
			space.bodies.add(_sensorWave);
			
			//setting interaction
			_sensorListener = new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, _deleterCBT, _deletingCBT, WaveCallback);
			space.listeners.add(_sensorListener);
			
			//increasing radius
			_sensorTween = new GTween(_sensorShape, MAX_RADIUS / WAVE_VEL, {radius:MAX_RADIUS});
			_sensorTween.onComplete = DestroySensor;
			
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.PAUSE, pauseDeteler);
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.RESUME, pauseDeteler);
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.REMOVED, onStateRemoved);
		}
		
		private function WaveCallback(cb:InteractionCallback):void {
			var bubble:Bubble = cb.int2.castBody.userData.ref as Bubble;
			bubble.Delete();
		}
		
		private function onStateRemoved(e:Event):void {
			if (_sensorTween) _sensorTween.end();
		}
		
		//removing sensor
		private function DestroySensor(e:GTween):void {	
			(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.PAUSE, pauseDeteler);
			(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.RESUME, pauseDeteler);
			(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.REMOVED, onStateRemoved);
			
			_sensorWave.space.listeners.remove(_sensorListener);
			_sensorWave.space = null
			_sensorTween.onComplete = null;
			_sensorTween = null;
		}
		
		private function pauseDeteler(e:Event):void {
			if (e.type == State.PAUSE) _sensorTween.paused = true;
			else _sensorTween.paused = false;
		}
	}
}