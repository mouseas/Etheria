package {
	
	import gameObjects.*;
	import org.flixel.*;
	import UIScreens.CargoShop;
	
	public class ShopItem extends FlxGroup {
		
		/**
		 * Image for the FlxSprite.
		 */
		public var icon:FlxSprite;
		
		/**
		 * Text label for the ShopItem.
		 */
		public var label:FlxText;
		
		/**
		 * How many of the item are available for purchase.
		 */
		private var _qtyAvail:int;
		public function get qtyAvail():int { return _qtyAvail; }
		public function set qtyAvail(qty:int):void {
			_qtyAvail = qty;
			availText.text = qty + "";
		}
		
		/**
		 * The displayed text for how many units are available.
		 */
		public var availText:FlxText;
		
		/**
		 * How many of the item the Player or his Ship has.
		 */
		private var _qtyOwned:int;
		
		/**
		 * The displayed text for how many units the Player has.
		 */
		public var ownedText:FlxText;
		
		/**
		 * Cost for one unit of this item
		 */
		public var price:int;
		
		/**
		 * FlxPoint that acts as the ShopItem's location.
		 */
		public function get location():FlxPoint {
			return _location;
		}
		public function set location(point:FlxPoint):void {
			_location = point;
			icon.x = point.x;
			icon.y = point.y;
			label.x = point.x + icon.width + 8;
			label.y = point.y + (icon.height / 2);
			availText.x = point.x + 300;
			availText.y = label.y;
			ownedText.x = point.x + 350;
			ownedText.y = label.y;
		}
		private var _location:FlxPoint;
		
		/**
		 * Selection object for the ShopItem;
		 */
		public var selection:Selection;
		
		/**
		 * The screen to which the shop item belongs.
		 */
		public var parent:CargoShop;
		
		/**
		 * Create a shop item.
		 * @param	x X position
		 * @param	y Y position
		 */
		public function ShopItem(_parent:CargoShop, x:Number = 0, y:Number = 0) {
			super();
			
			parent = _parent;
			
			label = new FlxText(0, 0, 150, "");
			label.scrollFactor = Main.NO_SCROLL;
			label.color = 0xFF000000;
			add(label);
			
			icon = new FlxSprite();
			icon.scrollFactor = Main.NO_SCROLL;
			add(icon);
			
			_qtyAvail = 0;
			availText = new FlxText(0, 0, 50, "0");
			availText.scrollFactor = Main.NO_SCROLL;
			add(availText);
			
			_qtyOwned = 0;
			ownedText = new FlxText(0, 0, 50, "0");
			ownedText.scrollFactor = Main.NO_SCROLL;
			add(ownedText);
			
			location = new FlxPoint(x, y);
			
			price = 0;
		}
		
		public function setName(_str:String):void {
			label.text = _str;
		}
		
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.visible && FlxG.mouse.justPressed()) {
				var _point:FlxPoint = new FlxPoint();
				FlxG.mouse.getScreenPosition(Main.spaceScreen.viewPortCam, _point);
				if(icon.overlapsPoint(_point, false, Main.spaceScreen.viewPortCam)) {
					parent.currentSelection = this;
					
				}
			}
		}
		
	}
	
}