package gameObjects
{
	import org.flixel.*;
	
	/**
	 * Little specks of light that fly past as the player flies around. Nothing more, nothing less.
	 */
	public class Star extends FlxSprite {
		
		/**
		* Image with all the possible star sprites.
		*/
		[Embed(source = "../../lib/stars.png")]private var _starImage:Class;
		
		/**
		 * Number of frames in the sprite image.
		 */
		private static const NUM_FRAMES:int = 3;
		
		/**
		 * Maximum scroll factor for a star. Lower decimals means farther stars. This should always be
		 * SCROLL_FACTON_MIN < this < 1. This represents the closest stars.
		 */
		private static const SCROLL_FACTOR_MAX:Number = 0.85;
		
		/**
		 * Minimum scroll factor for a star. Lower decimals means farther stars. This should always be
		 * 0 < this < SCROLL_FACTOR_MAX. This represents the most distant stars.
		 */
		private static const SCROLL_FACTOR_MIN:Number = 0.5;
		
		
		public function Star(posX:Number, posY:Number):void {
			super(posX, posY);
			this.x = posX;
			this.y = posY;
			loadGraphic(_starImage, true, false);
			cameras = Main.viewport;
			
			//Randomly pick which frame of the star to display
			frame = int(Math.random() * NUM_FRAMES)
			
			//Set the star's scroll factor (and thus apparent distance).
			var _scrollFactor:Number = (Math.random() * (SCROLL_FACTOR_MAX - SCROLL_FACTOR_MIN) + SCROLL_FACTOR_MIN);
			scrollFactor.x = scrollFactor.y = _scrollFactor; //assigns _scrollFactor's value to both y and x values of scrollFactor.
			
		}
		
		/**
		 * Standard update cycle.
		 */
		override public function update():void {
			super.update();
			
		}
		
	}
	
}