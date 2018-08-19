package;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;

class MapData
{
	var name: String;
	
	var skyboxImages: Array<BitmapData>;
	var fieldTexture: Texture;
	public var fieldDimension: Int;
	
	var skyboxTex: GLTexture;
	
	public function new(_name: String, _skyboxImagePaths: Array<String>,  _fieldTexturePath: String, _fieldDimension: Int) 
	{
		name = _name;
		skyboxImages = new Array();
		for(path in _skyboxImagePaths)
		{
			skyboxImages.push(Assets.getBitmapData(path));
		}
		TextureManager.load(name + "_field", _fieldTexturePath);
		fieldTexture = TextureManager.get(name + "_field");
		fieldDimension = _fieldDimension;
	}
	
	public function load()
	{
		skyboxTex = GL.createTexture();
		GL.activeTexture(GL.TEXTURE0);
		
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, skyboxTex);
		
		for(i in 0...6)
		{
			var image = skyboxImages[i].image;
			#if html5
			GL.texImage2DWEBGL(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL.RGBA, image.width, image.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, image.data, 0);
			#else
			GL.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL.RGBA, image.width, image.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, image.data);
			#end	
		}
		
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);	
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);	
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);		
	}
	
	public function bindTex(): Void
	{
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, skyboxTex);
	}
	
	public function unbindTex(): Void
	{
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
	}
}