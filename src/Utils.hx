package;

import openfl.geom.Matrix3D;
import openfl.geom.Point;
import openfl.geom.Vector3D;
import openfl.utils.Float32Array;

class Utils
{
	public static function dist(x1: Float, y1: Float, x2: Float, y2: Float): Float
	{
		var dx: Float = x2 - x1;
		var dy: Float = y2 - y1;
		
		return Math.sqrt((dx * dx) + (dy * dy));
	}
	
	public static function rectToRect(x1: Float, y1: Float, w1: Float, h1: Float, x2: Float, y2: Float, w2: Float, h2: Float): Bool
	{
		var xCollide: Bool = Math.abs(x2 - x1) < (w1 + w2) / 2;
		var yCollide: Bool = Math.abs(y2 - y1) < (h1 + h2) / 2;
		return xCollide && yCollide;
	}

	public static function sign(val: Float): Int
	{
		if (val < 0) return -1;
		if (val > 0) return 1;
		return 0;
	}
	
	public static function clamp(val: Float, min: Float, max: Float)
	{
		if (val < min) return min;
		if (val > max) return max;
		return val;
	}
	
	public static function toRad(deg: Float): Float
	{
		return deg * Math.PI / 180;
	}
	
	public static function toDeg(rad: Float): Float
	{
		return rad * 180 / Math.PI;
	}
	
	static var X: Vector3D = new Vector3D();
	static var Y: Vector3D = new Vector3D();
	static var Z: Vector3D = new Vector3D();
	public static function lookAt(position: Vector3D, target: Vector3D, up: Vector3D): Matrix3D
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
		
		return new Matrix3D(
			[
				X.x, Y.x, Z.x, 0,
				X.y, Y.y, Z.y, 0,
				X.z, Y.z, Z.z, 0,
				-X.dotProduct(position), -Y.dotProduct(position), -Z.dotProduct(position), 1
			]
		);		
	}
	
	public static function createPerspective(fov: Float, aspect: Float, near: Float, far: Float)
	{
		var matrix: Matrix3D = new Matrix3D();
		
		var f: Float = 1.0 / Math.tan(Utils.toRad(fov) / 2);
		var nf: Float = 1 / (near - far);
		
		matrix.rawData = [
			f / aspect, 0, 0, 0,
			0, f, 0, 0,
			0, 0, (far + near) * nf, -1,
			0, 0, (2 * far * near) * nf, 0
		];
		
		return matrix;
	}
}