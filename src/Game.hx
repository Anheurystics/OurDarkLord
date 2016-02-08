package;

import openfl.Lib;
import openfl.display.OpenGLView;
import openfl.events.Event;
import openfl.geom.Rectangle;
import openfl.geom.Vector3D;
import openfl.gl.GL;
import openfl.system.System;
import openfl.utils.Float32Array;

class Game extends OpenGLView
{	
	var renderer: Renderer;
	
	var shaderProgram: ShaderProgram;
	var skyboxProgram: ShaderProgram;
	var overlayProgram: ShaderProgram;
	
	var model: Mat4;

	var orthoView: Mat4;
	
	var quad: Array<Float> = [
		-0.5,  0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
		 0.5,  0.5, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0,
		 0.5, -0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0,
		-0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0
	];
	
	var quadIndices: Array<Int> = [
		0, 1, 2, 0, 2, 3
	];
	
	var skyboxVertices: Array<Float> = [         
		-1.0,  1.0, -1.0,
		-1.0, -1.0, -1.0,
		 1.0, -1.0, -1.0,
		 1.0, -1.0, -1.0,
		 1.0,  1.0, -1.0,
		-1.0,  1.0, -1.0,
		
		-1.0, -1.0,  1.0,
		-1.0, -1.0, -1.0,
		-1.0,  1.0, -1.0,
		-1.0,  1.0, -1.0,
		-1.0,  1.0,  1.0,
		-1.0, -1.0,  1.0,
		
		 1.0, -1.0, -1.0,
		 1.0, -1.0,  1.0,
		 1.0,  1.0,  1.0,
		 1.0,  1.0,  1.0,
		 1.0,  1.0, -1.0,
		 1.0, -1.0, -1.0,

		-1.0, -1.0,  1.0,
		-1.0,  1.0,  1.0,
		 1.0,  1.0,  1.0,
		 1.0,  1.0,  1.0,
		 1.0, -1.0,  1.0,
		-1.0, -1.0,  1.0,

		-1.0,  1.0, -1.0,
		 1.0,  1.0, -1.0,
		 1.0,  1.0,  1.0,
		 1.0,  1.0,  1.0,
		-1.0,  1.0,  1.0,
		-1.0,  1.0, -1.0,

		-1.0, -1.0, -1.0,
		-1.0, -1.0,  1.0,
		 1.0, -1.0, -1.0,
		 1.0, -1.0, -1.0,
		-1.0, -1.0,  1.0,
		 1.0, -1.0,  1.0
	];
	
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
		
		if (!OpenGLView.isSupported)
		{
			trace("OpenGL is not supported!");
			#if (desktop)
			System.exit(0);
			#end
		}
		
		gameInfo = {
			players: null,
			relics: null,
			viewports: null,
			circle: null,
			bounds: 0
		};
		
		desertMap = new MapData("desert", "graphics/skybox_sunset.png", 128, 20.0, "graphics/cobble.png", 25);
		gameInfo.bounds = desertMap.fieldDimension;	
		
		circle = new MagicCircle(0, 0, 4);
		
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
				controls[i]	
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
		floorMatrix = new Mat4().rotate(-90, Vector3D.X_AXIS).scale(planeWidth, 1.0, planeLength).translate(-0.5, -0.5, -0.5);		
		circleMatrix = new Mat4().rotate(-90, Vector3D.X_AXIS).scale(circle.scale, 1.0, circle.scale).translate(0, -0.49, 0);
		
		skyboxMatrix = new Mat4().scale(desertMap.skyboxFinalSize, desertMap.skyboxFinalSize, desertMap.skyboxFinalSize);
		
		Lib.current.stage.addEventListener(Event.RESIZE, resizeCallback);
		
		overlay = new Overlay();
		
		#if mobile
		Lib.current.stage.addEventListener(OpenGLView.CONTEXT_LOST, contextHandler);
		Lib.current.stage.addEventListener(OpenGLView.CONTEXT_RESTORED, contextHandler);
		#end		
		
		render = glRender;
		
		GL.enable(GL.DEPTH_TEST);
		GL.depthFunc(GL.LEQUAL);
		GL.depthMask(true);			
		
		renderer = new Renderer();
		
		shaderProgram = new ShaderProgram("shader", "shader");
		skyboxProgram = new ShaderProgram("skybox", "skybox");
		overlayProgram = new ShaderProgram("overlay", "overlay");
		
		TextureManager.load("cobble", "graphics/cobble.png");
		
		//TODO pack all relic sprites (or maybe everything?) into a spritesheet
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
		desertMap.load();
		
		quadMesh = new Mesh(quad, quadIndices, "quad");
		
		renderer.setAttribLayout("quad");
		renderer.addAttrib("position", 3);
		renderer.addAttrib("texCoord", 2);
		renderer.addAttrib("normal", 3);
		
		skyboxMesh = new Mesh(skyboxVertices, [], "skybox");
		
		renderer.setAttribLayout("skybox");
		renderer.addAttrib("position", 3);
		
		model = new Mat4();
		
		orthoView = new Mat4().translate(0, 0, -1);
		
		Lib.current.stage.addChild(overlay);
		
		prevUpdate = Lib.getTimer();
		
		resizeCallback(null);
		
		for (relic in relicList)
		{
			relics.set(relic, new Relic(Std.random(gameInfo.bounds) - (gameInfo.bounds / 2), Std.random(gameInfo.bounds) - (gameInfo.bounds / 2), relic));
		}	
		
