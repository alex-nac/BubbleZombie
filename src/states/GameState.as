package states {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Circular;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import FGL.GameTracker.GameTracker;
	
	import UI.AchievmentPanel;
	import UI.AirplaneTimeLeftIndicator;
	import UI.Indicator;
	import UI.MasterPopup;
	import UI.PlaneButton;
	import UI.SlidingPanel;
	import UI.WaveIndicator;
	
	import game.AchievmentsManager;
	import game.AimPointer;
	import game.Airplane;
	import game.BFS;
	import game.Bubble;
	import game.BubbleMesh;
	import game.FloatingText;
	import game.Gun;
	import game.Score;
	import game.bubbles.SimpleBubble;
	import game.bubbles.Zombie;
	import game.events.ComboEvent;
	import game.events.GunEvent;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	
	import util.Animation;
	import util.ClassResolver;
	import util.GameConfig;
	import util.State;
	import util.Timer;
	
	public class GameState extends State {
		//update loop delta time in ms
		private const DT:Number = 1000/30;
		
		//current state
		private const LOSE:int = 1;
		private const WON:int = 2;
		
		//whether the player losed the game
		private var _currWonState:int = 0;
		
		private var _useDebugView:Boolean;
	
		//sprite containers
		private var _game:Sprite = new Sprite();
		private var _pause:pop_pause_mc = new pop_pause_mc();
		private var _UI:Sprite = new Sprite();
		
		//game objects
		private var _space:Space = new Space();
		private var _debug:Debug;
		private var _mesh:BubbleMesh;
		private var _gun:Gun;
		private var _wonTimer:Timer	
		private var _score:Score;
		private var _lvlNum:int;
		private var _slidingPanel:SlidingPanel;
		private var _indicator:Indicator;
		private var _waveIndicator:WaveIndicator;
		private var _airplaneTimeLeftIndicator:AirplaneTimeLeftIndicator;
		private var _airplane:Airplane;
		private var _masterPopup:MasterPopup;
		
		public static var aimPointer:AimPointer = new AimPointer(); 

		//buttons	
		private var _planeBtn:PlaneButton;
		
		public function GameState(levelNum:int) {	
			super();
			addEventListener(State.PAUSE, pauseHandler);
			addEventListener(State.RESUME, resumeHandler);
			
			_lvlNum = levelNum;			
			addEventListener(Event.ADDED_TO_STAGE, CreateLevel);
		}		
				
		private function CreateLevel(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, CreateLevel);
						
			Main.SetPoiner(aimPointer);
			Main.SM.SetBackSong(new menu_snd());
													
			addChild(_game);
			_pause.visible = false;
			_pause.x = stage.stageWidth / 2;
			_pause.y = stage.stageHeight / 2;
			_pause.addEventListener(MouseEvent.CLICK, Resume);
			addChild(_pause); 
			addChild(_UI);
			
			_debug = new BitmapDebug(640, 480, 333333 ,true);
			addChild(_debug.display);
			
			var cfg:GameConfig = new GameConfig(Main.LVLC.GetLevel(_lvlNum));
			_useDebugView = Boolean(cfg.useDebugView);
			
			Bubble.MESH_BUBBLE_DIAMETR = cfg.meshBubbleDiametr;
			SimpleBubble.COLORS_AMOUNT = cfg.colors;
			
			//Background
			var BGclass:Class = ClassResolver.getClass(cfg.BGclassName);
			var back:Sprite = new BGclass();
			back.cacheAsBitmap = true;
			_game.addChild(back);
			var swatCar:swat_mc = new swat_mc();
			swatCar.x = stage.stageWidth / 2;
			swatCar.y = stage.stageHeight + 13;
			_game.addChild(swatCar);
			
			CreateGameConditionals(cfg);
			
			////////
			///UI///
			////////
			
			_score = new Score(cfg);
			_slidingPanel = new SlidingPanel(stage.stageWidth - 80, _lvlNum);
			_slidingPanel.onOpened = function():void { Pause(); }
			_slidingPanel.onClosed = function():void { Resume(); }
			_UI.addChild(_slidingPanel);		
			
			//game_pad
			var pad:MovieClip;
			if (cfg.planeButtonTime != 0) {
				_indicator = new Indicator(32, 445, 41);
				pad = new igm_ui_pad_mc(); 
				pad.scaleX = pad.scaleY = 0.8;
			}
			else {
				_indicator = new Indicator(34, 446, 41);
				pad = new igm_ui_pad_mc_noplane();
				pad.scaleX = pad.scaleY = 0.8;
			}
			pad.y = stage.stageHeight;
			_UI.addChild(pad);
			_UI.addChild(_indicator.view);
			
			//plane button & space_key
			if (cfg.planeButtonTime != 0) {
				_planeBtn = new PlaneButton(cfg.planeButtonTime, cfg.tutorClassName == "tutorial_04_mc");
				_planeBtn.x = 90;
				_planeBtn.y = 452;	
				_planeBtn.scaleX = _planeBtn.scaleY = 0.8;
				_planeBtn.addEventListener(MouseEvent.MOUSE_DOWN, StartPlane);			
				_UI.addChild(_planeBtn);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, StartPlane);
				
				if (cfg.planeButtonTime == -1) _planeBtn.isAirplaneAvalible = false;
				else _planeBtn.isAirplaneAvalible = true;
			}
			
			//wave indicator
			_waveIndicator = new WaveIndicator(cfg.rowsNum - cfg.rowsShowed, BubbleMesh.MESH_MOVING_TIME);
			_waveIndicator.x = 15;
			_waveIndicator.y = 16;			
			_UI.addChild(_waveIndicator);
			
						
			//GAME OBJECTS			  
			_mesh = new BubbleMesh(_space, cfg);	
			_mesh.addEventListener(ComboEvent.COMBO, ComboHandler); //score updating
			_mesh.addEventListener(BubbleMesh.LAST_WAVE, StartWonTimer);
			_mesh.addEventListener(BubbleMesh.CAR_EXPLOSION, ExplodeCar);
			_mesh.addEventListener(BubbleMesh.ALL_EMENIES_KILLED, MasterAchHandler);
			_mesh.addEventListener(BubbleMesh.NEW_ROW, _waveIndicator.NewRow);
			_game.addChild(_mesh.view);
			
			BFS.mesh = _mesh;
			
			_gun = new Gun(cfg, _space, _lvlNum >= 21, _mesh);
			_gun.addEventListener(GunEvent.SHOOT, _indicator.SetNextSprite);
			_gun.addEventListener(GunEvent.SHOOT, aimPointer.onNewBullet);
			_gun.addEventListener(GunEvent.MOVED, aimPointer.onGunMoved);
			_game.addChild(_gun.view);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, Shoot);
			
			CreateWalls(cfg);									
			
			_airplane = new Airplane(_space);	
			_airplane.addEventListener(Airplane.END_LAST_WAVE, EndLevel);
			_airplane.addEventListener(ComboEvent.COMBO, ComboHandler);
			_game.addChild(_airplane.view);
			
			//showing tutorial if it exist
			if (cfg.tutorClassName) {
				_pause.txt.visible = false;
				Pause();
				var tutorClass:Class = ClassResolver.getClass(cfg.tutorClassName);
				var tutor:Sprite = new tutorClass();
				new GTween(tutor, 0.7, {scaleX:0, scaleY:0}, {swapValues:true, ease:Circular.easeOut})
				_pause.addChild(tutor);
				addEventListener(State.RESUME, function closeTutor(e:Event):void {
					removeEventListener(State.RESUME, closeTutor);
					_pause.txt.visible = true;
					_pause.removeChild(tutor);
				});
			}
			//BlurPlugin.install();
		}
		
		private var _wallCBT:CbType = new CbType();
		private function CreateWalls(cfg:GameConfig):void {
			if (!cfg.useWalls) return;
				
			//bouncing walls
			var leftWall:Body = new Body(BodyType.STATIC);
			leftWall.shapes.add(new Polygon(Polygon.rect(0, 0, cfg.leftWallEdge, stage.stageHeight)));
			leftWall.shapes.at(0).material = new Material(1.0, 0.0);
			leftWall.cbTypes.add(_wallCBT);
			leftWall.space = _space;
			
			var rightWall:Body = new Body(BodyType.STATIC);
			rightWall.shapes.add(new Polygon(Polygon.rect(cfg.rightWallEdge, 0, stage.stageWidth - cfg.rightWallEdge, stage.stageHeight)));
			rightWall.shapes.at(0).material = new Material(1.0, 0.0);
			rightWall.cbTypes.add(_wallCBT);
			rightWall.space = _space;
			
			//annihilator
			var annihilator:Body = new Body(BodyType.STATIC);
			annihilator.shapes.add(new Polygon(Polygon.rect(-100, -100, stage.stageWidth + 200, 100 - 1.5 * Bubble.DIAMETR)));
			annihilator.shapes.at(0).sensorEnabled = true;
			annihilator.space = _space;
			var annihilatorCBT:CbType = new CbType();
			annihilator.cbTypes.add(annihilatorCBT);
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, annihilatorCBT, Bubble.BubbleCBType, AnnihilatorHandler));
		}
		
		private function CreateGameConditionals(cfg:GameConfig):void {
			//won conditional
			_wonTimer = new Timer(cfg.wonTime);
			_wonTimer.isPaused = true;
			_wonTimer.addEventListener(Timer.TRIGGED, GameWon);	
			
			//lose conditional 			
			var loseSensor:Body = new Body(BodyType.STATIC, new Vec2(0, 0));
			var shape:Shape = new Polygon(Polygon.rect(0, 416, stage.stageWidth, stage.stageHeight - 416));		
			shape.sensorEnabled = true; 
			loseSensor.shapes.add(shape);
			var loseSensorCBT:CbType = new CbType();
			loseSensor.cbTypes.add(loseSensorCBT);
			loseSensor.space = _space;
			//we use ongoing because of situation when we shoot with bubble and while connecting to the mesh it is touching sensor
			_space.listeners.add(new InteractionListener(CbEvent.ONGOING, InteractionType.SENSOR, loseSensorCBT, Bubble.ConnectedBubbleCBType, GameLose));
			
			//bullet exploding cond.
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, _wallCBT, Bubble.BubbleCBType, BulletTouchedWall, 1));
			
		}
		
		
		//deleting game state
		override public function Remove():void {
			super.Remove();
			
			if (_masterPopup) _masterPopup.Remove();
			if (_airplaneTimeLeftIndicator) _airplaneTimeLeftIndicator.Remove();
			
			_mesh.removeEventListener(BubbleMesh.NEW_ROW, _waveIndicator.NewRow);
			_mesh.removeEventListener(ComboEvent.COMBO, ComboHandler); //score updating
			_mesh.removeEventListener(BubbleMesh.LAST_WAVE, StartWonTimer);
			_mesh.removeEventListener(BubbleMesh.CAR_EXPLOSION, ExplodeCar);
			_mesh.removeEventListener(BubbleMesh.ALL_EMENIES_KILLED, MasterAchHandler);
			
			_gun.removeEventListener(GunEvent.SHOOT, _indicator.SetNextSprite);
			_gun.removeEventListener(GunEvent.SHOOT, aimPointer.onNewBullet);
			_gun.removeEventListener(GunEvent.MOVED, aimPointer.onGunMoved);
			
			_airplane.removeEventListener(ComboEvent.COMBO, ComboHandler);
			_airplane.removeEventListener(Airplane.END_LAST_WAVE, EndLevel);
			_airplane.Remove();
			
			Main.SetPoiner(new pointer_mc());
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, Shoot);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, StartPlane);
			_pause.removeEventListener(MouseEvent.CLICK, Resume);
			_slidingPanel.Delete();
			_space.clear();
		}
		
		//fixed time-step for correct physics 
		private var _currentTime:Number = getTimer();
		private var _accumulator:Number = 0.0;
		
		override protected function Update():void {		
			var newTime:Number = getTimer();
			var frameTime:Number = newTime - _currentTime;
			_currentTime = newTime;
			_accumulator += frameTime;
			
			_space.step(frameTime / 1000);
			
			while (_accumulator >= DT) {	
				_gun.Update();
				_mesh.Update();
				_airplane.Update();
				_wonTimer.Update();
				_slidingPanel.Update(_score, _wonTimer.GetRemainingTime());
				
				_accumulator -= DT;
			}
					
			if (_useDebugView) {
				_debug.clear();
				_debug.draw(_space);
				_debug.flush();
			}
		}
				
		private function Shoot(e:MouseEvent):void {
			//MasterAchHandler(null);
			_gun.Shoot(); 			
		}
		
		private function GameLose(e:InteractionCallback):void {	
			if (_currWonState != 0 || (e && !(e.int2.castBody.userData.ref as Bubble).isConnected)) return;
						
			//prevent won timer from triggering
			_wonTimer.removeEventListener(Timer.TRIGGED, GameWon);			
			
			_currWonState = LOSE;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, Shoot);
			if (_planeBtn) _planeBtn.removeEventListener(MouseEvent.MOUSE_DOWN, StartPlane);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, StartPlane);
			if (_planeBtn) _planeBtn.StopRecharging();
			_mesh.Stop();
			
			var blackScreen:Black_mc = new Black_mc();
			blackScreen.alpha = 0;
			addChild(blackScreen);
			
			//tween 
			var t_darkness:Number = 2;             //darkness time
			var t_tween:Number = t_darkness + 1;   //after that wait this time with constant alpha
			
			var loseTw:GTween = new GTween(blackScreen, 2);			
			
			loseTw.onChange = function onChange(gt:GTween):void {
				if (gt.ratio <= t_darkness / t_tween)				
					blackScreen.alpha = gt.ratio				
			}
			
			loseTw.onComplete = function onComplete (e:GTween):void {
				Main.GSM.PopState();
				Main.GSM.PushState(new LevelCompleteState(true, _lvlNum));
			}
		}
		
		private function GameWon(e:Event):void {
			
			if (_currWonState != 0) return;
			_currWonState = WON;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, Shoot);
			_wonTimer.removeEventListener(Timer.TRIGGED, GameWon);	
			_mesh.Stop();
			
			_airplane.StartLastPlane();			
			if (_planeBtn) _planeBtn.removeEventListener(MouseEvent.MOUSE_DOWN, StartPlane);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, StartPlane);
			if (_planeBtn) _planeBtn.StopRecharging();
		}
		
		private function StartWonTimer(e:Event):void {
			_wonTimer.isPaused = false;
			_airplaneTimeLeftIndicator = new AirplaneTimeLeftIndicator(_wonTimer.GetRemainingTime());
			_airplaneTimeLeftIndicator.x = _waveIndicator.x;
			_airplaneTimeLeftIndicator.y = _waveIndicator.y;
			addChild(_airplaneTimeLeftIndicator);
			_waveIndicator.visible = false;
		}
			
		private var _pauseTime:Number;
		private function pauseHandler(e:Event):void {
			Main.SM.SetBackSongState(true);
			_pauseTime = getTimer();
			Main.SetPoiner(new pointer_mc());
			_gun.canShoot = false;
			_pause.visible = true;
			_mesh.onGameStateChaged(true);
			_airplane.onGameStateChanged(true);
			if (_planeBtn) _planeBtn.paused = true;
			_waveIndicator.onGameStateChanged(true);
			if (_airplaneTimeLeftIndicator) _airplaneTimeLeftIndicator.onGameStateChanged(true);
			//new GTween(_game, 0.3, {blur:4});			
		}
		
		private function resumeHandler(e:Event):void {
			Main.SM.SetBackSongState(false);
			_currentTime += getTimer() - _pauseTime;
			Main.SetPoiner(aimPointer);
			_gun.canShoot = true;
			_pause.visible = false; 
			_mesh.onGameStateChaged(false);
			_airplane.onGameStateChanged(false);
			if (_planeBtn) _planeBtn.paused = false;
			_waveIndicator.onGameStateChanged(false);
			if (_airplaneTimeLeftIndicator) _airplaneTimeLeftIndicator.onGameStateChanged(false);
			//new GTween(_game, 0.3, {blur:0});
		}
	
		private function ComboHandler(e:ComboEvent):void {
			if (e.target is Airplane) 
				_score.UpdateScore(e, false);
			else _score.UpdateScore(e, true);
			
			//calculating killed zombies
			var killedZombies:int = 0;
			for each (var bubble:Bubble in e.killed)
			if (bubble is Zombie) killedZombies++;
			
			if (killedZombies < 6 && Math.random() < 0.15 && (_lvlNum <= 20 || _lvlNum == 25)) {
				if ( !(e.target is Airplane) || (e.target is Airplane && !(e.target as Airplane).wasLastPlaneCalled) ) {
					var floatingText:FloatingText = new FloatingText("GREAT!",new combo_mc(), 14);
					floatingText.x = 320;
					floatingText.y = 240;
					floatingText.scaleX = floatingText.scaleY = 1.7;
					if (e.killed[0].mesh) e.killed[0].mesh.AddEffect(floatingText, true);
				}
			}
			
			//checking for combo
			if (AchievmentsManager.CheckForZOMBIEHUNTER(killedZombies))
				_UI.addChild(new AchievmentPanel(AchievmentsManager.ZOMBIEHUNTER, stage.stageWidth, 0));
		}
		
		private function MasterAchHandler(e:Event):void {			
			if (_currWonState != 0) return;
			_currWonState = WON;
			
			//prevent won timer from triggering
			_wonTimer.removeEventListener(Timer.TRIGGED, GameWon);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, Shoot);
			_mesh.Stop();
			if (_planeBtn) _planeBtn.removeEventListener(MouseEvent.MOUSE_DOWN, StartPlane);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, StartPlane);
			if (_planeBtn) _planeBtn.StopRecharging();
			
			//if we gained ach -> showing bonus popup
			if (!_airplane.wasLastPlaneCalled) {
				if (AchievmentsManager.CheckForMASTER()) 
					_UI.addChild(new AchievmentPanel(AchievmentsManager.MASTER, stage.stageWidth, 0));
				_score.PlusMasterBonus();
				
				_masterPopup = new MasterPopup();
				_masterPopup.x = stage.stageWidth / 2;
				_masterPopup.y = stage.stageHeight / 2;
				_masterPopup.onPopupComplete = EndLevel;
				_game.addChild(_masterPopup);
				
			}
		
		}
		
		//just a little darkness at the end of the level
		private function EndLevel(e:Event = null):void {			
			var blackScreen:Black_mc = new Black_mc();
			blackScreen.alpha = 0;
			addChild(blackScreen);			
			 
			var tw:GTween = new GTween(blackScreen, 0.5, {alpha:1});
			tw.paused = true;
			tw.onComplete = function onComp(g:GTween):void {
				Main.GSM.PopState();
				Main.GSM.PushState(new LevelCompleteState(false, _lvlNum, _score.score, _score.enemiesKilled - _airplane.killedEnemiesWithLastWave, _masterPopup));
			}
				
			var delayTween:GTween = new GTween(null, 0.5);
			delayTween.nextTween = tw;
		}
		
		private function AnnihilatorHandler(e:InteractionCallback):void {
			(e.int2.castBody.userData.ref as Bubble).Delete();
		}
	
		private function ExplodeCar(e:Event):void {
			if (_currWonState != 0) return;
			_currWonState = LOSE;
			
			new GTween(_gun.view, 0.3, {alpha:0});
			var explosion:bomb_expl_mc = new bomb_expl_mc();
			explosion.x = _gun.view.x;
			explosion.y = _gun.view.y;
			addChild(new Animation(explosion, 1));
			GameLose(null);
		}
		
		//helping plane that destroy 1-st 3 rows
		private function StartPlane(e:Event):void {
			 
			e.stopImmediatePropagation();
			if (e.type == KeyboardEvent.KEY_DOWN && (e as KeyboardEvent).keyCode != Keyboard.SPACE) return;
			if (isPaused) return;
			if (!_planeBtn.isAirplaneAvalible) {
				Main.SM.PlaySound(new block_snd());
				return;
			}
			
			//if we can start plane now
			if (_planeBtn.isFullCharged) {
				GameTracker.api.customMsg("Plane Started at level " + _lvlNum);
				var y:Number = _mesh.GetDownMeshBound() - Bubble.DIAMETR;
				_airplane.Start(new Vec2(-320, y), new Vec2(700, y), Airplane.SPACE_PLANE_TIME, Bubble.DIAMETR + 50, 1, false);
				_planeBtn.RestartRecharging();
				_planeBtn.DeleteTutorial();
			}
		}
		
		public function BulletTouchedWall(e:InteractionCallback):void {
			(e.int2.castBody.userData.ref as Bubble).WallTouched();
		}
		
	}
	
}
