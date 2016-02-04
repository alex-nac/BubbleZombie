package util {
	import flash.net.SharedObject;

	public class SaveManager {
		private static var _sharedDataName:String = "BUBBLE_ZOMBIE_SHARED_OBJ";
		private static var _firstRun:Boolean;
		
		private static var _sharedData:SharedObject; 
		private static var _sharedGameData:Object = {};
		
		public function SaveManager() { }
		
		public static function initialize():void
		{			
			try {
				_sharedData = SharedObject.getLocal(_sharedDataName);													
			}
			catch(err:Error) {
 				
			}
			finally {
				checkShareData();			
			}
		}
				
		private static function checkShareData():void {
			
			if(_sharedData && _sharedData["data"] && _sharedData["data"]["wasLaunched"] == null) {
				
				_sharedData["data"]["wasLaunched"] = true;
				
				//first-launch settings
				_sharedData["data"]["was_airplane_tutorial_showed"] = false;
				_sharedData["data"]["soundEnabled"] = true;
										
				_sharedData.flush();
					
			}
			
			//copying data from sharedObject and saving sharedObject
			for (var key:* in _sharedData["data"]) 
				_sharedGameData[key] = _sharedData["data"][key]
		}	

		public static function setSharedData(data:Object):void {
			var key:String = data["key"];
			var value:* = data["value"];						
			_sharedGameData[key] = value;					
		}
		
		public static function getSharedData(key:String):* {
			var res:* = null;
			if(_sharedGameData[key])			
				res = _sharedGameData[key];
			 				
			return res;					
		}
		
		public static function saveSharedData():void {			
			for (var key:* in _sharedGameData) {
				_sharedData["data"][key] = _sharedGameData[key]
			}
			
			_sharedData.flush();
		}
				
		public static function clearData():void {
			_sharedData.clear();
			
			for (var key:* in _sharedGameData) {
				_sharedGameData[key] = null; 
			}
			checkShareData();
		}
	}
}