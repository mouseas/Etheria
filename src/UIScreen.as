package {
	
	import org.flixel.*;
	import gameObjects.*;
	
	/**
	 * Dialog box and screen base class. Subclasses are defined and used for landing, map, mission text, et cetera. This class
	 * automatically adds itself to the SpaceScreen, so you only need to declare a new UIScreen object and it will show up
	 * in front of everything else and pause gameplay.
	 * @author Martin Carney
	 */
	public class UIScreen extends FlxGroup {
		
		/**
		 * Button to close the screen.
		 */
		public var OKButton:FlxButton;
		
		/**
		 * Whether this is the current, top-most screen.
		 */
		public var current:Boolean;
		
		/**
		 * Background for the UI.
		 */
		public var uiBackground:FlxSprite;
		
		/**
		 * Image file used for the UI background.
		 */
		public var uiBackgroundImage:Class;
		
		/**
		 * Constructor.
		 * @param	backgroundImage What image to use as the background.
		 */
		public function UIScreen(backgroundImage:Class = null) {
			Main.spaceScreen.dialogScreen = this;
			Main.spaceScreen.dialogLayer.add(this);
			
			cameras = Main.viewport;
			
			uiBackgroundImage = backgroundImage;
			uiBackground = new FlxSprite(0, 0);
			if (uiBackgroundImage == null) {
				uiBackground.makeGraphic(400, 300, 0xffaaaaaa);
			} else {
				uiBackground.loadGraphic(uiBackgroundImage);
			}
			uiBackground.x = (Main.spaceScreen.viewPortCam.width / 2) - (uiBackground.width / 2);
			uiBackground.y = (Main.spaceScreen.viewPortCam.height / 2) - (uiBackground.height / 2);
			uiBackground.scrollFactor = (Main.NO_SCROLL);
			add(uiBackground);
			
			OKButton = new FlxButton(uiBackground.x + 10, uiBackground.y + 10, "OK", closeScreen);
			OKButton.scrollFactor = (Main.NO_SCROLL);
			add(OKButton);
			current = true;
		}
		
		
		/**
		 * Override this function to control how the screen disappears.
		 */
		public function closeScreen():void {
			Main.spaceScreen.dialogLayer.remove(this, true);
			if (Main.spaceScreen.dialogLayer.length > 0) {
				Main.spaceScreen.dialogScreen = Main.spaceScreen.dialogLayer.members[Main.spaceScreen.dialogLayer.length - 1];
			}
			Main.spaceScreen.unfreeze();
			destroy();
		}
		
		override public function update():void {
			if (!Main.spaceScreen.frozen) {
				Main.spaceScreen.freeze();
			}
			super.update();
			if (Main.spaceScreen.dialogScreen == this) {
				if (FlxG.keys.justPressed("ESCAPE") || FlxG.keys.justPressed("ENTER")) {
					closeScreen();
				}
			}
		}
		
		override public function destroy():void {
			OKButton.destroy();
			OKButton = null;
			//trace("UI screen destroy()");
			super.destroy();
		}
		
		
	}
}