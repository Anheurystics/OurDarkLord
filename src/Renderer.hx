package;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import openfl.utils.Int16Array;

typedef Attrib = 
{
	var name: String;
	var size: Int;
}

class Renderer
{
	var program: ShaderProgram;

	var vertexBuffer: GLBuffer;
	var indexBuffer: GLBuffer;

	var nVertices: Int;
	var nIndices: Int;
	
	var attribs: Map<String, Array<Attrib>>;
	var currentLayout: String;
	var attribSize: Map<String, Int>;
	
	public function new() 
	{
		vertexBuffer = GL.createBuffer();
		indexBuffer = GL.createBuffer();
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(1024), GL.DYNAMIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Int16Array(512), GL.DYNAMIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		
		attribs = new Map();
		attribSize = new Map();
	}
	
	public function setAttribLayout(name: String): Void
	{
		if (!attribs.exists(name))
		{
			attribs.set(name, new Array());
			attribSize.set(name, 0);
		}
		
		currentLayout = name;
	}
	
	public function addAttrib(name: String, size: Int): Void
	{
		attribs.get(currentLayout).push( { name: name, size: size } );
		attribSize.set(currentLayout, attribSize.get(currentLayout) + size);
	}	
	
	public function uploadProgram(program: ShaderProgram)
	{
		this.program = program;
		program.bind();
	}
	
	public function uploadMesh(mesh: Mesh): Void
	{		
		nVertices = mesh.nVertices;
		nIndices = mesh.nIndices;
		currentLayout = mesh.layout;
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, mesh.vertexArr);
		
		var off: Int = 0;
		for (att in attribs.get(currentLayout))
		{
			var loc: Int = program.attribLocation(att.name);
			if (loc != -1)
			{
				GL.vertexAttribPointer(loc, att.size, GL.FLOAT, false, attribSize.get(currentLayout) * Float32Array.BYTES_PER_ELEMENT, off);
				GL.enableVertexAttribArray(loc);
				off += att.size * Float32Array.BYTES_PER_ELEMENT;
			}
		}
		
		if (nIndices > 0)
		{
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
			GL.bufferSubData(GL.ELEMENT_ARRAY_BUFFER, 0, mesh.indexArr);		
		}
	}
	
	public function renderMesh(transform: Mat4 = null): Void
	{
		if (transform != null)
		{
			GL.uniformMatrix4fv(program.uniform("model"), false, transform.array());
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
}