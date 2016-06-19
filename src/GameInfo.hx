package;

import openfl.geom.Rectangle;

typedef GameInfo = 
{	
	public var players: Array<Player>;
	public var relics: Map<String, Relic>;
	public var viewports: Array<Rectangle>;
	public var circle: MagicCircle;
	public var bounds: Int;
}