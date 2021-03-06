package UIScreens {
	
	import org.flixel.*
	import gameObjects.*;
	
	public class mapScreen extends UIScreen {
		
		[Embed(source = "../../lib/map-ui.png")]public var bgImage:Class;
		
		public function mapScreen() {
			
			super(bgImage);
			OKButton.x = uiBackground.x + 60;
			OKButton.y = uiBackground.y + 460;
			OKButton.label.text = "Close";
			
			add(ConnectionLine.allConnectionLines);
			add(SpaceSystem.allSystems);
			add(SpaceSystem.allSystemNames);
			
			FlxG.addCamera(Main.spaceScreen.mapCam);
		}
		
		override public function closeScreen():void {
			remove(SpaceSystem.allSystems, true);
			remove(SpaceSystem.allSystemNames, true);
			remove(ConnectionLine.allConnectionLines, true);
			FlxG.removeCamera(Main.spaceScreen.mapCam,false)
			super.closeScreen();
		}
		
	}
}