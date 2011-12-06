package {
	
	import org.flixel.*;
	import gameObjects.*;
	
	
	public class UIScreen extends FlxState {
		
		
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
		public function UIScreen(backgroundImage:Class) {
			uiBackgroundImage = backgroundImage;
			
		}
		
		override public function create():void {
			super.create();
			
			
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
		}
		
		override public function update():void {
			super.update();
			if (current) {
				if (FlxG.keys.justPressed("ESCAPE") || FlxG.keys.justPressed("ENTER")) {
					closeScreen();
				}
			}
		}
		
		override public function destroy():void {
			OKButton.destroy();
			OKButton = null;
			super.destroy();
		}
		
		
	}
}