package util {
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import states.LevelSelectState;
	
	//class helds levels in xml format
	public class LevelContainer {		
		private const IS_DEBUG:Boolean = false;
		
		private var _levels:Vector.<XML> = new Vector.<XML>(LevelSelectState.LEVELS_AMOUNT); 
		
		[Embed(source='../data/level_01.xml', mimeType="application/octet-stream")] private var lvl1:Class;		
		[Embed(source='../data/level_02.xml', mimeType="application/octet-stream")] private var lvl2:Class;		
		[Embed(source='../data/level_03.xml', mimeType="application/octet-stream")] private var lvl3:Class;		
		[Embed(source='../data/level_04.xml', mimeType="application/octet-stream")] private var lvl4:Class;		
		[Embed(source='../data/level_05.xml', mimeType="application/octet-stream")] private var lvl5:Class;		
		[Embed(source='../data/level_06.xml', mimeType="application/octet-stream")] private var lvl6:Class;		
		[Embed(source='../data/level_07.xml', mimeType="application/octet-stream")] private var lvl7:Class;		
		[Embed(source='../data/level_08.xml', mimeType="application/octet-stream")] private var lvl8:Class;		
		[Embed(source='../data/level_09.xml', mimeType="application/octet-stream")] private var lvl9:Class;
		[Embed(source='../data/level_10.xml', mimeType="application/octet-stream")] private var lvl10:Class;
		[Embed(source='../data/level_11.xml', mimeType="application/octet-stream")] private var lvl11:Class;
		[Embed(source='../data/level_12.xml', mimeType="application/octet-stream")] private var lvl12:Class;
		[Embed(source='../data/level_13.xml', mimeType="application/octet-stream")] private var lvl13:Class;
		[Embed(source='../data/level_14.xml', mimeType="application/octet-stream")] private var lvl14:Class;
		[Embed(source='../data/level_15.xml', mimeType="application/octet-stream")] private var lvl15:Class;
		[Embed(source='../data/level_16.xml', mimeType="application/octet-stream")] private var lvl16:Class;
		[Embed(source='../data/level_17.xml', mimeType="application/octet-stream")] private var lvl17:Class;
		[Embed(source='../data/level_18.xml', mimeType="application/octet-stream")] private var lvl18:Class;
		[Embed(source='../data/level_19.xml', mimeType="application/octet-stream")] private var lvl19:Class;
		[Embed(source='../data/level_20.xml', mimeType="application/octet-stream")] private var lvl20:Class;
		[Embed(source='../data/level_21.xml', mimeType="application/octet-stream")] private var lvl21:Class;
		[Embed(source='../data/level_22.xml', mimeType="application/octet-stream")] private var lvl22:Class;
		[Embed(source='../data/level_23.xml', mimeType="application/octet-stream")] private var lvl23:Class;
		[Embed(source='../data/level_24.xml', mimeType="application/octet-stream")] private var lvl24:Class;
		[Embed(source='../data/level_25.xml', mimeType="application/octet-stream")] private var lvl25:Class;
		
		
		public function LevelContainer():void {	
		}
		
		public function GetLevel(number:int):XML {
			return _levels[number - 1];				
		}
		
		public function Init():void {
			var a:Array = [lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7, lvl8, lvl9, lvl10, lvl11, lvl12, lvl13, lvl14, 
							lvl15, lvl16, lvl17, lvl18, lvl19, lvl20, lvl21, lvl22, lvl23, lvl24, lvl25];
				
			for (var i:int = 0; i < LevelSelectState.LEVELS_AMOUNT; i++) 
				if (IS_DEBUG)
					LoadLevel(i + 1);
				else {
					var cl:Class = a[i] as Class;
					_levels[i] = new XML(new cl());
				}
			
		}
		
		
		private var _urlLoader:URLLoader; //for loading xml
		private function LoadLevel(num:int):void {			
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, function (e:Event):void {
				_levels[num - 1] = new XML(e.target.data);				
			});
			
			var name:String = "./data/level_";
			if (num < 10) name += "0";
			name += num.toString();
			name += ".xml";							
			
			_urlLoader.load(new URLRequest(name));
		}
		
	}
	
}