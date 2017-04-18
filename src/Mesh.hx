package;

import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import openfl.utils.Int16Array;

class Mesh
{	
	public var attribNames: Array<String>;
	public var attribSizes: Array<Int>;
	
	public var vertexBuffer: GLBuffer;
	public var indexBuffer: GLBuffer;
	
	public var nVertices: Int;
	public var nIndices: Int;
	
	public var totalAttribSize: Int;

	public function new(vertices: Array<Float>, indices: Array<Int>, attribNames: Array<String>, attribSizes: Array<Int>) 
	{		
		nVertices = vertices.length;
		nIndices = indices.length;
		
		vertexBuffer = GL.createBuffer();
		indexBuffer = GL.createBuffer();
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferData(GL.ARRAY_BUFFER, vertices.length * 4, new Float32Array(vertices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices.length * 2, new Int16Array(indices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		
		this.attribNames = attribNames;
		this.attribSizes = attribSizes;
		
		totalAttribSize = 0;
		for (size in attribSizes)
		{
			totalAttribSize += size;
		}
	}
}