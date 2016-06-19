package;

import openfl.Assets;
import openfl.gl.GL;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GLUniformLocation;

class ShaderProgram
{
	static var shaders: Array<ShaderProgram> = new Array();
	public static function restoreAll(): Void
	{
		for (shader in shaders)
		{
			shader.restore();
		}
	}
	
	var vertex: GLShader;
	var fragment: GLShader;
	var unit: GLProgram;
	
	var uniformLocations: Map<String, GLUniformLocation>;
	var attribLocations: Map<String, Int>;
	
	var vertName: String;
	var fragName: String;
	
	public function new(_vertName: String, _fragName: String) 
	{
		vertName = _vertName;
		fragName = _fragName;
		
		restore();
		
		shaders.push(this);
	}
	
	public function restore(): Void
	{
		uniformLocations = new Map();
		attribLocations = new Map();
		
		var vertSrc = Assets.getText("shaders/" + vertName + ".vert");
		var fragSrc = Assets.getText("shaders/" + fragName + ".frag");
		
		#if !html5
		vertSrc = "#version 120\n" + vertSrc;
		fragSrc = "#version 120\n" + fragSrc;
		#else
		fragSrc = "precision mediump float;" + fragSrc;
		
		vertSrc = StringTools.replace(vertSrc, "bgra", "rgba");
		fragSrc = StringTools.replace(fragSrc, "bgra", "rgba");
		#end
		
		unit = GL.createProgram();
		
		vertex = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vertex, vertSrc);
		GL.compileShader(vertex);
		if (GL.getShaderParameter(vertex, GL.COMPILE_STATUS) != 1)
		{
			trace("VERTEX SHADER (" + vertName + "): " + GL.getShaderInfoLog(vertex));
		}

		fragment = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(fragment, fragSrc);
		GL.compileShader(fragment);
		if (GL.getShaderParameter(fragment, GL.COMPILE_STATUS) != 1)
		{
			trace("FRAGMENT SHADER (" + fragName + "): " + GL.getShaderInfoLog(fragment));
		}
		
		GL.attachShader(unit, vertex);
		GL.attachShader(unit, fragment);
		GL.linkProgram(unit);
		if (GL.getProgramParameter(unit, GL.LINK_STATUS) != 1)
		{
			trace(GL.getProgramInfoLog(unit));
		}
	}
	
	public function bind(): Void
	{
		GL.useProgram(unit);
	}
	
	public function uniform(name: String): GLUniformLocation
	{
		if (uniformLocations.exists(name)) return uniformLocations.get(name);
		var loc: GLUniformLocation = GL.getUniformLocation(unit, name);
		uniformLocations.set(name, loc);
		return loc;
	}
	
	public function attribLocation(name: String): Int
	{
		if (attribLocations.exists(name)) return attribLocations.get(name);
		var loc: Int = GL.getAttribLocation(unit, name);
		attribLocations.set(name, loc);
		return loc;		
	}
	
	public function unbind(): Void
	{
		GL.useProgram(null);
	}
}
