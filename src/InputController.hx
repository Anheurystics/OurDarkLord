package;

import openfl.Lib;
import openfl.geom.Vector3D;

class InputController implements PlayerController
{	
	var gamepad: String;

	#if desktop
	var _player: Player;
	var _game: GameInfo;
	var mouseDeltaX: Float = 0;
	#end

	public function new(_gamepad: Int = -1) 
	{
		gamepad = _gamepad >= 0? Std.string(_gamepad) : "";
		#if desktop
		if(_gamepad == -1)
		{
			var window = Lib.application.window;
			window.mouseLock = true;
			window.onMouseMoveRelative.add(function(x, y) {
				if(Math.abs(x) < 2)
				{
					x = 0;
				}
				mouseDeltaX = x / window.width;
			});

			window.onMouseDown.add(function(x, y, btn) {
				if(_player != null && _game != null)
				{
					if(btn == 0) 
					{
						_player.throwRelic();
					}
					if(btn == 2)
					{
						_player.useButton(_game);
					}
				}
			});
		}
		#end
	}
	
	public function update(player: Player, game: GameInfo, delta: Float): Void
	{
		#if desktop
		_player = player;
		_game = game;
		#end

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
			if(player._movement.length > 0)
			{
				player.stamina -= 1.0;
			}
			player.runMultiplier = 1.5;
		}
		
		if (Input.isPressed(gamepad+"use"))
		{	
			player.useButton(game);
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

			#if desktop
			player.lookAngle += 180 * mouseDeltaX * player.lookspeed * delta * player.runMultiplier;
			mouseDeltaX = 0;
			#end
		}		
	}
}