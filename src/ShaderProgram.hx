package;

import openfl.Assets;
import lime.graphics.WebGLRenderContext;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;

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

	var gl: WebGLRenderContext;
	
	public function new(_gl: WebGLRenderContext, _vertName: String, _fragName: String) 
	{
		gl = _gl;
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
		
		unit = gl.createProgram();
		
		vertex = gl.createShader(gl.VERTEX_SHADER);
		gl.shaderSource(vertex, vertSrc);
		gl.compileShader(vertex);
		if (gl.getShaderParameter(vertex, gl.COMPILE_STATUS) != 1)
		{
			trace("VERTEX SHADER (" + vertName + "): " + gl.getShaderInfoLog(vertex));
		}

		fragment = gl.createShader(gl.FRAGMENT_SHADER);
		gl.shaderSource(fragment, fragSrc);
		gl.compileShader(fragment);
		if (gl.getShaderParameter(fragment, gl.COMPILE_STATUS) != 1)
		{
			trace("FRAGMENT SHADER (" + fragName + "): " + gl.getShaderInfoLog(fragment));
		}
		
		gl.attachShader(unit, vertex);
		gl.attachShader(unit, fragment);
		gl.linkProgram(unit);
		if (gl.getProgramParameter(unit, gl.LINK_STATUS) != 1)
		{
			trace(gl.getProgramInfoLog(unit));
		}
	}
	
	public function bind(): Void
	{
		gl.useProgram(unit);
	}
	
	public function uniform(name: String): GLUniformLocation
	{
		if (uniformLocations.exists(name)) return uniformLocations.get(name);
		var loc: GLUniformLocation = gl.getUniformLocation(unit, name);
		uniformLocations.set(name, loc);
		return loc;
	}
	
	public function attribLocation(name: String): Int
	{
		if (attribLocations.exists(name)) return attribLocations.get(name);
		var loc: Int = gl.getAttribLocation(unit, name);
		attribLocations.set(name, loc);
		return loc;		
	}
	
	public function unbind(): Void
	{
		gl.useProgram(null);
	}
}
