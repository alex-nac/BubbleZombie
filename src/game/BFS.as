package game {
	import game.bubbles.SimpleBubble;
	
	import nape.geom.Vec2;
	
	/* Class helps us with bsf in bubble mesh
	 * it can find if the bubble connected with 
	 * mesh root or find all the bubbles with the same
	 * type around current
	 */
	
	public class BFS {
		private static var _mesh:BubbleMesh;
		
		public static function set mesh(mesh:BubbleMesh):void { _mesh = mesh; }	
				
		/* Get all the bubbles with the same color  
		 * for this we use bfs. If withZombie parametr  
		 * is true then we include zombie bubbles
		 * with the same color
		 */
		public static function GetSameColorBubbles(meshPos:Vec2, withZombie:Boolean = false):Vector.<Bubble> {
			var bubbles:Vector.<Bubble> = new Vector.<Bubble>();     //bubbles for combo
			var boolMesh:Vector.<Vector.<Boolean>> = GetBoolMesh();  //used edges
			var queue:Vector.<Vec2> = new Vector.<Vec2>();
						
			//first edge			
			queue.push(meshPos);
			boolMesh[meshPos.x][meshPos.y] = true;			
			var color:int = (_mesh.At(meshPos.x, meshPos.y) as SimpleBubble).color;			
			//bfs
			while(queue.length != 0) {
				var v:Vec2 = queue.shift();
				var bbl:Bubble = _mesh.At(v.x, v.y);
				if (!withZombie && (bbl as SimpleBubble).color == SimpleBubble.UBER_BLACK) continue; //if it is zombie and we don't want zombie go to the next
				bubbles.push(_mesh.At(v.x, v.y));
				if ((bbl as SimpleBubble).color == SimpleBubble.UBER_BLACK) continue; //if it is zombie then we stop wave
				for each(var bubble:Bubble in _mesh.GetBubblesAround(_mesh.At(v.x, v.y))) {
					if (!(bubble is SimpleBubble)) continue;
					var point:Vec2 = bubble.meshPosition;
					if (!boolMesh[point.x][point.y] && ( (_mesh.At(point.x, point.y) as SimpleBubble).color == color 
					|| (_mesh.At(point.x, point.y) as SimpleBubble).color == SimpleBubble.UBER_BLACK)) {
						queue.push(point);
						boolMesh[point.x][point.y] = true;
					}
				}
			}
						
			return bubbles;
		}
		
		//doing bfs from all the bubbles in 1-st row 
		//and returning the bubbles that isn't connected to the root
		public static function GetUnrootedBubbles():Vector.<Bubble> {
			var bubbles:Vector.<Bubble> = new Vector.<Bubble>();     //bubbles for combo
			var boolMesh:Vector.<Vector.<Boolean>> = GetBoolMesh();  //used edges
						
			for (var j:int = 0; j < _mesh.columnsNum; j++) {
				if (_mesh.At(0, j) == null || boolMesh[0][j] == true) continue;
				
				var queue:Vector.<Vec2> = new Vector.<Vec2>();
				queue.push(new Vec2(0, j));
				boolMesh[0][j] = true;
				
				while(queue.length != 0) {
					var v:Vec2 = queue.shift();
					for each(var bubble:Bubble in _mesh.GetBubblesAround(_mesh.At(v.x, v.y))) {
						var point:Vec2 = bubble.meshPosition;
						if (!boolMesh[point.x][point.y]) {
							queue.push(point);
							boolMesh[point.x][point.y] = true;
						}
					}
				}
				
			}
			
			for (var i:int = 0 ; i < boolMesh.length; i++)
				for (j = 0; j < boolMesh[i].length; j++) 
					if (!boolMesh[i][j] && _mesh.At(i, j) != null)
						bubbles.push(_mesh.At(i, j));
				
			return bubbles;
		}
		
		
		
		
		//return empty mesh that show us if we were on an edge or not
		private static function GetBoolMesh():Vector.<Vector.<Boolean>> {
			var boolMesh:Vector.<Vector.<Boolean>> = new Vector.<Vector.<Boolean>>(_mesh.rowsNum);
			for (var i:int = 0; i < boolMesh.length; i++) {
				var vec:Vector.<Boolean> = new Vector.<Boolean>(_mesh.columnsNum);
				for (var j:int = 0; j < vec.length; j++)
					vec[j] = false;
				boolMesh[i] = vec;
			}
			
			return boolMesh;
		}
		
		
	}
}
