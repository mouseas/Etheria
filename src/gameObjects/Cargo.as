package gameObjects {
	import org.flixel.*;
	import flash.utils.ByteArray;
	
	public class Cargo extends FlxBasic {
		
		/**
		 * File containing all the data for cargo types.
		 */
		[Embed(source = "../data/cargo.xml", mimeType = "application/octet-stream")]public static var XMLFile:Class;
		
		/**
		 * Cargo type data; name, prices, etc. to generate a cargo object from or set up a cargo trade screen.
		 */
		public static var data:XML;
		
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
		 */
		public function Cargo() {
			super();
		}
		
		/**
		 * Gets the total mass of this cargo group.
		 * @return Number: total mass.
		 */
		public function getCargoMass():Number {
			return qty * massPerUnit;
		}
		
		public static function prepCargo():void {
			var file:ByteArray = new XMLFile;
			var str:String = file.readUTFBytes(file.length);
			data = new XML(str);
		}
		
		/**
		 * Create a new Cargo object by its
		 */
		public static function makeCargo(_id:uint, _qty:uint, _missionLinked:Boolean = false):Cargo {
			if (data == null) {
				prepCargo();
			}
			var result:Cargo = new Cargo();
			result.ID = _id;
			result.qty = _qty;
			if (data.cargo.length() > _id) {
				result.name = data.cargo[_id].name;
				result.shortName = data.cargo[_id].shortName;
				result.massPerUnit = data.cargo[_id].massPerUnit;
				result.missionLinked = _missionLinked;
				return result;
			} else {
				trace ("ERROR: invalid cargo type ID " + _id + " requested!");
				return null;
			}
		}
		
		
	}
	
	
}