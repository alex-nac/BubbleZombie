package util {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	//Class just help us with animations that need to be removed after "end" frame is reached
	
	public class Animation extends Sprite {
		private var _anim:MovieClip;
		public var onComplete:Function = function():void {};
		
		public function Animation(anim:MovieClip, scale:Number) {
			_anim = anim;
			_anim.scaleX = scale;
			_anim.scaleY = scale;
			
			_anim.gotoAndPlay("start");
			
			addChild(_anim);
			
			addEventListener(Event.ENTER_FRAME, CheckLastFrame); 
		}
				
		private function CheckLastFrame(e:Event):void {
			if (_anim.currentFrameLabel == "end") {
				onComplete();
				if (parent) parent.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, CheckLastFrame);
				_anim = null;
			}
		}		
	}
}