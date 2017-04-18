package;

import openfl.gl.GL;
import openfl.gl.GLUniformLocation;
import openfl.utils.Float32Array;
import openfl.utils.Int32Array;

typedef Attrib = 
{
	var name: String;
	var size: Int;
}

class Renderer
{
	var program: ShaderProgram;

	var nVertices: Int;
	var nIndices: Int;
	
	public function new() 
	{
	}

	public function viewport(x: Int, y: Int, w: Int, h: Int): Void
	{
		GL.viewport(x, y, w, h);
	}
	
	public function depthTest(func: Int = null): Void
	{
		if (func != null)
		{
			GL.enable(GL.DEPTH_TEST);
			GL.depthFunc(func);
		}
		else
		{
			GL.disable(GL.DEPTH_TEST);
		}
	}
	
	public function blend(src: Int = null, dest: Int = null): Void
	{
		if (src != null && dest != null)
		{
			GL.enable(GL.BLEND);
			GL.blendFunc(src, dest);
		}
		else
		{
			GL.disable(GL.BLEND);
		}
	}
	
	public function clear(r: Float = 0.0, g: Float = 0.0, b: Float = 0.0)
	{
		GL.clearColor(r, g, b, 1.0);	
		GL.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);		
	}
	
	public function uploadProgram(program: ShaderProgram)
	{
		this.program = program;
		program.bind();
	}
	
	public function uploadTexture(tex: Texture, unit: Int = GL.TEXTURE0)
	{
		GL.activeTexture(unit);
		GL.bindTexture(GL.TEXTURE_2D, tex.unit);
	}
	
	public function uploadMesh(mesh: Mesh): Void
	{		
		nVertices = mesh.nVertices;
		nIndices = mesh.nIndices;
		
		GL.bindBuffer(GL.ARRAY_BUFFER, mesh.vertexBuffer);
		
		var off: Int = 0;
		for (i in 0...mesh.attribNames.length)
		{
			var loc: Int = program.attribLocation(mesh.attribNames[i]);
			if (loc != -1)
			{
				GL.vertexAttribPointer(loc, mesh.attribSizes[i], GL.FLOAT, false, mesh.totalAttribSize * Float32Array.BYTES_PER_ELEMENT, off);
				GL.enableVertexAttribArray(loc);
				off += mesh.attribSizes[i] * Float32Array.BYTES_PER_ELEMENT;
			}
		}
		
		if (nIndices > 0)
		{
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, mesh.indexBuffer);	
		}
	}
	
	public function renderMesh(transform: Mat4 = null): Void
	{
		if (transform != null)
		{
			uniformMatrix("model", transform);
		}
			
		if (nIndices > 0)
		{
			GL.drawElements(GL.TRIANGLES, nIndices, GL.UNSIGNED_SHORT, 0);
		}
		else
		{
			GL.drawArrays(GL.TRIANGLES, 0, Std.int(nVertices / 3));
		}
	}
	
	public function uniformf(name: String, d1: Float, d2: Float = null, d3: Float = null, d4: Float = null)
	{
		var loc: GLUniformLocation = program.uniform(name);
		if (d2 == null) 		GL.uniform1f(loc, d1);
		else if (d3 == null) 	GL.uniform2f(loc, d1, d2);
		else if (d4 == null) 	GL.uniform3f(loc, d1, d2, d3);
		else 					GL.uniform4f(loc, d1, d2, d3, d4);
	}
	
	var uniformFV: Array<Dynamic> = [GL.uniform1fv, GL.uniform2fv, GL.uniform3fv, GL.uniform4fv];
	public function uniformfv(name: String, arr: Float32Array)
	{
		var loc: GLUniformLocation = program.uniform(name);
		uniformFV[arr.length - 1](loc, arr.length, arr#if(js && html5 && display), 0#end);
	}
	
	var uniformIV: Array<Dynamic> = [GL.uniform1iv, GL.uniform2iv, GL.uniform3iv, GL.uniform4iv];
	public function uniformiv(name: String, arr: Int32Array)
	{
		var loc: GLUniformLocation = program.uniform(name);
		uniformIV[arr.length - 1](loc, arr.length, arr#if(js && html5 && display), 0#end);
	}
	
	public function uniformi(name: String, d1: Int, d2: Int = null, d3: Int = null, d4: Int = null)
	{
		var loc: GLUniformLocation = program.uniform(name);
		if (d2 == null) 		GL.uniform1i(loc, d1);
		else if (d3 == null) 	GL.uniform2i(loc, d1, d2);
		else if (d4 == null) 	GL.uniform3i(loc, d1, d2, d3);
		else 					GL.uniform4i(loc, d1, d2, d3, d4);
	}
	
	public function uniformMatrix(name: String, mat: Mat): Void
	{
		if (mat.type() == 4)
		{
			GL.uniformMatrix4fv(program.uniform(name), 1, false, mat.array());
		}
	}
}	