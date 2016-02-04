package game.prefabs {
	import util.pair;
	
	//container class that keeps all the prefabs array organized
	
	public class PrefabData {
		//container for all arrays
		private var _figures:Vector.< Vector.<pair> > = new Vector.<Vector.<pair>>();
		
		public function PrefabData() {
		}
		
		//adding new array from array of coords strings like "-1_2"
		public function AddArrFromCoordArr(coords:Vector.<String>):void {
			var coordsVec:Vector.<pair> = new Vector.<pair>();
			for each (var str:String in coords) {
				//find "_"
				var ind:int = str.indexOf("_");
				if (ind == -1) throw new Error("Неверный формат префабов: нет '_' ");
								
				var x:int = int(str.substring(0, ind));
				var y:int = int(str.substring(ind + 1, str.length));
				coordsVec.push(new pair(x, y));				
			}
			
			_figures.push(coordsVec);
		}
		
		//getting array
		public function GetPrefab(index:int):Vector.<pair> {			
			return _figures[index];
		}
		
	}
}