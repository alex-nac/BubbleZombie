package game {
	import game.bubbles.SimpleBubble;
	import game.bubbles.Sprayer;
	import game.bubbles.Zombie;
	import game.prefabs.PrefabManager;
	
	import util.GameConfig;
	import util.pair;
	
	public class MeshPattern {
		
		private var _pattern:Vector.<Vector.<Bubble>> = new Vector.<Vector.<Bubble>>;
		private var _prefabManager:PrefabManager;
		private var _startRowsNum:int;
		private var _colNum:int;
		private var _rowsNum:int;
		private var _waveVel:int;
		private var _uberZombieAmount:int;
		private var _sprayers:Vector.<pair>;
		private var _frozenTime:Number;
		
		public function get columsNum():int { return _colNum; }
		public function get rowsNum():int { return _rowsNum; }
		public function get startRowsNum():int { return _startRowsNum; }	
		public function get waveVel():int { return _waveVel; }
		public function get frozenTime():Number { return _frozenTime; }
		public function get isLastRowOffseted():Boolean { return true; }
		
		
		public function MeshPattern(cfg:GameConfig) {
			//saving mesh parametrs
			_startRowsNum = cfg.rowsShowed;
			_colNum = cfg.columnsNum;
			_rowsNum = cfg.rowsNum;
			_waveVel = cfg.waveVelocity;
			_uberZombieAmount = cfg.uberZombieAmount;
			_sprayers = cfg.sprayers;
			_frozenTime = cfg.frozenTime;
			
			_prefabManager = new PrefabManager(cfg);
						
			//create mesh pattern
			CreateMeshPattern();
		}
		
		//getting next bubble row from pattern
		public function GetNextRow():Vector.<Bubble> {
			if (_pattern.length != 0)
				return _pattern.pop();
			else {
				trace("NO MORE ROWS!!")
				return null;
			}
		}
		
		//get all zombies that we have in pattern at the moment
		//we use this function to stop their animation
		public function GetRemainingZombies():Vector.<Zombie> {
			var zombieVec:Vector.<Zombie> = new Vector.<Zombie>();
			
			for (var i:int = 0; i < _pattern.length; i++) 
				for (var j:int = 0; j < _colNum; j++)
					if (_pattern[i][j] is Zombie) zombieVec.push(_pattern[i][j]);
			
			return zombieVec;
		}
		
		public function GetRemainingColors():Vector.<int> {
			var colors:Vector.<int> = new Vector.<int>();
			colors.push(0, 0, 0, 0, 0, 0, 0, 0);
			
			for (var i:int = 0; i < _pattern.length; i++) 
				for (var j:int = 0; j < _colNum; j++)
					if (_pattern[i][j] is SimpleBubble) colors[_pattern[i][j]["color"]]++;
			
			return colors;
		}
		
		
		//filling pattern
		private function CreateMeshPattern():void {
			var allBubbles:Vector.<Bubble> = new Vector.<Bubble>();  //collecting all bubble's types
			
			//fill it with random zombie
			for (var i:int = 0; i < _rowsNum; i++) {
				_pattern.push(new Vector.<Bubble>(_colNum));
				for (var j:int = 0; j < _colNum; j++) 
					_pattern[i][j] = new Zombie();
				allBubbles = allBubbles.concat(_pattern[i]);
			}
			
			//apply patterns
			_prefabManager.Init(isLastRowOffseted, _pattern);
			for (i = 0; i < _rowsNum; i++) {
				_prefabManager.ApplyPattern(i);
			}
			
			var currentUberZombieAmount:int = 0;
			for (i = 0; i < allBubbles.length; i++)
				if ((allBubbles[i] as Zombie).color == SimpleBubble.UBER_BLACK) {
					currentUberZombieAmount++;
					allBubbles.splice(i, 1);
				}
			
			//randomly choose zombie position			
			for (i = 0; i < _uberZombieAmount - currentUberZombieAmount; i++) {
				if (allBubbles.length == 0) break;
				
				var randomInd:int = Math.floor(Math.random() * allBubbles.length);
				(allBubbles[randomInd] as Zombie).color = SimpleBubble.UBER_BLACK;
				allBubbles.splice(randomInd, 1);
			}
			
			
			//randomly choose sprayer position
			for (i = 0; i < Math.min(_sprayers.length, allBubbles.length); i++) {
				
				//chose random position
				var r:int = Math.floor(Math.random() * _rowsNum); 
				var c:int = Math.floor(Math.random() * _colNum);
				
				//if it isn't "special" bubble already there set sprayrer here
				if (_pattern[r][c] is Zombie && (_pattern[r][c] as Zombie).color != SimpleBubble.UBER_BLACK) 
					_pattern[r][c] = new Sprayer(_sprayers[i].first, _sprayers[i].second);								
				else i--; //else find another places
				
			}
			
		}
	}
}