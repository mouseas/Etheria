package UIScreens {
	
	import org.flixel.*
	
	public class mapScreen extends UIScreen {
		
		[Embed(source = "../../lib/map-ui.png")]public var bgImage:Class;
		
		public function mapScreen() {
			
			super(bgImage);
			OKButton.x = uiBackground.x + 60;
			OKButton.y = uiBackground.y + 460;
			OKButton.label.text = "Close";
			
			add(Main.allSystems);
			
			FlxG.addCamera(Main.spaceScreen.mapCam);
		}
		
		override public function closeScreen():void {
			remove(Main.allSystems, true);
			FlxG.removeCamera(Main.spaceScreen.mapCam,false)
			super.closeScreen();
		}
		
	}
}