package {

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	import org.flixel.*;
	import gameObjects.*;
	import flash.net.FileReference;
	
	public class SaveGame {
		
		/**
		 * XML data to be constructed and saved.
		 */
		public var xml:XML;
		
		/**
		 * ByteArray the xml will be entered into
		 */
		public var ba:ByteArray;
		
		/**
		 * File to save to.
		 */
		public var file:FileReference;
		
		public function SaveGame() {
			prepXML();
			prepBA();
			prepFileRef();
		}
		
		private function prepXML():void {
			var player:Player = Main.player;
			xml = new XML('<?xml version="1.0" encoding="UTF-8"?><data></data>');
			xml.player.money = player.money;
			xml.player.ship.fuelCur = player.ship.fuelCur;
			xml.player.ship.energyCur = player.ship.energyCur;
			xml.player.ship.shieldCur = player.ship.shieldCur;
			xml.player.ship.armorCur = player.ship.armorCur;
			xml.player.ship.structCur = player.ship.structCur;
			xml.player.shiptype = player.ship.ID;
			xml.currentSystem = Main.spaceScreen.currentSystem.ID;
			xml.currentPlanet = player.planetTarget.ID;
			for (var i:int = 0; i < Planet.allPlanets.length; i++) {
				var segment:XML = new XML('<planet />');
				xml.appendChild(segment);
				var p:Planet = Planet.allPlanets.members[i];
				xml.planet[i].@id = i;
				xml.planet[i].population = p.population;
			}
			for (i = 0; i < SpaceSystem.allSystems.length; i++) {
				segment = new XML('<system />');
				xml.appendChild(segment);
				var s:SpaceSystem = SpaceSystem.allSystems.members[i];
				xml.system[i].@id = i;
				xml.system[i].explored = s.explored;
			}
			xml.date.year = Main.spaceScreen.date.year;
			xml.date.month = Main.spaceScreen.date.month;
			xml.date.day = Main.spaceScreen.date.date;
			trace("xml:\n" + xml.toXMLString());
			
		}
		
		private function prepBA():void {
			ba = new ByteArray();
			if (xml != null) {
				ba.writeUTFBytes('<?xml version="1.0" encoding="UTF-8"?>\n' + xml.toXMLString());
			}
		}
		
		private function prepFileRef():void {
			file = new FileReference()
			file.addEventListener(Event.SELECT, selectHandler);
			file.addEventListener(Event.CANCEL, cancelHandler);
			file.save(ba, "playername.eth");
		}
		
		private function selectHandler(event:Event):void {
			
		}
		
		private function cancelHandler(event:Event):void {
			trace("cancelled");
		}
		
		
		
		
	}
	
}