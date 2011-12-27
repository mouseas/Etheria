package gameObjects {
	
	import org.flixel.*;
	import flash.utils.ByteArray;
	
	public class SpaceSystem extends FlxSprite {
		
		/**
		 * Holds all the systems in existence. Globally available.
		 */
		public static var allSystems:FlxGroup;
		
		public static var allSystemNames:FlxGroup;
		
		
		/**
		 * Data file containing the SpaceSystems' data
		 */
		[Embed(source = "../data/systems.xml", mimeType = "application/octet-stream")]public static var XMLFile:Class;
		
		/**
		 * Little circle image used on the map to represent a system, ie the graphic for the FlxSprite.
		 */
		[Embed(source = "../../lib/system-map-circle.png")]public var radarImage:Class;
		
		/**
		 * XML data for the SpaceSystems to be generated from.
		 */
		public static var data:XML;
		
		/**
		 * Number of systems to attempt to load from systems.txt
		 */
		public static const NUM_SYSTEMS:int = 2;
		
		/**
		 * The name of the system.
		 */
		public function get name():String {
			return _name;
		}
		public function set name(str:String):void {
			_name = str;
			nameText.text = str;
		}
		private var _name:String;
		
		/**
		 * FlxText displaying the system's name.
		 */
		public var nameText:FlxText;
		
		/**
		 * All the planets in this system
		 */
		public var planetList:FlxGroup;
		
		/**
		 * The systems this system connects to
		 */
		public var connectionsList:FlxGroup;
		
		/**
		 * System description displayed upon warping into the system. Example: "This system is
		 * owned by the Fedora Empire. Please obey the laws."
		 */
		public var description:String;
		
		/**
		 * Whether the player has explored this system and added it to their map.
		 * SAVED
		 */
		public var explored:Boolean;
		
		/**
		 * Constructor - initializes all the groups but does not assign anything to them. 
		 */
		public function SpaceSystem(_id:int) {
			// note these aren't added to the group - if they were added, they would show up on the screen when the systems
			// are displayed. Which would really screw up the map. Bigtime.
			super(0, 0, radarImage);
			
			color = 0x00ff00;
			cameras = Main.map;
			
			planetList = new FlxGroup();
			connectionsList = new FlxGroup();
			ID = _id;
			_name = "Sol";
			
			nameText = new FlxText(1, 1, 300, _name);
			nameText.visible = false;
			nameText.cameras = Main.map;
			allSystemNames.add(nameText);
			
			explored = false;
			visible = false;
			
		}
		
		override public function update():void {
			super.update();
			nameText.x = x + width + 5;
			nameText.y = y - 3;
		}
		
		/**
		 * Add a planet to the system. This assigns the system to the planet as well.
		 * @param	p The Planet to add to this system.
		 */
		public function addPlanet(p:Planet):void {
			planetList.add(p);
			if (p.system != null && p.system != this) {
				trace ("ERROR: " + p.system.name + " has a planet assigned to " + name);
				//This shouldn't happen, but if the planet is already assigned to a system, this tidbit warns you about the mistake.
			}
		}
		
		/**
		 * Connects two systems together. This only needs to be called on one of the systems; it will connect both directions.
		 * @param	s The system to connect this system to.
		 */
		public function addConnection(s:SpaceSystem):void {
			if (connectionsList.members.indexOf(s) < 0 && s.connectionsList.members.indexOf(this) < 0) {
				ConnectionLine.allConnectionLines.add(new ConnectionLine(s, this));
				//trace("Adding line between " + s.name + " and " + name);
			}
			connectionsList.add(s);
			s.connectionsList.add(this);
		}
		
		/**
		 * Generate all the systems from an XML data file. Called when the game is first started.
		 */
		public static function generateSystems():void {
			// Make new FlxGroups (and delete any existing ones
			trace("Generating Systems.");
			if (allSystems != null) {
				trace ("Clearing existing systems from existence!");
				allSystems.destroy();
			}
			allSystems = new FlxGroup();
			if (allSystemNames != null) {
				trace ("Clearing existing systems' names from existence!");
				allSystemNames.destroy();
			}
			allSystemNames = new FlxGroup();
			ConnectionLine.prepAllConnectionLines()
			
			// Load the XML data from the embedded file
			trace("Generating Systems...Load XML data");
			if (data == null) {
				var file:ByteArray = new XMLFile;
				var str:String = file.readUTFBytes(file.length);
				data = new XML(str);
			}
			
			// Generate the systems from the XML data
			trace("Generating Systems...create systems from XML data");
			for (var i:int = 0; i < data.system.length(); i++) {
				var result:SpaceSystem = new SpaceSystem(i);
				result.name = data.system[i].name;
				result.x = data.system[i].x;
				result.y = data.system[i].y;
				if (data.system[i].description != undefined) { result.description = data.system[i].description; }
				allSystems.add(result);
			}
			
			// Connect all the systems now that they've been generated
			trace("Generating Systems...making connections");
			for (i = 0; i < data.system.length(); i++) {
				var system:SpaceSystem = allSystems.members[i] as SpaceSystem;
				for (var j:int = 0; j < data.system[i].connection.length(); j++) {
					system.addConnection(allSystems.members[data.system[i].connection[j]]);
				}
			}
			
			trace("Generating Systems...done!");
		}
		
		/**
		 * Function which goes through all the systems and connection lines to update their visibility. Called whenever a system is
		 * loaded, and after buying a map.
		 */
		public static function updateMap():void {
			for (var i:int = 0; i < allSystems.length; i++) {
				var sys:SpaceSystem = allSystems.members[i];
				if (sys.explored) {
					sys.visible = true;
					sys.nameText.visible = true;
					for (var j:int = 0; j < sys.connectionsList.length; j++) {
						var connectedSys:SpaceSystem = sys.connectionsList.members[j];
						if (!connectedSys.explored) {
							connectedSys.visible = true;
							connectedSys.nameText.visible = false;
						}
					}
				}
			}
			ConnectionLine.updateMap();
		}
		
		override public function toString():String {
			return "SpaceSystem - " + name + ", ID:" + ID + " Planets:" + planetList.length;
		}
		
	}
	
	
}