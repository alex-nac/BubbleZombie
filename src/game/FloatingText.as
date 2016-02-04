package game {
	import com.gskinner.motion.GTween;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class FloatingText extends Sprite {
		private const T_ALPHA:Number = 0.5;
		private const T_MOVING:Number = 1.0;
		
		public function FloatingText(text:String, textSprite:Sprite, movingPixelsAmount:int) {
			/*
			var floatingText:TextField = new TextField();
			floatingText.text = text;
			floatingText.autoSize = TextFieldAutoSize.LEFT;
			floatingText.setTextFormat(new TextFormat(null, size));			
			floatingText.selectable = false;
			floatingText.textColor = 0xFFFFFF;
			*/
			
			textSprite["txt"].text = text;
				
			var textMovingTween:GTween = new GTween(textSprite, T_MOVING, {y:textSprite.y - movingPixelsAmount});
			textMovingTween.onComplete = function (e:GTween):void {
				textMovingTween.onComplete = null;
				textMovingTween = null;
				textSprite.parent.removeChild(textSprite);
				textSprite = null;
			};
			
			
			//text is staying on the scene for 1 second 
			var scoreTimer:Timer = new Timer((T_MOVING - T_ALPHA) * 1000, 1);
			scoreTimer.addEventListener(TimerEvent.TIMER, function scoreTimerHandler (e:TimerEvent):void {
				scoreTimer.removeEventListener(TimerEvent.TIMER, scoreTimerHandler);
				
				var textTween:GTween = new GTween(textSprite, T_ALPHA, {alpha:0});
				textTween.onComplete = function (e:GTween):void {					
					textTween.onComplete = null;
					textTween = null;				
				};
			});
			scoreTimer.start();
			
			addChild(textSprite);
		}
	}
}