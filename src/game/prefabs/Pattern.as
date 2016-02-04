package game.prefabs
{
	import util.pair;

	internal class Pattern {		
		private var _prefabTypes:Vector.<int> = new Vector.<int>();
		private var _prefabProbability:Vector.<Number> = new Vector.<Number>();
		public var count:int;
		public var minDistance:int;
		public var canOverlay:Boolean;
		public var firstMaxIndex:int;
		
		private var _lastPrefabUsed:int = -1;
		
		public function set prefabTypes(value:Vector.<int>):void { _prefabTypes = value; }
		public function set prefabProbability(value:Vector.<Number>):void { _prefabProbability = value; }
		
		public function GetNextPrefabTypeAndProb():pair {
			_lastPrefabUsed++;
			if (_lastPrefabUsed == _prefabTypes.length) _lastPrefabUsed = 0;
			
			return new pair(_prefabTypes[_lastPrefabUsed], _prefabProbability[_lastPrefabUsed]);
		}
	}

}