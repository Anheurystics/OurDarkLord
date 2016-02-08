package;
import haxe.ds.Vector;
import openfl.Lib;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;
import openfl.utils.Float32Array;

class Camera
{
	public static var current: Camera;
	
	public var position: Vector3D;
	public var front: Vector3D;
	public var right: Vector3D;
	public var up: Vector3D;
	public var globalUp: Vector3D;
	public var yaw: Float;
	public var pitch: Float;
	
	var _view: Mat4;
	var _projection: Mat4;
	var _fov: Float = 74;
	
	public function new(position: Vector3D = null, up: Vector3D = null, yaw = 0, pitch = 0)
	{
		if (position == null) position = new Vector3D(0, 0, 0);
		if (up == null) up = new Vector3D(0, 1, 0);
		this.position = position;
		this.globalUp = this.up = up;
		this.front = new Vector3D(0, 0, -1);
		this.right = this.front.crossProduct(this.globalUp);
		this.yaw = yaw;
		this.pitch = pitch;
		
		_view = new Mat4();
		_projection = new Mat4().perspective(_fov, Lib.current.stage.stageWidth / Lib.current.stage.stageHeight, 0.1, 100.0);
	}
	
	public function setToPlayer(player: Player): Void
	{
		position.x = player.x;
		position.y = 0.25;
		position.z = player.z;
		yaw = player.lookAngle;
		_fov = player.fov;
	}
	
	public function update(): Void
	{
		var newFront: Vector3D = new Vector3D();
		var yawR: Float = Utils.toRad(yaw);
		var pitchR: Float = Utils.toRad(pitch);
		
		newFront.x = Math.cos(yawR) * Math.cos(pitchR);
		newFront.y = Math.sin(pitchR);
		newFront.z = Math.sin(yawR) * Math.cos(pitchR);
		
		front = newFront;
		
		right = front.crossProduct(globalUp);
		right.normalize();
		
		up = right.crossProduct(front);
		up.normalize();
		
		_projection = new Mat4().perspective(_fov, Lib.current.stage.stageWidth / Lib.current.stage.stageHeight, 0.1, 100.0);
	}
	
	public function updateProjection(aspect: Float): Void
	{
		_projection.perspective(_fov, aspect, 0.1, 100.0);
	}
	
	public function getProjection(): Mat4
	{
		return _projection;
	}
	
	public function getView(): Mat4
	{
		_view.lookAt(position, position.add(front), up);
		
		return _view;
	}
}