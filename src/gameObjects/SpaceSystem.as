package gameObjects {
	
	import org.flixel.*
	
	public class SpaceSystem extends FlxSprite {
		
		/**
		 * Static int holding the position of string array parsing
		 */
		public static var _i:int = 0;
		
		/**
		 * Number of systems to attempt to load from systems.txt
		 */
		public static const NUM_SYSTEMS:int = 2;
		
		/**
		 * The name of the system.
		 */
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
		 * The ships that exist in this system. Might be stupid to do it this way. I'll prolly change this later.
		 */
		public var shipsList:FlxGroup;
		
		/**
		 * System description displayed upon warping into the system. Example: "This system is
		 * owned by the Fedora Empire. Please obey the laws."
		 */
		public var description:String;
		
		[Embed(source = "../../lib/system-map-circle.png")]public var image:Class;
		
		/**
		 * Constructor - initializes all the groups but does not assign anything to them. 
		 */
		public function SpaceSystem(_id:int) {
			// note these aren't added to the group - if they were added, they would show up on the screen when the systems
			// are displayed. Which would really screw up the map. Bigtime.
			super(0, 0, image);
			
			color = 0x00ff00;
			cameras = Main.map;
			
			planetList = new FlxGroup();
			connectionsList = new FlxGroup();
			shipsList = new FlxGroup();
			ID = _id;
			_name = "Sol";
			
			nameText = new FlxText(1, 1, 300, _name);
			nameText.cameras = Main.map;
			Main.allSystemNames.add(nameText);
			
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
				//This shouldn't happen, but if the planet is already assigned to a system, this tidbit removes it from
				//that system's planetList before adding it to this system. This prevents it being in two places at once.
				p.system.planetList.remove(p, true); 
			}
			p.system = this;
		}
		
		/**
		 * Connects two systems together. This only needs to be called on one of the systems; it will connect both directions.
		 * @param	s The system to connect this system to.
		 */
		public function addConnection(s:SpaceSystem):void {
			connectionsList.add(s);
			s.connectionsList.add(this);
		}
		
		/**
		 * Passing in the string array, this will create a SpaceSystem from the data starting at startLine.
		 * @param	array The entire array of strings to pull strings from in order to parse them.
		 * @param	startLine Which index in the array to start at.
		 * @return The mostly-finished Planet. Any variables not defined in the systems.txt file for that entry will default
		 * to the values for Sol, ID 0.
		 */
		public static function parseSystemFromText(array:Array, startLine:int):SpaceSystem {
			var i:int = startLine;
			if (startLine < array.length) {
				//trace(startLine);
				var _ID:uint = StringParser.readInt(array[i++]);
				var result:SpaceSystem = new SpaceSystem(_ID);
				var str:String = StringParser.readVarName(array[i]);
				while (str.indexOf("ID") != 0 && i < array.length) {
					if (StringParser.assignValueFromStrings(array[i], result)) {
						
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
		
		public function set name(str:String):void {
			_name = str;
			nameText.text = str;
		}
		
		public function get name():String {
			return _name;
		}
		
		
	}
	
	
}