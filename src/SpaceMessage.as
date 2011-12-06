package {
	
	import org.flixel.*
	
	/**
	 * Message displayed on the player's screen and logged in the message log.
	 * @author Martin Carney
	 */
	public class SpaceMessage extends FlxBasic {
		
		/**
		 * The string in the message
		 */
		protected var str:String;
		
		/**
		 * The amount of time the message should remain on screen, 15 seconds by default.
		 */
		protected var life:Number;
		
		/**
		 * The color of the message, white by default.
		 */
		protected var color:uint;
		
		public function SpaceMessage(_str:String, _lifeSpan:Number = 10, _color:uint = 0xffffffff) {
			super();
			str = _str;
			life = _lifeSpan;
			color = _color;
			
		}
		
		public function getString():String {
			return str;
		}
		
		public function getLife():Number {
			return life;
		}
		
		public function getColor():uint {
			return color;
		}
		
		override public function update():void {
			super.update();
			if (life > 0) {
				if (life < FlxG.elapsed) {
					life = 0;
					active = false; //Skip updating this message in the game loop; reduce overhead.
				} else {
					life -= FlxG.elapsed;
				}
			}
		}
		
	}
}