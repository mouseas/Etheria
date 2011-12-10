package
{
	import org.flixel.*
	import gameObjects.*
	
	/**
	 * This is the main playing screen.
	 * 
	 * @author Martin Carney
	 */
	public class SpaceState extends FlxState {
		
		// ####################### Constants ###################### //
		
		/**
		 * Distance from system center at which a ship my enter hyperspace. This number *1.25 is also the distance at which
		 * they jump into the system.
		 */
		public const STD_JUMP_DISTANCE:Number = 1000;
		
		// ##################### Layers ######################### //
		
		/**
		 * Array of stars displayed on screen.
		 */
		public var starList:FlxGroup;
		
		/**
		 * Layer the planets are displayed in.
		 */
		public var planetLayer:FlxGroup;
		
		/**
		 * Layer the asteroids and debris are displayed in.
		 */
		public var asteroidLayer:FlxGroup;
		
		/**
		 * Layer the ships are displayed in, including the player's ship.
		 */
		public var shipsLayer:FlxGroup;
		
		/**
		 * Layer in which projectiles are displayed.
		 */
		public var projectileLayer:FlxGroup;
		
		/**
		 * Layer messages are displayed in.
		 */
		public var messageLayer:FlxGroup;
		
		/**
		 * Layer the dialog screens are displayed in.
		 */
		public var dialogLayer:FlxGroup;
		
		/**
		 * Layer the map's elements are displayed in - systems and the lines connecting them.
		 */
		public var mapLayer:FlxGroup;
		
		// #############################    ################################## //
		
		/**
		 * set at the first update() cycle; the game's main playing field is initialized and the main menu is opened.
		 */
		public var initialized:Boolean;
		
		/**
		 * Player sprite
		 */
		public var player:Player;
		
		
		
		/**
		 * Array of planets, space stations, and the like for ships to land on.
		 */
		public var planetList:FlxGroup;
		
		/**
		 * Keeps track of whether things are going on in Space. Set to false when dialog boxes and windows are open.
		 */
		public var frozen:Boolean;
		
		/**
		 * screen to display over current playscreen. When null, nothing should be displayed.
		 */
		public var dialogScreen:FlxState;
		
		/**
		 * Which system is currently displayed.
		 */
		public var currentSystem:SpaceSystem;
		
		/**
		 * Camera for the entire screen, used mainly by dialog screens and MainMenuState.
		 */
		public var fullScreenCam:FlxCamera;
		
		/**
		 * Camera for the main viewport.
		 */
		public var viewPortCam:FlxCamera;
		
		/**
		 * Camera for the radar.
		 */
		public var radarCam:FlxCamera;
		
		/**
		 * Camera for the mini-map.
		 */
		public var minimapCam:FlxCamera;
		
		/**
		 * Whether the map is being displayed currently.
		 */
		public var mapOn:Boolean;
		
		/**
		 * Camera for the main map.
		 */
		public var mapCam:FlxCamera;
		
		/**
		 * The HUD.
		 */
		public var hud:HUD;
		// I'm worried that since the HUD just sits off-screen, this is going to cause some conflicts later on.
		// Edit: Turns out with the other cameras, this just works fine.
		
		
		[Embed(source = "data/test.txt", mimeType = "application/octet-stream")]private var textFile:Class;
		
		public function SpaceState() {
			
			Main.spaceScreen = this; // This needs to come first, since other methods may reference the spaceScreen.
			Star.parent = this;
			
			// Create layer FlxGroups
			
			starList = new FlxGroup();
			planetLayer = new FlxGroup();
			asteroidLayer = new FlxGroup();
			shipsLayer = new FlxGroup();
			projectileLayer = new FlxGroup();
			messageLayer = new FlxGroup();
			dialogLayer = new FlxGroup();
			
			// Set up the cameras.
			
			viewPortCam = new FlxCamera(0, 0, FlxG.width - HUD.HUD_WIDTH, FlxG.height, 1);
			Main.viewport = new Array(viewPortCam);
			
			radarCam = new FlxCamera(FlxG.width - HUD.HUD_WIDTH + 10, 10, 111, 111, 1); //width and height need to be odd numbers or objects will jitter.
			Main.radar = new Array(radarCam);
			
			minimapCam = new FlxCamera(FlxG.width - HUD.HUD_WIDTH - 125, 0, 125, 125, 1);
			mapCam = new FlxCamera(25, 25, viewPortCam.width - 25, FlxG.height - 25, 1);
			Main.map = new Array(minimapCam, mapCam);
			
			// Prep the static parts of the universe.
			
			Main.initMissionFlags();
			Main.generateProtoships();
			Main.generateSystems();
			Main.generatePlanets();
			
			
		}
		
		/**
		 * Called when the game first starts up. Starts the MainMenuState.
		 */
		override public function create():void {
			
			add(dialogLayer);
			var startMenu:MainMenuState = new MainMenuState();
			startMenu.create();
			dialogLayer.add(startMenu);
			
			mapOn = false;
			
			initialized = false;
			
			
		}
		
		/**
		 * What would normally be in the create() method; this actually puts the playing field together before starting play.
		 */
		public function initPlayingField():void {
			
			//Temp code to test importing information from text files.
			/*var fileContent:String = new textFile();
			var result:Array = fileContent.split('\n');
			for (var i:int = 0; i < result.length; i++) {
				trace(i + " " + result[i]);
			}*/
			
			Main.player = new Player(this);
			player = Main.player;
			
			frozen = false;
			if (dialogScreen != null) {
				dialogScreen.destroy();
			}
			dialogScreen = null;
			
			FlxG.addCamera(viewPortCam);
			FlxG.addCamera(radarCam);
			
			// Layers
			starList = new FlxGroup();
			starList.cameras = Main.viewport;
			add(starList);
			
			planetList = new FlxGroup();
			add(planetList);
			
			add(Main.allSystems);
			
			add(SpaceMessage.messageLog);
			
			
			//Initialize Player (later to be the Player's ship).
			
			player.ship.x = (Math.random() * 500) - 250;
			player.ship.y = (Math.random() * 500) - 250;
			add(player);
			add(player.ship);
			viewPortCam.follow(player.ship);
			viewPortCam.update(); // This makes the camera move to cover the player so stars are generated on-screen.
			
			
			hud = new HUD();
			hud.create();
			add(hud);
			
			initialized = true;
		}
		
		/**
		 * Standard update cycle for the State.
		 */
		override public function update():void {
			
			super.update();
			if (initialized) {
				Star.checkStarsOnScreen();
				SpaceMessage.updateDisplayedMessages();
				
				if (FlxG.keys.justPressed("P")) {
					if(dialogScreen == null && !mapOn) {
						if (frozen) {
							unfreeze();
						} else {
							freeze();
						}
					}
				}
				if (FlxG.keys.justPressed("Z")) {
					Star.resetStars();
				}
				
				if (FlxG.keys.justPressed("M")) {
					if (mapOn) {
						mapOn = false;
						unfreeze();
						FlxG.removeCamera(mapCam, false);
					} else {
						mapOn = true;
						freeze();
						FlxG.addCamera(mapCam);
					}
				}
				
				if (FlxG.keys.justPressed("SLASH")) {
					if (FlxG.timeScale > 1) {
						FlxG.timeScale = 1;
					} else {
						FlxG.timeScale = 2;
					}
				}
			}
		}
		
		/**
		 * Clears connections to the current system's items, then adds the new system's items.
		 * @param	s System to load.
		 */
		public function loadSystem(s:SpaceSystem):void {
			for (var i:int = 0; i < planetList.length; i++) {
				var p:Planet = planetList.members[i];
				if (p != null) {
					//trace("Removing radar object for " + p.name);
					remove(p.radarCircle, true);
				}
				p = null;
			}
			currentSystem = s;
			replace(planetList, currentSystem.planetList); // replaces it in the display position (draw order)
			planetList = currentSystem.planetList; // replaces the object reference
			for (i = 0; i < planetList.length; i++) {
				p = planetList.members[i];
				if (p != null) {
					//trace("Adding radar object for " + p.name);
					add(p.radarCircle);
				}
				p = null;
			}
			var scroll:FlxPoint = currentSystem.getCenter();
			scroll.x -= mapCam.width / 2;
			scroll.y -= mapCam.height / 2;
			mapCam.scroll = scroll;
			scroll = currentSystem.getCenter();
			scroll.x -= minimapCam.width / 2;
			scroll.y -= minimapCam.height / 2;
			minimapCam.scroll = scroll;
			scroll = null;
			
			player.forgetTargetPlanet();
			player.shipTarget = null;
			
			Star.resetStars();
			
			// generate and load any ships in the system.
		}
		
		/**
		 * Called when the player jumps into the system from another system.
		 * @param	from Which system the player is leaving. Used to calculate angle, position, and speed.
		 * @param	to Which system the player is entering. Used to calculate angle, position, and speed, and
		 * is loaded into the scene.
		 */
		public function jumpSystems(from:SpaceSystem, to:SpaceSystem):void {
			//calculate the position to move the player.ship to, then move them there.
			//calculate the velocity the player.ship needs to be moving at, and set
			loadSystem(to);
		}
		
		/**
		 * Called when the player takes off from a planet (or when the game is loaded, based on
		 * the planet they saved on).
		 * @param	from The Planet they're leaving
		 * @param	to The system they're entering. This should be the Planet's sytem in normal cases.
		 */
		public function takeOff(from:Planet, to:SpaceSystem):void {
			var _x:Number = from.getCenter().x - (player.ship.width / 2);
			var _y:Number = from.getCenter().y - (player.ship.height / 2);
			player.ship.x = _x;
			player.ship.y = _y;
			player.ship.velocity.x = 0;
			player.ship.velocity.y = 0;
			player.ship.facingAngle = Math.random() * 2 * Math.PI;
			loadSystem(to);
			SpaceMessage.push(new SpaceMessage("Taking off from " + from.name + " on [date]."));
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/**
		 * Pauses everything going on in space. Used whenever opening a dialog.
		 */
		public function freeze():void {
			if(initialized) {
				frozen = true;
				player.ship.active = !frozen;
				starList.active = !frozen;
				planetList.active = !frozen;
			}
		}
		
		/**
		 * Unpauses everything going on in space. Used whenever closing a dialog.
		 */
		public function unfreeze():void {
			if(initialized && dialogLayer.length < 1) {
				frozen = false;
				player.ship.active = !frozen;
				starList.active = !frozen;
				planetList.active = !frozen;
			}
		}
		
		/**
		 * nulls out variables specific to Planets, then calls destroy() from the super class.
		 */
		override public function destroy():void {
			player = null;
			starList.destroy();
			starList = null;
			planetList = null;
			
			// Call this last.
			super.destroy();
		}
	}
	
}