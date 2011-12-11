package {
	
	import org.flixel.*
	
	/**
	 * Message displayed on the player's screen and logged in the message log.
	 * @author Martin Carney
	 */
	public class SpaceMessage extends FlxBasic {
		
		/**
		 * Backlog of messages displayed during gameplay.
		 */
		public static var messageLog:FlxGroup = new FlxGroup();
		
		/**
		 * Bottom-most line of in-game message text, the most recent item.
		 */
		public static var message1:FlxText = new FlxText(15, FlxG.height - 25, FlxG.width - 30, "");;
		
		/**
		 * Bottom-most line of in-game message text, the second-most recent item.
		 */
		public static var message2:FlxText = new FlxText(15, FlxG.height - 40, FlxG.width - 30, "");
		
		/**
		 * Bottom-most line of in-game message text, the oldest of the three messages.
		 */
		public static var message3:FlxText = new FlxText(15, FlxG.height - 55, FlxG.width - 30, "");
		
		/**
		 * The string in the message
		 */
		protected var str:String;
		
		/**
		 * The amount of time the message should remain on screen, 15 seconds by default.
		 */
		protected var life:Number;
		
		/**
		 * The color of the message, white by default.
		 */
		protected var color:uint;
		
		/**
		 * Has this class been properly initialized?
		 */
		private var initialized:Boolean = false;
		
		public function SpaceMessage(_str:String, _lifeSpan:Number = 10, _color:uint = 0xffffffff) {
			if (!initialized) {
				message1.scrollFactor = Main.NO_SCROLL;
				Main.spaceScreen.messageLayer.add(message1);
				message2.scrollFactor = Main.NO_SCROLL;
				Main.spaceScreen.messageLayer.add(message2);
				message3.scrollFactor = Main.NO_SCROLL;
				Main.spaceScreen.messageLayer.add(message3);
			}
			super();
			str = _str;
			life = _lifeSpan;
			color = _color;
			cameras = Main.viewport;
			
		}
		
		public function getString():String {
			return str;
		}
		
		public function getLife():Number {
			return life;
		}
		
		public function getColor():uint {
			return color;
		}
		
		override public function update():void {
			super.update();
			if (life > 0) {
				if (life < FlxG.elapsed) {
					life = 0;
					active = false; //Skip updating this message in the game loop; reduce overhead.
				} else {
					life -= FlxG.elapsed;
				}
			}
		}
		
		/**
		 * Called every update, this function deals with the updated messages - mostly making them fade when their lifespan is up.
		 */
		public static function updateDisplayedMessages():void {
			var numMessages:int = messageLog.length;
			if (numMessages > 2) {
				var m3:SpaceMessage = messageLog.members[numMessages - 3]
				if (m3.getLife() <= 0 && message3.alpha > 0) {
					message3.alpha -= FlxG.elapsed;
				}
			}
			if (numMessages > 1) {
				var m2:SpaceMessage = messageLog.members[numMessages - 2]
				if (m2.getLife() <= 0 && message2.alpha > 0) {
					message2.alpha -= FlxG.elapsed;
				}
			}
			if (numMessages > 0) {
				var m1:SpaceMessage = messageLog.members[numMessages - 1]
				if (m1.getLife() <= 0 && message1.alpha > 0) {
					message1.alpha -= FlxG.elapsed;
				}
			}
		}
		
		/**
		 * Puts a new message on the screen, bumps old messages up the line, and adds the message to the backlog.
		 * @param	message
		 */
		public static function push(message:SpaceMessage):void {
			messageLog.add(message);
			message3.text = message2.text;
			message3.color = message2.color;
			message3.alpha = message2.alpha;
			message2.text = message1.text;
			message2.color = message1.color;
			message2.alpha = message1.alpha;
			message1.alpha = 1;
			message1.text = message.getString();
			message1.color = message.getColor();
		}
		
	}
}