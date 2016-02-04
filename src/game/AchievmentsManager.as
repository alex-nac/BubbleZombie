package game {
	import states.LevelSelectState;
	
	import util.SaveManager;
	
	public class AchievmentsManager {
		public static const DEFENDER:int = 0;
		public static const VETERAN:int = 1;
		public static const ZOMBIEHUNTER:int = 2;
		public static const RECORDBREAKER:int = 3;
		public static const MASTER:int = 4;
		
		private static const DEFENDER_LEVELS_AMOUNT:int = 15;
		private static const VETERAN_LEVEL:int = 25;
		private static const ZOMBIEHUNTER_ZOMBIE_AMOUNT:int = 1000;
		private static const RECORDBREAKER_POINTS:int = 20000;
		
		public static const MASTER_ACH_SCORE_BONUS:int = 500;
		
		
		
		public function AchievmentsManager() {
			
		}
		
		//return true if we have enough levels completed
		public static function CheckForDEFENDER():Boolean {
			if (SaveManager.getSharedData("ach" + DEFENDER + "_passed"))
				return false;
			
			var numLevelsCompleted:int = 0;
			for (var i:int = 1; i <= LevelSelectState.LEVELS_AMOUNT; i++) 
				if (LevelSelectState.GetLevelPassed(i)) numLevelsCompleted++;
			
			if (numLevelsCompleted >= DEFENDER_LEVELS_AMOUNT) {
				SaveManager.setSharedData({key:"ach" + DEFENDER + "_passed", value:true});
				SaveManager.saveSharedData();
				return true;
			}
			else return false;			
		}
		
		//return true if we completed certain level
		public static function CheckForVETERAN():Boolean {
			if (SaveManager.getSharedData("ach" + VETERAN + "_passed"))
				return false;
			
			if (LevelSelectState.GetLevelPassed(VETERAN_LEVEL)) {
				SaveManager.setSharedData({key:"ach" + VETERAN + "_passed", value:true});
				SaveManager.saveSharedData();
				return true;
			}
			else return false;
		}
		
		//if we killed enough zombies
		public static function CheckForZOMBIEHUNTER(killedZombies:int):Boolean {
			if (SaveManager.getSharedData("ach" + ZOMBIEHUNTER + "_passed"))
				return false;
				
			var key:String = "zombie_killed_ach";
			SaveManager.setSharedData({key:key, value:SaveManager.getSharedData(key) + killedZombies});			
			
			if (SaveManager.getSharedData(key) >= ZOMBIEHUNTER_ZOMBIE_AMOUNT) {
				SaveManager.setSharedData({key:"ach" + ZOMBIEHUNTER + "_passed", value:true});				
				return true;
			}
			else return false;			
		}
		
		//if we get enougth scores
		public static function CheckForRECORDBREAKER():Boolean {
			if (SaveManager.getSharedData("ach" + RECORDBREAKER + "_passed"))
				return false;
			
			if (LevelSelectState.GetTotalScores() >= RECORDBREAKER_POINTS) {
				SaveManager.setSharedData({key:"ach" + RECORDBREAKER + "_passed", value:true});
				SaveManager.saveSharedData();
				return true;
			}
			else return false;
		}
		
		//if we killed all bubbles before the plane wave
		public static function CheckForMASTER():Boolean {
			//return false if we have already passed this achievment
			if (SaveManager.getSharedData("ach" + MASTER + "_passed"))
				return false;
			
			SaveManager.setSharedData({key:"ach" + MASTER + "_passed", value:true});
			SaveManager.saveSharedData();
			return true;
		}
		
		//checking if we have passed achievment
		public static function IsAchievmentPassed(ach:int):Boolean {
			var key:String = "ach" + ach + "_passed";
			return SaveManager.getSharedData(key);
		}		
		
		
	}
}