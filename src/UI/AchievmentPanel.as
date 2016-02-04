package UI {
	import com.gskinner.motion.GTween;
	
	import flash.display.Sprite;
	
	import game.AchievmentsManager;
	
	//just panel that goes out from top-rigth corner of our screen
	
	public class AchievmentPanel extends Sprite {
		
		private const MOVING_TIME:Number = 0.35;
		private const PAUSE_TIME:Number = 0.5;
		
		private var tw:GTween;
		
		public function AchievmentPanel(ach:int, x:int, y:int) {
			
			//firstable choosing achievment name
			var name:String;
			switch (ach) {
				case AchievmentsManager.DEFENDER:
					name = '"DEFENDER"';
					break;
				case AchievmentsManager.VETERAN:
					name = '"VETERAN"';
					break;
				case AchievmentsManager.ZOMBIEHUNTER:
					name = '"ZOMBIE HUNTER"';
					break;
				case AchievmentsManager.RECORDBREAKER:
					name = '"RECORD BREAKER"';
					break;
				case AchievmentsManager.MASTER:
					name = '"MASTER"';
					break;
			}
			
			//then start panel moving
			var achPanel:ach_completed_mc = new ach_completed_mc();
			achPanel.achName.text = name;
			achPanel.x = x - achPanel.width / 2;
			achPanel.y = y - 0.5 * achPanel.height;
			addChild(achPanel);
			
			var pauseTween:GTween = new GTween(null, PAUSE_TIME);
			pauseTween.paused = true;
			
			tw = new GTween(achPanel, MOVING_TIME, {y:achPanel.y + achPanel.height});
			tw.onComplete = onPanelOpened;
			tw.nextTween = pauseTween;
			
			pauseTween.nextTween = tw;
		}
		
		//releasing tween
		private function onPanelOpened(e:GTween):void {
			tw.swapValues();			
			tw.onComplete = onPanelClosed;
			
		}
		
		private function onPanelClosed(e:GTween):void {
			//removing this from parent
			if (parent) parent.removeChild(this);
			tw.onComplete = null;
			tw.nextTween = null;		
		}
		
		
	}
}