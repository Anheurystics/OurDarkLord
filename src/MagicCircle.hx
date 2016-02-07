package;

class MagicCircle extends Entity
{	
	public var scale: Float;
	
	public function new(x: Float, z: Float, scale: Float) 
	{
		super(x, z);
		this.scale = scale;
		
		sprite = Billboard.create(Billboard.STATIC);
	}
	
	override public function update(delta:Float, game:GameInfo):Void 
	{
		super.update(delta, game);
		
		sprite.x = x;
		sprite.z = z;
	}
}