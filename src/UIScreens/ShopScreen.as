package UIScreens {
	
	import org.flixel.*;
	import gameObjects.*;
	
	
	public class ShopScreen extends UIScreen {
		
		/**
		 * The Buy button for the shop.
		 */
		public var buyButton:FlxButton;
		
		/**
		 * The Sell button for the shop.
		 */
		public var sellButton:FlxButton;
		
		/**
		 * Which ShopItem is currently selected.
		 */
		public function get currentSelection():ShopItem { return _currentSelection; }
		public function set currentSelection(s:ShopItem):void {
			if (_currentSelection != null) {
				remove(_currentSelection.selection, true);
				_currentSelection.selection = null;
			}
			_currentSelection = s;
			if (_currentSelection != null) {
				_currentSelection.selection = new Selection(_currentSelection.icon);
				_currentSelection.selection.setAll("scrollFactor", Main.NO_SCROLL);
				add(_currentSelection.selection);
			}
		}
		private var _currentSelection:ShopItem;
		
		/**
		 * Constructor for the CargoShop screen
		 * @param	_planet The Planet the shop is on.
		 */
		public function ShopScreen() {
			super();
			
			buyButton = new FlxButton(OKButton.x, OKButton.y + 30, "Buy", buyItem);
			buyButton.active = false;
			buyButton.scrollFactor = Main.NO_SCROLL;
			buttonLayer.add(buyButton)
			
			sellButton = new FlxButton(OKButton.x, OKButton.y + 60, "Sell", sellItem);
			sellButton.active = false; 
			sellButton.scrollFactor = Main.NO_SCROLL;
			buttonLayer.add(sellButton);
			
		}
		
		/**
		 * Buy the currently selected item. Override this for each shop.
		 */
		public function buyItem():void {
			trace("buy");
		}
		
		/**
		 * Sell the currently selected item. Override this for each shop.
		 */
		public function sellItem():void {
			trace("sell");
		}
		
		override public function update():void {
			super.update();
			if (_currentSelection != null && FlxG.mouse.justReleased()) {
				checkBuySell();
			}
			
		}
		
		/**
		 * Update the Buy and Sell buttons to active or inactive. Override for each shop's behavior (since they sell different objects).
		 */
		public function checkBuySell():void {
			trace("checkBuySell");
		}
		
		override public function closeScreen():void {
			//Remove any persistent objects here.
			super.closeScreen();
		}
		
		override public function destroy():void {
			
			super.destroy();
		}
		
	}
}