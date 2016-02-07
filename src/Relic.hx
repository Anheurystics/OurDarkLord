package;
import openfl.Lib;

class Relic extends Entity
{
	public static var STATE_GROUND: Int = 0;
	public static var STATE_HELD: Int = 1;
	public static var STATE_THROWN: Int = 2;
	
	public var state: Int;
	public var type: String;
	
	var hoverAngle: Float = 0;
	var fallSpeed: Float = 0;
	public var owner: Player;
	
	public var isOnCircle: Bool = false;
	
	public function new(_x: Float, _z: Float, _type: String) 
	{
		super(_x, _z);
		
		sprite = Billboard.create(Billboard.STATIC);
		sprite.xScale = sprite.yScale = 0.4;
		
		sprite.y = -0.3;
		type = _type;
		
		state = STATE_GROUND;
	}
	
	override public function update(delta:Float, game:GameInfo):Void 
	{
		super.update(delta, game);
		
		x = Utils.clamp(x, -game.bounds / 2, game.bounds / 2);
		z = Utils.clamp(z, -game.bounds / 2, game.bounds / 2);	
		
		sprite.update(delta, game);
		
		hoverAngle += 90 * delta;
		if (hoverAngle >= 360) hoverAngle -= 360;
		
		if (state == STATE_THROWN)
		{
			sprite.y -= fallSpeed * delta;
			fallSpeed += 2.0 * delta;
			
			for (player in game.players)
			{
				if (player == owner) continue;
				
				var dist: Float = Utils.dist(x, z, player.x, player.z);
				
				if (dist < 0.5)
				{
					player.dislodgeRelic(this);
					
					velocityX *= -0.5;
					velocityZ *= -0.5;
					break;
				}
			}
			
			if (sprite.y <= -0.3)
			{
				sprite.y = -0.3;	
				state = STATE_GROUND;
				velocityX = velocityZ = 0;
				fallSpeed = 0;
			}
			
			
			sprite.x = x;
			sprite.z = z;
		}
			
		if (state == STATE_GROUND)
		{
			owner = null;
			sprite.y = -0.25 + (Math.cos(Utils.toRad(hoverAngle)) * 0.05);
			fallSpeed = 0;
			
			sprite.x = x;
			sprite.z = z;
		}
		
		if (state == STATE_HELD)
		{
			sprite.x = owner.x + (Math.cos(Utils.toRad(owner.lookAngle)) * 0.25);
			sprite.y = (Math.cos(Utils.toRad(hoverAngle)) * 0.05);
			sprite.z = owner.z + (Math.sin(Utils.toRad(owner.lookAngle)) * 0.25);
		}
		
		isOnCircle = (state == STATE_GROUND) && (Utils.dist(x, z, game.circle.x, game.circle.z) < game.circle.scale / 2);
	}
}