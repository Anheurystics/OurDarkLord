package;
import flash.geom.Vector3D;
import openfl.display.OpenGLView;
import openfl.geom.Rectangle;
import openfl.gl.GL;

class GLMenu extends OpenGLView
{
	var renderer: Renderer;
	var simpleProgram: ShaderProgram;
	var quad: Mesh;
	var cam: Camera;
	
	var cultist1: Billboard;
	var cultist2: Billboard;
	var cultist3: Billboard;
	var cultist4: Billboard;
	var cultist5: Billboard;
	
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
		cam.position.y = 0.75;
		cam.position.x = -3.5;
		cam.yaw = 0;
		
		//Not sure why valeus are these :O
		cultist1 = placeCultist(0);
		cultist2 = placeCultist(60);
		cultist3 = placeCultist(-60);
		cultist4 = placeCultist(120);
		cultist5 = placeCultist(-120);
		
		renderer.uploadProgram(simpleProgram);
		renderer.uniformi("tex1", 0);
		renderer.uniformi("useFog", 1);
		renderer.uniformf("fogDistance", 6);
		renderer.uniformf("fogRate", 1);
		renderer.uniformf("fogColor", 0.1, 0.1, 0.1, 1.0);
		renderer.uniformf("cameraPos", cam.position.x, cam.position.y, cam.position.z);
	}

	function placeCultist(angle: Float): Billboard
	{
		var cultist: Billboard = Billboard.create(Billboard.PERSPECTIVE_MIN);
		cultist.x = Math.cos(Utils.toRad(angle)) * 2;
		cultist.z = Math.sin(Utils.toRad(angle)) * 2;
		cultist.angleOffset = angle + 180;
		
		return cultist;
	}
	
	function glRender(rect: Rectangle): Void
	{
		Camera.current = cam;
		
		cam.update();
		
		renderer.depthTest(GL.LEQUAL);
		renderer.blend(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		renderer.clear(0.1, 0.1, 0.1);
		
		renderer.uploadProgram(simpleProgram);
		
		renderer.uniformf("flipX", 1);
		renderer.uniformf("offset", 0, 0);
		renderer.uniformf("tile", 1, 1);		
		
		renderer.uniformMatrix("view", cam.getView());
		renderer.uniformMatrix("proj", cam.getProjection());
		
		renderer.uploadMesh(quad);
		var mat: Mat4 = new Mat4().rotate(-90, Vector3D.X_AXIS).scale(30.0, 1.0, 30.0).translate(0, -0.5, 0);		
		renderer.uniformf("tile", 30, 30);
		TextureManager.get("cobble").bind(GL.TEXTURE0);
		renderer.renderMesh(mat);	
		
		mat.identity().rotate( -90, Vector3D.X_AXIS).scale(4.0, 1.0, 4.0).translate(0, -0.49, 0);
		renderer.uniformf("tile", 1, 1);
		TextureManager.get("circle_1").bind(GL.TEXTURE0);
		renderer.renderMesh(mat);
		
		TextureManager.get("cultist_sheet").bind(GL.TEXTURE0);
		cultist1.bind(renderer);
		renderer.renderMesh();
		cultist2.bind(renderer);
		renderer.renderMesh();
		cultist3.bind(renderer);
		renderer.renderMesh();
		cultist4.bind(renderer);
		renderer.renderMesh();
		cultist5.bind(renderer);
		renderer.renderMesh();
	}
}