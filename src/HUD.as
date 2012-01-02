package {
	
import org.flixel.*;
import org.flixel.plugin.photonstorm.FlxBar;
import gameObjects.*;


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
		
		public var cash:FlxText;
		
		public var bgElement:FlxSprite;
		
		
		public function HUD() {
			hudBackground = new FlxSprite(FlxG.width - HUD_WIDTH, 0, bgImage);
			hudBackground.scrollFactor.x = hudBackground.scrollFactor.y = 0;
			
			shieldBar = new DispBar(FlxG.width - 110, 130, Player.p.ship, "shieldCur", 0, Player.p.ship.shieldCap, 100, 10);
			shieldBar.scrollFactor.x = shieldBar.scrollFactor.y = 0;
			
			armorBar = new DispBar(FlxG.width - 110 , 150, Player.p.ship, "armorCur", 0, Player.p.ship.armorCap, 100, 10, 0xff444444, 0xff888888);
			armorBar.scrollFactor.x = armorBar.scrollFactor.y = 0;
			
			strucBar = new DispBar(FlxG.width - 110 , 170, Player.p.ship, "structCur", 0, Player.p.ship.structCap, 100, 10, 0xff550000, 0xff8888ff);
			strucBar.scrollFactor.x = strucBar.scrollFactor.y = 0;
			
			
			fuelBar = new DispBar(FlxG.width - 110 , 190, Player.p.ship, "fuelCur", 0, Player.p.ship.fuelCap, 100, 10, 0xff441144, 0xffff44ff);
			fuelBar.scrollFactor.x = fuelBar.scrollFactor.y = 0;
			
			energyBar = new DispBar(FlxG.width - 110 , 210, Player.p.ship, "energyCur", 0, Player.p.ship.energyCap, 100, 10, 0xff444400, 0xffffff00);
			energyBar.scrollFactor.x = energyBar.scrollFactor.y = 0;
			
			cash = new FlxText(FlxG.width - 110, 500, 100, "0");
			cash.scrollFactor.x = cash.scrollFactor.y = 0;
			cash.alignment = "right";
			
			bgElement = new FlxSprite(FlxG.width - 120 , 250); // currently used to mark off the ship target area.
			bgElement.makeGraphic(110, 110, 0xff222222);
			bgElement.scrollFactor = Main.NO_SCROLL;
			
		}
		
		override public function create():void {
			add(hudBackground);
			add(bgElement);
			add(shieldBar);
			add(armorBar);
			add(strucBar);
			add(fuelBar);
			add(energyBar);
			add(cash);
			
		}
		
		override public function update():void {
			super.update();
			cash.text = Player.p.money + "";
		}
		
	}
}