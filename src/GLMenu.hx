package;
import flash.geom.Vector3D;
import openfl.display.OpenGLView;
import openfl.geom.Rectangle;

class GLMenu extends OpenGLView
{
	var renderer: Renderer;
	var simpleProgram: ShaderProgram;
	var quad: Mesh;
	var cam: Camera;
	
	public function new() 
	{
		super();
		
		TextureManager.load("cobble", "graphics/cobble.png");
		
		TextureManager.load("black_candle", 	"graphics/black_candle.png");
		TextureManager.load("suggestive_book", 	"graphics/suggestive_book.png");
		TextureManager.load("donut", 			"graphics/donut.png");
		TextureManager.load("dummy", 			"graphics/dummy.png");
		TextureManager.load("moms_spaghetti", 	"graphics/moms_spaghetti.png");
		TextureManager.load("rabbit", 			"graphics/rabbit.png");
		TextureManager.load("small_loan", 		"graphics/small_loan.png");
		TextureManager.load("spork", 			"graphics/spork.png");
		
		TextureManager.load("cultist_sheet", 	"graphics/cultist_sheet.png");
		
		TextureManager.load("circle_1", 		"graphics/circle_1.png");
		
		TextureManager.load("stamina",			"graphics/stamina.png");
		TextureManager.load("summon",			"graphics/summon.png");		
		
		render = glRender;
		
		renderer = new Renderer();
		simpleProgram = new ShaderProgram("simple", "simple");
		
		quad = new Mesh(Geometry.quadVertices, Geometry.quadIndices, ["position", "texCoord", "normal"], [3, 2, 3]);
		
		cam = new Camera();
		cam.yaw = 0;
	}

	function glRender(rect: Rectangle): Void
	{
		
	}
}