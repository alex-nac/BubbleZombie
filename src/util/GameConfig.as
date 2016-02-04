package util {
	import flash.geom.Point;
	
	import game.Airplane;
	import game.Bubble;
	import game.prefabs.PatternData;
	import game.prefabs.PrefabData;
	
	import nape.space.Space;
	
	//configuration file for game	
	public class GameConfig {
		public var wonTime:Number;
		public var useDebugView:int;
		public var BGclassName:String;
		public var tutorClassName:String;
		public var meshBubbleDiametr:Number;
		public var planeButtonTime:Number;
		
		//mesh config
		public var waveVelocity:Number;
		public var columnsNum:int;
		public var rowsShowed:int;
		public var rowsNum:int;		
		public var uberZombieAmount:int;
		public var sprayers:Vector.<pair> = new Vector.<pair>();
		public var frozenTime:Number;
		public var offset:int;
		
		//walls config
		public var useWalls:int;
		public var leftWallEdge:int;
		public var rightWallEdge:int;
		
		//bubbles config			
		public var colors:int;
		
		//bullets config
		public var superBulletPercent:int;
		public var bombPercent:int;
		public var freezeBombPercent:int;
		public var colorBombPercent:int;
		
		//scores system
		public var basicScores:int;
		public var basicComboBonus:int;
		public var uberScores:int;
		public var steamScores:int;
		
		//prefabs
		public var prefabData:PrefabData;
		public var patternData:PatternData;
		
		//popups
		public var popupsVector:Vector.<String> = new Vector.<String>();
		public var popupSpawnPeriond:Number;
		public var popupMaxTimeOffset:Number;
		public var popupLifeTime:Number;
		public var popupProbability:Number;
		
		//reading content from XML
		public function GameConfig(data:XML) {
			wonTime = data.won_time;
			BGclassName = data.background_class_name;
			tutorClassName = data.tutorial;
			frozenTime = data.frozen_time;
			useDebugView = data.use_debug_view;
			meshBubbleDiametr = data.mesh_bubble_diametr;			
			planeButtonTime = data.plane_button_time;
			if (planeButtonTime < Airplane.SPACE_PLANE_TIME && planeButtonTime != 0 && planeButtonTime != -1) 
				throw new Error("Введенное тобой время для самолетной кнопки меньше времени полета самолета, иными словами меньше " + Airplane.SPACE_PLANE_TIME + " секунд" );
			
			waveVelocity = data.wave_velocity;
			rowsNum = data.rows_num;
			columnsNum = data.columns_num;
			rowsShowed = data.rows_showed;			
			uberZombieAmount = data.zombie;	
			offset = int(data.mesh_offset);
			
			useWalls = data.use_walls;
			leftWallEdge = data.left_wall_edge;
			rightWallEdge = data.right_wall_edge;
			
			for each (var sprayer:XML in data.zombie_sprayer.children())
				sprayers.push(new pair(sprayer.activeGuns, sprayer.time));
			
			
			colors = data.colors;
			
			superBulletPercent = data.super_bullet_percent;
			bombPercent = data.bomb_percent;
			freezeBombPercent = data.freeze_bomb_percent;
			colorBombPercent = data.color_bomb_percent;
			
			basicScores = data.basic_scores;
			basicComboBonus = data.basic_combo_bonus;
			uberScores = data.uber_scores;
			steamScores = data.steam_scores;
			
			//save prefabs arrays
			prefabData = new PrefabData();
			for each (var array:XML in data.Arrays.children()) {
				var coords:Vector.<String> = new Vector.<String>();
				for each (var dot:XML in array.children()) 
					coords.push(String(dot.@position));
				prefabData.AddArrFromCoordArr(coords);
			}
			
			//save prefabs patterns
			patternData = new PatternData();
			for each (var pattern:XML in data.Patterns.children()) {
				patternData.AddPattern(pattern.@firstMaxIndex, pattern.@prefabTypes, pattern.@probability, pattern.@count, pattern.@minDistance, Boolean(int(pattern.@canOverlay)));				
			}
			
			//save popups
			for each (var popup:String in data.Pop_ups.children()) 
				popupsVector.push(popup);
			popupSpawnPeriond = data.Pop_ups.@spawnPeriod;
			popupMaxTimeOffset = data.Pop_ups.@maxTimeOffset;
			popupLifeTime = data.Pop_ups.@lifeTime;
			popupProbability = data.Pop_ups.@probability;
		}
				
	}	
}
