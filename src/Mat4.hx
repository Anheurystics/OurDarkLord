package;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;
import openfl.utils.Float32Array;

class Mat4
{
	private var _matrix: Matrix3D;
	private var _array: Float32Array;
	
	public function new() 
	{
		_matrix = new Matrix3D();
		_array = new Float32Array(16);
	}
	
	public function identity(): Mat4
	{
		_matrix.identity();
		return this;
	}
	
	public function translate(x: Float = 0, y: Float = 0, z: Float = 0): Mat4
	{
		_matrix.appendTranslation(x, y, z);
		return this;
	}
	
	public function rotate(degrees: Float, axis: Vector3D, pivotPoint: Vector3D = null): Mat4
	{
		_matrix.appendRotation(degrees, axis, pivotPoint);
		return this;
	}
	
	public function scale(x: Float = 1, y: Float = 1, z: Float = 1): Mat4
	{
		_matrix.appendScale(x, y, z);
		return this;
	}
	
	public function array(): Float32Array
	{
		for (i in 0...16)
		{
			_array[i] = _matrix.rawData[i];
		}
		return _array;
	}
	
	public function perspective(fov: Float, aspect: Float, near: Float, far: Float): Mat4
	{		
		var f: Float = 1.0 / Math.tan(Utils.toRad(fov) / 2);
		var nf: Float = 1 / (near - far);
		
		_matrix.rawData = [
			f / aspect, 0, 0, 0,
			0, f, 0, 0,
			0, 0, (far + near) * nf, -1,
			0, 0, (2 * far * near) * nf, 0
		];
		
		return this;
	}
	
	public function ortho(x0:Float, x1:Float, y0:Float, y1:Float, zNear:Float, zFar:Float): Mat4
	{	
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		var sz = 1.0 / (zFar - zNear);
		
		_matrix.rawData = [ 2.0 * sx, 0, 0, 0, 0, 2.0 * sy, 0, 0, 0, 0, -2.0 * sz, 0, -(x0 + x1) * sx, -(y0 + y1) * sy, -(zNear + zFar) * sz, 1 ];			
	
		return this;
	}

	static var X: Vector3D = new Vector3D();
	static var Y: Vector3D = new Vector3D();
	static var Z: Vector3D = new Vector3D();	
	public function lookAt(position: Vector3D, target: Vector3D, up: Vector3D): Mat4
	{
		X.setTo(0, 0, 0);
		Y.setTo(0, 0, 0);
		Z.setTo(0, 0, 0);
		
		Z = position.subtract(target);
		Z.normalize();
		X = up.crossProduct(Z);
		Y = Z.crossProduct(X);
		X.normalize();
		Y.normalize();
		
		_matrix.rawData = 
			[
				X.x, Y.x, Z.x, 0,
				X.y, Y.y, Z.y, 0,
				X.z, Y.z, Z.z, 0,
				-X.dotProduct(position), -Y.dotProduct(position), -Z.dotProduct(position), 1
			];
			
		return this;
	}
}