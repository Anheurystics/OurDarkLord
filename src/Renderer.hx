package;

import lime.graphics.opengl.WebGLContext;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;
import lime.utils.Int32Array;

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

	var uniformFV: Array<GLUniformLocation -> Float32Array -> Void>;
	var uniformIV: Array<GLUniformLocation -> Int32Array -> Void>;

	var gl: WebGLContext;
	
	public function new(gl: WebGLContext) 
	{
		this.gl = gl;

		uniformFV = [gl.uniform1fv, gl.uniform2fv, gl.uniform3fv, gl.uniform4fv];
		uniformIV = [gl.uniform1iv, gl.uniform2iv, gl.uniform3iv, gl.uniform4iv];
	}

	public function viewport(x: Int, y: Int, w: Int, h: Int): Void
	{
		gl.viewport(x, y, w, h);
	}
	
	public function depthTest(func: Int = null): Void
	{
		if (func != null)
		{
			gl.enable(gl.DEPTH_TEST);
			gl.depthFunc(func);
		}
		else
		{
			gl.disable(gl.DEPTH_TEST);
		}
	}
	
	public function blend(src: Int = null, dest: Int = null): Void
	{
		if (src != null && dest != null)
		{
			gl.enable(gl.BLEND);
			gl.blendFunc(src, dest);
		}
		else
		{
			gl.disable(gl.BLEND);
		}
	}
	
	public function clear(r: Float = 0.0, g: Float = 0.0, b: Float = 0.0)
	{
		gl.clearColor(r, g, b, 1.0);	
		gl.clear(gl.DEPTH_BUFFER_BIT | gl.COLOR_BUFFER_BIT);		
	}
	
	public function uploadProgram(program: ShaderProgram)
	{
		this.program = program;
		program.bind();
	}
	
	public function uploadTexture(tex: Texture, unit: Int = 0)
	{
		unit = gl.TEXTURE0;
		gl.activeTexture(unit);
		gl.bindTexture(gl.TEXTURE_2D, tex.unit);
	}
	
	public function uploadMesh(mesh: Mesh): Void
	{		
		nVertices = mesh.nVertices;
		nIndices = mesh.nIndices;
		
		gl.bindBuffer(gl.ARRAY_BUFFER, mesh.vertexBuffer);
		
		var off: Int = 0;
		for (i in 0...mesh.attribNames.length)
		{
			var loc: Int = program.attribLocation(mesh.attribNames[i]);
			if (loc != -1)
			{
				gl.vertexAttribPointer(loc, mesh.attribSizes[i], gl.FLOAT, false, mesh.totalAttribSize * Float32Array.BYTES_PER_ELEMENT, off);
				gl.enableVertexAttribArray(loc);
				off += mesh.attribSizes[i] * Float32Array.BYTES_PER_ELEMENT;
			}
		}
		
		if (nIndices > 0)
		{
			gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.indexBuffer);	
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
			gl.drawElements(gl.TRIANGLES, nIndices, gl.UNSIGNED_SHORT, 0);
		}
		else
		{
			gl.drawArrays(gl.TRIANGLES, 0, Std.int(nVertices / 3));
		}
	}
	
	public function uniformf(name: String, d1: Float, d2: Float = null, d3: Float = null, d4: Float = null)
	{
		var loc: GLUniformLocation = program.uniform(name);
		if (d2 == null) 		gl.uniform1f(loc, d1);
		else if (d3 == null) 	gl.uniform2f(loc, d1, d2);
		else if (d4 == null) 	gl.uniform3f(loc, d1, d2, d3);
		else 					gl.uniform4f(loc, d1, d2, d3, d4);
	}
	
	public function uniformfv(name: String, arr: Float32Array)
	{
		var loc: GLUniformLocation = program.uniform(name);
		uniformFV[arr.length - 1](loc, arr);
	}
	
	public function uniformiv(name: String, arr: Int32Array)
	{
		var loc: GLUniformLocation = program.uniform(name);
		uniformIV[arr.length - 1](loc, arr);
	}
	
	public function uniformi(name: String, d1: Int, d2: Int = null, d3: Int = null, d4: Int = null)
	{
		var loc: GLUniformLocation = program.uniform(name);
		if (d2 == null) 		gl.uniform1i(loc, d1);
		else if (d3 == null) 	gl.uniform2i(loc, d1, d2);
		else if (d4 == null) 	gl.uniform3i(loc, d1, d2, d3);
		else 					gl.uniform4i(loc, d1, d2, d3, d4);
	}
	
	public function uniformMatrix(name: String, mat: Mat): Void
	{
		if (mat.type() == 4)
		{
			gl.uniformMatrix4fv(program.uniform(name), false, mat.array());
		}
	}
}	