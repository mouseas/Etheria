package gameObjects {
	
	import org.flixel.*;
	
	/**
	 * 
	 * @author Martin Carney
	 */
	public class Protoship extends FlxBasic {
		
		/**
		 * How many types of ship there are. When Main makes all the protoships, it runs a for loop this number of times
		 * and calls out each ID case. If there is a blank slot, a shuttlecraft will be loaded and an error message
		 * given to the console.
		 */
		public static const NUM_SHIP_TYPES:uint = 3;
		
		/**
		 * The ship's name, eg "Shuttle". Not to be mistaken for longName, which is has model number type info.
		 */
		public var name:String;
		
		/**
		 * The ship's long name, which might contain model info. Example: "Globocon Industries MK 4 Shuttlecraft".
		 */
		public var longName:String;
		
		/**
		 * Image used for the ship's sprite.
		 */
		public var _spriteImage:Class;
		
		/**
		 * Image displayed in the shipyard
		 */
		public var shipyardImage:Class;
		
		/**
		 * Image displayed when more details are displayed for the ship.
		 */
		public var awesomeImage:Class;
		
		/**
		 * How much mass an empty version of this ship is. Any mods the ship comes with adds to totalMass but not baseMass.
		 */
		public var baseMass:Number;
		
		/**
		 * How many units of cargo this ship can fit.
		 */
		public var cargoCap:uint;
		
		/**
		 * How many spaces the ship has for mods. Note that this is before adding any standard mods.
		 */
		public var modSpace:uint;
		
		/**
		 * How much shielding the ship has (before mods).
		 */
		public var shieldCap:Number;
		
		/**
		 * How many units of shield the ship can recharge per second (without mods);
		 */
		public var shieldRecharge:Number;
		
		/**
		 * How much armor plating the ship has (before mods).
		 */
		public var armorCap:Number;
		
		/**
		 * How much damage the ship's structure can take once armor and shields are down (before mods).
		 */
		public var structCap:Number;
		
		/**
		 * How much fuel the ship can carry (before mods).
		 */
		public var fuelCap:Number;
		
		/**
		 * How much energy the ship's batteries can have available (before mods). This must be at least 100 for a ship
		 * to be able to jump from system to system.
		 */
		public var energyCap:Number;
		
		/**
		 * How much thruster power the ship has (before mods).
		 */
		public var baseThrust:Number;
		
		/**
		 * The ship's unmodded top speed.
		 */
		public var baseMaxSpeed:Number;
		
		/**
		 * The ship's unmodded turn rate.
		 */
		public var baseRcs:Number;
		
		/**
		 * How much fuel the ship may use per second to replenish energy. May be depricated when engines are implemented.
		 */
		public var baseFuelBurnRate:Number;
		
		/**
		 * How much energy each unit of fuel produces as it's consumed. May be depricated when engines are implemented.
		 */
		public var baseFuelEfficiency:Number;
		
		/**
		 * All the mods that come with the ship when purchased new.
		 */
		public var baseMods:FlxGroup;
		
		/**
		 * Flags to determine whether this ship may be purchased at shipyards.
		 */
		public var avalableFlags:Array;
		
		/**
		 * Flags to determine whether this ship is visible in shipyards.
		 */
		public var visibleFlags:Array;
		
		/**
		 * What group of technology this ship belongs to (useful for grouping gov't-specific ships)
		 */
		public var techValue:uint;
		
		/**
		 * Used when generating all the Protoships to keep track of where along the array the process is.
		 */
		public static var _i:int = 0;
		
		
		public function Protoship(_id:uint) {
			ID = _id;
			baseMods = new FlxGroup();
			avalableFlags = new Array();
			visibleFlags = new Array();
			
			// These are all default values in case a value is missing from the ships.txt data file.
			name = "Freighter";
			longName = "Quickster light cargo freighter";
			spriteImage = shipSprite0001;
			baseMass = 14.0;
			cargoCap = 45
			modSpace = 15;
			shieldCap = 170;
			shieldRecharge = 3.5;
			armorCap = 40;
			structCap = 95;
			fuelCap = 950;
			baseFuelBurnRate = 6.5;
			baseFuelEfficiency = 1;
			energyCap = 210;
			baseMaxSpeed = 85;
			baseRcs = 1.3;
			baseThrust = 140;
		}
		
		override public function destroy():void {
			baseMods.destroy();
			baseMods = null;
			avalableFlags = null;
			visibleFlags = null;
			
			super.destroy();
		}
		
		public function newShipBuy(ship:Ship):void {
			ship.name = name;
			ship.longName = longName;
			ship._shipSprite = spriteImage;
			if (ship._shipSprite == null) { trace ("NULL protoship graphic, ID: " + ID); }
			ship.baseMass = baseMass;
			ship.cargoCap = cargoCap;
			ship.modSpace = modSpace;
			ship.shieldCap = ship.shieldCur = shieldCap;
			ship.shieldRecharge = shieldRecharge;
			ship.armorCap = ship.armorCur = armorCap;
			ship.structCap = ship.structCur = structCap;
			ship.fuelCap = ship.fuelCur = fuelCap;
			ship.fuelBurnRate = baseFuelBurnRate;
			ship.fuelEfficiency = baseFuelEfficiency;
			ship.energyCap = ship.energyCur = energyCap;
			ship.maxSpeed = baseMaxSpeed;
			ship.rcs = baseRcs;
			ship.thrustPower = baseThrust;
			for (var i:uint = 0; i < baseMods.length; i++) {
				var m:Mod = baseMods.members[i];
				ship.mods.add(m.copyOf());
			}
			
			
		}
		
		
		
		[Embed(source = "../../lib/ship-0000.png")]private var shipSprite0000:Class;
		[Embed(source = "../../lib/ship-0001.png")]private var shipSprite0001:Class;
		
		/**
		 * Passing in the string array, this will create a Protoship from the data starting at startLine.
		 * @param	array The entire array of strings to pull strings from in order to parse them.
		 * @param	startLine Which index in the array to start at.
		 * @return The finished Protoship. Any variables not defined in the ships.txt file for that entry will default
		 * to the values for a freighter, ship type ID 2.
		 */
		public static function parseShipFromText(array:Array, startLine:int):Protoship {
			//var NUM_LINES_NEEDED:int = 18;
			var i:int = startLine;
			if (startLine < array.length) {
				//trace(startLine);
				var _ID:uint = StringParser.readInt(array[i++]);
				var result:Protoship = new Protoship(_ID);
				var str:String = StringParser.readVarName(array[i]);
				while (str.indexOf("ID") != 0 && i < array.length) {
					if (StringParser.readVarName(array[i]).indexOf("spriteImage") > -1) {
						var newImage:String = StringParser.readValue(array[i]);
						result.spriteImage = result[newImage];
					} else if (StringParser.assignValueFromStrings(array[i], result)) {
						
					} else {
						trace("Error at line " + i + ". Contents: " + array[i]);
					}
					i++;
					if(i < array.length) {
						str = StringParser.readVarName(array[i]);
					}
				}
				_i = i;
				//trace(result.ID + " " + result.name);
				return result;
			} else {
				trace("Not enough lines left in the file. Index was " + _i);
				return null;
			}
			
			
		}
		
		public function set spriteImage(newImage:Class):void {
			_spriteImage = newImage;
		}
		public function get spriteImage():Class {
			return _spriteImage;
		}
		
		
		
	}
	
	
}