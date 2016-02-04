package  {	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import FGL.GameTracker.GameTracker;
	
	import states.MainMenuState;
	
	import util.ClassResolver;
	import util.GameStateManager;
	import util.LevelContainer;
	import util.SaveManager;
	import util.SiteLock;
	import util.SoundManager;
	
	[SWF(backgroundColor="#000000", width="640", height="480", frameRate="30")]
	public class Main extends Sprite {
		//state manager
		public static var GSM:GameStateManager;
		public static var LVLC:LevelContainer = new LevelContainer();
		public static var SM:SoundManager = new SoundManager();
		
		private static var _pointer:Sprite = new Sprite();
		private static var _stage:Stage;
		
		public static function SetPoiner (pointer:Sprite):void {
			_pointer.removeChildren();
			_pointer.addChild(pointer);
		}
		
		public function Main():void {	
			new GameTracker();
			GameTracker.api.beginGame();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//stage.quality = StageQuality.LOW;
			
			_stage = stage;
			
			var siteLock:SiteLock = new SiteLock(stage.loaderInfo.url);
			if (siteLock.CheckCurrentDomain()) Initialization();
			else {
				Main.SM.PlaySound(new level_but_snd());
				var tf:TextField = new TextField();
				//tf.text = "Domain not avalible";
				tf.text = stage.loaderInfo.url;
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.setTextFormat(new TextFormat(null, 30));
				tf.textColor = 0xFFFFFF;
				addChild(tf);
			}
		}
		
		private function Initialization():void {
			SaveManager.initialize();
			RegisterSWCClasses();
			LVLC.Init();
			SM.Init();
			
			var stateSprite:Sprite = new Sprite();
			addChild(stateSprite);
			GSM = new GameStateManager(stateSprite);
			
			GSM.PushState(new MainMenuState());
			
			//SWFProfiler.init(stage, 0, 0);
			//SWFProfiler.run();
			stage.addEventListener(Event.ENTER_FRAME, UpdatePointer);
			
			_pointer.mouseChildren = false;
			_pointer.mouseEnabled = false;
			addChild(_pointer);
			SetPoiner(new pointer_mc());
		}
		
		private function RegisterSWCClasses():void {
			ClassResolver.registerClass(level_bridge_01_mc, "level_bridge_01_mc");
			ClassResolver.registerClass(level_city_01_mc, "level_city_01_mc");
			ClassResolver.registerClass(level_city_02_mc, "level_city_02_mc");
			ClassResolver.registerClass(level_city_03_mc, "level_city_03_mc");
			ClassResolver.registerClass(level_city_04_mc, "level_city_04_mc");
			ClassResolver.registerClass(level_city_05_mc, "level_city_05_mc");
			ClassResolver.registerClass(level_suburb_01_mc, "level_suburb_01_mc");
			ClassResolver.registerClass(level_suburb_04_mc, "level_suburb_04_mc");
			ClassResolver.registerClass(level_suburb_05_mc, "level_suburb_05_mc");
			ClassResolver.registerClass(level_village_02_mc, "level_village_02_mc");
			ClassResolver.registerClass(level_village_04_mc, "level_village_04_mc");
			ClassResolver.registerClass(level_village_05_mc, "level_village_05_mc");
			
			ClassResolver.registerClass(tutorial_02_mc, "tutorial_02_mc");
			ClassResolver.registerClass(tutorial_03_mc, "tutorial_03_mc");
			ClassResolver.registerClass(tutorial_04_mc, "tutorial_04_mc");
			ClassResolver.registerClass(tutorial_05_mc, "tutorial_05_mc");
			ClassResolver.registerClass(tutorial_06_mc, "tutorial_06_mc");
			ClassResolver.registerClass(tutorial_07_mc, "tutorial_07_mc");
		}
						
		private function UpdatePointer(e:Event):void {
			_pointer.getChildAt(0).x = stage.mouseX;
			_pointer.getChildAt(0).y = stage.mouseY;
		}
	}
}