package states {
	import com.gskinner.motion.GTween;
	
	import flash.events.MouseEvent;
	
	import util.State;
	
	//Intro state class, the game intro is shown after the PLAY button is pressed
	
	public class IntroState extends State {		
		private var _BGsprite:menu; 
		
		public function IntroState() {
			_BGsprite = new menu();
			_BGsprite.backBtn.visible = false;
			_BGsprite.achievmentsBtn.visible = false;
			_BGsprite.restartBtn.visible = false;
			_BGsprite.resetBtn.visible = false;
			_BGsprite.skipLevelBtn.visible = false;
			if (Main.SM.soundEnabled) _BGsprite.sndOffBtn.visible = false;
			else _BGsprite.sndOnBtn.visible = false;
			
			_BGsprite.nextLvlBtn.shade.visible = false;
			_BGsprite.skipLevelBtn.shade.visible = false;
						
			_BGsprite.sndOnBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.sndOffBtn.addEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.nextLvlBtn.addEventListener(MouseEvent.CLICK, OpenLevelSelect);
			_BGsprite.lvlMapBtn.addEventListener(MouseEvent.CLICK, BackToMenu);
			
			new GTween(_BGsprite.nextLvlBtn.arrow, 0.2, { alpha:0 }, { reflect:true, repeatCount:0, delay:1 });
						
			addChild(_BGsprite);
			
			var intro_content:intro_content_mc = new intro_content_mc();
			intro_content.x = 320;
			intro_content.y = 240;
			addChild(intro_content);
			
			//smooth appearing
			new GTween(_BGsprite, 0.3, {alpha:0}, {swapValues:true});
			
			super();
		}
		
		public override function Remove():void {
			_BGsprite.sndOnBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
			_BGsprite.sndOffBtn.removeEventListener(MouseEvent.CLICK, SoundBtnCB);
		}
		
		private function SoundBtnCB(e:MouseEvent):void {
			Main.SM.soundEnabled = !Main.SM.soundEnabled;
			_BGsprite.sndOffBtn.visible = !_BGsprite.sndOffBtn.visible;
			_BGsprite.sndOnBtn.visible = !_BGsprite.sndOnBtn.visible;
		}
		
		private function OpenLevelSelect(e:MouseEvent):void {	
			Main.GSM.Switch(new LevelSelectState());
		}	
				
		private function BackToMenu(e:MouseEvent):void {
			Main.GSM.Switch(new MainMenuState());
		}
	}
}