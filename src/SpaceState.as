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
		
		
		/**
		 * Number of stars to display on the screen at any given time.
		 */
		private const NUM_STARS:int = 50;
		
		/**
		 * Distance from system center at which a ship my enter hyperspace. This number *1.25 is also the distance at which
		 * they jump into the system.
		 */
		public const STD_JUMP_DISTANCE:Number = 1000;
		
		/**
		 * set at the first update() cycle; the game's main playing field is initialized and the main menu is opened.
		 */
		public var initialized:Boolean;
		
		/**
		 * Player sprite
		 */
		public var player:Player;
		
		/**
		 * Array of stars displayed on screen.
		 */
		public var starList:FlxGroup;
		
		/**
		 * Array of planets, space stations, and the like for ships to land on.
		 */
		public var planetList:FlxGroup;
		
		/**
		 * Backlog of messages displayed during gameplay.
		 */
		public var messageLog:FlxGroup;
		
		/**
		 * Bottom-most line of in-game message text, the most recent item.
		 */
		public var message1:FlxText;
		
		/**
		 * Bottom-most line of in-game message text, the second-most recent item.
		 */
		public var message2:FlxText;
		
		/**
		 * Bottom-most line of in-game message text, the oldest of the three messages.
		 */
		public var message3:FlxText;
		
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
		
		/**
		 * Called when the game first starts up. Creates all the global variable holders
		 */
		override public function create():void {
			
			// ############# Initialize Global Stuff ############
			Main.spaceScreen = this; // This needs to come first, since other methods may reference the spaceScreen.
			
			viewPortCam = new FlxCamera(0, 0, FlxG.width - HUD.HUD_WIDTH, FlxG.height, 1);
			Main.viewport = new Array(viewPortCam);
			radarCam = new FlxCamera(FlxG.width - HUD.HUD_WIDTH + 10, 10, 111, 111, 1); //width and height need to be odd numbers or objects will jitter.
			Main.radar = new Array(radarCam);
			minimapCam = new FlxCamera(FlxG.width - HUD.HUD_WIDTH - 125, 0, 125, 125, 1);
			mapCam = new FlxCamera(25, 25, viewPortCam.width - 25, FlxG.height - 25, 1);
			Main.map = new Array(minimapCam, mapCam);
			
			
			
			Main.messageLog = new FlxGroup();
			Main.initMissionFlags();
			Main.generateProtoships();
			Main.generateSystems();
			Main.generatePlanets();
			
			
			
			dialogScreen = new MainMenuState();
			dialogScreen.create();
			add(dialogScreen);
			
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
			
			messageLog = Main.messageLog;
			add(messageLog);
			message1 = new FlxText(15, FlxG.height - 25, FlxG.width - 30, "");
			message1.scrollFactor = new FlxPoint(0, 0);
			add(message1);
			message2 = new FlxText(15, FlxG.height - 40, FlxG.width - 30, "");
			message2.scrollFactor = new FlxPoint(0, 0);
			add(message2);
			message3 = new FlxText(15, FlxG.height - 55, FlxG.width - 30, "");
			message3.scrollFactor = new FlxPoint(0, 0);
			add(message3);
			
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
				checkStarsOnScreen();
				updateDisplayedMessages();
				
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
					resetStars();
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
		 * Checks for off-screen stars, then replaces them with new ones depending on the player's direction and the star's position.
		 */
		private function checkStarsOnScreen():void {
			for (var i:int = 0; i < starList.length; i++) {
				var star:Star = starList.members[i];
				if (star != null && !star.onScreen(viewPortCam)) {
					var point:FlxPoint = star.getScreenXY(null,viewPortCam);
					//star.kill();
					
					if (player.ship.velocity.x > 0 && point.x < 0) {
						star = spawnStarRight();
					} else if (player.ship.velocity.x < 0 && point.x > viewPortCam.width) {
						star = spawnStarLeft();
					} else if (player.ship.velocity.y > 0 && point.y < 0) {
						star = spawnStarBottom();
					} else if (player.ship.velocity.y < 0 && point.y > viewPortCam.height) {
						star = spawnStarTop();
					}
					starList.members[i] = star;
					point = null;
				}
				
			}
		}
		
		/**
		 * Generates a star along the top of the screen.
		 * @return The star generated.
		 */
		private function spawnStarTop():Star {
			var star:Star = new Star(0, 0);
			star.x = (viewPortCam.scroll.x * star.scrollFactor.x) + (Math.random() * viewPortCam.width);
			star.y = (viewPortCam.scroll.y) * star.scrollFactor.y;
			return star;
		}
		/**
		 * Generates a star along the left of the screen.
		 * @return The star generated.
		 */
		private function spawnStarLeft():Star {
			var star:Star = new Star(0, 0);
			star.x = (viewPortCam.scroll.x) * star.scrollFactor.x;
			star.y = (viewPortCam.scroll.y * star.scrollFactor.y) + (Math.random() * viewPortCam.height);
			return star;
		}
		/**
		 * Generates a star along the bottom of the screen.
		 * @return The star generated.
		 */
		private function spawnStarBottom():Star {
			var star:Star = new Star(0, 0);
			star.x = (viewPortCam.scroll.x * star.scrollFactor.x) + (Math.random() * viewPortCam.width) ;
			star.y = (viewPortCam.scroll.y * star.scrollFactor.y) + viewPortCam.height;
			return star;
		}
		/**
		 * Generates a star along the right of the screen.
		 * @return The star generated.
		 */
		private function spawnStarRight():Star {
			var star:Star = new Star(0, 0);
			star.x = (viewPortCam.scroll.x * star.scrollFactor.x) + viewPortCam.width;
			star.y = (viewPortCam.scroll.y * star.scrollFactor.y) + (Math.random() * viewPortCam.height);
			return star;
		}
		
		/**
		 * Internal function used to reset the star field whenever the player takes off or changes systems.
		 */
		private function resetStars():void {
			if (starList == null) {
				starList = new FlxGroup();
				trace("new starList");
			}
			while (starList.length > 0) { // Clear out any existing stars first
				//trace(starList.length);
				starList.remove(starList.members[0], true);
			}
			for (var i:int = 0; i < NUM_STARS; i++) { // Then create NUM_STARS new stars on the visible screen.
				var star:Star = new Star(0, 0);
				star.x = (viewPortCam.scroll.x * star.scrollFactor.x) + (Math.random() * viewPortCam.width);
				star.y = (viewPortCam.scroll.y * star.scrollFactor.y) + (Math.random() * viewPortCam.height);
				starList.add(star);
			}
		}
		
		/**
		 * Called every update, this function deals with the updated messages - mostly making them fade when their lifespan is up.
		 */
		private function updateDisplayedMessages():void {
			var numMessages:int = messageLog.length;
			if (numMessages > 2) {
				var m3:SpaceMessage = messageLog.members[numMessages - 3]
				if (m3.getLife() <= 0 && message3.alpha > 0) {
					message3.alpha -= FlxG.elapsed;
				}
			}
			if (numMessages > 1) {
				var m2:SpaceMessage = messageLog.members[numMessages - 2]
				if (m2.getLife() <= 0 && message2.alpha > 0) {
					message2.alpha -= FlxG.elapsed;
				}
			}
			if (numMessages > 0) {
				var m1:SpaceMessage = messageLog.members[numMessages - 1]
				if (m1.getLife() <= 0 && message1.alpha > 0) {
					message1.alpha -= FlxG.elapsed;
				}
			}
		}
		
		/**
		 * Puts a new message on the screen, bumps old messages up the line, and adds the message to the backlog.
		 * @param	message
		 */
		public function newMessage(message:SpaceMessage):void {
			messageLog.add(message);
			message3.text = message2.text;
			message3.color = message2.color;
			message3.alpha = message2.alpha;
			message2.text = message1.text;
			message2.color = message1.color;
			message2.alpha = message1.alpha;
			message1.alpha = 1;
			message1.text = message.getString();
			message1.color = message.getColor();
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
			
			resetStars();
			
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
			newMessage(new SpaceMessage("Taking off from " + from.name + " on [date]."));
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
			if(initialized) {
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
			messageLog = null;
			message1.destroy();
			message1 = null;
			message2.destroy();
			message2 = null;
			message3.destroy();
			message3 = null;
			
			// Call this last.
			super.destroy();
		}
	}
	
}