package;

import openfl.geom.Vector3D;

class Player extends Entity
{
	public var fov: Float = 55;
	public var movespeed: Float = 2.5; 
	public var lookspeed: Float = 100;
	public var pickupRange: Float = 1.25;
	public var camera: Camera;
	
	public var _movement: Vector3D = new Vector3D();
	public var runMultiplier: Float = 1.0;
	
	public var holding: Relic = null;
	public var goalRelics: Array<String> = [];
	
	public var showGoals: Bool = true;
	var isStationary: Bool = true;
	var showGoalsTimer: Float = 0.0;
	
	public var stamina: Float = 100.0;
	var staminaGap: Float = 0.0;
	
	public var numberCorrectItems: Int = 0;
	public var numberWrongItems: Int = 0;
	
	public var summonLength: Float = 0;
	
	public var name: String;
	
	public var r: Float = 1.0;
	public var g: Float = 1.0;
	public var b: Float = 1.0;
	
	var controller: PlayerController;
	
	public function new(_name: String, _x: Float = 0,  _z: Float = 0, _lookAngle: Float = 0, _controller: PlayerController) 
	{
		super(_x, _z);
		name = _name;
		lookAngle = _lookAngle;
		
		camera = new Camera();
		camera.setToPlayer(this);
		
		controller = _controller;
		
		sprite = Billboard.create(Billboard.PERSPECTIVE_MIN);
	}
	
	override public function update(delta: Float, game: GameInfo): Void 
	{
		super.update(delta, game);
		
		x = Utils.clamp(x, -game.bounds / 2, game.bounds / 2);
		z = Utils.clamp(z, -game.bounds / 2, game.bounds / 2);
		
		if (stamina < 0)
		{
			stamina = 0;
		}
		
		staminaGap -= delta;
		if (staminaGap < 0) staminaGap = 0;
		if (staminaGap == 0)
		{
			stamina += 25 * delta;
		}
		
		if (stamina > 100)
		{
			stamina = 100;
		}
		
		if (numberCorrectItems == goalRelics.length && numberWrongItems == 0)
		{
			summonLength += delta;
		}
		
		if (holding != null)
		{
			holding.x = x;
			holding.z = z;
		}
		
		_movement.setTo(0, 0, 0);
	
		controller.update(this, game, delta);
		
		var speed: Float = movespeed * runMultiplier;
		
		isStationary = _movement.length == 0;
		
		if (isStationary)
		{
			showGoalsTimer += delta;
			if (showGoalsTimer > 1.0)
			{
				showGoals = true;
			}
		}
		else
		{
			showGoalsTimer = 0;
			showGoals = false;
		}
		
		velocityX = _movement.x * speed;
		velocityZ = _movement.z * speed;
		
		camera.position.x = x;
		camera.position.z = z;
		camera.yaw = lookAngle;
		camera.update();
		
		sprite.x = x;
		sprite.z = z;
		sprite.angleOffset = lookAngle;
	}

	public function useButton(game: GameInfo): Void
	{
		if (holding == null)
		{
			var front: Vector3D = new Vector3D(Math.cos(Utils.toRad(lookAngle)), 0, Math.sin(Utils.toRad(lookAngle)));
			var nearest: Float = Math.POSITIVE_INFINITY;
			var toPickUp: Relic = null;
			for (relic in game.relics)
			{	
				if (relic.state == Relic.STATE_GROUND)
				{
					var toRelic: Vector3D = new Vector3D(x - relic.x, 0, z - relic.z);
					var dist: Float = toRelic.normalize();
					if (dist < pickupRange && dist < nearest)
					{
						var dot: Float = front.dotProduct(toRelic);
						if (dot < -0.85) 
						{
							nearest = dist;
							toPickUp = relic;
						}							
					}
				}
			}	
			if (toPickUp != null)
			{
				pickupRelic(toPickUp);
			}
			else
			{
				nearest = Math.POSITIVE_INFINITY;
				var toPickUpFrom: Player = null;
				for (other in game.players)
				{
					if (other.holding != null)
					{
						var playerFront: Vector3D = new Vector3D(Math.cos(Utils.toRad(other.lookAngle)), 0, Math.sin(Utils.toRad(other.lookAngle)));
						var toPlayer: Vector3D = new Vector3D(x - other.x, 0, z - other.z);
						var dist: Float = toPlayer.normalize();
						if (dist < pickupRange && dist < nearest)
						{
							var dot: Float = front.dotProduct(playerFront);
							if (dot < -0.85)
							{
								nearest = dist;
								toPickUpFrom = other;
							}
						}
					}
				}
				if (toPickUpFrom != null)
				{
					holding = toPickUpFrom.holding;
					toPickUpFrom.holding = null;
				}
			}
		}
		else
		{
			dropRelic();
		}
	}
	
	public function pickupRelic(relic: Relic): Void
	{
		if (relic.state != Relic.STATE_GROUND) return;
		
		holding = relic;
		holding.owner = this;
		relic.state = Relic.STATE_HELD;
	}
	
	public function dropRelic(): Void
	{
		if (holding != null)
		{
			holding.x = x + (Math.cos(Utils.toRad(lookAngle)) * 0.75);
			holding.z = z + (Math.sin(Utils.toRad(lookAngle)) * 0.75);
			holding.state = Relic.STATE_GROUND;
			holding = null;
		}
	}	
	
	public function dislodgeRelic(relic: Relic): Void
	{
		staminaGap = 2.0;
		
		if (holding != null)
		{
			stamina -= 50.0;
			
			var angle: Float = Math.atan2(relic.velocityZ, relic.velocityX);
			
			holding.state = Relic.STATE_THROWN;
			holding.x = x + (Math.cos(Utils.toRad(angle)) * 0.5);
			holding.sprite.y = 0.2;
			holding.z = z + (Math.sin(Utils.toRad(angle)) * 0.5);
			holding.velocityX = Math.cos(Utils.toRad(angle)) * 5;
			holding.velocityZ = Math.sin(Utils.toRad(angle)) * 5;
			
			holding = null;
		}		
		else
		{
			stamina -= 25.0;
		}
	}
	
	public function throwRelic(force: Float = 10.0): Void
	{
		if (holding != null)
		{
			stamina -= 30.0;
			staminaGap = 2.0;			
			
			holding.state = Relic.STATE_THROWN;
			holding.x = x + (Math.cos(Utils.toRad(lookAngle)) * 0.5);
			holding.sprite.y = 0.2;
			holding.z = z + (Math.sin(Utils.toRad(lookAngle)) * 0.5);
			holding.velocityX = Math.cos(Utils.toRad(lookAngle)) * force;
			holding.velocityZ = Math.sin(Utils.toRad(lookAngle)) * force;
			
			holding = null;
		}
	}
}