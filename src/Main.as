package {
	
	import gameObjects.*;
	import org.flixel.*;
	[SWF(width = "850", height = "640", backgroundColor = "#000000")]
	

	/**
	 * Etheria is a space trading and combat game inspired by the Escape Velocity series of games.
	 * @author Martin Carney
	 */
	public class Main extends FlxGame
	{
		/**
		 * The number of mission flags available for use. Every time a game is saved, all the flags need to be read
		 * and saved into the game's data. Whenever a game is loaded, all flags need to be reset to false and then read
		 * from the save file.
		 */
		public static const NUM_MISSION_FLAGS:int = 1000;
		
		public static var NO_SCROLL:FlxPoint = new FlxPoint(0, 0);
		
		/**
		 * The scale to zoom out the radar from the main playfield.
		 */
		public static const RADAR_ZOOM:Number = 25;
		
		/**
		 * The player object, held globally so it can be accessed anywhere in the program.
		 */
		public static var player:Player;
		
		/**
		 * Globally-held reference to the SpaceState.
		 */
		public static var spaceScreen:SpaceState;
		
		/**
		 * Globally-held reference to the message backlog. Should be wiped when loading save games, and maybe saved with
		 * save games.
		 */
		public static var messageLog:FlxGroup;
		
		/**
		 * Holds all the systems in existence. Globally available.
		 */
		public static var allSystems:FlxGroup;
		
		/**
		 * Holds all the Planets in existence. Globally available.
		 */
		public static var allPlanets:FlxGroup;
		
		/**
		 * Array of booleans to keep track of mission string progress, technology advances, etc. Before loading
		 * any flags, all cells in this array are set to false.
		 */
		public static var missionFlags:Array;
		
		/**
		 * Holds the library of ships that can be generated.
		 */
		public static var protoships:FlxGroup;
		
		/**
		 * Array holding the camera used by the radar.
		 */
		public static var radar:Array;
		
		/**
		 * Array holding the camera used by the main playing field view.
		 */
		public static var viewport:Array;
		
		/**
		 * Array holding the camera used by the map of all the solar systems.
		 */
		public static var map:Array;
		
		
		
		/**
		 * Constructor for the main game class.
		 */
		public function Main()
		{
			super(850, 640, SpaceState, 1);
		}
		
		
		
		
		/**
		 * Loads the embedded file ships.txt and parses its values into Protoships.
		 */
		public static function generateProtoships():void {
			trace("Generating Protoships.");
			var fileContent:String = new shipTypeDataFile();
			shipDataStrings = fileContent.split('\n');
			
			if (protoships != null) {
				protoships.destroy();
				protoships = null;
			}
			protoships = new FlxGroup();
			for (var i:uint = 0; i < Protoship.NUM_SHIP_TYPES; i++) {
				protoships.add(Protoship.parseShipFromText(shipDataStrings,Protoship._i));
			}
			trace("Generating Protoships...Done. Total: " + protoships.length);
		}
		
		/**
		 * Loads the embedded file systems.txt and parses its values into SpaceSystems.
		 */
		public static function generateSystems():void {
			trace("Generating Systems.");
			var fileContent:String = new spaceSystemDataFile();
			spaceSystemDataStrings = fileContent.split('\n');
			fileContent = null;
			
			if (allSystems != null) {
				allSystems.destroy();
				allSystems = null;
			}
			allSystems = new FlxGroup();
			for (var i:uint = 0; i < SpaceSystem.NUM_SYSTEMS; i++) {
				allSystems.add(SpaceSystem.parseSystemFromText(spaceSystemDataStrings, SpaceSystem._i));
			}
			trace("Generating Systems...Making Connections.");
			
			//Add code to make connections between systems.
			
			trace("Generating Systems...Done. Total: " + allSystems.length);
		}
		
		/**
		 * Loads the embedded file planets.txt and parses its values into Planets.
		 */
		public static function generatePlanets():void {
			trace("Generating Planets.");
			var fileContent:String = new planetDataFile();
			planetDataStrings = fileContent.split('\n');
			fileContent = null;
			
			if (allPlanets != null) {
				allPlanets.destroy();
				allPlanets = null;
			}
			allPlanets = new FlxGroup();
			for (var i:uint = 0; i < Planet.NUM_PLANETS; i++) {
				allPlanets.add(Planet.parsePlanetFromText(planetDataStrings,Planet._i));
			}
			trace("Generating Planets...Assigning to Systems.");
			
			for (var j:int = 0; j < allPlanets.length; j++) {
				try {
					var p:Planet = allPlanets.members[j];
					p.system = allSystems.members[p.preSystem];
					p.system.addPlanet(p);
					//trace("Added " + p + " to System " + p.system.name);
				} catch (e:Error) {
					trace("ERROR in connecting planets to their systems: " + e.getStackTrace());
				}
			}
			
			trace("Generating Planets...Done. Total: " + allPlanets.length);
		}
		
		/**
		 * Gets an object from a flixel group by its id number. Ideally, every object will be in the
		 * FlxGroup's members array at the position matching its id. However, this accounts for the
		 * possibility that the object is not present at that matching position.
		 * @param	id The ID of the FlxBasic to search for
		 * @param	group What FlxGroup to search in.
		 * @return The matching FlxBasic, or null if not found. You'll probably want to use "as" to
		 * match it with the type you're expecting.
		 */
		public static function getObjectByID(id:int, group:FlxGroup):FlxBasic {
			if (group.length > id) { // Try array location = id first, then search
				var sys:FlxBasic = group.members[id];
				if (sys != null && sys.ID == id) {
					return sys;
				}
				sys = null;
			}
			for (var i:int = 0; i < group.length; i++) {
				if (group.members[i] != null) {
					var s:FlxBasic = group.members[i];
					if (s.ID == id) {
						return s;
					}
				} else {
					trace ("Null object at [" + i + "]!");
				}
			}
			trace ("Get object by ID returned null! ID Number: " + id);
			return null;
		}
		
		/**
		 * Makes an array and fills it with NUM_MISSION_FLAGS booleans set to false.
		 */
		public static function initMissionFlags():void {
			if (missionFlags != null) {
				missionFlags.length = 0;
				missionFlags = null;
			}
			missionFlags = new Array();
			for (var i:int = 0; i < NUM_MISSION_FLAGS; i++) {
				missionFlags.push(false);
			}
		}
		
		
		// ###################### Embedded data files and corresponding arrays of Strings ##########################
		
		/**
		 * File containing all the data for existing ship types.
		 */
		[Embed(source = "data/ships.txt", mimeType = "application/octet-stream")]public static var shipTypeDataFile:Class;
		
		/**
		 * Array that holds Strings read from the lines of ships.txt.
		 */
		public static var shipDataStrings:Array;
		
		/**
		 * File containing all the data for existing systems.
		 */
		[Embed(source = "data/systems.txt", mimeType = "application/octet-stream")]public static var spaceSystemDataFile:Class;
		
		/**
		 * Array that holds Strings read from the lines of systems.txt
		 */
		public static var spaceSystemDataStrings:Array;
		
		/**
		 * File containing all the data for the connections to make between systems.
		 */
		[Embed(source = "data/systems.txt", mimeType = "application/octet-stream")]public static var connectionSystemDataFile:Class;
		
		/**
		 * Array that holds Strings read from the lines of connections.txt
		 */
		public static var connectionSystemDataStrings:Array;
		
		/**
		 * File containing all the data for existing planets.
		 */
		[Embed(source = "data/planets.txt", mimeType = "application/octet-stream")]public static var planetDataFile:Class;
		
		/**
		 * Array that holds Strings read from the lines of planets.txt
		 */
		public static var planetDataStrings:Array;
	}
}
