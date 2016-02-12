package;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.gl.GL;
import openfl.gl.GLTexture;

class MapData
{
	var name: String;
	
	var skyboxImage: BitmapData;
	var skyboxDimension: Int;
	public var skyboxFinalSize: Float;
	
	var fieldTexture: Texture;
	public var fieldDimension: Int;
	
	var skyboxTex: GLTexture;
	
	public function new(_name: String, _skyboxImagePath: String, _skyboxDimension: Int, _skyboxFinalSize: Float, _fieldTexturePath: String, _fieldDimension: Int) 
	{
		name = _name;
		skyboxImage = Assets.getBitmapData(_skyboxImagePath);
		skyboxDimension = _skyboxDimension;
		skyboxFinalSize = _skyboxFinalSize;
		TextureManager.load(name + "_field", _fieldTexturePath);
		fieldTexture = TextureManager.get(name + "_field");
		fieldDimension = _fieldDimension;
	}
	
	public function load()
	{
		skyboxTex = GL.createTexture();
		GL.activeTexture(GL.TEXTURE0);
		
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, skyboxTex);
		
		var skyboxTextures: Array<BitmapData> = [];
		var d: Int = skyboxDimension;
		for(i in 0...6)
		{
			skyboxTextures.push(new BitmapData(d, d));
		}
		
		var point: Point = new Point();
		skyboxTextures[0].copyPixels(skyboxImage, new Rectangle(d * 3, d, d, d), point);
		skyboxTextures[1].copyPixels(skyboxImage, new Rectangle(d, d, d, d), point);
		skyboxTextures[2].copyPixels(skyboxImage, new Rectangle(d * 3, 0, d, d), point);
		skyboxTextures[3].copyPixels(skyboxImage, new Rectangle(d * 3, d * 2, d, d), point);
		skyboxTextures[4].copyPixels(skyboxImage, new Rectangle(d * 2, d, d, d), point);
		skyboxTextures[5].copyPixels(skyboxImage, new Rectangle(0, d, d, d), point);
		
		for(i in 0...6)
		{
			GL.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL.RGBA, d, d, 0, GL.RGBA, GL.UNSIGNED_BYTE, skyboxTextures[i].image.data);
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