package;

import openfl.Lib;
import openfl.display.OpenGLRenderer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.RenderEvent;
import openfl.geom.Rectangle;
import openfl.geom.Vector3D;
import lime.graphics.opengl.WebGLContext;
import lime.utils.Float32Array;

class Game extends Sprite 
{	
	var renderer: Renderer;
	
	var simpleProgram: ShaderProgram;
	var skyboxProgram: ShaderProgram;
	var overlayProgram: ShaderProgram;
	
	var model: Mat4;
	var orthoView: Mat4;

	var relics: Map<String, Relic> = new Map();

	var cubeMesh: Mesh;
	var quadMesh: Mesh;
	var skyboxMesh: Mesh;
	
	var ceilMatrix: Mat4;
	var floorMatrix: Mat4;
	var circleMatrix: Mat4;
	var skyboxMatrix: Mat4;
	
	var planeWidth: Int;
	var planeLength: Int;

	var overlay: Overlay;
	
	var prevUpdate: Int;
	
	var players: Array<Player>;
	var playerHand: Mat4;
	var gameInfo: GameInfo;
	
	var viewmodelScaleX: Float;
	var viewmodelScaleY: Float;
	
	var colorWhite: Float32Array = new Float32Array([1.0, 1.0, 1.0]);
	var colorRed: Float32Array = new Float32Array([1.0, 0.2, 0.2]);
	var colorGray: Float32Array = new Float32Array([0.3, 0.3, 0.3]);
	
	var viewports: Array<Array<Rectangle>> = [
		[new Rectangle(0, 0, 1, 1)],
		[new Rectangle(0, 0, 1, 0.5), new Rectangle(0, 0.5, 1, 0.5)],
		[new Rectangle(0.25, 0, 0.5, 0.5), new Rectangle(0, 0.5, 0.5, 0.5), new Rectangle(0.5, 0.5, 0.5, 0.5)],
		[new Rectangle(0, 0, 0.5, 0.5), new Rectangle(0.5, 0, 0.5, 0.5),new Rectangle(0, 0.5, 0.5, 0.5), new Rectangle(0.5, 0.5, 0.5, 0.5)]
	];
	
	var relicList: Array<String> = ["black_candle", "suggestive_book", "donut", "dummy", "moms_spaghetti", "rabbit", "small_loan", "spork"];
	
	var desertMap: MapData;
	
	var circle: MagicCircle;
	
	var endGame: Bool = false;
	
	public function new(controls: Array<Int>) 
	{
		super();
		
		gameInfo = {
			players: null,
			relics: null,
			viewports: null,
			circle: null,
			bounds: 0
		};
		
		var desertSkyboxPath = [
			"graphics/Nalovardo/posx.jpg",
			"graphics/Nalovardo/negx.jpg",
			"graphics/Nalovardo/posy.jpg",
			"graphics/Nalovardo/negy.jpg",
			"graphics/Nalovardo/posz.jpg",
			"graphics/Nalovardo/negz.jpg"
		];

		desertMap = new MapData("desert", desertSkyboxPath, "graphics/cobble.png", 25);
		gameInfo.bounds = desertMap.fieldDimension;	
		
		circle = new MagicCircle(0, 0, 2);
		
		players = new Array();
		var angleDiff: Float = Math.PI / controls.length;
		var generatedGoals: Array<Int> = [];
		for (i in 0...controls.length)
		{
			var player: Player;
			
			players.push(player =  new Player(
				"Player " + (i + 1),
				Math.cos(i * angleDiff) * ((gameInfo.bounds / 2) - 1),
				Math.sin(i * angleDiff) * ((gameInfo.bounds / 2) - 1),
				Utils.toDeg(i * angleDiff),
				new InputController(controls[i])
			));
			
			while (true)
			{
				var goal: Int = Std.random(128);
				
				var n: Int = 0;
				
				for (i in 0...8)
				{
					if (goal >> i & 1 == 1)
					{
						n += 1;
					}
				}
				
				if (n == 3 && generatedGoals.indexOf(goal) == -1)
				{
					generatedGoals.push(goal);
					
					for (i in 0...8)
					{
						if (goal >> i & 1 == 1)
						{
							player.goalRelics.push(relicList[i]);
						}
					}
					
					break;
				}
			}
		}
		
		playerHand = new Mat4().identity();
		
		planeWidth = Std.int(gameInfo.bounds + 5);
		planeLength = Std.int(gameInfo.bounds + 5);
		
		ceilMatrix = new Mat4().rotate(90, Vector3D.X_AXIS).scale(planeWidth, 1.0, planeLength).translate(0.0, 0.5, 0.0);
		floorMatrix = new Mat4().rotate(-90, Vector3D.X_AXIS).scale(planeWidth, 1.0, planeLength).translate(0, -0.5, 0);		
		circleMatrix = new Mat4().rotate(-90, Vector3D.X_AXIS).scale(circle.scale, 1.0, circle.scale).translate(0, -0.49, 0);
		
		skyboxMatrix = new Mat4().scale(20, 20, 20);
		
		Lib.current.stage.addEventListener(Event.RESIZE, resizeCallback);
		
		overlay = new Overlay();

		addEventListener(Event.ENTER_FRAME, enterFrame);
		addEventListener(RenderEvent.RENDER_OPENGL, glRender);

		
		prevUpdate = Lib.getTimer();
		
		resizeCallback(null);
		
		for (relic in relicList)
		{
			var spawnX: Float;
			var spawnY: Float;
			do
			{
				spawnX = Std.random(gameInfo.bounds) - (gameInfo.bounds / 2);
				spawnY = Std.random(gameInfo.bounds) - (gameInfo.bounds / 2);
			}
			while (Utils.dist(spawnX, spawnY, gameInfo.bounds / 2, gameInfo.bounds / 2) < circle.scale / 2);
			
			relics.set(relic, new Relic(spawnX, spawnY, relic));
		}	
		
		gameInfo.players = players;
	}

