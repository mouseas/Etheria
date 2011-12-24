package {
	
	import org.flixel.*;
	
	public class DispBar extends FlxGroup {
		
		/**
		 * Colored rectangle that makes up the empty or background part of the bar.
		 */
		public var background:FlxSprite;
		
		/**
		 * Colored rectangle that makes up the full part of the bar.
		 */
		public var bar:FlxSprite;
		
		/**
		 * Where the bar is at now.
		 */
		public var value:Number;
		
		/**
		 * The lowest value for the bar, usually 0.
		 */
		public var min:Number;
		
		/**
		 * The highest value for the bar, usually the variable's upper capacity.
		 */
		public var max:Number;
		
		/**
		 * The variable to watch as the max for the bar. May be used or ignored.
		 */
		public var maxVar:String;
		
		/**
		 * How wide the bar is.
		 */
		public var width:Number;
		
		/**
		 * How tall the bar is.
		 */
		public var height:Number;
		
		/**
		 * Which variable of the parent this bar auto-follows.
		 */
		public var variable:String;
		
		/**
		 * Which object this bar is attached to.
		 */
		public var parent:*;
		
		/**
		 * The bar's x position
		 */
		public var x:Number;
		
		/**
		 * The bar's y position
		 */
		public var y:Number;
		
		/**
		 * The color for the empty portion of the bar.
		 */
		public var emptyColor:uint;
		
		/**
		 * The color for the full portion of the bar.
		 */
		public var fullColor:uint;
		
		/**
		 * The bar's scroll factor. Usually this will be (0,0) for a HUD item.
		 */
		public var scrollFactor:FlxPoint;
		
		/**
		 * Creates a display bar, which fills or drops each update cycle.
		 * @param	_x X position of the top-left corner of the bar
		 * @param	_y Y position of the top-left corner of the bar
		 * @param	_parent Which object to watch
		 * @param	_variable The name of the variable to watch within the parent.
		 * @param	_min Low value for the bar. Usually 0.
		 * @param	_max High value for the bar. For health, this might be the maximum health.
		 * @param	_width How wide the bar is.
		 * @param	_height How tall the bar is.
		 * @param	_emptyColor What color the empty portion of the bar is, formated 0xAARRGGBB.
		 * @param	_fullColor What color the filled portion of the bar is, formatted 0xAARRGGBB.
		 */
		public function DispBar(_x:Number, _y:Number, _parent:* = null, _variable:String="", _min:Number = 0, _max:Number = 100, _width:Number = 100, _height:Number = 10, _emptyColor:uint = 0xff006600, _fullColor:uint = 0xff00ff00) {
			
			super();
			x = _x;
			y = _y;
			parent = _parent;
			variable = _variable;
			min = _min;
			max = _max;
			width = _width;
			height = _height;
			emptyColor = _emptyColor;
			fullColor = _fullColor;
			
			scrollFactor = new FlxPoint(1, 1);
			
			background = new FlxSprite(x, y);
			background.makeGraphic(width, height, emptyColor);
			background.scrollFactor = scrollFactor;
			add(background);
			
			bar = new FlxSprite(x, y);
			bar.makeGraphic(width, height, fullColor);
			bar.scrollFactor= scrollFactor;
			add(bar);
			bar.origin.x = 0;
			
			maxVar = "";
			
		}
		
		/**
		 * Changes the parent, target variable, max, and min.
		 * @param	_parent The new parent to assign. If null, keeps the old parent.
		 * @param	_variable The variable name to watch. If blank, keeps the old variable to watch.
		 * @param	_min The new minimum for the bar. Any value below _min shows an empty bar.
		 * @param	_max The new maximum for the bar. Any value about _max shows a full bar.
		 */
		public function changeParent(_parent:* = null, _variable:String = "", _max:Number = 100, _min:Number = 0):void {
			if (_parent != null) {
				parent = _parent;
			}
			if (_variable.length > 0) {
				variable = _variable;
			}
			max = _max;
			min = _min;
			maxVar = "";
		}
		
		/**
		 * Changes the colors used for the empty and full versions of the bar.
		 * @param	full Color for the full portion of the bar.
		 * @param	empty Color for the empty portion of the bar.
		 */
		public function changeColors(full:uint = 0xff00ff00, empty:uint = 0xff006600):void {
			fullColor = full;
			emptyColor = empty;
			background.fill(emptyColor);
			bar.fill(fullColor);
		}
		
		
		/**
		 * Standard update cycle.
		 */
		override public function update():void {
			bar.x = background.x = x;
			bar.y = background.y = y;
			if (parent != null) {
				try {
					if (maxVar.length > 1) {
						max = parent[maxVar];
					}
					value = parent[variable];
					if (value >= max) {
						bar.scale.x = 1;
					} else if (value <= min) {
						bar.scale.x = 0;
					} else {
						bar.scale.x = (value - min) / (max - min);
					}
				} catch (errObject:Error) {
					trace("Error occured while updating a bar value. This probably means you're watching a variable that's not a Number.\n" + 
						"Message: " + errObject.message);
				}
			}
			super.update();
			
			
		}
		
		/**
		 * Called when the object is no longer in use.
		 * Destroys objects that are part of the DispBar, then uses super.destroy().
		 */
		override public function destroy():void {
			//background.destroy();
			background = null;
			//bar.destroy();
			bar = null;
			scrollFactor = null;
			
			super.destroy();
		}
		
		
		
		
		
	}
	
	
	
}