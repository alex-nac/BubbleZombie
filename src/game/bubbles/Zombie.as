package game.bubbles {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.plugins.CurrentFramePlugin;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	import game.FloatingText;
	import game.Score;
	
	import util.Animation;
	import util.State;
	
	public class Zombie extends SimpleBubble {
		private const NORMAL_ZM:int = 1;
		private const EVIL1_ZM:int = 2;
		private const EVIL2_ZM:int = 3;
		private const EVIL3_ZM:int = 4;
				
		//help value for creating prefab
		public var canOverlay:Boolean = true;
				
		
		//private var _tw:GTween; 						//current animation tween
		private var _currentMode:int = 0;				
		private var _currAnim:MovieClip;				//current animation playing
		private var _repeatCnt:int = 1;					//sometime we play animation several times, this is how much times elapsed
		private var _infectionState:int = 0; 			//how much zombie infected by steam machine
		private var _animationActive:Boolean = true;	//if we play animation for this zombie or not
		private var _delayTimer:util.Timer;
		private var _flickTween:GTween;
		
		private var m_MC:MovieClip;		
		
		public function Zombie(color:int=0) {
			super(color);
			SetView();
		}
		
		public function set animationActive(value:Boolean):void {
			_animationActive = value;
		}
		
		public override function set color(newColor:int):void {
			_color = newColor;
			SetView();
			if (isFrozen || !_animationActive) _currAnim.stop(); //pause new tween if bubble is frozened or animation is turned off
		}
		
		public override function set isFrozen(value:Boolean):void {
			if (isFrozen == value) return; //if current state is the same as value we do nothing
			
			if (value) _currAnim.stop();
			else if (_animationActive) _currAnim.play();
			super.isFrozen = value;						
		}
		
		public override function Update():void {
			if (_currAnim.currentFrame == _currAnim.totalFrames) SetNextAnimation();
			if (_delayTimer) _delayTimer.Update();
			super.Update();
		}
	
		
		private function SetView():void {
			CurrentFramePlugin.install();
			
			m_MC = GetBubbleImage();
		
			SetNextAnimation();
			scale = DIAMETR / m_MC.width;
			
			m_MC.width *= scale;
			m_MC.height *= scale;
			view = m_MC;
			
			if (_color == SimpleBubble.UBER_BLACK) {
				var axe:axe_mc = new axe_mc();
				axe.width *= scale;
				axe.height *= scale;
				_effects.addChild(new axe_mc());
			}
		}
		
		//callback for onComplete
		private function SetNextAnimation():void {	
			_repeatCnt--;
			if (_repeatCnt != 0) return;	
			
			//default we play animation 1 time
			_repeatCnt = 1;
									
			if (_currentMode == NORMAL_ZM) {
				m_MC.gotoAndStop("evil1");
				_currAnim = MovieClip(m_MC.getChildByName("evil1"));				
			}
			
			if (_currentMode == EVIL1_ZM) {
				m_MC.gotoAndStop("evil2");
				_currAnim = MovieClip(m_MC.getChildByName("evil2"));								
			}
			
			if (_currentMode == EVIL2_ZM) { 
				m_MC.gotoAndStop("evil3");
				_currAnim = MovieClip(m_MC.getChildByName("evil3"));				
			}
			
			//0 means we set the tween first time
			if (_currentMode == EVIL3_ZM || _currentMode == 0) {				
				m_MC.gotoAndStop("normal");
				_currAnim = MovieClip(m_MC.getChildByName("normal"));
				_repeatCnt = Math.floor(Math.random() * 3) + 1;				
				
				//a random delay at the beginning of the game 
				if (_currentMode == 0) {
					_currAnim.stop();
					
					_delayTimer = new util.Timer(Math.random() * 3);
					_delayTimer.addEventListener(util.Timer.TRIGGED, function onTrig(e:Event):void {
						_delayTimer.removeEventListener(util.Timer.TRIGGED, onTrig);
						_delayTimer = null;
						if (_animationActive && !isFrozen) _currAnim.play();
					});
				}
			}
			
			if (_currentMode == 4) _currentMode = 1;
			else _currentMode++;						
		}
			
		override public function GetBubbleImage():MovieClip {
			var bubbleMC:MovieClip;
			switch(_color) {				
				case PINK:
					bubbleMC = new zombie_pink_mc();
					break;
				case YELLOW:
					bubbleMC = new zombie_yellow_mc();
					break;
				case RED:
					bubbleMC = new zombie_red_mc();
					break;
				case GREEN:
					bubbleMC = new zombie_green_mc();
					break;
				case BLUE:
					bubbleMC = new zombie_blue_mc();
					break;
				case VIOLETT:
					bubbleMC = new zombie_violet_mc();
					break;
				case UBER_BLACK:
					bubbleMC = new zombie_black_mc();
					break;
			}
			
			return bubbleMC;
		}
		
		public function Infect():void {
			if (isFrozen) return; //if it is frozened illnes doesn't affect to it
			
			_infectionState++;	
			if (_flickTween) {
				_flickTween.beginning();
				return;
			}
							
			
			//else flick it a bit and slow brightness by 20%			
			_flickTween = new GTween(view, 0.05, { alpha:0 }, { reflect:true, repeatCount:8 });
			_flickTween.onComplete = function(e:GTween):void {
				_flickTween.onComplete = null;
				_flickTween = null;
				
				var colorTransform:ColorTransform = view.transform.colorTransform;
				
				//if it is the last state of infection turn zombie to uber
				if (_infectionState == 3) {
					color = SimpleBubble.UBER_BLACK;
					
					//set brightness to 1					
					colorTransform.redMultiplier = 1
					colorTransform.greenMultiplier = 1
					colorTransform.blueMultiplier = 1			
				}
				else {					
					colorTransform.redMultiplier *= 0.8;
					colorTransform.greenMultiplier *= 0.8;
					colorTransform.blueMultiplier *= 0.8;				
				}
				
				view.transform.colorTransform = colorTransform;
				
			}
				
		}
		
		override public function Delete(withPlane:Boolean = false):void {
			var deathAnim:Animation = new Animation(new death_animation_mc(), 0.6 * scale);
			deathAnim.x = x;
			deathAnim.y = y;
			_mesh.AddEffect(deathAnim);
			
			Main.SM.PlaySound(new shot_02_snd());
			
			if (withPlane) var score:String = Score.AIRPLANE_SCORE.toString();
			else if (color != UBER_BLACK) score = Score.BASIC_SCORE.toString();
			else score = Score.UBER_SCORE.toString();
			var floatingText:FloatingText = new FloatingText(score, new point_mc(), 13);
			floatingText.x = view.x;
			floatingText.y = view.y - 15;
			if (_mesh) _mesh.AddEffect(floatingText, true);
			
			_currAnim.stop();
			if (_flickTween) _flickTween.end();		
						
			super.Delete(withPlane);
		}
				
		//handling game pause/resume		
		override public function onGameStateChanged(e:Event):void {
			if (e.type == State.PAUSE) _currAnim.stop();
			else if (_animationActive && !isFrozen) _currAnim.play();
			
			super.onGameStateChanged(e);
		}
		
	}
}