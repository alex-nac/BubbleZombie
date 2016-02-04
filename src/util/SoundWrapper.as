package util {	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	
	//just wrapper for simple pausing/resuming sound and repeat playing
		
	public class SoundWrapper extends EventDispatcher{
		public static const STOPPED_AND_DELETED:String = "STOPPED_AND_DELETED";
		
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _soundTransform:SoundTransform;
		private var _isPaused:Boolean = true;
		private var _pausePos:Number = 0;
		private var _currRepeatTimes:int = 0;
		private var _repeatTimes:int;
		
		public function set soundTransform(value:SoundTransform):void { 
			_soundTransform = value;			
			if (_channel) _channel.soundTransform = value;
		}
		
		public function get isPaused():Boolean { return _isPaused; }
		public function get sound():Sound { return _sound; }
		
		
		
		//repeatTimes = 0 means we play it infinitly
		public function SoundWrapper(sound:Sound, repeatTimes:int = 1) { 
			_sound = sound;
			_repeatTimes = repeatTimes;
		}
		
		public function Play():void {
			if (!_isPaused || !_sound) return;
			
			_channel = _sound.play(_pausePos);
			if (_soundTransform) _channel.soundTransform = _soundTransform;
			_channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_isPaused = false;
		}
					
		public function Pause():void {
			if (_isPaused || !_sound) return;
			
			_isPaused = true;
			_pausePos = _channel.position;
			_channel.stop();
			_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);			
		}
						
		public function StopAndDelete():void {
			if (_channel) {
				_channel.stop();
				_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
			
			_soundTransform = null;
			_channel = null;
			_sound = null;			
			
			dispatchEvent(new Event(STOPPED_AND_DELETED));
		}
		
		private function onSoundComplete(e:Event):void {
			_currRepeatTimes++;
			_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			if (_currRepeatTimes < _repeatTimes || _repeatTimes == 0) {
				var sndTr:SoundTransform = _channel.soundTransform;
				_channel = _sound.play();
				_channel.soundTransform = sndTr;
				_channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
			else { 				
				StopAndDelete();
			}
						
			dispatchEvent(new Event(Event.SOUND_COMPLETE));
		}
		
	}
}