package;
import openfl.geom.Matrix3D;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import openfl.utils.Int16Array;

typedef Attrib = 
{
	var loc: Int;
	var name: String;
	var size: Int;
}

class Mesh
{
	static var meshes: Array<Mesh> = new Array();
	public static function restoreAll(): Void
	{
		for (mesh in meshes)
		{
			mesh.restore();
		}
	}
	
	var vertexBuffer: GLBuffer;
	var indexBuffer: GLBuffer;
	
	var vertexArr: Float32Array;
	var indexArr: Int16Array;
	
	var BYTES_PER_ELEMENT: Int = Float32Array.BYTES_PER_ELEMENT;

	var _vertices: Array <Float>;
	var _indices: Array<Int>;
	
	var _attribs: Array<Attrib>;
	var _attribSize: Int;
	
	public function new(vertices: Array<Float>, indices: Array<Int>) 
	{		
		_vertices = vertices;
		_indices = indices;
		
		_attribs = new Array();
		_attribSize = 0;
		
		restore();
		
		meshes.push(this);
	}

	public function restore(): Void
	{
		vertexBuffer = GL.createBuffer();
		indexBuffer = GL.createBuffer();
		
		vertexArr = new Float32Array(_vertices);
		indexArr = new Int16Array(_indices);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferData(GL.ARRAY_BUFFER, vertexArr, GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		
		if (_indices.length > 0)
		{
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indexArr, GL.STATIC_DRAW);
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		}
	}
	
	public function addAttrib(name: String, size: Int): Void
	{
		_attribs.push( { loc: -1, name: name, size: size } );
		_attribSize += size;
	}
	
	public function bind(shader: ShaderProgram): Void
	{
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		
		var offset: Int = 0;
		for (att in _attribs)
		{
			var location: Int = shader.attribLocation(att.name);
			if (att.loc == -1) att.loc = location;
			
			if (att.loc != -1)
			{
				GL.vertexAttribPointer(att.loc, att.size, GL.FLOAT, false, _attribSize * BYTES_PER_ELEMENT, offset);
				GL.enableVertexAttribArray(att.loc);
				offset += att.size * BYTES_PER_ELEMENT;
			}
		}

		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
	}
	
	public function render(shader: ShaderProgram, transform: Mat4 = null): Void
	{
		if(transform != null) GL.uniformMatrix4fv(shader.uniform("model"), false, transform.array());
		if (_indices.length > 0)
		{
			GL.drawElements(GL.TRIANGLES, _indices.length, GL.UNSIGNED_SHORT, 0);	
		}
		else
		{
			GL.drawArrays(GL.TRIANGLES, 0, Std.int(_vertices.length / 3));
		}
	}
	
	public function unbind(): Void
	{
		for (att in _attribs)
		{
			if(att.loc != -1)
				GL.disableVertexAttribArray(att.loc);
		}
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
	}
}