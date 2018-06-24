package;

import lime.graphics.opengl.WebGLContext;
import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

class Mesh
{	
	public var attribNames: Array<String>;
	public var attribSizes: Array<Int>;
	
	public var vertexBuffer: GLBuffer;
	public var indexBuffer: GLBuffer;
	
	public var nVertices: Int;
	public var nIndices: Int;
	
	public var totalAttribSize: Int;

	public function new(gl: WebGLContext, vertices: Array<Float>, indices: Array<Int>, attribNames: Array<String>, attribSizes: Array<Int>) 
	{		
		nVertices = vertices.length;
		nIndices = indices.length;
		
		vertexBuffer = gl.createBuffer();
		indexBuffer = gl.createBuffer();
		
		gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
		gl.bindBuffer(gl.ARRAY_BUFFER, null);
		
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Int16Array(indices), gl.STATIC_DRAW);
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
		
		this.attribNames = attribNames;
		this.attribSizes = attribSizes;
		
		totalAttribSize = 0;
		for (size in attribSizes)
		{
			totalAttribSize += size;
		}
	}
}