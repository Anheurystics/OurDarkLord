package;

import openfl.geom.Vector3D;

class Transform
{
	private var _matrix: Mat4;
	private var _position: Vector3D;
	private var _rotation: Vector3D;
	private var _scale: Vector3D;
	private var _dirty: Bool = true;
	
	public function new() 
	{
		_matrix = new Mat4();
		_position = new Vector3D(0, 0, 0, 1);
		_rotation = new Vector3D(0, 0, 0, 1);
		_scale = new Vector3D(1, 1, 1, 1);
	}
	
	public function moveTo(x: Float, y: Float, z: Float): Transform
	{
		_position.x = x;
		_position.y = y;
		_position.z = z;
		_dirty = true;
		return this;
	}
	
	public function moveBy(x: Float, y: Float, z: Float): Transform
	{
		_position.x += x;
		_position.y += y;
		_position.z += z;
		_dirty = true;
		return this;
	}
	
	public function rotateTo(x: Float, y: Float, z: Float): Transform
	{
		_rotation.x = x;
		_rotation.y = y;
		_rotation.z = z;
		_dirty = true;
		return this;
	}
	
	public function rotateBy(x: Float, y: Float, z: Float): Transform
	{
		_rotation.x += x;
		_rotation.y += y;
		_rotation.z += z;
		_dirty = true;
		return this;
	}
	
	public function scaleTo(x: Float, y: Float, z: Float): Transform
	{
		_scale.x = x;
		_scale.y = y;
		_scale.z = z;
		_dirty = true;
		return this;
	}
	
	public function scaleBy(x: Float, y: Float, z: Float): Transform
	{
		_scale.x *= x;
		_scale.y *= y;
		_scale.z *= z;
		_dirty = true;
		return this;
	}
	
	public function getMatrix(): Mat4
	{
		if (_dirty)
		{
			_matrix.identity().scale(_scale.x, _scale.y, _scale.z).translate(_position.x, _position.y, _position.z).rotate(_rotation.x, Vector3D.X_AXIS).rotate(_rotation.y, Vector3D.Y_AXIS).rotate(_rotation.z, Vector3D.Z_AXIS);	
			_dirty = false;
		}
		
		return _matrix;
	}
}