		gameInfo.players = players;
	}

	#if mobile
	var needsRestoreContext: Bool = false;
	function contextHandler(e: Event)
	{
		if (e.type == OpenGLView.CONTEXT_LOST)
		{
			needsRestoreContext = true;
		}
		else
		if (e.type == OpenGLView.CONTEXT_RESTORED)
		{
			if (needsRestoreContext)
			{
				needsRestoreContext = false;
				
				GL.enable(GL.DEPTH_TEST);
				GL.depthFunc(GL.LEQUAL);
				GL.depthMask(true);
				
				ShaderProgram.restoreAll();
				Texture.restoreAll();
				Mesh.restoreAll();
			}
		}
	}
	#end
	
	function glRender(rect: Rectangle): Void
	{		
		var delta: Float = (Lib.getTimer() - prevUpdate) / 1000;
		prevUpdate = Lib.getTimer();
		
		updateScene(delta);
		
		GL.enable(GL.DEPTH_TEST);
		GL.depthFunc(GL.LEQUAL);
		
		GL.viewport(0, 0, Std.int(rect.width), Std.int(rect.height));
		
		GL.clearColor(0.0, 0.0, 0.0, 1.0);
		GL.enable(GL.BLEND);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		
		GL.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
		
		renderer.uploadProgram(shaderProgram);
		
		renderer.uniformi("tex1", 0);
		renderer.uniformi("useFog", 0);
		renderer.uniformf("fogDistance", 5);
		renderer.uniformf("fogRate", 1);
		renderer.uniformf("fogColor", 0.6, 0.0, 0.0, 1.0);
		
		var viewportLayout: Array<Rectangle> = viewports[players.length - 1];
		var w: Int = Std.int(rect.width);
		var h: Int = Std.int(rect.height);
		gameInfo.viewports = viewportLayout;
		//TODO turn renderPlayerPOV method into renderPOV in player
		for (i in 0...players.length)
		{
			var vp: Rectangle = viewportLayout[i];
			renderPlayerPOV(players[i], Std.int(w * vp.x), Std.int(h * vp.y), Std.int(w * vp.width), Std.int(h * vp.height));
			GL.viewport(0, 0, w, h);
		}
		
		overlay.update(delta, gameInfo);
	}
	
	function renderPlayerPOV(player: Player, x: Int, y: Int, w: Int, h: Int)
	{
		GL.viewport(x, Lib.current.stage.stageHeight - y - h, w, h);
		
		Camera.current = player.camera;
		
		var proj: Mat4 = new Mat4().perspective(player.fov, w / h, 0.1, 100.0);
		var ortho: Mat4 = new Mat4().ortho(0, w, h, 0, 0.1, 100.0);
		
		GL.depthMask(false);
		renderer.uploadProgram(skyboxProgram);
		
		renderer.uniformMatrix("view", player.camera.getView());
		renderer.uniformMatrix("proj", proj);
		
		desertMap.bindTex();
		renderer.uploadMesh(skyboxMesh);
		renderer.renderMesh(skyboxMatrix);
		desertMap.unbindTex();
		
		GL.depthMask(true);
		renderer.uploadProgram(shaderProgram);
		
		renderer.uniformMatrix("view", player.camera.getView());
		renderer.uniformMatrix("proj", proj);
		renderer.uniformf("cameraPos", player.x, 0, player.z);
		
		renderer.uploadMesh(quadMesh);
		
		renderer.uniformf("tile", planeWidth, planeLength);
		TextureManager.get("cobble").bind(GL.TEXTURE0);
		renderer.renderMesh(floorMatrix);
		
		renderer.uniformf("tile", 1, 1);
		TextureManager.get("circle_1").bind(GL.TEXTURE0);
		renderer.renderMesh(circleMatrix);
		
		for (p in players)
		{
			if (p != player)
			{
				TextureManager.get("cultist_sheet").bind(GL.TEXTURE0);
				p.sprite.bind(shaderProgram);
				renderer.renderMesh();
			}
		}
		
		for (relic in relics)
		{
			renderer.uniformf("flipX", 1);
			renderer.uniformf("offset", 0, 0);
			renderer.uniformf("title", 1, 1);		
			TextureManager.get(relic.type).bind(GL.TEXTURE0);
			var relicTransform: Mat4 = null;
			
			if (relic.state == Relic.STATE_GROUND || relic.state == Relic.STATE_THROWN)
			{
				relic.sprite.bind(shaderProgram);
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
					relic.sprite.bind(shaderProgram);
				}
			}
			
			renderer.renderMesh(relicTransform);
			TextureManager.get(relic.type).unbind();
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
			renderer.uniformf("alpha", onCircle ? 1.0: .25);
			TextureManager.get(player.goalRelics[i]).bind(GL.TEXTURE0);
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
				TextureManager.get(relicType).bind(GL.TEXTURE0);
				renderer.renderMesh(mat);
				
				mat.translate(50, 0, 0);
			}
		}
		
		renderer.uniformf("alpha", 1.0);
		renderer.uniformfv("tint", colorWhite);
		
		TextureManager.get("stamina").bind(GL.TEXTURE0);
		mat.identity().scale(2 * player.stamina, 30, 1).translate(player.stamina + 70, 100, 0);
		renderer.renderMesh(mat);
		
		TextureManager.get("summon").bind(GL.TEXTURE0);
		mat.identity().scale(20 * player.summonLength, 30, 1).translate((player.summonLength * 10) + 30, 150, 0);
		renderer.renderMesh(mat);
		
		TextureManager.get("circle_1").bind(GL.TEXTURE0);	
		mat.identity().scale(40, 40, 1).translate(25, 150, 0);
		renderer.renderMesh(mat);
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