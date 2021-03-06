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
		public var loadedData:String;
		
		/**
		 * XML data loaded from the save file.
		 */
		public var xml:XML;
		
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
			remove(load, true);
			load.destroy();
			load = null;
			
		}
		
		/**
		 * Loads all the values that change from game to game - takes the save game data and loads
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
				startGame();
			}
		}
		
		public function startGame():void {
			if(!Main.spaceScreen.initialized) {
				Main.spaceScreen.initPlayingField();
			}
			if (Main.spaceScreen.currentSystem == null) {
				Main.spaceScreen.loadSystem(Main.getObjectByID(0, SpaceSystem.allSystems) as SpaceSystem);
			} else {
				Main.spaceScreen.loadSystem(Main.spaceScreen.currentSystem);
			}
			
			loadTheUniverse();
			
			Main.spaceScreen.dialogLayer.remove(this, true);
			Main.spaceScreen.unfreeze();
			this.destroy();
		}
		
	}
}