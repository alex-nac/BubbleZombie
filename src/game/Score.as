package game {	
	
	import game.bubbles.SimpleBubble;
	import game.bubbles.Sprayer;
	import game.bubbles.Zombie;
	import game.events.ComboEvent;
	
	import util.GameConfig;
	
	//class thats calcilates the scores
	
	public class Score {
		private var _score:int = 0;
		private var _basicComboBonus:int;
		private var _enemiesKilled:int = 0;
		private var _wasMasterBonusGained:Boolean = false;
		
		private static var _basicScores:int;
		private static var _uberScores:int;
		private static var _steamScores:int;
		private static var _airplaneScores:int = 1;
		
		public static function get BASIC_SCORE():int { return _basicScores; }
		public static function get UBER_SCORE():int { return _uberScores; }
		public static function get STEAM_SCORE():int { return _steamScores; }
		public static function get AIRPLANE_SCORE():int { return _airplaneScores; }
		public function get score():int { return _score; }
		public function get enemiesKilled():int { return _enemiesKilled; } 
		public function get wasMasterBonusGained():Boolean { return _wasMasterBonusGained; }
		
		public function Score(cfg:GameConfig) {
			_basicComboBonus = cfg.basicComboBonus;
			_basicScores = cfg.basicScores;
			_uberScores = cfg.uberScores;
			_steamScores = cfg.steamScores;
		}
		
		//mesh sends event when something influence the scores
		public function UpdateScore(e:ComboEvent, checkForCombo:Boolean):void {
			var killedZombie:int = 0;
			var killedSteam:int = 0;
			var killedUber:int = 0;
			
			for each (var bbl:Bubble in e.killed) { 
				if (bbl is Zombie) {
					if (bbl["color"] == SimpleBubble.UBER_BLACK) killedUber++;
					else killedZombie++;
				}
				
				if (bbl is Sprayer) killedSteam++;
			}
						
			//if we check for combo we use combo formula
			if (checkForCombo && killedZombie + killedUber >= 6) {	
				var comboLevel:int = (killedZombie + killedUber) / 3 - 1;
				var bonus:int = comboLevel * _basicComboBonus;
				_score += bonus;
				
				var maxY:int = int.MIN_VALUE, maxX:int = int.MIN_VALUE, minY:int = int.MAX_VALUE, minX:int = int.MAX_VALUE;
				for each (bbl in e.killed) { 
					if (bbl.x > maxX) maxX = bbl.x;
					if (bbl.x < minX) minX = bbl.x;
					if (bbl.y > maxY) maxY = bbl.y;
					if (bbl.y < minY) minY = bbl.y;
				}
				
				//finding the center of the combo and showing big text "Combo nX!!!" here
				var centerX:int = minX + (maxX - minX) / 2;
				var centerY:int = minY + (maxY - minY) / 2;
				var floatingText:FloatingText = new FloatingText("Combo " + comboLevel + "X!!! Bonus: " + bonus, new combo_mc(), 14);
				floatingText.x = centerX;
				floatingText.y = centerY;
				floatingText.scaleX = floatingText.scaleY = 1.7;
				e.killed[0].mesh.AddEffect(floatingText, true);
			}
			
			//if it isn't from airplane
			if (checkForCombo) _score += killedZombie * _basicScores + killedUber * _uberScores + killedSteam * _uberScores;
			else _score += e.killed.length * _airplaneScores;
			
			_enemiesKilled += killedSteam + killedUber + killedZombie;
		}
		
		public function PlusMasterBonus():void {
			_score += AchievmentsManager.MASTER_ACH_SCORE_BONUS;	
			_wasMasterBonusGained = true;		
		}
		
	}
}