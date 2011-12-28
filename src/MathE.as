package 
{
	import org.flixel.FlxPoint;
	
	/**
	 * Misc functions to help out with common things in Etheria
	 * @author Martin Carney
	 */
	public class MathE
	{
		
		/**
		 * Pythagorean Theorem says a^2 + b^2 = c^3. Use this to calculate strait light ranges and velocities from the x and y values.
		 * @param	x side a
		 * @param	y side b
		 * @return side c, the hypotenuse
		 */
		public static function pythag(x:Number, y:Number):Number {
			var c:Number = 0;
			x = x * x;
			y = y * y;
			c = Math.sqrt(x + y);
			return c;
		}
		
		/**
		 * Calculates a point out from a center/source point, at a given angle and distance.
		 * @param	center Source / Center point from which the resulting point is spaced
		 * @param	angle Angle at which the resulting point will be from center
		 * @param	distance How far (in pixels) from the center the resulting point will be
		 */
		public static function pointFromAngle(center:FlxPoint, angle:Number, distance:Number = 1):FlxPoint {
			var result:FlxPoint = new FlxPoint();
			result.x = center.x + (distance * Math.cos(angle));
			result.y = center.y + (distance * Math.sin(angle));
			return result;
		}
		
		/**
		 * Calculates the strait-line distance between two points
		 * @param	one Point A
		 * @param	two Point B
		 * @return Distance between Point A and Point B.
		 */
		public static function distance(one:FlxPoint, two:FlxPoint):Number {
			return pythag(one.x - two.x, one.y - two.y);
		}
		
		/**
		 * Takes two angles and gives the amount to turn for currentAngle to match goalAngle the shortest way.
		 * @param	currentAngle Angle 1, usually the angle the current object is facing
		 * @param	goalAngle Angle 2, usually the angle the object needs to turn towards.
		 * @return Signed difference between the angles. If positive, turn clockwise; if negative, turn counterclockwise.
		 */
		public static function turnDifference(currentAngle:Number, goalAngle:Number):Number {
			return Math.atan2(Math.sin(goalAngle - currentAngle), Math.cos(goalAngle - currentAngle));
			
		}
		
		/**
		 * Calculates the angle from point one to point two.
		 * @param	one Point A, usually the origin.
		 * @param	two Point B, usually the target.
		 * @param   posAngleNeeded Math.atan2 usually outputs a value between pi and -pi. If a positive angle is
		 * needed, this will add 2 * pi to any negative angles until it's positive.
		 * @return  The angle.
		 */
		public static function angleBetweenPoints(one:FlxPoint, two:FlxPoint, posAngleNeeded:Boolean=true):Number {
			var angle:Number = Math.atan2(two.y - one.y, two.x - one.x);
			while (angle > Math.PI * 2) {
				angle -= Math.PI * 2;
			}
			while (angle < 0 && posAngleNeeded) {
				angle += Math.PI * 2;
			}
			return angle;
		}
		
		/**
		 * Round to x decimal places (3 by default).
		 * @param	n Input number.
		 * @param   x Number of decimal places to round to.
		 * @return    Rounded number.
		 */
		public static function rnd(n:Number, x:uint = 3):Number {
			var multiplier:uint = Math.pow(10, x);
			return Math.round(n * multiplier) / multiplier;
		}
		
		/**
		 * Given a point, it returns a string of the x and y coords rounded to 3 decimal places
		 * @param	p FlxPoint given as input.
		 * @return String representing the input FlxPoint.
		 */
		public static function pointString(p:FlxPoint):String {
			return "(" + rnd(p.x) + "," + rnd(p.y) + ")";
		}
		
		/**
		 * Gives a random angle between 0 and 2 * PI from a current angle and an angle range, both in radians.
		 * Imagine a slice of pie. "current" is the line down the middle of the pie. The return is a random line from the pie's
		 * corner somewhere on that pie slice. This is mostly used for inaccuracy with weapons.
		 * Note that range must be between 0 and 2 * PI or your result will be 0.
		 * @param	current The angle relative to which the random angle is centered
		 * @param	range How wide an angle the random angle can be within
		 * @return Angle generated.
		 */
		public static function randomAngleWithinRange(current:Number, range:Number):Number {
			if (range < 0 || range > Math.PI * 2) {
				trace(range + " is an invalid range for a random angle!");
				return 0;
			}
			while (current > Math.PI * 2) {
				current -= Math.PI * 2;
			}
			while (current < 0) {
				current += Math.PI * 2;
			}
			var outangle:Number = Math.random() * range;
			outangle += current - (range / 2);
			while (outangle > Math.PI * 2) {
				outangle -= Math.PI * 2;
			}
			while (outangle < 0) {
				outangle += Math.PI * 2;
			}
			return outangle;
		}
	}
	
}