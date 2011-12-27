package
{
	import org.flixel.*;
	import gameObjects.*;
	import UIScreens.*;
	
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
		public var starLayer:FlxGroup;
		
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
		 * Superlayer with all the layers of the playing field. Used to freeze / unfreeze game action.
		 */
		public var playingField:FlxGroup;
		
		/**
		 * Layer that radar objects are displayed in.
		 */
		public var radarLayer:FlxGroup;
		
		/**
		 * Layer the dialog screens are displayed in.
		 */
		public var dialogLayer:FlxGroup;
		
		/**
		 * Layer the map's elements are displayed in - systems and the lines connecting them.
		 */
		public var mapLayer:FlxGroup;
		
		/**
		 * Layer the Selectors appear on.
		 */
		public var selectorLayor:FlxGroup;
		
		// #############################    ################################## //
		
		/**
		 * set at the first update() cycle; the game's main playing field is initialized and the main menu is opened.
		 */
		public var initialized:Boolean = false;
		
		/**
		 * Player sprite
		 */
		public var player:Player;
		
		/**
		 * What day, month, and year it is in-game.
		 */
		public var date:Date;
		
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
		public var dialogScreen:FlxGroup;
		
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
			starLayer = new FlxGroup();
			planetLayer = new FlxGroup();
			asteroidLayer = new FlxGroup();
			shipsLayer = new FlxGroup();
			projectileLayer = new FlxGroup();
			playingField = new FlxGroup();
			messageLayer = new FlxGroup();
			radarLayer = new FlxGroup();
			dialogLayer = new FlxGroup();
			mapLayer = new FlxGroup();
			selectorLayor = new FlxGroup();
			
			// Set up the cameras.
			
			viewPortCam = new FlxCamera(0, 0, FlxG.width - HUD.HUD_WIDTH, FlxG.height, 1);
			Main.viewport = new Array(viewPortCam);
			
			radarCam = new FlxCamera(FlxG.width - HUD.HUD_WIDTH + 10, 10, 111, 111, 1); //width and height need to be odd numbers or objects will jitter.
			Main.radar = new Array(radarCam);
			
			minimapCam = new FlxCamera(FlxG.width - HUD.HUD_WIDTH - 125, 0, 125, 125, 1);
			mapCam = new FlxCamera(142, 136, 336, 336, 1);
			Main.map = new Array(minimapCam, mapCam);
			
			fullScreenCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
			Main.fullScreen = new Array(fullScreenCam);
			
			// Prep the static parts of the universe.
			
			Main.initMissionFlags();
			
			SpaceSystem.generateSystems();
			Planet.generatePlanets();
			
			
		}
		
		/**
		 * Called when the game first starts up. Starts the MainMenuState.
		 */
		override public function create():void {
			
			//Layers
			add(playingField);
			playingField.add(starLayer);
			playingField.add(planetLayer);
			playingField.add(asteroidLayer);
			playingField.add(shipsLayer);
			playingField.add(projectileLayer);
			playingField.add(selectorLayor);
			playingField.add(radarLayer);
			add(messageLayer);
			add(dialogLayer);
			add(mapLayer);
			
			//Prep MainMenuState
			var startMenu:MainMenuState = new MainMenuState();
			startMenu.create();
			dialogLayer.add(startMenu);
			
			mapOn = false; // Might want to just get rid of this once dialog boxes are properly implemented.
			
		}
		
		/**
		 * What would normally be in the create() method in other Flixel games; this actually puts the playing 
		 * field together before starting play.
		 */
		public function initPlayingField():void {
			
			Main.player = player = new Player(this);
			date = new Date(2142, 7, 22);
			
			
			frozen = false;
			
			/*if (dialogScreen != null) {
				dialogScreen.destroy();
			}
			dialogScreen = null;*/
			
			FlxG.addCamera(fullScreenCam);
			FlxG.addCamera(viewPortCam);
			FlxG.addCamera(radarCam);
			
			planetList = new FlxGroup();
			planetLayer.add(planetList);
			
			add(SpaceMessage.messageLog);
			
			
			//Initialize the Player and their ship).
			
			player.ship.x = (Math.random() * 500) - 250;
			player.ship.y = (Math.random() * 500) - 250;
			add(player);
			player.ship.addToScreen();
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
				if (!frozen) {
					if (FlxG.keys.justPressed("Z")) {
						if (currentSystem == SpaceSystem.allSystems.members[0]) {
							loadSystem(SpaceSystem.allSystems.members[1]);
						} else {
							loadSystem(SpaceSystem.allSystems.members[0]);
						}
					}
					if (FlxG.keys.justPressed("BACKSLASH")) {
						new UIScreen();
					}
					
					if (FlxG.keys.justPressed("M")) {
						new mapScreen();
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
		}
		
		/**
		 * Clears connections to the current system's items, then adds the new system's items.
		 * @param	s System to load.
		 */
		public function loadSystem(s:SpaceSystem):void {
			date.date++;
			
			//pull radar objects from screen.
			for (var i:int = 0; i < planetList.length; i++) {
				var p:Planet = planetList.members[i];
				if (p != null) {
					//trace("Removing radar object for " + p.name);
					radarLayer.remove(p.radarCircle, true);
				}
				p = null;
			}
			while (shipsLayer.length > 0) {
				var oldSysShip:Ship = shipsLayer.members[0];
				oldSysShip.removeFromScreen();
			}
			player.ship.addToScreen();
			
			currentSystem = s;
			planetLayer.replace(planetList, currentSystem.planetList); // replaces it in the display position (draw order)
			planetList = currentSystem.planetList; // replaces the object reference
			
			// add radar objects to screen
			for (i = 0; i < planetList.length; i++) {
				p = planetList.members[i];
				if (p != null) {
					//trace("Adding radar object for " + p.name);
					radarLayer.add(p.radarCircle);
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
			
			player.planetTarget = null;
			player.shipTarget = null;
			
			Star.resetStars();
			
			var newShip:Ship = Ship.cloneShip(0);
			newShip.x = Math.random() * 200;
			newShip.y = Math.random() * 200;
			newShip.addToScreen();
			trace(newShip);
			
			newShip = Ship.cloneShip(1);
			newShip.x = Math.random() * 200;
			newShip.y = Math.random() * 200;
			newShip.addToScreen();
			trace(newShip);
			
			newShip = Ship.cloneShip(2);
			newShip.x = Math.random() * 200;
			newShip.y = Math.random() * 200;
			newShip.addToScreen();
			trace(newShip);
			
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
		 * @param	to The system they're entering. This should be the Planet's system in normal cases.
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
			SpaceMessage.push(new SpaceMessage("Taking off from " + from.name + " on " + date + "."));
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/**
		 * Pauses everything going on in space. Used whenever opening a dialog.
		 */
		public function freeze():void {
			if(initialized) {
				frozen = true;
				player.ship.active = !frozen;
				playingField.active = !frozen;
			}
		}
		
		/**
		 * Unpauses everything going on in space. Used whenever closing a dialog.
		 */
		public function unfreeze():void {
			if(initialized && dialogLayer.length < 1) {
				frozen = false;
				player.ship.active = !frozen;
				playingField.active = !frozen;
			}
		}
		
	}
	
}