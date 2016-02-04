package game.events {
	import flash.events.Event;
	import game.Bubble;
	
	public class ComboEvent extends Event {
		
		public static const COMBO:String = "combo";
		public var killed:Vector.<Bubble>;
		
		public function ComboEvent(type:String, killed:Vector.<Bubble>, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.killed = killed;
		}
	}
}