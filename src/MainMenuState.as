package 
{
	import org.flixel.*;
	import gameObjects.*;

	/**
	 * The main menu, which the player reaches when the game first runs.
	 * @author Martin Carney
	 */
	public class MainMenuState extends FlxState
	{
		/**
		 * Sprite used to display the splash screen background.
		 */
		private var background:FlxSprite;
		
		/**
		 * Background image used by the background sprite.
		 */
		[Embed(source = "../lib/splash.png")]public var bgImage:Class;
		
		/**
		 * Line of text to get the player to be able to start gameplay.
		 */
		private var startInstructions:FlxText;
		
		/**
		 * held object for loading a saved game.
		 */
		public var load:LoadGame;
		
		/**
		 * Array of strings loaded from file.
		 */
		public var loadedData:Array;
		
		/**
		 * Button to load a saved game.
		 */
		public var loadButton:FlxButton;
		
		/**
		 * Set to true when starting to load a file. Part of the update cycle checks if this is attempting
		 * to load, then checks the status of the loadGame object.
		 */
		public var attemptingToLoad:Boolean;
		
		
		/**
		 * Called whenever the screen changes.
		 */
		override public function create():void
		{
			attemptingToLoad = false;
			FlxG.mouse.show();
			
			background = new FlxSprite(0, 0, bgImage);
			add(background);
			
			startInstructions = new FlxText(100, 400, 300, "Press 'X' to start", false);
			startInstructions.color = 0x555555;
			add(startInstructions);
			
			loadButton = new FlxButton(100, 425, "Load Game", loadButtonClicked);
			add(loadButton);
			
		}
		
		/**
		 * Called when a saved game has been successfully opened.
		 */
		public function loadButtonClicked():void {
			
			load = new LoadGame(loadComplete);
			add(load);
			attemptingToLoad = true;
			
			
		}
		
		public function loadComplete():void {
			var str:String = load.data.toString();
			remove(load, true);
			load.destroy();
			load = null;
			loadedData = str.split("\n");
			str = null;
			
			//Parse the loaded data, checking for errors along the way.
			
			
			//clear out the message log when the saved game is loaded.
			if (SpaceMessage.messageLog != null ) {
				SpaceMessage.messageLog.destroy();
			}
			SpaceMessage.messageLog = new FlxGroup();
			
		}
		
		/**
		 * Loads all the values that change rom game to game - takes the save game data and loads
		 * everything to make the primordial universe match the saved state.
		 */
		public function loadTheUniverse():void {
			// Load and apply all the loaded game values
			
			
			// Put the player in the system they start in.
			var sys:SpaceSystem = SpaceSystem.allSystems.members[0];
			var pla:Planet = Planet.allPlanets.members[0];
			//something missing here...
		}
		
		/**
		 * Standard update cycle.
		 */
		override public function update():void {
			super.update();
			 
			if (load != null && load.cancelled) {
				remove(load, true);
				load.destroy();
				load = null;
			}
			// Keyboard command: start SpaceState in debug mode.
			if (FlxG.keys.justPressed("X")) {
				if(!Main.spaceScreen.initialized) {
					Main.spaceScreen.initPlayingField();
				}
				
				loadTheUniverse();
				
				Main.spaceScreen.loadSystem(Main.getObjectByID(0, SpaceSystem.allSystems) as SpaceSystem);
				Main.spaceScreen.dialogLayer.remove(this, true);
				Main.spaceScreen.unfreeze();
				this.destroy();
			}
		}
		
	}
}