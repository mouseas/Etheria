package org.flixel {
	
	import org.flixel.*
	
	/**
	 * Custom Flixel class that automatically makes a line from one point to another of a given color
	 * @author Martin Carney
	 */
	public class FlxLine extends FlxSprite {
		
		
		public var lineOrigin:FlxPoint;
		public var lineEnd:FlxPoint;
		public var lineColor:uint;
		
		/**
		 * Constructor for the FlxLine.
		 * @param	origin Point to start the line at
		 * @param	end Point to end the line at
		 * @param	color Line's color. Default is white.
		 */
		public function FlxLine(_lineOrigin:FlxPoint, _lineEnd:FlxPoint, _lineColor:uint = 0xffffffff) {
			lineOrigin = _lineOrigin;
			lineEnd = _lineEnd;
			lineColor = _lineColor;
			redrawLine();
		}
		
		public function redrawLine():void {
			var left:Number = Math.min(lineOrigin.x, lineEnd.x);
			var top:Number = Math.min(lineOrigin.y, lineEnd.y);
			var right:Number = Math.max(lineOrigin.x, lineEnd.x);
			var bottom:Number = Math.max(lineOrigin.y, lineEnd.y);
			this.x = left;
			this.y = top;
			makeGraphic((uint)(right - left), (uint)(bottom - top), 0x00000000, true);
			drawLine(lineOrigin.x - x, lineOrigin.y - y, lineEnd.x - x, lineEnd.y - y, lineColor);
		}
		
		override public function destroy():void {
			lineOrigin = null;
			lineEnd = null;
			
			
			super.destroy();
		}
		
		
		
		
	}
	
	
}