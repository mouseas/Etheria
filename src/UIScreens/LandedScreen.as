package UIScreens {
	
	import org.flixel.*;
	import gameObjects.*;
	
	
	public class LandedScreen extends UIScreen {
		
		/**
		 * Which planet the player has landed on.
		 */
		public var planet:Planet;
		
		/**
		 * Constructor.
		 * @param	_planet Which planet the player has landed on, and from which to draw info and image.
		 */
		public function LandedScreen(_planet:Planet) {
			OKButton.label.text = "Leave";
			planet = _planet;
			
			
		}
		
		/**
		 * Update cycle.
		 */
		override public function update():void {
			super.update();
			
			
		}
		
		/**
		 * Destroy this screen and prep it for garbage collection.
		 */
		override public function destroy():void {
			//trace("landed screen destroy()");
			planet = null;
			super.destroy();
		}
		
		/**
		 * Called when the player leaves the planet, either by pressing "L" or clicking the "Leave" button.
		 */
		override public function closeScreen():void {
			Main.spaceScreen.takeOff(planet, planet.system);
			super.closeScreen();
			
		}
		
		
	}
}