package gameObjects {
	
	import org.flixel.*;
	
	public class ConnectionLine extends FlxSprite {
		
		/**
		 * First system the line connects to.
		 */
		public var system1:SpaceSystem;
		
		/**
		 * Second system the line connects to.
		 */
		public var system2:SpaceSystem;
		
		/**
		 * Static holder for all the ConnectionLines.
		 */
		public static var allConnectionLines:FlxGroup;
		
		public function ConnectionLine(sys1:SpaceSystem, sys2:SpaceSystem) {
			super(0, 0);
			cameras = Main.map;
			system1 = sys1;
			system2 = sys2;
			
			findCorners();
		}
		
		public function findCorners():void {
			var topLeft:FlxPoint = new FlxPoint();
			var bottomRight:FlxPoint = new FlxPoint();
			var p1:FlxPoint = system1.getCenter();
			var p2:FlxPoint = system2.getCenter();
			if (p1.x < p2.x) {
				topLeft.x = p1.x;
				bottomRight.x = p2.x;
			} else {
				topLeft.x = p2.x;
				bottomRight.x = p1.x;
			}
			if (p1.y < p2.y) {
				topLeft.y = p1.y;
				bottomRight.y = p2.y;
			} else {
				topLeft.y = p2.y;
				bottomRight.y = p1.y;
			}
			x = topLeft.x;
			y = topLeft.y;
			makeGraphic(bottomRight.x - topLeft.x, bottomRight.y - topLeft.y, 0x000000, true);
			//alpha = 1;
			drawLine(p1.x - topLeft.x, p1.y - topLeft.y, p2.x - topLeft.x, p2.y - topLeft.y, 0xFFAAAAAA);
		}
		
		public function checkVisibility():void {
			if (system1.visible && system2.visible) {
				visible = true;
			} else {
				visible = false;
			}
		}
		
		/**
		 * Function which goes through all the systems and connection lines to update their visibility. Called whenever a system is
		 * loaded, and after buying a map.
		 */
		public static function updateMap():void {
			for (var i:int = 0; i < allConnectionLines.length; i++) {
				var line:ConnectionLine = allConnectionLines.members[i];
				line.checkVisibility();
			}
		}
		
		/**
		 * Creates a new FlxGroup to hold all the ConnectionLines, and deletes the old one, if any.
		 */
		public static function prepAllConnectionLines():void {
			if (allConnectionLines != null) {
				trace ("Clearing existing map lines from existence!");
				allConnectionLines.destroy();
			}
			allConnectionLines = new FlxGroup();
		}
	}
	
}