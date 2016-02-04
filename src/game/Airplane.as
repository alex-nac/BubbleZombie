package game {
	import com.gskinner.motion.GTween;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import game.bubbles.Sprayer;
	import game.bubbles.Zombie;
	import game.events.ComboEvent;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import util.Animation;
	import util.SoundWrapper;
			
	//Class represent airplane that appears when we win the game
	
	public class Airplane extends EventDispatcher {		
		private var EXPLOSION_CHANCE:Number;
		public static const END_FLY:String = "END_FLY";
		public static const END_LAST_WAVE:String = "END_LAST_WAVE";
		public static const SPACE_PLANE_TIME:int = 3;
		
		private const LAST_WAVE_SPEED:Number = 272;           //pixels by second
		private const LAST_WAVE_DELETING_SPEED:Number = 136;  //pixels by second
		
		private var _space:Space;
		private var _view:MovieClip;
		private var _bombArea:Body;
		private var _bombAreaCBT:CbType = new CbType();
		private var _movingTween:GTween;
		private var _shadowOffset:Vec2;
		private var _interactionListener:InteractionListener;
		
		private var _lastWaveBody:Body;
		private var _lastWaveTween:GTween;
		private var _wasLastWaveTouchedBubble:Boolean = false;
		
		private var _airplaneSound:SoundWrapper;
		private var _bombSound:SoundWrapper;
		
		private var _lastPlaneStarted:Boolean = false;
		private var _isFlying:Boolean = false;
		private var _wasLastPlaneCalled:Boolean = false;
		private var _bigBangTimer:Timer;
		
		private var _killedBubbles:Vector.<Bubble> = new Vector.<Bubble>();
		private var _killedEnemiesWithLastWave:int = 0;
			
		//sound management
		private var _actionCount:int = 10000;
				
		//public var onComplete:Function = function():void {};		
		public function get view():MovieClip { return _view; }
		public function get wasLastPlaneCalled():Boolean { return _wasLastPlaneCalled; }
		public function get killedEnemiesWithLastWave():int { return  _killedEnemiesWithLastWave; }
		
		public function Airplane(space:Space) {
			var plainMC:MovieClip = new plain_shadow_mc();
			_view = plainMC;
			_view.visible = false;
			
			
			_space = space;			
			_bombArea = new Body(BodyType.KINEMATIC);			
			_bombArea.cbTypes.add(_bombAreaCBT);
		}
		
		//firstable we start plane tween
		public function Start(startP:Vec2, endP:Vec2, movingTime:Number, bombAreaDiametr:int = 300, explosionChance:Number = 2/3, deleteAll:Boolean = true):void {	
			_isFlying = true;
			_actionCount = 0;
			EXPLOSION_CHANCE = explosionChance;
			
			_view.rotation = startP.sub(endP).angle * 180 / Math.PI;
			var scale:Number = bombAreaDiametr / _view.width * _view.scaleX;
			_view.scaleX = scale;
			_view.scaleY = scale;
			
			if (deleteAll) _shadowOffset = startP.sub(endP).normalise().mul(270);
			else _shadowOffset = startP.sub(endP).normalise().mul(280);
			 
			
			//deleting all the shapes and adding new one
			_bombArea.shapes.clear();
			_bombArea.shapes.add(new Circle(bombAreaDiametr / 2));
			_bombArea.shapes.at(0).sensorEnabled = true;
			_bombArea.position = startP;
			_bombArea.space = _space;
			
			//we set interaction listener ans when plane touches the bubble it explodes it
			_interactionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, _bombAreaCBT, Bubble.ConnectedBubbleCBType, OnBubbleTouched, 1); 
			_space.listeners.add(_interactionListener);
			
			_movingTween = new GTween(_bombArea.position, movingTime, {x:endP.x, y:endP.y});
			_movingTween.onComplete = OnMovingTweenComplete;
			_movingTween.data = deleteAll;
									
			UpdateGraphics(null);
			_view.visible = true;
			_view.addEventListener(Event.ENTER_FRAME, UpdateGraphics);
		}
		
		public function Remove():void {
			if (_bigBangTimer) _bigBangTimer.removeEventListener(TimerEvent.TIMER, ShowBigBang);
		}
		
		//we do this because of the issue when the last plane started while the regular plane was deleting bubbles
		public function StartLastPlane():void {
			_lastPlaneStarted = true;
			_wasLastPlaneCalled = true;
		}
		
		public function Update():void {	
			if (_lastPlaneStarted && !_isFlying) {
				_lastPlaneStarted = false;
				Start(new Vec2(-150, 590), new Vec2(500, 98), 5);
				
				_bigBangTimer = new Timer(2000, 1);
				_bigBangTimer.addEventListener(TimerEvent.TIMER, ShowBigBang);
				_bigBangTimer.start();
			}
			
			//we start plane sound 
			if (_actionCount == 0) 
				_airplaneSound = Main.SM.PlaySound(new plain_snd());
			
			//we start bomb sound after 0.5 second
			if (_wasLastPlaneCalled) 
				if (_actionCount == 15) _bombSound = Main.SM.PlaySound(new airstrike_snd());
			
			if (!_wasLastPlaneCalled)
				if (_actionCount == 15) _bombSound = Main.SM.PlaySound(new pl_fire_snd());
			
			_actionCount++;
		}

		private function ShowBigBang(e:TimerEvent):void {
			var anim:Animation = new Animation(new bomb_expl_mc(), 1.1);
			anim.x = 320;
			anim.y = 240;
			if (_view && _view.parent) _view.parent.addChild(anim);
		}
		
		public function onGameStateChanged(isPaused:Boolean):void {
			if (_movingTween) _movingTween.paused = isPaused;
			if (_lastWaveTween) _lastWaveTween.paused = isPaused;
			if (_bigBangTimer) isPaused ? _bigBangTimer.stop() : _bigBangTimer.start();
			
			if (_airplaneSound) 
				if (isPaused) _airplaneSound.Pause();
				else _airplaneSound.Play();
			
			if (_bombSound) 
				if (isPaused) _bombSound.Pause();
				else _bombSound.Play();
		}
		
		private function OnMovingTweenComplete(e:GTween):void {
			
			//if we need last wave after the plane
			if (e.data as Boolean) {
				_lastWaveBody = new Body(BodyType.KINEMATIC);
				_lastWaveBody.shapes.add(new Polygon(Polygon.box(_view.stage.stageWidth, 1)));
				_lastWaveBody.position = new Vec2(_view.stage.stageWidth / 2, _view.stage.stageHeight);
				_lastWaveBody.shapes.at(0).sensorEnabled = true;
				_lastWaveBody.cbTypes.add(_bombAreaCBT);
				_lastWaveBody.space = _space;
				_lastWaveTween = new GTween(_lastWaveBody.position, 480 / LAST_WAVE_SPEED, {y:0});
				_lastWaveTween.onComplete = OnLastWaveTweenComplete;
			}
			else {
				_space.listeners.remove(_interactionListener);
				_interactionListener = null;
				for each (var bbl:Bubble in BFS.GetUnrootedBubbles()) {
					_killedBubbles.push(bbl);
					bbl.Delete(true);
				}
				dispatchEvent(new ComboEvent(ComboEvent.COMBO, _killedBubbles));
				_killedBubbles.splice(0, _killedBubbles.length);
			}
			
			
			_movingTween.target = null;
			_movingTween.onComplete = null;
			_movingTween = null;
						
			_view.removeEventListener(Event.ENTER_FRAME, UpdateGraphics);
			_view.visible = false;
			
			_bombArea.space = null;
						
			if (_airplaneSound) {
				_airplaneSound.StopAndDelete();
				_airplaneSound = null;
			}	
			if (_bombSound) {
				_bombSound.StopAndDelete();
				_bombSound = null;
			}	
			
			_isFlying = false;
			dispatchEvent(new Event(END_FLY));
		}
		
		private function OnLastWaveTweenComplete(e:GTween):void {
			_lastWaveTween.target = null;
			_lastWaveTween.onComplete = null;
			_lastWaveTween = null;
			_lastWaveBody.space = null;
			_lastWaveBody = null;
			
			_space.listeners.remove(_interactionListener);
			_interactionListener = null;
			
			
			_space = null;
			_view.parent.removeChild(_view);
			_view = null;
			
			_bombArea = null;
			_bombAreaCBT = null;
			
			for each (var bbl:Bubble in _killedBubbles) 
				if (bbl is Zombie || bbl is Sprayer) _killedEnemiesWithLastWave++;
			dispatchEvent(new ComboEvent(ComboEvent.COMBO, _killedBubbles));
			_killedBubbles.splice(0, _killedBubbles.length);
			
			//onComplete();
			//onComplete = null;
			dispatchEvent(new Event(END_LAST_WAVE));
		}
		
		//shadow must follow the _bombArea body
		private function UpdateGraphics(e:Event):void {
			_view.x = _bombArea.position.x - _shadowOffset.x;
			_view.y = _bombArea.position.y - _shadowOffset.y;
		}
		
		//the last row we've destroyed with last wave
		private var _lastRowDestroyed:int = -1;
		
		//exploding bubble if we touched it
		private function OnBubbleTouched(e:InteractionCallback):void {
			//we use chance only for moving plane tween
			if (Math.random() > EXPLOSION_CHANCE && _movingTween) return;
			
			var bubble:Bubble = e.int2.castBody.userData.ref as Bubble;
			
			//play bomb sound every row if it is last wave 
			if (_lastWaveTween && bubble.meshPosition.x != _lastRowDestroyed) {
				_lastRowDestroyed = bubble.meshPosition.x;
				Main.SM.PlaySound(new explosion_02_snd());
				if (!_wasLastWaveTouchedBubble) {					
					_wasLastWaveTouchedBubble = true;
					
					//delete this tween
					var endY:Number = _lastWaveTween.getValue("y");
					_lastWaveTween.deleteValue("y");
					_lastWaveTween.target = null;	
					_lastWaveTween.onComplete = null;
					
					//set new speed to tween
					_lastWaveTween = new GTween(_lastWaveBody.position, (_lastWaveBody.position.y - endY) / LAST_WAVE_DELETING_SPEED, {y:endY});
					_lastWaveTween.onComplete = OnLastWaveTweenComplete;
				}
			}
				
			_killedBubbles.push(bubble);
			ExplodeBubble(bubble);				
		}
		
		private function ExplodeBubble(bubble:Bubble):void {
			var bombExplMc:bomb_expl_mc = new bomb_expl_mc();
			bombExplMc.x = bubble.x;
			bombExplMc.y = bubble.y;
			var anim:Animation = new Animation(bombExplMc, Bubble.DIAMETR / bombExplMc.width);
			_view.parent.addChild(anim); 
			
			bubble.Delete(true);
		}
		
	}
}