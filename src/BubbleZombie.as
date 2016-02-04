package   {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.Mouse;
	import flash.utils.getDefinitionByName;

	//import util.FGLAds;


	[SWF(backgroundColor="#000000", width="640", height="480", frameRate="30")]
	public class BubbleZombie extends MovieClip {

		public var mainClassName:String = "BubbleZombie";
		private var _firstEnterFrame:Boolean;
		private var _preloaderBackground:Shape
		private var _preloaderPercent:Shape;

		public function BubbleZombie() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stop();

			Mouse.show();
			Mouse.hide();

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.MEDIUM
		}

		public function start():void {
			_firstEnterFrame=true;

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.scaleMode=StageScaleMode.SHOW_ALL;
			stage.align=StageAlign.TOP_LEFT;
			start()

			//new FGLAds(stage, "FGL-20029468");
			//FGLAds.api.addEventListener(FGLAds.EVT_API_READY, onShowAds);
		}

		private function onShowAds(e:Event):void {
			//FGLAds.api.removeEventListener(FGLAds.EVT_API_READY, onShowAds);
			//FGLAds.api.showAdPopup(FGLAds.FORMAT_AUTO, 1000, 3000);
			//FGLAds.api.addEventListener(FGLAds.EVT_AD_SHOWN, onShowMouse);
		}

		private function onShowMouse(e:Event):void {
			//FGLAds.api.removeEventListener(FGLAds.EVT_AD_SHOWN, onShowMouse);
			Mouse.show();
			//FGLAds.api.addEventListener(FGLAds.EVT_AD_CLOSED, function onShowMouse(e:Event):void {
			//	FGLAds.api.removeEventListener(FGLAds.EVT_AD_CLOSED, onShowMouse);
			//	Mouse.show();
			//	Mouse.hide();
			//});
		}

		private function onEnterFrame(event:Event):void {
			if (_firstEnterFrame) {
				_firstEnterFrame=false;
				if (root.loaderInfo.bytesLoaded >= root.loaderInfo.bytesTotal) {
					dispose()
					run()
				} else {
					beginLoading();
				}
				return;
			}
			//trace(root.loaderInfo.bytesLoaded + "/" + root.loaderInfo.bytesTotal)
			if (root.loaderInfo.bytesLoaded >= root.loaderInfo.bytesTotal) {
				dispose()
				run()
			} else {
				var percent:Number=root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
				updateLoading(percent);
			}
		}

		// this function may never be called if the load is instant
		private function updateLoading(a_percent:Number):void {
			_preloaderPercent.scaleX = a_percent
		}

		// this function may never be called if the load is instant
		private function beginLoading():void {
			_preloaderBackground = new Shape()
			_preloaderBackground.graphics.beginFill(0x333333)
			_preloaderBackground.graphics.lineStyle(2,0x000000)
			_preloaderBackground.graphics.drawRect(0,0,200,20)
			_preloaderBackground.graphics.endFill()

			//
			_preloaderPercent = new Shape()
			_preloaderPercent.graphics.beginFill(0xFFFFFFF)
			_preloaderPercent.graphics.drawRect(0,0,200,20)
			_preloaderPercent.graphics.endFill()
			//
			addChild(_preloaderBackground)
			addChild(_preloaderPercent)
			_preloaderBackground.x = _preloaderBackground.y = 10
			_preloaderPercent.x = _preloaderPercent.y = 10
			_preloaderPercent.scaleX = 0

			_preloaderBackground.x = _preloaderPercent.x = 320 - _preloaderBackground.width / 2;
			_preloaderBackground.y = _preloaderPercent.y = 240 - _preloaderBackground.height / 2;
		}


		private function dispose():void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if (_preloaderBackground){
				removeChild(_preloaderBackground)
			}
			if (_preloaderPercent){
				removeChild(_preloaderPercent)
			}
			_preloaderBackground = null
			_preloaderPercent = null
		}

		private function run():void {
			gotoAndStop(2);

			const MainType:Class = getDefinitionByName("Main") as Class;
			addChild(new MainType() as DisplayObject);
		}
	}
}