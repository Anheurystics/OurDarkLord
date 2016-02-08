package;
import openfl.display.OpenGLView;
import openfl.geom.Rectangle;

class GLMenu extends OpenGLView
{

	public function new() 
	{
		super();
		
		render = glRender;
	}

	function glRender(rect: Rectangle): Void
	{
		
	}
}