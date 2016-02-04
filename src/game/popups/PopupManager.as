package game.popups {
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import game.Bubble;
	import game.bubbles.SimpleBubble;
	import game.bubbles.Zombie;
	
	import states.GameState;
	
	import util.GameConfig;
	import util.State;
	
	//class that helps us with popups

	public class PopupManager {
		//how mush time zombie needs to answer
		private const DIALOG_TIME_OFFSET:Number = 1.3;
		
		private var _mesh:Vector.<Vector.<Bubble>>;
		
		private var _popupsVector:Vector.<String> = new Vector.<String>();
		private var _spawnPeriond:Number;
		private var _maxTimeOffset:Number;
		private var _lifeTime:Number;
		private var _probability:Number;
		private var _delayTimers:Vector.<Timer> = new Vector.<Timer>();
		
		private var _currentPeriod:Number;
		
		public function PopupManager(cfg:GameConfig, mesh:Vector.<Vector.<Bubble>>) {
			_mesh = mesh;
			
			_popupsVector = cfg.popupsVector;
			_spawnPeriond = cfg.popupSpawnPeriond;
			_maxTimeOffset = cfg.popupMaxTimeOffset;
			_lifeTime = cfg.popupLifeTime;
			_probability = cfg.popupProbability;
			
			_currentPeriod = _spawnPeriond + Math.random() * _maxTimeOffset;
			(Main.GSM.GetCurrentState() as GameState).addEventListener(State.REMOVED, onStateRemoved);
		}
		
		private var _actionCounter:int = 0;
		public function Update():void {
			_actionCounter++;
			
			if (_actionCounter / 30 >=  _currentPeriod && _popupsVector.length != 0) {				
				var popup:String = _popupsVector[Math.floor(Math.random() * _popupsVector.length)];
				var spIndex:int = popup.indexOf('_');
				var leftBubble:Bubble, rightBubble:Bubble;
				var middleRow:int = _mesh[0].length / 2;
				
				//randomly choose bubble from the left part of the mesh
				var bubbles:Vector.<Bubble> = new Vector.<Bubble>();
				for (var i:int = 1; i < _mesh.length; i++)
					for (var j:int = 0; j < middleRow; j++) 
						if (_mesh[i][j] && _mesh[i][j] is Zombie) bubbles.push(_mesh[i][j]);
				if (bubbles.length != 0)
					leftBubble = bubbles[Math.floor(Math.random() * bubbles.length)];
				
				//randomly choose bubble from the right part of the mesh
				bubbles.splice(0, bubbles.length);
				for (i = 1; i < _mesh.length; i++)
					for (j = middleRow + 2; j < _mesh[0].length; j++) 
						if (_mesh[i][j] && _mesh[i][j] is Zombie ) bubbles.push(_mesh[i][j]);
				if (bubbles.length != 0)
					rightBubble = bubbles[Math.floor(Math.random() * bubbles.length)];
								
				//choose where to put dialog(s)
				if (leftBubble && rightBubble) {
					if (spIndex == -1) {
						if (Math.round(Math.random()) == 1) leftBubble.effects.addChild(new Popup(Popup.RIGHT, popup, _lifeTime));						
						else rightBubble.effects.addChild(new Popup(Popup.LEFT, popup, _lifeTime));				
					}
					else {
						leftBubble.effects.addChild(new Popup(Popup.RIGHT, popup.slice(0, spIndex), _lifeTime));
						
						//right zombie answers after a bit delay 
						var timer:Timer = new Timer(DIALOG_TIME_OFFSET * 1000, 1);
						timer.start();
						timer.addEventListener(TimerEvent.TIMER, function onTimer(e:TimerEvent):void {
							timer.removeEventListener(TimerEvent.TIMER, onTimer);
		
							_delayTimers.splice(_delayTimers.indexOf(timer), 1);							
							
							//if the bubble was killed while the delay we choose new one
							if (!rightBubble.isConnected) {
								rightBubble = null;
								
								//randomly choose bubble from the right part of the mesh
								bubbles.splice(0, bubbles.length);
								for (i = 1; i < _mesh.length; i++)
									for (j = middleRow + 2; j < _mesh[0].length; j++) 
										if (_mesh[i][j] && _mesh[i][j] is Zombie) bubbles.push(_mesh[i][j]);
								if (bubbles.length != 0)
									rightBubble = bubbles[Math.floor(Math.random() * bubbles.length)];
							}
							
							//minus DIALOG_TIME_OFFSET in order to close dialogs at one time
							if (rightBubble) rightBubble.effects.addChild(new Popup(Popup.LEFT, popup.slice(spIndex + 1, popup.length), _lifeTime - DIALOG_TIME_OFFSET));
							
						});
						_delayTimers.push(timer);
					}
				}
				else {
					if (leftBubble) {
						if (spIndex == -1) leftBubble.effects.addChild(new Popup(Popup.RIGHT, popup, _lifeTime));
						else leftBubble.effects.addChild(new Popup(Popup.RIGHT, popup.slice(0, spIndex), _lifeTime));
					}
					
					if (rightBubble) {
						if (spIndex == -1) rightBubble.effects.addChild(new Popup(Popup.LEFT, popup, _lifeTime));
						else rightBubble.effects.addChild(new Popup(Popup.LEFT, popup.slice(0, spIndex), _lifeTime));
					}
				}
				
				_actionCounter = 0;
				_currentPeriod = _spawnPeriond + Math.random() * _maxTimeOffset; 
			}			
		}
		
		public function onGameStateChanged(isPaused:Boolean):void {
			for each (var t:Timer in _delayTimers)
				isPaused ? t.stop() : t.start();
		}
		
		private function onStateRemoved(e:Event):void {
			(Main.GSM.GetCurrentState() as GameState).removeEventListener(State.REMOVED, onStateRemoved);
			for each (var t:Timer in _delayTimers) t.stop();			
		}
	}
}