package gameObjects
{
	
	import flash.utils.ByteArray;
	import org.flixel.*
	
	
	/**
	 * a ship object.
	 * @author Martin Carney
	 */
	public class Ship extends FlxSprite {
		
		// ####################### Prototypes ############################# //
		
		/**
		 * File containing all the data for existing ship types.
		 */
		[Embed(source = "../data/ships.xml", mimeType = "application/octet-stream")]public static var shipTypeXMLFile:Class;
		
		/**
		 * XML data for the ship types
		 */
		public static var data:XML;
		
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
		
		/**
		 * How much money the ship is carrying. This is randomized by +/- 50% from the value in the ships XML data. Also, the player's
		 * cash is handled separately.
		 */
		public var cash:uint;
		
		/**
		 * Selection bracket around a target ship.
		 */
		public var selection:Selection;
		
		/**
		 * Is the ship warping out into another system?
		 */
		public var inHyperspace:Boolean;
		
		/**
		 * Which system the ship is currently targeting for hyperspace.
		 */
		public var hyperTarget:SpaceSystem;
		
		/**
		 * Constructor function.
		 * @param _parent The screen this ship is on.
		 * @param typeID What protoship ID to load when creating this ship.
		 */
		public function Ship(_parent:SpaceState, typeID:uint):void {
			super(0, 0);
			ID = typeID;
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
			
			if (true) {// These are all default values in case a value is missing from the ships.xml data file.
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
				cash = 0;
			}
			
		}
		
		/**
		 * Creates a ship from its prototype.
		 * @param	ID The ID of the ship to clone.
		 * @return     The resulting ship cloned from its prototype.
		 */
		public static function cloneShip(_ID:uint):Ship {
			var result:Ship = loadShipFromXML(_ID);
			return result;
		}
		
		private static function loadShipFromXML(index:int):Ship {
			if (data == null) {
				var file:ByteArray = new shipTypeXMLFile;
				var str:String = file.readUTFBytes(file.length);
				data = new XML(str);
			}
			var result:Ship = new Ship(Main.spaceScreen, index);
			result._shipSprite = result[data.ship[index].spriteImage];
			result.NUM_FRAMES = data.ship[index].NUM_FRAMES;
			result.loadGraphic(result._shipSprite, true);
			result.name = data.ship[index].name;
			result.longName = data.ship[index].longName;
			result.rcs = data.ship[index].rcs;
			result.thrustPower = data.ship[index].thrustPower;
			result.maxSpeed = data.ship[index].maxSpeed;
			result.shieldCap = data.ship[index].shieldCap;
			result.shieldCur = data.ship[index].shieldCap;
			result.shieldRecharge = data.ship[index].shieldRecharge;
			result.armorCap = data.ship[index].armorCap;
			result.armorCur = data.ship[index].armorCap;
			result.structCap = data.ship[index].structCap;
			result.structCur = data.ship[index].structCap;
			result.fuelCap = data.ship[index].fuelCap;
			result.fuelCur = data.ship[index].fuelCap;
			result.fuelBurnRate = data.ship[index].fuelBurnRate;
			result.fuelEfficiency = data.ship[index].fuelEfficiency;
			result.energyCap = data.ship[index].energyCap;
			result.energyCur = data.ship[index].energyCap;
			result.cargoCap = data.ship[index].cargoCap;
			result.cargoCur = data.ship[index].cargoCap;
			result.baseMass = data.ship[index].baseMass;
			result.modSpace = data.ship[index].modSpace;
			result.calculateMass();
			result.cash = data.ship[index].cash;
			result.cash = (result.cash * Math.random()) + (result.cash / 2); // randomize ship cash by +/- 50%
			return result;
		}
		
		[Embed(source = "../../lib/ship-0000.png")]private var shipSprite0000:Class;
		[Embed(source = "../../lib/ship-0001.png")]private var shipSprite0001:Class;
		
		/**
		 * Pre-update cycle. Currently re-positions the radarDot to match the ship's position, scaled for the radar.
		 */
		override public function preUpdate():void {
			radarDot.x = x / Main.RADAR_ZOOM;
			radarDot.y = y / Main.RADAR_ZOOM;
			while (facingAngle > 2 * Math.PI) {
				facingAngle -= 2 * Math.PI;
			}
			while (facingAngle < 0) {
				facingAngle += 2 * Math.PI;
			}
		}
		
		/**
		 * Standard update cycle.
		 */
		override public function update():void {
			if (playerControlled) {
				
			} else {
				// Call ai stuff here, too.
				clickCheck();
			}
			
			if (FlxG.keys.N) { // Debug keystroke.
				shieldCur -= FlxG.elapsed * 15;
				if (shieldCur < 0) {
					shieldCur = 0;
				}
			}
			//checkCaps();
			calculateMass();
			rechargeShields();
			rechargeEnergy();
			
			if (inHyperspace) {
				hyperSpace();
			}
			frame = int((facingAngle / (Math.PI * 2)) * NUM_FRAMES);
			
			velAngle = Math.atan2(velocity.y, velocity.x); // Need to calculate this every cycle. Used in several places.
			velSpeed = MathE.pythag(velocity.x, velocity.y); // Need to calculate this every cycle too.
			
			if (velAngle < 0) {
				velAngle += 2 * Math.PI;
			}
			
			
			if (Math.abs(velSpeed) > maxSpeed && !inHyperspace) {
				//limits the speed of the ship to maxSpeed.
				velocity.x = Math.cos(velAngle) * maxSpeed;
				velocity.y = Math.sin(velAngle) * maxSpeed;
			}
			
			super.update();
		}
		
		public function hyperSpace():void {
			if (hyperTarget == null) {
				inHyperspace = false;
				return;
			}
			if (energyCur < 100) {
				inHyperspace = false;
				SpaceMessage.push(new SpaceMessage("Insufficient energy to complete hyperjump.", 10, 0xffffff00));
				return;
			}
			var goalFacing:Number = MathE.angleBetweenPoints(Main.spaceScreen.currentSystem.getCenter(), hyperTarget.getCenter());
			if (Math.abs(MathE.turnDifference(facingAngle, goalFacing)) < 0.1) {
				thrust();
				if (velSpeed > maxSpeed * 10) {
					velSpeed = maxSpeed;
					inHyperspace = false;
					hyperTarget = null;
					energyCur -= 100;
					if (playerControlled) {
						Main.spaceScreen.jumpSystems(Main.spaceScreen.currentSystem, Player.p.systemTarget);
					} else {
						this.removeFromScreen();
						if (true) { // not a persistent ship, ie a mission ship
							this.destroy();
						}
						// Handle other ships hypering out here.
					}
				}
			} else {
				turnTowardTarget(goalFacing);
			}
		}
		
		private function checkCaps():void {
			if (shieldCur > shieldCap) {
				shieldCur = shieldCap;
			}
			if (armorCur > armorCap) {
				armorCur = armorCap;
			}
			if (structCur > structCap) {
				structCur = structCap;
			}
			if (energyCur > energyCap) {
				energyCur = energyCap;
			}
			if (fuelCur > fuelCap) {
				fuelCur = fuelCap;
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
					c = Cargo.makeCargo(_id, qty);
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
		
		public function turnTowardTarget(goalAngle:Number):void {
			var turn:Number = MathE.turnDifference(facingAngle, goalAngle);
			if (Math.abs(turn) < rcs * FlxG.elapsed) {
				//facingAngle = goalAngle; // if the amount to turn is less than the ship can turn this frame, just match the goalAngle.
			} else if (turn > 0) {
				turnRight();
			} else {
				turnLeft();
			}
		}
		
		/**
		 * Function for handling when the player clicks on a planet.
		 */
		public function clickCheck():void {
			if(FlxG.mouse.visible) {
				var _point:FlxPoint = new FlxPoint();
				FlxG.mouse.getWorldPosition(Main.spaceScreen.viewPortCam,_point);
				if(overlapsPoint(_point, false, Main.spaceScreen.viewPortCam)) {
					
					// Mouse is over Planet.
					
					if (FlxG.mouse.justPressed()) {
						// Ship clicked.
						Player.p.shipTarget = this;
					}
					
				}
				
			}
		}
		
		/**
		 * Called when the player stops targeting this planet (resets some flags). This should also happen when
		 * the player leaves the system.
		 */
		public function loseFocus():void {
			Main.spaceScreen.selectorLayor.remove(selection, true);
		}
		
		public function getFocus():void {
			selection = new Selection(this);
			Main.spaceScreen.selectorLayor.add(selection);
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
		
		/**
		 * Produces a useful string to identify ships while debugging.
		 * @return Ship's name and ID.
		 */
		override public function toString():String {
			var str:String = "Ship: " + name + " ID: " + ID;
			if (playerControlled) {
				str += " Player Ship!"
			}
			return str;
		}
	}
	
}