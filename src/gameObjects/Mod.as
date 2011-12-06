package gameObjects {
	import org.flixel.*;
	
	/**
	 * 
	 * @author Martin Carney
	 */
	public class Mod extends FlxBasic{
		
		/**
		 * How much mass one of this mod adds to the ship's mass.
		 */
		public var unitMass:Number;
		
		/**
		 * How many mod spaces one of this item will take up. Most ammo will take 0 but still add mass.
		 */
		public var spaceUsedPerUnit:int; //Normally this will be positive, but cargo to space mods may be negative.
		
		/**
		 * How many of this mod a ship can have at once.
		 */
		public var maxOwnable:uint;
		
		/**
		 * Items captured from another ship but not yet installed. Maybe make salvage have a linked cargo item?
		 * Note that ammo can be used in installed weapons even when salvaged. Salvage may be sold or may be installed for
		 * 1/10 the purchase price at an outfitter.
		 */
		public var isSalvage:Boolean;
		
		/**
		 * How many of this mod a ship is carrying. This goes unused for the mods in a store. Maybe use this some day as
		 * a limit on how much a shop has available? Probably not.
		 */
		public var qty:uint;
		
		/**
		 * Standard price for one unit of this mod. Sale price is 1/2 price, salvage price is 1/3 price, and salvage install
		 * cost is 1/5 price.
		 */
		public var price:uint;
		
		public function Mod(_id:uint, _qty:int = 1) {
			ID = _id;
			qty = _qty;
		}
		
		public function copyOf():Mod {
			var copy:Mod = new Mod(ID, qty);
			copy.unitMass = unitMass;
			copy.spaceUsedPerUnit = spaceUsedPerUnit;
			copy.maxOwnable = maxOwnable;
			copy.price = price;
			
			
			copy.isSalvage = isSalvage;
			return copy;
		}
		
		public function get salvagePrice():uint {
			return (uint)(price / 3);
		}
		
		public function get salvageInstallPrice():uint {
			return (uint)(price / 5);
		}
		
		public function get salePrice():uint {
			return (uint)(price / 2);
		}
		
	}
	
	
	
	
}