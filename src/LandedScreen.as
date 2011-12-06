package {
	
	import org.flixel.*;
	import gameObjects.*;
	
	
	public class LandedScreen extends FlxState {
		
		/**
		 * Which planet the player has landed on.
		 */
		public var planet:Planet;
		
		/**
		 * Button to take off from the planet.
		 */
		public var leaveButton:FlxButton;
		
		
		public function LandedScreen(_planet:Planet) {
			planet = _planet;
			
		}
		
		override public function create():void {
			super.create();
			
			
			var background:FlxSprite = new FlxSprite(0, 0);
			background.makeGraphic(400, 300, 0xffaaaaaa);
			background.x = (Main.spaceScreen.viewPortCam.width / 2) - (background.width / 2);
			background.y = (Main.spaceScreen.viewPortCam.height / 2) - (background.height / 2);
			background.scrollFactor = (Main.NO_SCROLL);
			add(background);
			
			leaveButton = new FlxButton(background.x + 10, background.y + 10, "Leave", leavePlanet);
			leaveButton.scrollFactor = (Main.NO_SCROLL);
			add(leaveButton);
			
		}
		
		override public function update():void {
			super.update();
			if (FlxG.keys.justPressed("ESCAPE") || FlxG.keys.justPressed("ENTER")) {
				leavePlanet();
			}
			
		}
		
		override public function destroy():void {
			leaveButton.destroy();
			leaveButton = null;
			planet = null;
			super.destroy();
		}
		
		/**
		 * Called when the player leaves the planet, either by pressing "L" or clicking the "Leave" button.
		 */
		public function leavePlanet():void {
			//Main.addDays(1); //Passes time, updates the date.
			Main.spaceScreen.remove(this, true);
			Main.spaceScreen.dialogScreen = null;
			Main.spaceScreen.takeOff(planet, planet.system);
			destroy();
			Main.spaceScreen.unfreeze();
		}
		
		
	}
}