package gameObjects {
	import org.flixel.*;
	
	public class Cargo extends FlxBasic {
		
		/**
		 * Number of units of this cargo. A ship's cargo hold is based off units
		 */
		public var qty:uint;
		
		/**
		 * How much mass each unit of cargo has.
		 */
		public var massPerUnit:Number;
		
		/**
		 * Name for the cargo item.
		 */
		public var name:String;
		
		/**
		 * Short version of cargo name, for display.
		 */
		public var shortName:String;
		
		/**
		 * Is this cargo item connected to a mission? (Prevents buy/sell and combining with other cargos);
		 */
		public var missionLinked:Boolean;
		
		/**
		 * Buy/sell price when price is Low
		 */
		public var lowValue:uint;
		
		/**
		 * Buy/sell price when price is Medium
		 */
		public var medValue:uint;
		
		/**
		 * Buy/sell price when price is High
		 */
		public var highValue:uint;
		
		/**
		 * Creates a new Cargo object from the ID
		 * @param	_id The id of the cargo - determines its type and other values besides qty.
		 * @param  _qty How much cargo to make.
		 */
		public function Cargo(_id:uint, _qty:uint = 1, _mission:Boolean = false) {
			ID = _id;
			qty = _qty;
			missionLinked = _mission;
		}
		
		/**
		 * Gets the total mass of this cargo group.
		 * @return Number: total mass.
		 */
		public function getCargoMass():Number {
			return qty * massPerUnit;
		}
		
		
		
		
		
		
		
		/**
		 * All the cargo values, by ID. Whenever creating a new type of cargo, add a case here.
		 */
		private function newCargoById():void {
			switch (ID) {
				case 0:
					name = "Food";
					shortName = "Food";
					massPerUnit = 1.0;
					lowValue = 48;
					medValue = 64;
					highValue = 79;
				break;
				
				case 1:
					name = "Common Metals";
					shortName = "Metal";
					massPerUnit = 5.4;
					lowValue = 140;
					medValue = 210;
					highValue = 280;
				break;
				
				case 2:
					name = "Rare Metals";
					shortName = "Rare Met.";
					massPerUnit = 7.0;
					lowValue = 315;
					medValue = 417;
					highValue = 519;
				break;
				
				case 3:
					name = "Manufacturing Equipment";
					shortName = "Mfg. Eq.";
					massPerUnit = 2.8;
					lowValue = 240;
					medValue = 340;
					highValue = 440;
				break;
				
				case 4:
					name = "Plastics";
					shortName = "Plastic";
					massPerUnit = 1.2;
					lowValue = 48;
					medValue = 65;
					highValue = 79;
				break;
				
				case 5:
					name = "Luxury Goods";
					shortName = "Lux Goods";
					massPerUnit = 0.6;
					lowValue = 413;
					medValue = 604;
					highValue = 795;
				break;
				
				case 6:
					name = "Terraforming Equipment";
					shortName = "Ter. Eq.";
					massPerUnit = 2.2;
					lowValue = 281;
					medValue = 392;
					highValue = 503;
				break;
				
				
				default:
				trace("Invalid Cargo ID " + ID + "has been generated. Copying values for Food.");
				name = "Food Bad ID";
				shortName = "FoodB";
				massPerUnit = 1.0;
				lowValue = 48;
				medValue = 65;
				highValue = 79;
				
			}
		}
		
		
	}
	
	
}