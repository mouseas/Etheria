package gameObjects
{
	
	import org.flixel.*
	
	
	/**
	 * The Player character. Not only holds the player's ship, but also other aspects of the player character.
	 * @author Martin Carney
	 */
	public class Player extends FlxSprite {
		
		/**
		 * The screen which the player's ship is on.
		 */
		public var screen:SpaceState;
		 
		/**
		 * The player's ship.
		 */
		public var ship:Ship;
		
		/**
		 * Number of credits the player has.
		 */
		public var money:int = 10000;
		
		/**
		 * Ship the player is currently targeting.
		 */
		private var _shipTarget:Ship;
		
		public function get shipTarget():Ship {
			return _shipTarget;
		}
		
		public function set shipTarget(ship:Ship):void {
			if (_shipTarget != null) {
				_shipTarget.loseFocus();
			}
			_shipTarget = ship;
			if (_shipTarget != null) {
				_shipTarget.getFocus();
			}
		}
		
		/**
		 * Planet the player is currently targeting.
		 */
		private var _planetTarget:Planet;
		
		/**
		 * Planet the player is currently targeting.
		 */
		public function get planetTarget():Planet { return _planetTarget }
		
		/**
		 * Change which planet the player is currently targeting. Calls loseFocus on the old planet (if any) and getFocus on the
		 * new planet (if any).
		 */
		public function set planetTarget(planet:Planet):void {
			if (_planetTarget != null) {
				_planetTarget.loseFocus();
			}
			_planetTarget = planet;
			if (_planetTarget != null) {
				_planetTarget.getFocus();
			}
			
		}
		
		public function get systemTarget():SpaceSystem {
			return _systemTarget;
		}
		public function set systemTarget(sys:SpaceSystem):void {
			if (_systemTarget != null) { _systemTarget.loseFocus() };
			_systemTarget = sys;
			if (_systemTarget != null) { _systemTarget.getFocus() };
		}
		private var _systemTarget:SpaceSystem;
		
		/**
		 * Constructor function.
		 * @param _screen The screen to put the player's ship on when flying about.
		 */
		public function Player(_screen:*):void {
			super(0, 0);
			screen = _screen;
			
			this.makeGraphic(1, 1, 0x00000000);
			
			ship = Ship.cloneShip(0);
			screen.radarCam.follow(ship.radarDot);
			ship.playerControlled = true;
		}
		
		/**
		 * Standard update cycle.
		 */
		override public function update():void {
			
			if (!screen.frozen) {
				ship.acceleration.x = ship.acceleration.y = 0; // set to 0, then adjust if accelerating.
				flyingKeys();
			}
			
			super.update();
			
		}
		
		
		/**
		 * All keyboard commands used while flying around space. Part of the update cycle.
		 */
		private function flyingKeys():void {
			//Turning the ship
			if (FlxG.keys.LEFT) {
				ship.turnLeft();
			} else if (FlxG.keys.RIGHT) {
				ship.turnRight();
			} else if (FlxG.keys.DOWN) { // Turn to face opposite move direction
				turnTowardTarget(ship.velAngle + Math.PI);
			} else if (FlxG.keys.A) { //Autopilot
				if (shipTarget != null) {
					turnTowardTarget(MathE.angleBetweenPoints(ship.getCenter(), shipTarget.getCenter()));
				} else if (planetTarget != null) {
					turnTowardTarget(MathE.angleBetweenPoints(ship.getCenter(), planetTarget.getCenter()));
				}
				
			}
			
			//Accelerating
			if (FlxG.keys.UP) {
				ship.thrust();
			}
			
			//Landing / selecting planets
			if (FlxG.keys.justPressed("L")) {
				if (planetTarget == null) {
					var distance:Number;
					var closest:Planet = null;
					for (var i:int = 0; i < screen.planetList.length; i++) { // target the closest landable planet
						var p:Planet = screen.planetList.members[i];
						if (p.canLand) {
							if (isNaN(distance) || MathE.distance(ship.getCenter(), p.getCenter()) < distance) {
								distance = MathE.distance(ship.getCenter(), p.getCenter());
								closest = p;
							}
						}
					}
					if (closest != null) {
						planetTarget = closest;
					}
				}
				if (planetTarget != null) {
					planetTarget.requestLanding();
				}
			}
		}
		
		private function turnTowardTarget(goalAngle:Number):void {
			var turn:Number = MathE.turnDifference(ship.facingAngle, goalAngle);
			if (Math.abs(turn) < ship.rcs * FlxG.elapsed) {
				//ship.facingAngle = goalAngle; // if the amount to turn is less than the ship can turn this frame, just match the goalAngle.
			} else if (turn > 0) {
				ship.turnRight();
			} else {
				ship.turnLeft();
			}
		}
		
		/**
		 * nulls out variables specific to Players, then calls destroy() from FlxSprite.
		 */
		override public function destroy():void {
			ship = null;
			shipTarget = null;
			screen = null;
			planetTarget = null;
			
			// Call this last.
			super.destroy();
		}
	}
	
}