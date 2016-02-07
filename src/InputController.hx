package;

import openfl.geom.Vector3D;

class InputController implements PlayerController
{
	var gamepad: String;
	
	public function new(_gamepad: Int = -1) 
	{
		gamepad = _gamepad >= 0? Std.string(_gamepad) : "";
	}
	
	public function update(player: Player, game: GameInfo, delta: Float): Void
	{
		if (gamepad.length > 0)
		{
			var yAxis: Float = GamepadInput.axis(gamepad + "LEFT_Y");
			if (Math.abs(yAxis) < 0.5) yAxis = 0;
			var xAxis: Float = GamepadInput.axis(gamepad + "LEFT_X");
			if (Math.abs(xAxis) < 0.5) xAxis = 0;
			var axes: Vector3D = new Vector3D();
			
			var yFront: Vector3D = player.camera.front.clone();
			yFront.scaleBy(-yAxis);
			var xRight: Vector3D = player.camera.right.clone();
			xRight.scaleBy(xAxis);
			
			axes = axes.add(yFront).add(xRight);
			axes.normalize();
			
			player._movement = player._movement.add(axes);
		}
		else
		{
			if (Input.isDown("forward")) 
				player._movement = player._movement.add(player.camera.front);
			if (Input.isDown("back")) 
				player._movement = player._movement.subtract(player.camera.front);
			if (Input.isDown("strafe_left")) 
				player._movement = player._movement.subtract(player.camera.right);
			if (Input.isDown("strafe_right")) 
				player._movement = player._movement.add(player.camera.right);						
		}
		
		if (Input.isDown(gamepad + "run") && player.stamina > 0)
		{
			player.stamina -= 1.0;
			player.runMultiplier = 1.5;
		}
		
		if (Input.isPressed(gamepad+"use"))
		{	
			if (player.holding == null)
			{
				var front: Vector3D = new Vector3D(Math.cos(Utils.toRad(player.lookAngle)), 0, Math.sin(Utils.toRad(player.lookAngle)));
				var nearest: Float = Math.POSITIVE_INFINITY;
				var toPickUp: Relic = null;
				for (relic in game.relics)
				{	
					if (relic.state == Relic.STATE_GROUND)
					{
						var toRelic: Vector3D = new Vector3D(player.x - relic.x, 0, player.z - relic.z);
						var dist: Float = toRelic.normalize();
						if (dist < 1 && dist < nearest)
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
					player.pickupRelic(toPickUp);
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
							var toPlayer: Vector3D = new Vector3D(player.x - other.x, 0, player.z - other.z);
							var dist: Float = toPlayer.normalize();
							if (dist < 1 && dist < nearest)
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
						player.holding = toPickUpFrom.holding;
						toPickUpFrom.holding = null;
					}
				}
			}
			else
			{
				player.dropRelic();
			}
		}
		
		if (player.stamina >= 30.0 && Input.isPressed(gamepad + "shoot"))
		{
			player.throwRelic();
		}
		
		if (gamepad.length > 0)
		{
			if (GamepadInput.axis(gamepad+"RIGHT_X") < -0.9) player.lookAngle -= player.lookspeed * delta * player.runMultiplier;
			if (GamepadInput.axis(gamepad+"RIGHT_X") >  0.9) player.lookAngle += player.lookspeed * delta * player.runMultiplier;
		}
		else
		{
			if (Input.isDown("turn_left")) player.lookAngle -= player.lookspeed * delta * player.runMultiplier;
			if (Input.isDown("turn_right")) player.lookAngle += player.lookspeed * delta * player.runMultiplier;					
		}		
	}
}