package;

import openfl.geom.Rectangle;

class TextureManager
{	
	static var textures: Map<String, Texture> = new Map();
	static var areas: Map<String, Map<String, Rectangle>> = new Map();
	
	public static function load(name: String, path: String): Void
	{
		textures.set(name, new Texture(path));
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