	function enterFrame(_): Void
	{
		Lib.current.stage.invalidate();
	}

	function glInit(gl: WebGLContext)
	{
		gl.enable(gl.DEPTH_TEST);
		gl.depthFunc(gl.LEQUAL);
		gl.depthMask(true);			
			
		renderer = new Renderer(gl);
		
		simpleProgram = new ShaderProgram(gl, "simple", "simple");
		skyboxProgram = new ShaderProgram(gl, "skybox", "skybox");
		overlayProgram = new ShaderProgram(gl, "overlay", "overlay");

		desertMap.load();
		
		quadMesh = new Mesh(gl, Geometry.quadVertices, Geometry.quadIndices, ["position", "texCoord", "normal"], [3, 2, 3]);
		skyboxMesh = new Mesh(gl, Geometry.skyboxVertices, [], ["position"], [3]);
		
		model = new Mat4();
		orthoView = new Mat4().translate(0, 0, -1);
		
		Lib.current.stage.addChild(overlay);
	}
	
	var initialized: Bool = false;
	function glRender(event: RenderEvent): Void
	{		
		var gl: WebGLContext = cast(cast(event.renderer, OpenGLRenderer).gl);
		if(!initialized) 
		{
			glInit(gl);
			initialized = true;
		}

		var delta: Float = (Lib.getTimer() - prevUpdate) / 1000;
		prevUpdate = Lib.getTimer();

		updateScene(delta);
		
		renderer.depthTest(gl.LEQUAL);
		renderer.blend(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

		var w: Int = Std.int(Lib.application.window.width);
		var h: Int = Std.int(Lib.application.window.height);
		
		renderer.viewport(0, 0, Lib.application.window.width, Lib.application.window.height);
		
		renderer.clear();
		
		renderer.uploadProgram(simpleProgram);
		
		renderer.uniformi("tex1", 0);
		renderer.uniformi("useFog", 0);
		renderer.uniformf("fogDistance", 5);
		renderer.uniformf("fogRate", 1);
		renderer.uniformfv("tint", colorWhite);
		renderer.uniformf("fogColor", 0.6, 0.0, 0.0, 1.0);
		
		var viewportLayout: Array<Rectangle> = viewports[players.length - 1];
		gameInfo.viewports = viewportLayout;
		
		for (i in 0...players.length)
		{
			var vp: Rectangle = viewportLayout[i];
			renderPlayerPOV(players[i], Std.int(w * vp.x), Std.int(h * vp.y), Std.int(w * vp.width), Std.int(h * vp.height));
		}
		
		renderer.viewport(0, 0, w, h);
		overlay.update(delta, gameInfo);
	}
	
	private function renderPlayerPOV(player: Player, x: Int, y: Int, w: Int, h: Int)
	{
		renderer.viewport(x, Lib.current.stage.stageHeight - y - h, w, h);
		
		Camera.current = player.camera;
		player.camera.updateProjection(w / h);
		
		var ortho: Mat4 = new Mat4().ortho(0, w, h, 0, 0.1, 100.0);
		
		renderer.uploadProgram(skyboxProgram);
		
		renderer.uniformMatrix("view", player.camera.getView());
		renderer.uniformMatrix("proj", player.camera.getProjection());
		
		desertMap.bindTex();
		renderer.uploadMesh(skyboxMesh);
		renderer.renderMesh(skyboxMatrix);
		desertMap.unbindTex();
		
		renderer.uploadProgram(simpleProgram);
		
		renderer.uniformMatrix("view", player.camera.getView());
		renderer.uniformMatrix("proj", player.camera.getProjection());
		renderer.uniformf("cameraPos", player.x, 0, player.z);
		
		renderer.uploadMesh(quadMesh);
		
		renderer.uniformf("tile", planeWidth, planeLength);
		renderer.uploadTexture(TextureManager.get("cobble"));
		renderer.renderMesh(floorMatrix);
		
		renderer.uniformf("tile", 1, 1);
		renderer.uploadTexture(TextureManager.get("circle_2"));
		renderer.renderMesh(circleMatrix);
		
		for (p in players)
		{
			if (p != player)
			{
				renderer.uploadTexture(TextureManager.get("cultist_sheet"));
				p.sprite.bind(renderer);
				renderer.renderMesh();
			}
		}
		
		for (relic in relics)
		{
			renderer.uniformf("flipX", 1);
			renderer.uniformf("offset", 0, 0);
			renderer.uniformf("title", 1, 1);		
			renderer.uploadTexture(TextureManager.get(relic.type));
			var relicTransform: Mat4 = null;
			
			if (relic.state == Relic.STATE_GROUND || relic.state == Relic.STATE_THROWN)
			{
				relic.sprite.bind(renderer);
			}
			else
			if(relic.state == Relic.STATE_HELD)
			{
				if (player.holding == relic)
				{
					playerHand.identity();
					
					var rad: Float = Utils.toRad(player.lookAngle);
					var pioffset: Float = Math.PI / 24;
					
					playerHand.scale(-0.4, 0.4, 0.4).rotate(90 - player.lookAngle, Vector3D.Y_AXIS).translate(player.x + (Math.cos(rad + pioffset) * 0.5), player.holding.sprite.y, player.z + (Math.sin(rad + pioffset) * 0.5));					
					
					renderer.uniformf("tile", 1, 1);
					relicTransform = playerHand;							
				}
				else
				{	
					if (relic.owner.sprite.angle > 2)
					{			
						continue;
					}
					relic.sprite.bind(renderer);
				}
			}
			
			renderer.renderMesh(relicTransform);
			renderer.uploadTexture(TextureManager.get(relic.type));
		}
		
		renderer.uploadProgram(overlayProgram);	
		renderer.uniformf("alpha", 1.0);
		renderer.uniformfv("tint", colorWhite);
		renderer.uniformMatrix("view", orthoView);
		renderer.uniformMatrix("proj", ortho);
		
		var mat = new Mat4().identity().scale(-50, -50, 1).translate(30, 30, 0);
		
		player.numberCorrectItems = 0;
		for (i in 0...player.goalRelics.length)
		{
			var onCircle: Bool = relics.get(player.goalRelics[i]).isOnCircle;
			if (onCircle)
			{
				player.numberCorrectItems += 1;
			}
			renderer.uniformf("alpha", onCircle ? 1.0: 0.5);
			renderer.uniformfv("tint", onCircle ? colorWhite : colorGray);
			renderer.uploadTexture(TextureManager.get(player.goalRelics[i]));
			renderer.renderMesh(mat);
			
			mat.translate(50, 0, 0);
		}
		
		renderer.uniformf("alpha", 1.0);
		
		player.numberWrongItems = 0;
		for (relicType in relics.keys())
		{
			if (player.goalRelics.indexOf(relicType) == -1 && relics.get(relicType).isOnCircle)
			{
				player.numberWrongItems += 1;
				
				renderer.uniformfv("tint", colorRed);
				renderer.uploadTexture(TextureManager.get(relicType));
				renderer.renderMesh(mat);
				
				mat.translate(50, 0, 0);
			}
		}
		
		renderer.uniformf("alpha", 1.0);
		renderer.uniformfv("tint", colorWhite);
		
		renderer.uploadTexture(TextureManager.get("stamina"));
		mat.identity().scale(2 * player.stamina, 20, 1).translate(player.stamina + 30, 100, 0);
		renderer.renderMesh(mat);
		
		renderer.uploadTexture(TextureManager.get("summon"));
		mat.identity().scale(20 * player.summonLength, 20, 1).translate((player.summonLength * 10) + 30, 140, 0);
		renderer.renderMesh(mat);
		/*
		renderer.uploadTexture(TextureManager.get("circle_1"));
		mat.identity().scale(40, 40, 1).translate(25, 150, 0);
		renderer.renderMesh(mat);
		*/
	}
	
	function updateScene(delta: Float)
	{
		Input.update(delta);
		
		if (!endGame)
		{		
			gameInfo.players = players;
			gameInfo.relics = relics;
			gameInfo.circle = circle;
			
			for (player in players)
			{
				player.update(delta, gameInfo);
				if (player.summonLength >= 10)
				{
					endGame = true;
					overlay.playerWins.text = player.name + " Wins!";
					overlay.playerWins.visible = true;
				}
			}
			
			for (relic in relics)
			{
				relic.update(delta, gameInfo);
			}
		}
	}

	function shortenFloat(f: Float, n: Int)
	{
		var mag: Int = Std.int(Math.pow(10, n));
		return Math.floor(f * mag) / mag;
	}
	
	function resizeCallback(_)
	{
		var newWidth: Int = Lib.current.stage.stageWidth;
		var newHeight: Int = Lib.current.stage.stageHeight;
		var aspect: Float = newWidth / newHeight;
		
		viewmodelScaleY = newHeight / 2;
		var viewAspect = Utils.clamp(aspect, 4/3, 16/9);
		viewmodelScaleX = viewmodelScaleY * viewAspect;
	}
}