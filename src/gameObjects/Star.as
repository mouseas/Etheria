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
		
		/**
		 * Number of stars to display on the screen at any given time.
		 */
		private static const NUM_STARS:int = 50;
		
		/**
		 * Screen the Star appears on.
		 */
		public static var parent:SpaceState;
		
		/**
		 * Bin from which to pull recycled stars.
		 */
		public static var recycleBin:Array = new Array();
		
		
		public function Star(posX:Number, posY:Number):void {
			super(posX, posY);
			this.x = posX;
			this.y = posY;
			loadGraphic(_starImage, true, false);
			cameras = Main.viewport;
			
			if (parent == null) {
				parent = Main.spaceScreen;
			}
			
			//Randomly pick which frame of the star to display
			frame = int(Math.random() * NUM_FRAMES);
			
			//Set the star's scroll factor (and thus apparent distance).
			var _scrollFactor:Number = (Math.random() * (SCROLL_FACTOR_MAX - SCROLL_FACTOR_MIN) + SCROLL_FACTOR_MIN);
			scrollFactor.x = scrollFactor.y = _scrollFactor; //assigns _scrollFactor's value to both y and x values of scrollFactor.
			
		}
		
		public static function makeStar(_x:Number = 0, _y:Number = 0):Star {
			var result:Star;
			if (recycleBin.length > 0) {
				result = recycleBin.pop();
				result.x = _x;
				result.y = _y;
				result.frame = int(Math.random() * NUM_FRAMES);
				var _scrollFactor:Number = (Math.random() * (SCROLL_FACTOR_MAX - SCROLL_FACTOR_MIN) + SCROLL_FACTOR_MIN);
				result.scrollFactor.x = result.scrollFactor.y = _scrollFactor;
				
			} else {
				result = new Star(_x, _y);
			}
			return result;
		}
		
		public function recycle():void {
			recycleBin.push(this);
		}
		
		/**
		 * Standard update cycle.
		 */
		override public function update():void {
			super.update();
			
		}
		
		/**
		 * Checks for off-screen stars, then replaces them with new ones depending on the player's direction and the star's position.
		 */
		public static function checkStarsOnScreen():void {
			for (var i:int = 0; i < parent.starLayer.length; i++) {
				var oldStar:Star = parent.starLayer.members[i];
				if (oldStar != null && !oldStar.onScreen(parent.viewPortCam)) {
					var point:FlxPoint = oldStar.getScreenXY(null,parent.viewPortCam);
					oldStar.recycle();
					parent.starLayer.remove(oldStar);
					
					var newStar:Star;
					
					if (Main.player.ship.velocity.x > 0 && point.x < 0) {
						newStar = spawnStarRight();
					} else if (Main.player.ship.velocity.x < 0 && point.x > parent.viewPortCam.width) {
						newStar = spawnStarLeft();
					} else if (Main.player.ship.velocity.y > 0 && point.y < 0) {
						newStar = spawnStarBottom();
					} else if (Main.player.ship.velocity.y < 0 && point.y > parent.viewPortCam.height) {
						newStar = spawnStarTop();
					}
					parent.starLayer.add(newStar);
					point = null;
				}
				
			}
		}
		
		/**
		 * Internal function used to reset the star field whenever the player takes off or changes systems.
		 */
		public static function resetStars():void {
			if (parent.starLayer == null) {
				parent.starLayer = new FlxGroup();
				trace("new starList");
			}
			while (parent.starLayer.length > 0) { // Clear out any existing stars first
				//trace(starList.length);
				parent.starLayer.remove(parent.starLayer.members[0], true);
			}
			for (var i:int = 0; i < NUM_STARS; i++) { // Then create NUM_STARS new stars on the visible screen.
				var star:Star = makeStar(0, 0);
				star.x = (parent.viewPortCam.scroll.x * star.scrollFactor.x) + (Math.random() * parent.viewPortCam.width);
				star.y = (parent.viewPortCam.scroll.y * star.scrollFactor.y) + (Math.random() * parent.viewPortCam.height);
				parent.starLayer.add(star);
			}
		}
		
		/**
		 * Generates a star along the top of the screen.
		 * @return The star generated.
		 */
		public static function spawnStarTop():Star {
			var star:Star = makeStar(0, 0);
			star.x = (parent.viewPortCam.scroll.x * star.scrollFactor.x) + (Math.random() * parent.viewPortCam.width);
			star.y = (parent.viewPortCam.scroll.y) * star.scrollFactor.y;
			return star;
		}
		/**
		 * Generates a star along the left of the screen.
		 * @return The star generated.
		 */
		public static function spawnStarLeft():Star {
			var star:Star = makeStar(0, 0);
			star.x = (parent.viewPortCam.scroll.x) * star.scrollFactor.x;
			star.y = (parent.viewPortCam.scroll.y * star.scrollFactor.y) + (Math.random() * parent.viewPortCam.height);
			return star;
		}
		/**
		 * Generates a star along the bottom of the screen.
		 * @return The star generated.
		 */
		public static function spawnStarBottom():Star {
			var star:Star = makeStar(0, 0);
			star.x = (parent.viewPortCam.scroll.x * star.scrollFactor.x) + (Math.random() * parent.viewPortCam.width) ;
			star.y = (parent.viewPortCam.scroll.y * star.scrollFactor.y) + parent.viewPortCam.height;
			return star;
		}
		/**
		 * Generates a star along the right of the screen.
		 * @return The star generated.
		 */
		public static function spawnStarRight():Star {
			var star:Star = makeStar(0, 0);
			star.x = (parent.viewPortCam.scroll.x * star.scrollFactor.x) + parent.viewPortCam.width;
			star.y = (parent.viewPortCam.scroll.y * star.scrollFactor.y) + (Math.random() * parent.viewPortCam.height);
			return star;
		}
		
	}
	
}