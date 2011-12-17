package gameObjects
{
	
	import org.flixel.*
	import org.flixel.plugin.photonstorm.FlxBar;
	
	
	/**
	 * a ship object.
	 * @author Martin Carney
	 */
	public class Ship extends FlxSprite {
		
		// ####################### Prototypes ############################# //
		
		/**
		 * File containing all the data for existing ship types.
		 */
		[Embed(source = "../data/ships.txt", mimeType = "application/octet-stream")]public static var shipTypeDataFile:Class;
		
		/**
		 * Counter to keep track of where in the file to start parsing each ship.
		 */
		public static var _i:int = 0;
		
		/**
		 * Array that holds Strings read from the lines of ships.txt.
		 */
		public static var shipDataStrings:Array;
		
		/**
		 * Originals of each type of ship.
		 */
		public static var prototypes:FlxGroup = new FlxGroup();
		
		/**
		 * How many types of ship there are. When Main makes all the protoships, it runs a for loop this number of times
		 * and calls out each ID case. If there is a blank slot, a shuttlecraft will be loaded and an error message
		 * given to the console.
		 */
		public static const NUM_SHIP_TYPES:uint = 3;
		
		// ######################## Unit Variables ######################## //
		
		/**
		 * The ship's sprite image.
		 */
		public var _shipSprite:Class;
		
		/**
		 * The dot this ship makes on the radar screen.
		 */
		public var radarDot:FlxSprite;
		
		/**
		 * Number of images in the sprite sheet. First image should be facing 0 degrees, to the right.
		 */
		public var NUM_FRAMES:int = 36;
		
		/**
		 * Is this the player's ship? If true, skip all AI processes.
		 */
		public var playerControlled:Boolean;
		
		/**
		 * object that owns the Player object.
		 */
		public var parent:SpaceState;
		
		/**
		 * The ship's name. Usually this match's the ship's prototype, but can be altered for Player.ship and unique people.
		 */
		public var name:String;
		
		/**
		 * The ship's long name, used just once when the ship is purchased. Maybe this should be removed and just called
		 * from the Protoship when the ship is bought?
		 */
		public var longName:String;
		
		/**
		 * Max speed according to ship type and outfits.
		 */
		public var maxSpeed:Number;
		
		/**
		 * Angle in degrees the ship sprite is facing.
		 */
		public var facingAngle:Number;
		
		/**
		 * Angle in degrees the ship is moving along.
		 */
		public var velAngle:Number;
		
		/**
		 * Speed at which the ship is moving.
		 */
		public var velSpeed:Number;
		
		/**
		 * How much force the ship's thruster applies when accelerating.
		 */
		public var thrustPower:Number;
		
		/**
		 * Rate at which the ship rotates.
		 */
		public var rcs:Number;
		
		/**
		 * The ship's maximum shields.
		 */
		public var shieldCap:Number;
		
		/**
		 * The ship's current shields.
		 */
		public var shieldCur:Number;
		
		/**
		 * How many units of shield the ship recharges each second. Also how much energy is used to recharge each second
		 */
		public var shieldRecharge:Number;
		
		/**
		 * The ship's maximum protective armor.
		 */
		public var armorCap:Number;
		
		/**
		 * The ship's current protective armor.
		 */
		public var armorCur:Number;
		
		/**
		 * The ship's maximim structural integrity. As integrity takes damage, systems start to shut down, disabling the ship.
		 */
		public var structCap:Number;
		
		/**
		 * The ship's current structural integrity.
		 */
		public var structCur:Number;
		
		/**
		 * The maximum amount of fuel the ship can carry.
		 */
		public var fuelCap:Number;
		
		/**
		 * The current amount of fuel the ship is carrying. Note that fuel is in 1 KG units.
		 */
		public var fuelCur:Number;
		
		/**
		 * How manu units of fuel the reactor can use each second to produce energy.
		 */
		public var fuelBurnRate:Number;
		
		/**
		 * How many units of energy produced per unit of fuel. Most old-style engines are around 1, wile
		 * Matter/Anti-matter reactors might be somewhere around 10-20. [Some research required]
		 */
		public var fuelEfficiency:Number;
		
		/**
		 * Maximum amount of energy the ship can have available.
		 */
		public var energyCap:Number;
		
		/**
		 * Current amount of energy the ship has available.
		 */
		public var energyCur:Number;
		
		/**
		 * FlxGroup containing the ship's cargo.
		 */
		public var cargoHold:FlxGroup;
		
		/**
		 * Maximum cargo the ship can hold.
		 */
		public var cargoCap:uint;
		
		/**
		 * How much cargo the ship is currently holding.
		 */
		public var cargoCur:uint;
		
		/**
		 * Total mass of the ship and everything in it. Mass is measured in metric tons (1000 KG = 1 Metric Ton)
		 */
		public var totalMass:Number;
		
		/**
		 * The mass of the ship itself, without cargo, fuel, mods, etc.
		 */
		public var baseMass:Number;
		
		/**
		 * The total mass of all the ship's currently-stowed cargo.
		 */
		public var cargoMass:Number;
		
		/**
		 * Total mass of all the ship's mods.
		 */
		public var modMass:Number;
		
		/**
		 * How many spaces the ship has for mods.
		 */
		public var modSpace:uint;
		
		/**
		 * The ship's mods.
		 */
		public var mods:FlxGroup;
		
		//public var pointer:FlxSprite; // temp variable to indicate heading.
		//public var pointer2:FlxSprite;
		
		/**
		 * Constructor function.
		 * @param _parent The screen this ship is on.
		 * @param typeID What protoship ID to load when creating this ship.
		 */
		public function Ship(_parent:SpaceState, typeID:uint):void {
			super(0, 0);
			playerControlled = false;
			parent = _parent;
			cameras = Main.viewport;
			
			//var proto:Protoship = Main.protoships.members[typeID];
			//proto.newShipBuy(this);
			//proto = null;
			
			facingAngle = Math.random() * Math.PI * 2;
			
			cargoHold = new FlxGroup(); // If cargo isn't transferring to a new ship, this is why.
			
			//Prime the mass variables so you don't have uninitialized numbers.
			cargoMass = 0;
			modMass = 0;
			calculateMass();
			
			//Make the radarDot (but don't add it yet).
			radarDot = new FlxSprite(x / Main.RADAR_ZOOM, y / Main.RADAR_ZOOM);
			radarDot.makeGraphic(1, 1, 0xff8888ff);
			radarDot.cameras = Main.radar;
			
			//loadGraphic(_shipSprite, true); // This is done when the prototype is cloned.
			
			mods = new FlxGroup();
			
			if (true) {// These are all default values in case a value is missing from the ships.txt data file.
				name = "Freighter";
				longName = "Quickster light cargo freighter";
				_shipSprite = shipSprite0001;
				baseMass = 14.0;
				cargoCap = 45
				modSpace = 15;
				shieldCap = 170;
				shieldCur = shieldCap;
				shieldRecharge = 3.5;
				armorCap = 40;
				armorCur = armorCap;
				structCap = 95;
				structCur = structCap;
				fuelCap = 950;
				fuelCur = fuelCap;
				fuelBurnRate = 6.5;
				fuelEfficiency = 1;
				energyCap = 210;
				energyCur = energyCap;
				maxSpeed = 85;
				rcs = 1.3;
				thrustPower = 140;
			}
			
		}
		
		/**
		 * Creates a ship from its prototype.
		 * @param	ID The ID of the ship to clone.
		 * @return     The resulting ship cloned from its prototype.
		 */
		public static function cloneShip(_ID:uint):Ship {
			var result:Ship = new Ship(Main.spaceScreen, _ID);
			var prototype:Ship = prototypes.members[_ID];
			
			//Make sure we're cloning a valid prototype first.
			if (prototype == null) {
				// If not, clone a shuttlecraft and send an error.
				trace ("Invalid prototype ship id " + _ID + ". Copying ship ID 0.");
				prototype = prototypes[0];
				if (prototype == null) {
					// If shuttlecraft didn't load either, then ship data probably was not loaded.
					trace ("FATAL ERROR: Failed to load ships data.");
				}
			} 
			
			//Copy most values. Mods need to be cloned rather than pointed, and the prototype's graphic needs to be loaded.
			result._shipSprite = prototype._shipSprite;
			result.NUM_FRAMES = prototype.NUM_FRAMES;
			result.loadGraphic(result._shipSprite, true);
			result.name = prototype.name;
			result.longName = prototype.longName;
			result.rcs = prototype.rcs;
			result.thrustPower = prototype.thrustPower;
			result.maxSpeed = prototype.maxSpeed;
			result.shieldCap = prototype.shieldCap;
			result.shieldCur = prototype.shieldCur;
			result.shieldRecharge = prototype.shieldRecharge;
			result.armorCap = prototype.armorCap;
			result.armorCur = prototype.armorCur;
			result.structCap = prototype.structCap;
			result.structCur = prototype.structCur;
			result.fuelCap = prototype.fuelCap;
			result.fuelCur = prototype.fuelCur;
			result.fuelBurnRate = prototype.fuelBurnRate;
			result.fuelEfficiency = prototype.fuelEfficiency;
			result.energyCap = prototype.energyCap;
			result.energyCur = prototype.energyCur;
			result.cargoCap = prototype.cargoCap;
			result.cargoCur = prototype.cargoCur;
			result.totalMass = prototype.totalMass;
			result.baseMass = prototype.baseMass;
			result.cargoMass = prototype.cargoMass;
			result.modMass = prototype.modMass;
			result.modSpace = prototype.modSpace;
			
			for (var i:int = 0; i < prototype.mods.length; i++) {
				trace(i);
				//result.mods.add(prototype.mods.members[i].clone()); // Need to implement mods with a clone() method.
			}
			
			// Copy values from prototype to result.
			// Make sure to clone base outfits and to create a new cargo hold FlxGroup rather than copying.
			
			return result;
		}
		
		public static function generateShipPrototypes():void {
			trace("Generating Ship Prototypes.");
			var fileContent:String = new shipTypeDataFile();
			shipDataStrings = fileContent.split('\n');
			
			if (prototypes != null) {
				prototypes.destroy();
				prototypes = null;
			}
			prototypes = new FlxGroup();
			for (var i:uint = 0; i < Protoship.NUM_SHIP_TYPES; i++) {
				prototypes.add(parseShipFromText(shipDataStrings,_i));
			}
			trace("Generating Ship Prototypes...Done. Total: " + prototypes.length);
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
		public static function parseShipFromText(array:Array, startLine:int):Ship {
			//var NUM_LINES_NEEDED:int = 18;
			var i:int = startLine;
			if (startLine < array.length) {
				//trace(startLine);
				var _ID:uint = StringParser.readInt(array[i++]);
				var result:Ship = new Ship(Main.spaceScreen, _ID);
				var str:String = StringParser.readVarName(array[i]);
				while (str.indexOf("ID") != 0 && i < array.length) {
					if (StringParser.readVarName(array[i]).indexOf("spriteImage") > -1) {
						var newImage:String = StringParser.readValue(array[i]);
						result._shipSprite = result[newImage];
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
		
		/**
		 * Pre-update cycle. Currently re-positions the radarDot to match the ship's position, scaled for the radar.
		 */
		override public function preUpdate():void {
			radarDot.x = x / Main.RADAR_ZOOM;
			radarDot.y = y / Main.RADAR_ZOOM;
		}
		
		/**
		 * Standard update cycle.
		 */
		override public function update():void {
			if (FlxG.keys.N) {
				shieldCur -= FlxG.elapsed * 15;
				if (shieldCur < 0) {
					shieldCur = 0;
				}
			}
			calculateMass();
			rechargeShields();
			rechargeEnergy();
			
			frame = int((facingAngle / (Math.PI * 2)) * NUM_FRAMES);
			super.update();
			
			velAngle = Math.atan2(velocity.y, velocity.x); // Need to calculate this every cycle. Used in several places.
			velSpeed = MathE.pythag(velocity.x, velocity.y); // Need to calculate this every cycle too.
			
			if (velAngle < 0) {
				velAngle += 2 * Math.PI;
			}
			
			
			if (Math.abs(velSpeed) > maxSpeed) {
				//limits the speed of the ship to maxSpeed.
				velocity.x = Math.cos(velAngle) * maxSpeed;
				velocity.y = Math.sin(velAngle) * maxSpeed;
			}
			
		}
		
		private function rechargeShields():void {
			if (shieldCur < shieldCap) {
				if(energyCur > FlxG.elapsed * shieldRecharge) {
					if (shieldCur + FlxG.elapsed * shieldRecharge <= shieldCap) {
						shieldCur += FlxG.elapsed * shieldRecharge;
						energyCur -= FlxG.elapsed * shieldRecharge;
					} else {
						energyCur -= shieldCap - shieldCur;
						shieldCur = shieldCap;
					}
				}
			}
		}
		
		private function rechargeEnergy():void {
			if (energyCur < energyCap) {
				if (fuelCur > FlxG.elapsed * fuelBurnRate * fuelEfficiency) {
					if (energyCur + (fuelBurnRate * fuelEfficiency * FlxG.elapsed) <= energyCap) {
						//fully running the generators won't overload the batteries
						fuelCur -= fuelBurnRate * FlxG.elapsed;
						energyCur += fuelBurnRate * fuelEfficiency * FlxG.elapsed;
					} else {
						//Produce only as much as is needed to fill the batteries.
						var fuelToBurn:Number = (energyCap - energyCur) / fuelEfficiency;
						fuelCur -= fuelToBurn;
						energyCur += fuelToBurn * fuelEfficiency;
					}
				} else { //Use up the last of the fuel
					energyCur += fuelCur * fuelEfficiency; //Can produce erroneous results only when burning more fuel than is needed to refill batteries.
					fuelCur = 0;
				}
			}
		}
		
		/**
		 * Method called every update cycle to adjust ship's mass from
		 */
		public function calculateMass():void {
			totalMass = baseMass + cargoMass + (fuelCur / 1000) + modMass;
		}
		
		/**
		 * Adds or subtracts non-mission cargo from the ship's hold.
		 * @param	_id ID of the cargo type to add or remove.
		 * @param	qty How many units to move. Positive values to add cargo, negative to remove.
		 * @return Whether the transfer was successful. A false return is the result of a bug.
		 */
		public function moveCargo(_id:uint, qty:int):Boolean {
			if (qty == 0) { return true;}
			var c:Cargo = null;
			var i:int = 0;
			//First, find if there is a matching cargo item.
			while (c == null && i < cargoHold.length) {
				var d:Cargo = cargoHold.members[i];
				if (d != null && d.ID == _id && !d.missionLinked) {
					c = d;
				}
				d = null;
			}
			//Then, add or remove cargo, creating new Cargo if needed.
			if (c == null) {
				if (qty > 0) {
					//Adding cargo
					c = new Cargo(_id, qty);
					cargoHold.add(c);
				} else {
					trace("Attempted to remove " + qty + " units of cargo that doesn't exist!");
					return false; // Removing non-existant cargo!
				}
			} else {
				if (c.qty + qty > 0) {
					//Adding cargo to existing Cargo object.
					c.qty += qty;
				} else if (c.qty + qty == 0) {
					// Removing exactly as much cargo as there is.
					c.qty = 0;
					cargoHold.remove(c, true);
				} else {
					trace("Attempted to remove " + qty + " units of cargo from " + c.qty + "!");
					return false; //Removing more cargo than there is!
				}
			}
			c = null;
			calculateCargo();
			return true;
		}
		
		/**
		 * Calculates the cargo mass as well as current units filled / available.
		 */
		public function calculateCargo():void {
			cargoMass = 0;
			cargoCur = 0;
			for (var i:int = 0; i < cargoHold.length; i++) {
				if (cargoHold.members[i] != null) {
					var c:Cargo = cargoHold.members[i] as Cargo;
					cargoMass += c.getCargoMass();
					cargoCur += c.qty;
				} else {
					trace("Null cargo hold entry at " + i);
					cargoHold.remove(cargoHold.members[i], true);
					i--;
				}
			}
			if (cargoCur > cargoCap) {
				trace ("Too much cargo in the hold! " + cargoCur + " units in " + cargoCap + " spaces.");
			}
		}
		
		/**
		 * Mostly-internal function for when the ship is turning counter-clockwise.
		 */
		public function turnLeft():void {
			if(energyCur > (totalMass * FlxG.elapsed) / 1000) {
				facingAngle -= rcs * FlxG.elapsed;
				energyCur -= (totalMass * FlxG.elapsed) / 1000;
				if (facingAngle < 0) {
					facingAngle += 2 * Math.PI;
				}
			}
		}
		
		/**
		 * Mostly-internal function for when the ship is turning clockwise.
		 */
		public function turnRight():void {
			if(energyCur > (totalMass * FlxG.elapsed) / 1000) {
				facingAngle += rcs * FlxG.elapsed;
				energyCur -= (totalMass * FlxG.elapsed) / 1000;
				if (facingAngle > 2 * Math.PI) {
					facingAngle -= 2 * Math.PI;
				}
			}
		}
		
		public function thrust():void {
			if(energyCur > thrustPower * FlxG.elapsed / 1000) {
				acceleration.x = (Math.cos(facingAngle) * thrustPower) / (totalMass / 10);
				acceleration.y = (Math.sin(facingAngle) * thrustPower) / (totalMass / 10);
				energyCur -= thrustPower * FlxG.elapsed / 1000
			}
		}
		
		/**
		 * Used to add a ship to the screen, along with its radar dot.
		 */
		public function addToScreen():void {
			Main.spaceScreen.shipsLayer.add(this);
			Main.spaceScreen.radarLayer.add(radarDot);
		}
		
		/**
		 * Removes a ship and its radar dot from the screen.
		 */
		public function removeFromScreen():void {
			Main.spaceScreen.shipsLayer.remove(this, true);
			Main.spaceScreen.radarLayer.remove(radarDot, true);
		}
		
		/**
		 * nulls out variables specific to Ships, then calls destroy() from FlxSprite.
		 */
		override public function destroy():void {
			parent.radarLayer.remove(radarDot, true);
			cargoHold = null;
			radarDot.destroy();
			radarDot = null;
			parent = null;
			
			// Call this last.
			super.destroy();
		}
	}
	
}