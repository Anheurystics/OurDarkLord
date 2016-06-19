package;

import openfl.geom.Vector3D;

class Entity
{
	public var x(get, set): Float;
	public function get_x(): Float
	{
		return position.x;
	}
	public function set_x(_x: Float): Float
	{
		position.x = _x;
		return _x;
	}
	
	public var z(get, set): Float;
	public function get_z(): Float
	{
		return position.z;
	}
	public function set_z(_z: Float): Float
	{
		position.z = _z;
		return _z;
	}
	
	public var position: Vector3D;
	public var lookAngle: Float;
	
	public var velocityX: Float = 0;
	public var velocityZ: Float = 0;
	
	public var sprite: Billboard;
	
	public function new(_x: Float, _z: Float) 
	{
		position = new Vector3D(_x, 0, _z);
		lookAngle = 0;
	}
	
	public function update(delta: Float, game: GameInfo): Void 
	{
		moveCollide(velocityX * delta, velocityZ * delta, game);
	}
	
	var _bufferX: Float = 0;
	var _bufferZ: Float = 0;
	function moveCollide(moveX: Float, moveZ: Float, game: GameInfo): Void
	{		
		var pow: Float = 150;
		
		_bufferX += (moveX * pow);
		_bufferZ += (moveZ * pow);
		
		var dx: Int = Std.int(_bufferX);
		var dz: Int = Std.int(_bufferZ);
		
		_bufferX -= dx;
		_bufferZ -= dz;
		
		moveX = 0;
		moveZ = 0 ;
		
		var sx: Int = Utils.sign(dx);
		moveX = dx / pow;
		moveZ = dz / pow;

		/*
		while (Math.abs(dx) > 0)
		{
			moveX += sx * (1 / pow);
			dx -= sx;
			if (game.level.edgeCheck(x + moveX, z + moveZ, 0.8, 0.8))
			{
				moveX -= sx * (1 / pow);
				break;
			}
		}
		
		var sz: Int = Utils.sign(dz);
		while (Math.abs(dz) > 0)
		{
			moveZ += sz * (1 / pow);
			dz -= sz;
			if (game.level.edgeCheck(x + moveX, z + moveZ, 0.8, 0.8))
			{
				moveZ -= sz * (1 / pow);
				break;
			}
		}		
		*/
		
		x += moveX;
		z += moveZ;
	}
}