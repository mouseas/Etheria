package UIScreens {
	
	import org.flixel.*;
	import gameObjects.*;
	import UIScreens.*;
	
	
	public class CargoShop extends ShopScreen {
		
		/**
		 * The planet at which the player is trading
		 */
		public var planet:Planet;
		
		/**
		 * Constructor for the CargoShop screen
		 * @param	_planet The Planet the shop is on.
		 */
		public function CargoShop(_planet:Planet) {
			super();
			
			planet = _planet;
			for (var i:int = 0; i < planet.cargos.length; i++) {
				var c:ShopItem = new ShopItem(this);
				c.location = new FlxPoint(100 + uiBackground.x, (uiBackground.y + 15) + (36 * i));
				c.setName(Cargo.data.cargo[planet.cargos[i]].name);
				c.ID = planet.cargos[i];
				var cargo:Cargo = Cargo.makeCargo(c.ID, 1);
				
				add(c);
			}
		}
		
		/**
		 * Buy the currently selected item.
		 */
		override public function buyItem():void {
			if (Player.p.money > currentSelection.price) {
				if (Player.p.ship.cargoCur < Player.p.ship.cargoCap) {
					Player.p.ship.addRemoveCargo(currentSelection.ID, 1);
					Player.p.money -= currentSelection.price;
				}
			}
		}
		
		/**
		 * Sell the currently selected item.
		 */
		override public function sellItem():void {
			var i:int = Player.p.ship.hasCargo(currentSelection.ID);
			if (i > -1) {
				Player.p.ship.addRemoveCargo(currentSelection.ID, -1);
				Player.p.money += currentSelection.price;
			} else {
				trace ("Player does not have this type of cargo.");
			}
		}
		
		override public function update():void {
			super.update();
			
		}
		
		/**
		 * Update the Buy and Sell buttons to active or inactive.
		 */
		override public function checkBuySell():void {
			
		}
		
		override public function closeScreen():void {
			//Remove any persistent objects here.
			super.closeScreen();
		}
		
		override public function destroy():void {
			
			super.destroy();
		}
		
	}
}