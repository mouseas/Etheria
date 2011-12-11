package UIScreens {
	
	import org.flixel.*;
	import gameObjects.*;
	
	
	public class LandedScreen extends UIScreen {
		
		/**
		 * Which planet the player has landed on.
		 */
		public var planet:Planet;
		
		public function LandedScreen(_planet:Planet) {
			OKButton.label.text = "Leave";
			planet = _planet;
			
			
		}
		
		override public function update():void {
			super.update();
			
			
		}
		
		override public function destroy():void {
			trace("landed screen destroy()");
			//planet = null;
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