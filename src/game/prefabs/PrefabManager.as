package game.prefabs {
	import game.Bubble;
	import game.bubbles.SimpleBubble;
	import game.bubbles.Zombie;
	
	import util.GameConfig;
	import util.pair;
	
	//class for applying prefabs to our mesh
	
	public class PrefabManager {	
		private var _prefabData:PrefabData;
		private var _patternData:PatternData;
		private var _mesh:Vector.<Vector.<Bubble>>;
		
		private var _isFirstRowOffseted:Boolean;
		
		public function PrefabManager(cfg:GameConfig) {
			_prefabData = cfg.prefabData;
			_patternData = cfg.patternData;		
		}
		
		public function Init(islastRowOffseted:Boolean, mesh:Vector.<Vector.<Bubble>>):void {
			_mesh = mesh;
			
			_isFirstRowOffseted = mesh.length % 2 == 1 ? islastRowOffseted : !islastRowOffseted;
		}
		
		public function ApplyPattern(rowNum:int):void {
			var currPattern:Pattern = _patternData.GetRandomPattern();
			if (currPattern == null) return;
			
			var colNum:int = Math.round(Math.random() * currPattern.firstMaxIndex);
			var prefabCount:int = 0;
			 
			//applying pattern to the row until we get out of bounds or get out of max prefabs count
			while (colNum < _mesh[0].length && prefabCount < currPattern.count) {
				var typeAndProb:pair = currPattern.GetNextPrefabTypeAndProb();
				if (Math.random() > typeAndProb.second) {
					//set next col
					colNum += currPattern.minDistance;
					continue;
				}
				
				var prefab:Vector.<pair> = _prefabData.GetPrefab(typeAndProb.first);
				
				//checking if prefab can be applied
				var canBeApplied:Boolean = true;
				for each (var offS:pair in prefab) 
					if (!isOverlayable(GetDot(rowNum, colNum, offS))) {
						canBeApplied = false;
						break;
					}					
								
				//and if we can - we put it
				if (canBeApplied) {
					prefabCount++;
					for each (offS in prefab) {
						var pos:pair = GetDot(rowNum, colNum, offS);
						if (At(pos.first, pos.second)) {
							(_mesh[pos.first][pos.second] as Zombie).color = SimpleBubble.UBER_BLACK;
							(_mesh[pos.first][pos.second] as Zombie).canOverlay = currPattern.canOverlay;
						}
					}						
				}				
				//set next col
				colNum += currPattern.minDistance;
					
			}			
			
		}		
		
		//if bubble exist or not
		private function At(row:int, col:int):Boolean {
			if (row >= 0 && row < _mesh.length && col >= 0 && col < _mesh[0].length) return true;
			else return false;
		}
		
		//getting appropriate dot with offset
		private function GetDot(row:int, col:int, offset:pair):pair {
			var isCurrRowOffseted:Boolean = row % 2 == 0 ? _isFirstRowOffseted : !_isFirstRowOffseted;
			
			//if we have changed row's offset
			if (Math.abs(offset.first % 2) == 1) {
				if (isCurrRowOffseted && offset.second < 0) return new pair(row + offset.first, col + offset.second + 1);
				if (!isCurrRowOffseted && offset.second > 0) return new pair(row + offset.first, col + offset.second - 1);
			}
			
			return new pair(row + offset.first, col + offset.second);
		}
		
		//checking if we can put prefab at pos
		private function isOverlayable(pos:pair):Boolean {
			if (!At(pos.first, pos.second)) return true;
			
			return (_mesh[pos.first][pos.second] as Zombie).canOverlay;
		}
		
	}
}