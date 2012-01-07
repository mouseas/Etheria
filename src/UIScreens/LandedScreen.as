package UIScreens {
	
	import org.flixel.*;
	import gameObjects.*;
	
	
	public class LandedScreen extends UIScreen {
		
		/**
		 * Which planet the player has landed on.
		 */
		public var planet:Planet;
		
		/**
		 * Refuel button.
		 */
		public var refuelButton:FlxButton;
		
		/**
		 * Save button.
		 */
		public var saveButton:FlxButton;
		
		/**
		 * Cargo shop button.
		 */
		public var cargoButton:FlxButton;
		
		/**
		 * Constructor.
		 * @param	_planet Which planet the player has landed on, and from which to draw info and image.
		 */
		public function LandedScreen(_planet:Planet) {
			OKButton.label.text = "Leave";
			planet = _planet;
			
			if (planet.inhabited) {
				if (Player.p.ship.fuelCur < Player.p.ship.fuelCap) {
					refuelButton = new FlxButton(OKButton.x, OKButton.y + 30, "Refuel", refuel);
					refuelButton.scrollFactor = Main.NO_SCROLL;
					buttonLayer.add(refuelButton);
				}
				
				cargoButton = new FlxButton(OKButton.x, OKButton.y + 90, "Trade", cargoShop);
				cargoButton.scrollFactor = Main.NO_SCROLL;
				buttonLayer.add(cargoButton);
			}
			saveButton = new FlxButton(OKButton.x, OKButton.y + 60, "Save", save);
			saveButton.scrollFactor = Main.NO_SCROLL;
			buttonLayer.add(saveButton);
			
			
		}
		
		/**
		 * Update cycle.
		 */
		override public function update():void {
			super.update();
			
		}
		
		/**
		 * Destroy this screen and prep it for garbage collection, without destroying persistent objects.
		 */
		override public function destroy():void {
			planet = null;
			super.destroy();
		}
		
		/**
		 * Called when the player leaves the planet, either by pressing "L" or clicking the "Leave" button.
		 */
		override public function closeScreen():void {
			Main.spaceScreen.takeOff(planet, planet.system);
			super.closeScreen();
			
		}
		
		/**
		 * Refuels the player's ship. Fuel costs 1 credit per unit, so 1 jump costs 100 credits, give or take.
		 */
		public function refuel():void {
			if (planet.inhabited) {
				var p:Player = Player.p;
				if (p.money >= p.ship.fuelCap - p.ship.fuelCur) {
					p.money -= (int)(p.ship.fuelCap - p.ship.fuelCur);
					p.ship.fuelCur = p.ship.fuelCap;
				} else {
					p.ship.fuelCur += p.money;
					p.money = 0;
				}
				buttonLayer.remove(refuelButton, true);
				refuelButton.destroy();
				refuelButton = null;
			}
		}
		
		/**
		 * Saves the current game data to a file in xml format.
		 */
		public function save():void {
			var save:SaveGame = new SaveGame();
		}
		
		public function cargoShop():void {
			trace ("cargoshop clicked");
			//cargoButton.update();
			cargoButton._pressed
			new CargoShop(planet);
		}
		
	}
}