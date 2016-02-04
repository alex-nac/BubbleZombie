package game {
	
	import com.gskinner.motion.GTween;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import game.bubbles.SimpleBubble;
	import game.bubbles.Sprayer;
	import game.bubbles.Zombie;
	import game.popups.PopupManager;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.space.Space;
	
	import util.GameConfig;
	import util.Timer;
	
	public class BubbleMesh extends EventDispatcher {
		
		public static const LAST_WAVE:String = "LAST_WAVE";		
		public static const CAR_EXPLOSION:String = "CAR_EXPLOSION";
		public static const NEW_ROW:String = "NEW_ROW";
		public static const ALL_EMENIES_KILLED:String = "ALL_EMENIES_KILLED";
		
		private const STOP_ZOMBIE_ANIMATION_FPS:int = 25;
		
		public const EMPTY_SPACE:int = 1;  //horizontal space between the bubbles
		private const MESH_Y:int = 5;
		public static const MESH_MOVING_TIME:Number = 1.5;
		
		
		/////////////
		//VARIABLES//
		/////////////		
				
		private var _mesh:Vector.<Vector.<Bubble>> = new Vector.<Vector.<Bubble>>();
		private var _colors:Vector.<int>;
		private var _meshPattern:MeshPattern;
		private var _rowsNum:int = 0;
		private var _wavesNum:int = 0;
		private var _enemiesNum:int = 0;  //sprayers + zombies
		private var _offset:Vector.<Boolean> = new Vector.<Boolean>(); //is row offseted or not			
		private var _space:Space;
		private var _meshOriginBody:Body;
		private var _waveTimer:Timer;
		private var _pauseMeshTimer:Timer;              //timer that preventing mesh from adding next row when it is frozen
		private var _view:Sprite = new Sprite();
		private var _bubbleLayer:Sprite = new Sprite(); //layer where all bubbles exist
		private var _bubbleEffectsLayer:Sprite = new Sprite(); //layer where bubble-specified effects exist (the axe)
		private var _generalEffectsLayer:Sprite = new Sprite(); //layer where general effects exist 
		private var _textEffectsLayer:Sprite = new Sprite();
		private var _popupManager:PopupManager;
		private var _wasMeshStopped:Boolean = false;		
				
		private var _isMeshMoving:Boolean = false;
		private var _movingTween:GTween;   				//while moving mesh we need some timer
		private var _generalEffectsTween:GTween;
		private var _textEffectsTween:GTween;
		private var _deletedBubbles:Vector.<Bubble> = new Vector.<Bubble>(); //dirty code - this container help us with bubble deleter
		
		//////////////////
		//GETTES/SETTERS//
		//////////////////
		
		public function get rowsNum():int { return _rowsNum; }
		public function get columnsNum():int { return _meshPattern.columsNum; }
		public function get view():Sprite { return _view; }
		
		public function set allowMeshMovement(value:Boolean):void { if (!_wasMeshStopped) _waveTimer.isPaused = !value; }
		public function set enemiesNum(value:int):void {
			_enemiesNum = value;
			if (_enemiesNum == 0) 
				dispatchEvent(new Event(ALL_EMENIES_KILLED));
		}
		
	
		
		
		/////////////
		//FUNCTIONS//
		/////////////
		
		//creating
		public function BubbleMesh(space:Space, cfg:GameConfig) {
			_view.addEventListener(Event.ADDED_TO_STAGE, function f(e:Event): void { 
				_view.removeEventListener(Event.ADDED_TO_STAGE, f);
				
				_view.addChild(_bubbleLayer);
				_view.addChild(_generalEffectsLayer);
				_view.addChild(_bubbleEffectsLayer);		
				_view.addChild(_textEffectsLayer);
				
				_space = space;
				_meshPattern = new MeshPattern(cfg);
				_colors = _meshPattern.GetRemainingColors();
				_meshOriginBody = new Body(BodyType.KINEMATIC, new Vec2((_view.stage.stageWidth - (Bubble.DIAMETR + EMPTY_SPACE) * _meshPattern.columsNum + EMPTY_SPACE - 0.5 * Bubble.DIAMETR)/2 + cfg.offset, MESH_Y));
				_meshOriginBody.space = space;
				_offset.push(!_meshPattern.isLastRowOffseted);
				
				//creating mesh
				CreateMesh(_meshPattern.startRowsNum);				
				
				_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, Bubble.ConnectedBubbleCBType, Bubble.BubbleCBType, BubbleHDR, -1));
					
				_waveTimer = new Timer(_meshPattern.waveVel);
				_waveTimer.addEventListener(Timer.TRIGGED, WaveTimerHandler);	
				
				_popupManager = new PopupManager(cfg, _mesh);
				
				StopAnimations(4);
			});
		}
				
		//update mesh
		public function Update():void {			
			for (var i:int = 0; i < _rowsNum; i++)
				for each(var bubble:Bubble in _mesh[i]) {
					if (bubble) bubble.Update();
				}
			if (_pauseMeshTimer) _pauseMeshTimer.Update();
			_waveTimer.Update();
			_popupManager.Update();
		}
		
		//determining position in mesh and return row and column
		public function GetMeshPos(bubble:Bubble):Vec2 {
			var worldPos:Vec2 = bubble.position;
			worldPos = worldPos.sub(_meshOriginBody.position);
			var row:int = Math.ceil(worldPos.y / Bubble.DIAMETR) - 1;	
			if (row < 0) { if (!_offset[0]) worldPos.x -= Bubble.DIAMETR / 2; }			
			else { if (_offset[row]) worldPos.x -= Bubble.DIAMETR / 2; }
			var col:int = Math.ceil(worldPos.x / (Bubble.DIAMETR + EMPTY_SPACE)) - 1;	
			return new Vec2(row, col);
		}
				
		//getting all around bubbles
		public function GetBubblesAround(bubble:Bubble, withNulls:Boolean = false):Vector.<Bubble> {
			//if we meet place where there is no bubble and withNulls == true, we pushBack(null);
			
			var vec:Vector.<Bubble> = new Vector.<Bubble>();
			
			var i:int = bubble.meshPosition.x;
			var j:int = bubble.meshPosition.y;
			
			if (At(i, j - 1)) vec.push(_mesh[i][j - 1]) else vec.push(null); 			 
			if (At(i - 1, j - 1 + _offset[i])) vec.push(_mesh[i - 1][j - 1 + _offset[i]]) else vec.push(null); 
			if (At(i - 1, j + _offset[i])) vec.push(_mesh[i - 1][j + _offset[i]]) else vec.push(null); 
			if (At(i, j + 1)) vec.push(_mesh[i][j + 1]) else vec.push(null);
			if (At(i + 1, j + _offset[i])) vec.push(_mesh[i + 1][j + _offset[i]]) else vec.push(null); 
			if (At(i + 1, j - 1 + _offset[i])) vec.push(_mesh[i + 1][j - 1 + _offset[i]]) else vec.push(null);			
			
			//Code HACK - dirty code, previous code in game use non-null return
			//and sprayer need null bubbles, so we add this option
			if (!withNulls) 
				for (i = 0; i < vec.length; i++)
					if (vec[i] == null) {
						vec.splice(i, 1);
						i--;
					}
			
			return vec;
		}
						
		//checking if there is bubble in (i, j) position
		public function At(i:int, j:int):Bubble {
			if (i < 0 || j < 0 || i > _mesh.length - 1 || j > _mesh[i].length - 1 || _mesh[i][j] == null)
				return null
			else  
				return _mesh[i][j];
		}
		
		public function Delete(bubble:Bubble):void {
			_deletedBubbles.push(bubble);
			var meshPos:Vec2 = bubble.meshPosition;
			_mesh[meshPos.x][meshPos.y] = null;				
			
			if (bubble is Zombie || bubble is Sprayer) enemiesNum = _enemiesNum - 1;
			if (bubble is SimpleBubble) _colors[bubble["color"]]--;
		}
		
		public function Stop():void {
			_wasMeshStopped = true;
			_waveTimer.isPaused = true;
		}
		
		public function PlusColor(color:int):void { _colors[color]++; }
		public function MinusColor(color:int):void { _colors[color]--; }
		
		//froze the mesh
		public function Freeze():void {
			allowMeshMovement = false;					
			
			if (_pauseMeshTimer) _pauseMeshTimer.removeEventListener(Timer.TRIGGED, Unfreeze);
			_pauseMeshTimer = new Timer(_meshPattern.frozenTime);
			_pauseMeshTimer.addEventListener(Timer.TRIGGED, Unfreeze);
		}
		
		private function Unfreeze(e:Event):void {
			_pauseMeshTimer.removeEventListener(Timer.TRIGGED, Unfreeze);
			_pauseMeshTimer = null;
			allowMeshMovement = true;
			for (var i:int = 0; i < _rowsNum; i++)
				for each(var bubble:Bubble in _mesh[i]) {
				if (bubble) bubble.isFrozen = false;
			}
		}
		
		public function AddEffect(effect:DisplayObject, isTextEffect:Boolean = false):void {
			var container:Sprite;
			isTextEffect ? container = _textEffectsLayer : container = _generalEffectsLayer;		
			effect.x -= container.x;
			effect.y -= container.y;
			container.addChild(effect);			
		}
			
		//handling game pause/resume
		public function onGameStateChaged(isPaused:Boolean):void {	
			_popupManager.onGameStateChanged(isPaused);	
			if (_textEffectsTween) _textEffectsTween.paused = isPaused;
			if (_generalEffectsTween) _generalEffectsTween.paused = isPaused;
			if (_movingTween) _movingTween.paused = isPaused;
		}
		
		//getting the low bound of the mesh
		public function GetDownMeshBound():Number {
			for (var i:int = _rowsNum - 1; i >= 0; i--)
				for each(var bubble:Bubble in _mesh[i]) {
				if (bubble) return bubble.position.y + Bubble.DIAMETR / 2;
			}
			
			//if no bubbles in mesh return null
			return 0;
		}
		
		public function GetRemainingBubblesByColor(color:int):int { return _colors[color]; }
		
		/////////////////////
		//PRIVATE FUNCTIONS//
		/////////////////////
		
		//adding one more row to the top of the mesh
		private function AddRow():void {	 
			dispatchEvent(new Event(NEW_ROW));
			
			//firstable setting bubbles positions for our new row
			var topRow:Vector.<Bubble> = _meshPattern.GetNextRow();
			for (var j:int = 0; j < topRow.length; j++) {
				if (_offset[0]) topRow[j].position = GetWorldPos(new Vec2(0, j)).sub(new Vec2(Bubble.DIAMETR / 2, 0));
				else topRow[j].position = GetWorldPos(new Vec2(0, j)).add(new Vec2(Bubble.DIAMETR / 2, 0));
				topRow[j].position = topRow[j].position.sub(new Vec2(0, Bubble.DIAMETR));
				topRow[j].space = _space;
				topRow[j].mesh = this;				
				_bubbleLayer.addChild(topRow[j].view);
				_bubbleEffectsLayer.addChild(topRow[j].effects);
			}
			
			
			_offset.unshift(!_offset[0]);
			_mesh.unshift(topRow);	
			_rowsNum++;
			_wavesNum++;
			_meshOriginBody.position.y -= Bubble.DIAMETR;
						
			//moving mesh
			MoveMesh();
							
			//if it is the last wave
			if (_wavesNum == _meshPattern.rowsNum - _meshPattern.startRowsNum) 
				dispatchEvent(new Event(LAST_WAVE));			
		}		
		
		private function MoveMesh(onComplete:Function = null):void {
			_meshOriginBody.velocity = new Vec2(0, Bubble.DIAMETR / MESH_MOVING_TIME);
			_isMeshMoving = true;
			
			for each(var bblRow:Vector.<Bubble> in _mesh)
				for each (var bbl:Bubble in bblRow) 
					if (bbl) bbl.velocity = new Vec2(0, Bubble.DIAMETR / MESH_MOVING_TIME);
							
			for each (bbl in _deletedBubbles) {
				if (bbl.hasBody) bbl.velocity = new Vec2(0, Bubble.DIAMETR / MESH_MOVING_TIME);
				else _deletedBubbles.splice(_deletedBubbles.indexOf(bbl), 1);
			}
						
			if (!_generalEffectsTween) _generalEffectsTween = new GTween(_generalEffectsLayer, MESH_MOVING_TIME, {y:_generalEffectsLayer.y + Bubble.DIAMETR});
			else _generalEffectsTween.setValue("y", _generalEffectsTween.getValue("y") + Bubble.DIAMETR); 
			
			if (!_textEffectsTween) _textEffectsTween = new GTween(_textEffectsLayer, MESH_MOVING_TIME, {y:_textEffectsLayer.y + Bubble.DIAMETR});
			else _textEffectsTween.setValue("y", _textEffectsTween.getValue("y") + Bubble.DIAMETR); 
			
			if (!_movingTween) {				
				//we save it is correct position because of some strange timing problems, and due to it - we have incorrent mesh offset
				_meshOriginBody.userData.y = _meshOriginBody.position.y + Bubble.DIAMETR;
				
				_movingTween = new GTween(null, MESH_MOVING_TIME);
				_movingTween.onComplete = function(e:GTween):void { 
					if (onComplete != null) onComplete();
					_isMeshMoving = false;
					_meshOriginBody.velocity.setxy(0, 0);
					_meshOriginBody.position.y = _meshOriginBody.userData.y; 
					for each(var bblRow:Vector.<Bubble> in _mesh)
						for each (var bbl:Bubble in bblRow)  
							if (bbl) { 
								bbl.velocity = new Vec2();
								bbl.position = GetWorldPos(bbl.meshPosition);
							}
							
					for each (bbl in _deletedBubbles) {
						if (bbl.hasBody) bbl.velocity = new Vec2(0, 0);
						else _deletedBubbles.splice(_deletedBubbles.indexOf(bbl), 1);
					}
				}
			}
			else {
				_movingTween.beginning();
				_movingTween.paused = false;
				_meshOriginBody.userData.y = _meshOriginBody.position.y + Bubble.DIAMETR;
			}	
		}
				
		//collision with mesh handler
		private function BubbleHDR(e:InteractionCallback):void {
			var bubble:Bubble = e.int2.castBody.userData.ref as Bubble;
			if (bubble.wasCallbackCalled) return;			
			bubble.wasCallbackCalled = true;
								
			//connect bubble to the mesh
			var meshPos:Vec2 = GetMeshPos(bubble);
			if (meshPos.x < 0) {
				bubble.Delete(); 
				return; 
			}
			if (meshPos.y < 0) meshPos.y = 0
			if (meshPos.y >= _meshPattern.columsNum) meshPos.y = _meshPattern.columsNum - 1; 
			
			if (At(meshPos.x, meshPos.y)) {				
				//throw (new Error("HEEEEEEEY!! Here we have already have bubble!! You're trying to put at " + meshPos + "while " +
					//"coordinates is " + bubble.position.x + " " + bubble.position.y));
				//dispatchEvent(new Event(CAR_EXPLOSION));
				bubble.Delete();				
				return;
			}
			
			//if we need to create new row
			if (meshPos.x > _mesh.length - 1) {
				_rowsNum++;
				_mesh.push(new Vector.<Bubble>(_meshPattern.columsNum));
				_offset.push(!_offset[_offset.length - 1]);
			}
			
			_mesh[meshPos.x][meshPos.y] = bubble;
			if (_isMeshMoving) bubble.velocity = new Vec2(0, Bubble.DIAMETR / MESH_MOVING_TIME);
			else bubble.velocity = new Vec2();
									
			_bubbleLayer.addChild(bubble.view);
			_bubbleEffectsLayer.addChild(bubble.effects);
			
			
			if (bubble is SimpleBubble) _colors[bubble["color"]]++; 
									
			var pos:Vec2 = GetWorldPos(meshPos);			
			bubble.x = pos.x;
			bubble.y = pos.y;
			bubble.onConnected(this);		
		}		

		//determining world position by mesh coord
		private function GetWorldPos(meshPos:Vec2):Vec2 {
			var pos:Vec2 = new Vec2(meshPos.y * (Bubble.DIAMETR + EMPTY_SPACE) + Bubble.DIAMETR / 2 * (int(_offset[meshPos.x] + 1)), 
				(meshPos.x + 0.5) * Bubble.DIAMETR);
			pos = pos.add(_meshOriginBody.position);
			return pos;
		}	
		
		private function WaveTimerHandler(e:Event):void {					
			if (_wavesNum < _meshPattern.rowsNum - _meshPattern.startRowsNum) AddRow();
			else MoveMesh();			
		}
		
		//creating mesh at the beggining 
		private function CreateMesh(startRowAmount:int):void {
			for (var i:int = 0; i < startRowAmount; i++) {
			
				_rowsNum++;			
				_offset.unshift(!_offset[0]); 
				
				var topRow:Vector.<Bubble> = _meshPattern.GetNextRow();
				for (var j:int = 0; j < topRow.length; j++) {
					topRow[j].position = GetWorldPos(new Vec2(0, j));
					topRow[j].space = _space;
					topRow[j].mesh = this;
					_bubbleLayer.addChild(topRow[j].view);
					_bubbleEffectsLayer.addChild(topRow[j].effects);
				}
				
				for each(var bblRow:Vector.<Bubble> in _mesh)
					for each (var bbl:Bubble in bblRow) 
						if (bbl) bbl.position = bbl.position.add(new Vec2(0, Bubble.DIAMETR));	
						
				for each(var effect:DisplayObject in _bubbleEffectsLayer)
					effect.y += Bubble.DIAMETR;
				
				
				_mesh.unshift(topRow);
				
													
				//if it is the last wave
				if (_wavesNum == _meshPattern.rowsNum - _meshPattern.startRowsNum) {
					dispatchEvent(new Event(LAST_WAVE));
					break;
				}
			}	
			
			enemiesNum = _meshPattern.columsNum * _meshPattern.rowsNum;
		}
		
		//if every == 3 every 3rd zombie will be deleted
		private var _wasAnimationStopped:Boolean = false;
		private function StopAnimations(every:int):void {
			if (_wasAnimationStopped) return;
			
			_wasAnimationStopped = true;
			
			//firstable get all zombies from the pattern
			var zombieVec:Vector.<Zombie> = _meshPattern.GetRemainingZombies();
			
			//then from the mesh
			for (var i:int = 0; i < _mesh.length; i++) 
				for (var j:int = 0; j < _meshPattern.columsNum; j++)
					if (_mesh[i][j] is Zombie) zombieVec.push(_mesh[i][j]);
			
			for (i = 0; i < zombieVec.length; i += every)
				zombieVec[i].animationActive = false;
		}
				
	}	
}
