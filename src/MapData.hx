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
		
		var point: Point = new Point();
		var d: Int = skyboxDimension;
		var front: BitmapData = new BitmapData(d, d);
		front.copyPixels(skyboxImage, new Rectangle(0, d, d, d), point);
		var left: BitmapData = new BitmapData(d, d);
		left.copyPixels(skyboxImage, new Rectangle(d, d, d, d), point);
		var back: BitmapData = new BitmapData(d, d);
		back.copyPixels(skyboxImage, new Rectangle(d * 2, d, d, d), point);
		var right: BitmapData = new BitmapData(d, d);
		right.copyPixels(skyboxImage, new Rectangle(d * 3, d, d, d), point);
		var up: BitmapData = new BitmapData(d, d);
		up.copyPixels(skyboxImage, new Rectangle(d * 3, 0, d, d), point);
		var down: BitmapData = new BitmapData(d, d);
		down.copyPixels(skyboxImage, new Rectangle(d * 3, d * 2, d, d), point);
		
		GL.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X, 0, GL.RGBA, d, d, 0, GL.RGBA, GL.UNSIGNED_BYTE, right.image.data);
		GL.texImage2D(GL.TEXTURE_CUBE_MAP_NEGATIVE_X, 0, GL.RGBA, d, d, 0, GL.RGBA, GL.UNSIGNED_BYTE, left.image.data);
		GL.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_Y, 0, GL.RGBA, d, d, 0, GL.RGBA, GL.UNSIGNED_BYTE, up.image.data);
		GL.texImage2D(GL.TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, GL.RGBA, d, d, 0, GL.RGBA, GL.UNSIGNED_BYTE, down.image.data);
		GL.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_Z, 0, GL.RGBA, d, d, 0, GL.RGBA, GL.UNSIGNED_BYTE, back.image.data);
		GL.texImage2D(GL.TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, GL.RGBA, d, d, 0, GL.RGBA, GL.UNSIGNED_BYTE, front.image.data);
		
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