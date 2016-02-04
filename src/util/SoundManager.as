package util {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getDefinitionByName;
	
	import avmplus.getQualifiedClassName;
	
	public class SoundManager {
		private var _soundEnabled:Boolean;
			
		private var _backSong:SoundWrapper;	
		private var _backSongPaused:Boolean;
		private var _wrappersContainer:Vector.<SoundWrapper> = new Vector.<SoundWrapper>();
		
		//setting sound on/off
		public function set soundEnabled(value:Boolean):void { 
			_soundEnabled = value;
			SaveManager.setSharedData({key:"soundEnabled", value:value});
			SaveManager.saveSharedData();
			
			//if we have background song we resuming playing it
			if (value) {
				if (_backSong && !_backSongPaused) _backSong.Play();
			}
			else {
				_backSong.Pause();
				for each (var sCh:SoundWrapper in _wrappersContainer) 
					if (!sCh.isPaused) sCh.StopAndDelete(); //we don't delete paused sounds								
			}
		}
		
		public function get soundEnabled():Boolean { return _soundEnabled; }
		
		
		
		
		public function SoundManager() {
		}	
		
		public function Init():void {
			_soundEnabled = SaveManager.getSharedData("soundEnabled");
		}
		
		//play simple sound
		public function PlaySound(sound:Sound):SoundWrapper {
			if (!_soundEnabled) return null;
			
			var newSnd:SoundWrapper = new SoundWrapper(sound);	
			newSnd.Play();
			_wrappersContainer.push(newSnd);
			newSnd.addEventListener(Event.SOUND_COMPLETE, SoundComplete);
			newSnd.addEventListener(SoundWrapper.STOPPED_AND_DELETED, SoundDelete);
			
			return newSnd;
		}
		
		public function SetBackSong(sound:Sound):void {
			//if (_backSong && sound is Class(getDefinitionByName(getQualifiedClassName(_backSong.sound)))) return;
			_backSongPaused = false;
			if (_backSong) _backSong.StopAndDelete();
			_backSong = new SoundWrapper(sound, 0);			
			_backSong.soundTransform = new SoundTransform(0.3, 0);
			if (soundEnabled) _backSong.Play();			
		}
		
		public function SetBackSongState(paused:Boolean):void {
			if (_backSong && _soundEnabled) 
				paused ? _backSong.Pause() : _backSong.Play();
			
			_backSongPaused = paused;
		}
		
		//complete sound handler
		private function SoundComplete(e:Event):void {
			e.target.removeEventListener(Event.SOUND_COMPLETE, SoundComplete);
			(e.target as SoundWrapper).StopAndDelete();  
		}	
		
		//delete sound handler
		private function SoundDelete(e:Event):void {
			e.target.removeEventListener(SoundWrapper.STOPPED_AND_DELETED, SoundDelete);			
			_wrappersContainer.splice(_wrappersContainer.indexOf(e.target as SoundWrapper), 1);	
		}
		
	}
}