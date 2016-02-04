package game.prefabs {
	
	
	
	public class PatternData {
		private var _patterns:Vector.<Pattern> = new Vector.<Pattern>();
		
		public function PatternData() {
		}
		
		private function GetArrayFromString(str:String):Vector.<Number> {
			var lastSpace:int = 0;
			var arr:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < str.length; i++) {
				if (str.charAt(i) == "_" || i == str.length - 1) {
					if (i == str.length - 1) i++;
					arr.push(Number(str.substring(lastSpace, i)));
					lastSpace = i + 1;
				}
			}		
			
			return arr;
		}
		
		public function AddPattern(firstMaxIndex:int, prefabTypes:String, prefabProbability:String, count:int, minDistance:int, canOverlay:Boolean):void {
			var pattern:Pattern = new Pattern();
			pattern.firstMaxIndex = firstMaxIndex;
			pattern.prefabTypes = Vector.<int>(GetArrayFromString(prefabTypes));
			pattern.prefabProbability = GetArrayFromString(prefabProbability);
			pattern.count = count;
			pattern.minDistance = minDistance;
			pattern.canOverlay = canOverlay;			
			
			_patterns.push(pattern);
		}
		
		public function GetRandomPattern():Pattern {
			if (_patterns.length == 0) return null;
			
			var ind:int = Math.floor(Math.random() * _patterns.length);
			return _patterns[ind];	
		}
		
	}
}