package {
	
import org.flixel.*;
import org.flixel.plugin.photonstorm.FlxBar;


	public class HUD extends FlxState {
		
		public var hudBackground:FlxSprite;
		
		public static const HUD_WIDTH:uint = 130;
		
		public static const HUD_HEIGHT:uint = 640;
		
		[Embed(source = "../lib/hud-background.png")]private var bgImage:Class;
		
		public var shieldBar:DispBar;
		
		public var armorBar:DispBar;
		
		public var strucBar:DispBar;
		
		public var fuelBar:DispBar;
		
		public var energyBar:DispBar;
		
		public var bgElement:FlxSprite;
		
		
		public function HUD() {
			hudBackground = new FlxSprite(FlxG.width - HUD_WIDTH, 0, bgImage);
			hudBackground.scrollFactor.x = hudBackground.scrollFactor.y = 0;
			
			shieldBar = new DispBar(FlxG.width - 110, 130, Main.player.ship, "shieldCur", 0, Main.player.ship.shieldCap, 100, 10);
			shieldBar.scrollFactor.x = shieldBar.scrollFactor.y = 0;
			
			armorBar = new DispBar(FlxG.width - 110 , 150, Main.player.ship, "armorCur", 0, Main.player.ship.armorCap, 100, 10, 0xff444444, 0xff888888);
			armorBar.scrollFactor.x = armorBar.scrollFactor.y = 0;
			
			strucBar = new DispBar(FlxG.width - 110 , 170, Main.player.ship, "structCur", 0, Main.player.ship.structCap, 100, 10, 0xff550000, 0xff8888ff);
			strucBar.scrollFactor.x = strucBar.scrollFactor.y = 0;
			
			fuelBar = new DispBar(FlxG.width - 110 , 190, Main.player.ship, "fuelCur", 0, Main.player.ship.fuelCap, 100, 10, 0xff441144, 0xffff44ff);
			fuelBar.scrollFactor.x = fuelBar.scrollFactor.y = 0;
			
			energyBar = new DispBar(FlxG.width - 110 , 210, Main.player.ship, "energyCur", 0, Main.player.ship.energyCap, 100, 10, 0xff444400, 0xffffff00);
			energyBar.scrollFactor.x = energyBar.scrollFactor.y = 0;
			
			bgElement = new FlxSprite(FlxG.width - 120 , 250); // currently used to mark off the ship target area.
			bgElement.makeGraphic(110, 110, 0xff222222);
			bgElement.scrollFactor.x = bgElement.scrollFactor.y = 0;
			
		}
		
		override public function create():void {
			add(hudBackground);
			add(bgElement);
			add(shieldBar);
			add(armorBar);
			add(strucBar);
			add(fuelBar);
			add(energyBar);
			
		}
		
		
		
	}
}