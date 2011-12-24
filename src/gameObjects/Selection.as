package gameObjects {
	
	import org.flixel.*;
	
	public class Selection extends FlxGroup {
		
		[Embed(source = "../../lib/selection-corner.png")]private var selectionCorner:Class;
		
		/**
		 * What object the Selection will center around / follow
		 */
		public var target:FlxSprite;
		
		/**
		 * Top left corner for the selection's visual appearance.
		 */
		public var topLeft:FlxSprite;
		
		/**
		 * Top right corner for the selection's visual appearance.
		 */
		public var topRight:FlxSprite;
		
		/**
		 * Bottom left corner for the selection's visual appearance.
		 */
		public var bottomLeft:FlxSprite;
		
		/**
		 * Bottom right corner for the selection's visual appearance.
		 */
		public var bottomRight:FlxSprite;
		
		public function Selection(_target:FlxSprite ) {
			target = _target;
			topLeft = makeCorner(0);
			topRight = makeCorner(1);
			bottomLeft = makeCorner(2);
			bottomRight = makeCorner(3);
			
			
		}
		
		private function makeCorner(frame:uint):FlxSprite {
			var result:FlxSprite = new FlxSprite(0, 0);
			result.loadGraphic(selectionCorner, true);
			result.frame = frame;
			result.cameras = Main.viewport;
			add(result);
			return result;
		}
		
		override public function update():void {
			if (target != null) {
				topLeft.x = target.x - topLeft.width;
				topLeft.y = target.y - topLeft.height;
				topRight.x = target.x + target.width;
				topRight.y = target.y - topRight.height;
				bottomLeft.x = target.x - bottomLeft.width;
				bottomLeft.y = target.y + target.height;
				bottomRight.x = target.x + target.width;
				bottomRight.y = target.y + target.height;
			}
			super.update();
		}
		
		public function set color(_color:uint):void {
			topLeft.color = _color;
			topRight.color = _color;
			bottomLeft.color = _color;
			bottomRight.color = _color;
		}
		
		
		
	}
	
}