package gameObjects {
	
	import org.flixel.*;
	import UIScreens.*;
	import flash.utils.ByteArray;
	
	/**
	 * Planets, space stations, shipyards, and other stellar objects. Anything the player might try to land on should be
	 * a Planet or a subclass of Planet.
	 * @author Martin Carney
	 */
	public class Planet extends FlxSprite {
		
		/**
		 * Holds all the Planets in existence. Globally available.
		 */
		public static var allPlanets:FlxGroup;
		
		/**
		 * Core XML data for the planets to be generated from.
		 */
		private static var data:XML;
		
		[Embed(source = "../data/planets.xml", mimeType = "application/octet-stream")]public static var planetXMLFile:Class;
		
		// ################# Flags ###################
		
		/**
		 * Can the player land on this stellar object?
		 */
		public var canLand:Boolean;
		
		/**
		 * Is the planet or station inhabited? Inhabited planets can refuel ships and can be hailed. Most other features
		 * require this boolean to be true.
		 */
		public var inhabited:Boolean;
		
		/**
		 * Initial landing request has been made.
		 */
		public var initialLandingRequest:Boolean;
		
		// ################ Graphics ###################
		
		/**
		 * Graphic used by the planet as its static sprite.
		 */
		public var _spriteImage:Class;
		
		/**
		 * Image of the planet's surface, used on the landing screen.
		 */
		public var _planetLandView:Class;
		
		/**
		 * Image with each size of planet for the radar.
		 */
		[Embed(source = "../../lib/planet-radar.png")]public var radarImage:Class;
		
		/**
		 * Selection markers around this object.
		 */
		public var selection:Selection;
		
		// ############### Variables #################
		
		/**
		 * Screen the planet is displayed on.
		 */
		public var parent:SpaceState;
		
		/**
		 * Planet's name.
		 */
		public var name:String;
		
		/**
		 * Graphic used to display the planet on the radar.
		 */
		public var radarCircle:FlxSprite;
		
		/**
		 * String describing why the player cannot land on an unlandable planet.
		 */
		public var reason:String;
		
		/**
		 * Which cargoes the Planet trades in.
		 */
		public var cargos:Array;
		
		/**
		 * How much of each cargo the Planet has in store.
		 */
		public var cargosQty:Array;
		
		/**
		 * Which price to use; 0 for Low, 1 for Med, and 2 for High.
		 */
		public var cargosPrice:Array;
		
		/**
		 * The space system the Planet resides in.
		 */
		public function get system():SpaceSystem {
			return _system;
		}
		public function set system(sys:SpaceSystem):void {
			if (_system != null) {
				_system.planetList.remove(this, true);
			}
			sys.addPlanet(this);
			_system = sys;
			//trace(_system);
		}
		private var _system:SpaceSystem;
		
		/**
		 * The planet's number of inhabitants. This grows over time, but gets diminished by various events.
		 * Note that a decimal place results from average growth over time. Whenever displaying the population, this
		 * needs to be cast as an integer.
		 */
		public var population:int; //not used yet
		
		/**
		 * The decimal growth of the planet's population. Used to allow for growth of small populations over time ( <1 birth/day)
		 */
		public var popPartial:Number;
		
		/**
		 * Rate at which the population grows in 1 year's time. Earth's current rate is 1.092 % or 0.01092
		 * High growth should be around 2% (0.02), and low growth should be around 0.75% (0.075). Negative numbers mean
		 * more deaths than births - population decline.
		 * Remember when calculating population change to scale it to the amount of time passed - this rate is one year!
		 */
		public var popGrowthRate:Number; //not used yet
		
		// ############### Functions #################
		
		/**
		 * Constructor method.
		 * @param _id The ID number to make the Planet.
		 */
		public function Planet(_id:int) {
			super(50, 50);
			
			parent = Main.spaceScreen;
			
			ID = _id;
			cameras = Main.viewport;
			
			radarCircle = new FlxSprite(x / Main.RADAR_ZOOM, y / Main.RADAR_ZOOM);
			radarCircle.loadGraphic(radarImage, true);
			radarCircle.cameras = Main.radar;
			
			name = "New Earth";
			canLand = true;
			inhabited = true;
			reason = "Its environment is too hostile.";
			
			cargos = new Array();
			cargosQty = new Array();
			cargosPrice = new Array();
			
			loseFocus(); // Sets some variables to false.
			
		}
		
		public static function generatePlanets():void {
			trace("Generating Planets.");
			if (allPlanets != null) {
				trace ("Clearing existing planets from existence!");
				allPlanets.destroy();
			}
			if (data == null) {
				trace("Generating Planets...loading XML.");
				var file:ByteArray = new planetXMLFile;
				var str:String = file.readUTFBytes(file.length);
				data = new XML(str);
			}
			allPlanets = new FlxGroup();
			trace("Generating Planets...creating " + data.planet.length() + " planets.");
			for (var i:int = 0; i < data.planet.length(); i++) {
				var result:Planet = new Planet(i);
				if (i != data.planet[i].@id) {
					trace ("WARNING: Planet ID does not match position. i:" + i + "  @id:" + data.planet[i].@id);
				}
				result.name = data.planet[i].name
				result.x = data.planet[i].x;
				result.y = data.planet[i].y;
				result.canLand = data.planet[i].canLand == "true";
				result.inhabited = data.planet[i].inhabited == "true";
				if (data.planet[i].reason != undefined) { result.reason = data.planet[i].reason; }
				result.population = data.planet[i].population;
				result.popGrowthRate = data.planet[i].popGrowthRate;
				result.system = SpaceSystem.allSystems.members[data.planet[i].system];
				result.spriteImage = result[data.planet[i].spriteImage];
				allPlanets.add(result);
				for (var j:int = 0; j < data.planet[i].cargo.length(); j++) {
					result.cargos.push(data.planet[i].cargo[j].type);
					result.cargosQty.push(data.planet[i].cargo[j].qty);
					result.cargosPrice.push(data.planet[i].cargo[j].price);
				}
			}
			
			trace("Generating Planets...done!");
		}
		
		/**
		 * Standard update cycle.
		 */
		override public function update():void {
			super.update();
			
			// Keep the radarCircle to the scaled position of the planet (in case the planet ever moves).
			radarCircle.x = ((x + (width / 2)) / Main.RADAR_ZOOM) - (radarCircle.width / 2);
			radarCircle.y = ((y + (height / 2)) / Main.RADAR_ZOOM) - (radarCircle.height / 2);
			
			// Check to see if the player has clicked on this planet.
			clickCheck();
		}
		
		/**
		 * Whenever the player requests to land at a planet, 
		 */
		public function requestLanding():void {
			if (canLand) {
				if (initialLandingRequest || !inhabited) {
					if (MathE.distance(Player.p.ship.getCenter(), getCenter()) < this.width + Player.p.ship.width) {
						if (Player.p.ship.velSpeed <= Player.p.ship.maxSpeed / 10) {
							// Successful landing here!
							SpaceMessage.push(new SpaceMessage("Landed successfully on " + name + "!"));
							
							Main.spaceScreen.freeze();
							new LandedScreen(this);
							if (inhabited) {
								Player.p.ship.energyCur = Player.p.ship.energyCap;
								Player.p.ship.shieldCur = Player.p.ship.shieldCap;
							}
							
						} else {
							SpaceMessage.push(new SpaceMessage("You are moving too fast to land on " + name + ".", 10, 0xffff9900));
						}
					} else {
						SpaceMessage.push(new SpaceMessage("You too far away to land on " + name + ".", 10, 0xffff9900));
					}
				} else {
					SpaceMessage.push(new SpaceMessage("Initial request to land on " + name + " has been received.", 4));
					initialLandingRequest = true;
				}
			} else {
				SpaceMessage.push(new SpaceMessage("Cannot land on " + name + ". " + reason, 10, 0xffff9900));
			}
		}
		
		/**
		 * Called when the player stops targeting this planet (resets some flags). This should also happen when
		 * the player leaves the system.
		 */
		public function loseFocus():void {
			Main.spaceScreen.selectorLayor.remove(selection, true);
			initialLandingRequest = false;
		}
		
		public function getFocus():void {
			selection = new Selection(this);
			if (inhabited) {
				if (true) { // friendly
					selection.color = 0xFFFFFF00;
				} else { // enemy
					selection.color = 0xFFFF0000;
				}
			} else { // uninhabited
				if (canLand) {
					selection.color = 0xFF0000FF;
				} else { // cannot land
					selection.color = 0xFFBBBBBB;
				}
			}
			Main.spaceScreen.selectorLayor.add(selection);
		}
		
		/**
		 * Function for handling when the player clicks on a planet.
		 */
		public function clickCheck():void {
			if(FlxG.mouse.visible && FlxG.mouse.justPressed()) {
				var _point:FlxPoint = new FlxPoint();
				FlxG.mouse.getWorldPosition(parent.viewPortCam,_point);
				if(overlapsPoint(_point, false, parent.viewPortCam)) {
					
					if (Player.p.planetTarget != null) {
						Player.p.planetTarget.loseFocus();
					}
					Player.p.planetTarget = this;
					
				}
				
			}
		}
		
		[Embed(source = "../../lib/planet000.png")]public var planet000:Class;
		[Embed(source = "../../lib/planet001.png")]public var planet001:Class;
		[Embed(source = "../../lib/planet002.png")]public var planet002:Class;
		
		/**
		 * Sets and loads the sprite, and makes the radarCircle match the size of the new sprite.
		 */
		public function set spriteImage(newImage:Class):void {
			_spriteImage = newImage;
			loadGraphic(_spriteImage);
			var size:int = (int)(width / Main.RADAR_ZOOM);
			if (size < 2) {
				radarCircle.frame = 5;
			} else if (size == 2) {
				radarCircle.frame = 4;
			} else if (size == 3) {
				radarCircle.frame = 3;
			} else if (size == 4) {
				radarCircle.frame = 2;
			} else if (size == 5) {
				radarCircle.frame = 1;
			} else {
				radarCircle.frame = 0;
			}
		}
		
		/**
		 * Gets the sprite image.
		 */
		public function get spriteImage():Class {
			return _spriteImage;
		}
		
		/**
		 * Outputs a useful string for identifying the System when debugging.
		 * @return String with basic identifying info about the System.
		 */
		override public function toString():String {
			return name + " [ID:" + ID + ", System: " + system.name + "]";
		}
		
		/**
		 * Grows a population whenever time passes
		 * @param	days Number of days that have passed.
		 */
		public function updatePopulation(days:int):void {
			var growth:Number = days * (popGrowthRate / 365) * population;
			population = (int)(growth);
			popPartial += growth - (int)(growth);
			while (popPartial > 1) {
				popPartial--;
				population++;
			}
			
		}
		
		
		
		
		/**
		 * nulls out variables specific to Planets, then calls destroy() from FlxSprite.
		 */
		override public function destroy():void {
			spriteImage = null;
			_planetLandView = null;
			parent = null;
			
			// Call this last.
			super.destroy();
		}
	}
	
}