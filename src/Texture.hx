package;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.utils.UInt8Array;

class Texture
{	
	static var textures: Array<Texture> = new Array();
	public static function restoreAll(): Void
	{
		for (texture in textures)
		{
			texture.restore();
		}
	}	
	
	var tex: GLTexture;
	
	public var width: Int;
	public var height: Int;
	var source: Dynamic;
	
	public function new(_source: Dynamic)
	{
		source = _source;
		
		restore();
		textures.push(this);
	}
	
	public function restore(): Void
	{
		var bitmapData: BitmapData = null;
		if(Std.is(source, BitmapData))
			bitmapData = cast(source, BitmapData);
		if (Std.is(source, String))
			bitmapData = Assets.getBitmapData(cast(source, String));
			
		if (bitmapData == null)
		{
			return;
		}
			
		width = bitmapData.width;
		height = bitmapData.height;
			
		#if lime
		var pixels = bitmapData.image.data;
		#else
		var pixels = new UInt8Array(bitmapData.getPixels(bitmapData.rect));
		#end
		
		tex = GL.createTexture();
		
		var wrap: Int = GL.REPEAT;
		#if html5
		if (!isPowerOfTwo(bitmapData.width) || !isPowerOfTwo(bitmapData.height))
		{
			wrap = GL.CLAMP_TO_EDGE;
		}
		#end
		
		GL.bindTexture(GL.TEXTURE_2D, tex);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, wrap);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, wrap);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, bitmapData.width, bitmapData.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, pixels);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		GL.bindTexture (GL.TEXTURE_2D, null);
	}
	
	function isPowerOfTwo(n: Int): Bool
	{
		while (n & 1 == 0 && n != 1)
		{
			n = n >> 1;
		}
		return n == 1;
	}
	
	public function bind(unit: Int): Void
	{
		GL.activeTexture(unit);
		GL.bindTexture(GL.TEXTURE_2D, tex);
	}
	
	public function unbind(): Void
	{
		GL.bindTexture (GL.TEXTURE_2D, null);
	}
}