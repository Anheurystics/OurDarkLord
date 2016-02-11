package;

import openfl.geom.Rectangle;
import openfl.gl.GL;

class TextureManager
{	
	static var textures: Map<String, Texture> = new Map();
	static var areas: Map<String, Map<String, Rectangle>> = new Map();
	
	public static function load(name: String, source: Dynamic, filter: Int = GL.NEAREST)
	{
		textures.set(name, new Texture(source, filter));
	}
	
	public static function setTextureArea(textureName: String, areaName: String, area: Rectangle)
	{
		if (areas.get(textureName) == null)
		{
			areas.set(textureName, new Map<String, Rectangle>());
		}
		
		areas.get(textureName).set(areaName, area);
	}
	
	public static function get(name: String): Texture
	{
		return textures.get(name);
	}
}