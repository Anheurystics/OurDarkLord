package;

import openfl.geom.Matrix3D;
import openfl.geom.Transform;
import openfl.geom.Vector3D;
import openfl.gl.GL;
import openfl.utils.Float32Array;

typedef Sequence =
{
	var name: String;
	var order: Array<Int>;
	var framerate: Float;
	var loop: Bool;
};

class Billboard
{	
	public static inline var STATIC: Int = 0;
	public static inline var PERSPECTIVE: Int = 1;
	public static inline var PERSPECTIVE_MIN: Int = 2;
	
	var type: Int;
	public var angle: Int;
	
	public var isAnimated: Bool;
	public var frameWidth: Int;
	public var frameHeight: Int;
	
	public var current: Sequence;
	public var frame: Int;
	
	public var x: Float;
	public var y: Float;
	public var z: Float;
	public var xScale: Float;
	public var yScale: Float;
	public var lookAt: Vector3D;
	
	public var angleOffset: Float = 0;
	
	var rows: Int;
	var columns: Int;
	
	var timer: Float;
	var finishCallback: String->String->Void;
	
	var sequences: Map<String, Sequence>;
	
	var matrix: Mat4;
	
	function new()
	{
		angle = 0;
		x = 0;
		y = 0;
		z = 0;
		xScale = 1;
		yScale = 1;
		lookAt = null;
		
		matrix = new Mat4();
	}
	
	public static function create(_type: Int): Billboard
	{
		var sprite: Billboard = new Billboard();
		sprite.isAnimated = false;
		sprite.type = _type;
		return sprite;
	}
	
	public static function createAnimated(_type: Int, _rows: Int, _columns: Int, _finishCallback: String->String->Void = null): Billboard
	{
		var sprite: Billboard = new Billboard();

		sprite.isAnimated = true;
		sprite.type = _type;
		sprite.columns = _columns;
		sprite.rows = _rows;
		sprite.finishCallback = _finishCallback;
		sprite.sequences = new Map();
		sprite.timer = 0;
		return sprite;
	}
	
	public function define(name: String, order: Array<Int>, framerate: Float, loop: Bool): Void
	{
		sequences.set(name, { name: name, order: order, framerate: framerate, loop: loop } );
	}
	
	public function play(name: String, restart: Bool = false): Void
	{
		var seq: Sequence = sequences.get(name);
		if (seq != null)
		{
			if (current != null && seq.name == current.name)
			{
				if (restart)
				{
					timer = 0;
					frame = 0;
				}
			}
			else
			{
				current = seq;
				timer = 0;
				frame = 0;
			}
		}
	}
	
	public function update(delta: Float, gameInfo: GameInfo): Void
	{
		if (current != null)
		{
			timer += delta;
			if (timer >= 1 / current.framerate)
			{
				timer = 0;
				frame += 1;
				if (frame == current.order.length)
				{
					frame = current.loop? 0 : current.order.length - 1;
					if (finishCallback != null)
					{
						finishCallback(frame == 0? "repeat" : "end", current.name);
					}
				}
			}
		}
	}
	
	public function bind(renderer: Renderer): Void
	{
		lookAt = Camera.current.position;
		var diff1: Float = Math.atan2(z - lookAt.z, x -  lookAt.x);
		diff1 = Utils.toDeg(diff1) - angleOffset;
		if (diff1 < 0) diff1 += 360;
		diff1 += 180;
		diff1 %= 360;
		
		angle = Math.round(diff1 / 45);
		
		if (!isAnimated)
		{
			if (type != STATIC)
			{
				var flipX: Int = 1;
				var angles: Int = 8;
				
				if (type == PERSPECTIVE_MIN)
				{
					angles = 5;
					if (angle > 4) 
					{
						angle = 8 - angle;
						flipX = -1;
					}
				}
				
				renderer.uniformf("flipX", flipX);
				renderer.uniformf("offset", angle / angles, 0);
				renderer.uniformf("tile", 1 / angles, 1);
			}
			else
			{
				renderer.uniformf("flipX", 1);
				renderer.uniformf("offset", 0, 0);
				renderer.uniformf("tile", 1, 1);
			}
		}
		else
		{
			var currentIndex: Int = current.order[frame];
			
			var widthRatio: Float = 1 / columns;
			var heightRatio: Float = 1 / rows;
			
			var i: Int = 0;
			var j: Int = 0;
			
			var flipX: Int = 1;
			
			if (type == STATIC)
			{
				i = currentIndex % columns;
				j = Std.int(currentIndex / columns);
			}
			else
			{
				if (type == PERSPECTIVE_MIN && angle >= 5)
				{
					if (angle > 4) 
					{
						angle = 8 - angle;
						flipX = -1;
					}
				}
				
				i = angle;
				j = currentIndex % rows;
			}
			
			renderer.uniformf("flipX", flipX);
			renderer.uniformf("offset", i * widthRatio, j * heightRatio);
			renderer.uniformf("tile", widthRatio, heightRatio);			
		}
		
		matrix.identity().scale(xScale, yScale, 0).rotate(Std.int(Utils.toDeg(Math.atan2(lookAt.x - x, lookAt.z - z)) / 5) * 5, Vector3D.Y_AXIS).translate(x, y, z);
		renderer.uniformMatrix("model", matrix);
	}
}