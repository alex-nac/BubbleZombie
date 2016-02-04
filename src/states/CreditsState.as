package states {
	import flash.events.MouseEvent;
	
	import util.State;
	
	public class CreditsState extends State {
		
		public function CreditsState() {
			var BGsprite:CreditsBGD = new CreditsBGD();
			BGsprite.addEventListener(MouseEvent.CLICK, MenuBtnCB);
			
			addChild(BGsprite);
		}
		
		private function MenuBtnCB(e:MouseEvent):void {
			Main.GSM.PopState();
			Main.GSM.PushState(new MainMenuState());
		}
		
	}
}