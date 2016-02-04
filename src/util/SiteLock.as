package util {
	
	public class SiteLock {
		//turn sitelock on
		private const SITELOCK_ENABLED:Boolean = false;
		private var _url:String;
		private var _urlsAllowed:Array = [ "www.flashgamelicense.com", "gametrax.eu", "www.dropbox.com" ];
		
		public function SiteLock(currentDomain:String) {
			//converting for ex. http://help.adobe.com/ru_RU/FlashPlatform -> help.adobe.com
			var url_parts:Array = currentDomain.split("://");
			url_parts = url_parts[1].split("/");
			_url = url_parts[0];
		}
		
		//checking if we are at the correct domain
		public function CheckCurrentDomain():Boolean {
			if (!SITELOCK_ENABLED) return true;
			
			for (var i:int = 0; i < _urlsAllowed.length; i++)
				if (_urlsAllowed[i] == _url) return true;
			
			return false;
		}
	}
}