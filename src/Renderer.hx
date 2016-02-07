package;
import openfl.gl.GL;
import openfl.gl.GLBuffer;

class Renderer
{
	var program: ShaderProgram;

	var vertexBuffer: GLBuffer;
	var indexBuffer: GLBuffer;
	
	public function new() 
	{
		vertexBuffer = GL.createBuffer();
		indexBuffer = GL.createBuffer();
	}
	
	public function uploadMesh(mesh: Mesh): Void
	{
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		
	}
	
	public function renderMesh(transform: Mat4 = null): Void
	{
		
	}
}