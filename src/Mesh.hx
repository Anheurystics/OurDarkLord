package;

import openfl.utils.Float32Array;
import openfl.utils.Int16Array;

class Mesh
{	
	public var nVertices: Int;
	public var nIndices: Int;

	public var vertexArr: Float32Array;
	public var indexArr: Int16Array;
	
	public var layout: String;
	
	public function new(vertices: Array<Float>, indices: Array<Int>, layout: String) 
	{		
		vertexArr = new Float32Array(vertices);
		indexArr = new Int16Array(indices);
		
		nVertices = vertices.length;
		nIndices = indices.length;
		
		this.layout = layout;
	}
}