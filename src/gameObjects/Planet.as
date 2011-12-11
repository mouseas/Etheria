package gameObjects {
	
	import org.flixel.*;
	import UIScreens.*;
	
	/**
	 * Planets, space stations, shipyards, and other stellar objects. Anything the player might try to land on should be
	 * a Planet or a subclass of Planet.
	 * @author Martin Carney
	 */
	public class Planet extends FlxSprite {
		
		/**
		 * Static counter to keep track of where the parsing of planets is at.
		 */
		public static var _i:int = 0;
		
		/**
		 * How many planets to attempt to load.
		 */
		public static const NUM_PLANETS:int = 2;
		
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
		 * The space system the Planet resides in.
		 */
		public var system:SpaceSystem;
		
		/**
		 * The id of the system to attach this planet to. Used when first assembling the universe.
		 */
		public var preSystem:int;
		
		/**
		 * The planet's number of inhabitants. This grows over time, but gets diminished by various events.
		 * Note that a decimal place results from average growth over time. Whenever displaying the population, this
		 * needs to be cast as an integer.
		 */
		public var population:int; //not used yet
		
		/**
		 * Rate at which the population grows in 1 year's time. Earth's current rate is 1.092 % or 0.01092
		 * High growth should be around 2%, and low growth should be around 0.75%. Negative numbers mean
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
			radarCircle.makeGraphic(4, 4, 0xff00ff00);
			radarCircle.cameras = Main.radar;
			
			name = "New Earth";
			canLand = true;
			inhabited = true;
			reason = "Its environment is too hostile.";
			
			loseFocus(); // Sets some variables to false.
			
		}
		
		override public function update():void {
			super.update();
			radarCircle.x = x / Main.RADAR_ZOOM;
			radarCircle.y = y / Main.RADAR_ZOOM;
			clickCheck();
		}
		
		/**
		 * Whenever the player requests to land at a planet, 
		 */
		public function requestLanding():void {
			if (canLand) {
				if (initialLandingRequest) {
					if (MathE.distance(Main.player.ship.getCenter(), getCenter()) < this.width + Main.player.ship.width) {
						if (Main.player.ship.velSpeed <= Main.player.ship.maxSpeed / 10) {
							// Successful landing here!
							SpaceMessage.push(new SpaceMessage("Landed successfully on " + name + "!"));
							
							Main.spaceScreen.freeze();
							new LandedScreen(this);
							if (inhabited) {
								Main.player.ship.energyCur = Main.player.ship.energyCap;
								Main.player.ship.shieldCur = Main.player.ship.shieldCap;
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
			initialLandingRequest = false;
		}
		
		/**
		 * Function for handling when the player clicks on a planet.
		 */
		public function clickCheck():void {
			if(FlxG.mouse.visible) {
				var _point:FlxPoint = new FlxPoint();
				FlxG.mouse.getWorldPosition(parent.viewPortCam,_point);
				if(overlapsPoint(_point,false,parent.viewPortCam)) {
					
					// Mouse is over Planet.
					
					if (FlxG.mouse.justPressed()) {
						//trace("Clicked on " + name);
						// Planet clicked.
						if (Main.player.planetTarget != null) {
							Main.player.planetTarget.loseFocus();
						}
						Main.player.planetTarget = this;
					}
					
				}
				
			}
		}
		
		/**
		 * Passing in the string array, this will create a Planet from the data starting at startLine.
		 * @param	array The entire array of strings to pull strings from in order to parse them.
		 * @param	startLine Which index in the array to start at.
		 * @return The mostly-finished Planet. Any variables not defined in the planets.txt file for that entry will default
		 * to the values for New Earth, ID 0.
		 */
		public static function parsePlanetFromText(array:Array, startLine:int):Planet {
			var i:int = startLine;
			if (startLine < array.length) {
				//trace(startLine);
				var _ID:uint = StringParser.readInt(array[i++]);
				var result:Planet = new Planet(_ID);
				var str:String = StringParser.readVarName(array[i]);
				while (str.indexOf("ID") != 0 && i < array.length) {
					if (StringParser.readVarName(array[i]).indexOf("spriteImage") > -1) {
						var newImage:String = StringParser.readValue(array[i]);
						//trace("Loading sprite for planet " + result.ID + " named " + newImage);
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
		
		//[Embed(source = "../../lib/planet000.png")]public var planet000:Class;
		[Embed(source = "../../lib/planet001.png")]public var planet001:Class;
		//[Embed(source = "../../lib/planet002.png")]public var planet002:Class;
		
		public function set spriteImage(newImage:Class):void {
			_spriteImage = newImage;
			loadGraphic(_spriteImage);
		}
		public function get spriteImage():Class {
			return _spriteImage;
		}
		
		override public function toString():String {
			return name + " [ID:" + ID + ", System: " + system.name + "]";
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