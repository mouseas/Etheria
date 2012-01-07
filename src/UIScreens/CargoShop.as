package UIScreens {
	
	import org.flixel.*;
	import gameObjects.*;
	
	
	public class CargoShop extends UIScreen {
		
		/**
		 * The planet at which the player is trading
		 */
		public var planet:Planet;
		
		//public static var i:uint = 0;
		//public var unique:uint;
		
		public function CargoShop(_planet:Planet) {
			super();
			//unique = i++;
			
			planet = _planet;
		}
		
		override public function update():void {
			
			super.update();
			
		}
		
		override public function closeScreen():void {
			//Remove any persisten objects here.
			//trace("close cargo shop " + unique);
			super.closeScreen();
		}
		
		override public function destroy():void {
			
			super.destroy();
		}
		
	}
}