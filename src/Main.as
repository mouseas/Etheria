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
		 * Array of booleans to keep track of mission string progress, technology advances, etc. Before loading
		 * any flags, all cells in this array are set to false.
		 */
		public static var missionFlags:Array;
		
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
		 * Array holding the camera used by anything shown on the whole screen.
		 */
		public static var fullScreen:Array;
		
		
		
		/**
		 * Constructor for the main game class.
		 */
		public function Main()
		{
			super(850, 640, SpaceState, 1);
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
		
	}
}
