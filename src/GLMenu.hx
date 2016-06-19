package;

import openfl.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.OpenGLView;
import openfl.geom.Rectangle;
import openfl.geom.Vector3D;
import openfl.gl.GL;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

typedef CamTransform = {
	var x: Float;
	var y: Float;
	var z: Float;
	var pitch: Float;
	var yaw: Float;
};

class GLMenu extends OpenGLView
{
	static inline var STATE_MAIN: Int = 0;
	static inline var STATE_LOBBY: Int = 1;
	static inline var STATE_OPTIONS: Int = 2;
	
	static inline var EMPTY_SLOT: Int = -2;
	
	var straightToHell: Font = Assets.getFont("fonts/straighttohell.bb.ttf");
	var straightToHellSinner: Font = Assets.getFont("fonts/straighttohell.sinner-bb.ttf");	
	
	var menuState: Int;
	var destState: Int;
	var transitioning: Bool = false;
	var transitionTimer: Float = 0;
	var transitionDuration: Float;
	
	var mainCameraTransform: CamTransform;
	var lobbyCameraTransform: CamTransform;
	var optionsCameraTransform: CamTransform;
	
	var currentCameraTransform: CamTransform;
	var destCameraTransform: CamTransform;
	
	var renderer: Renderer;
	var simpleProgram: ShaderProgram;
	var quad: Mesh;
	var cam: Camera;
	
	var menuCultists: Array<Billboard>;
	var lobbyCultists: Array<Billboard>;

	var titleMatrix: Mat4;
	var menuItemMatrix: Mat4;
	var relicMatrix: Mat4;
	
	var menuItems: Array<String> = ["Start", "Options", "Exit"];
	var menuItemRelicMap: Map<String, String> = [
		"Start" => "rabbit",
		"Options" => "suggestive_book",
		"Exit" => "donut"
	];
	var menuItemMatrixMap: Map<String, Mat4> = new Map();
	
	var selectedIndex: Int = 0;
	var selectedOption: String;
	
	var axisZero: Bool = true;
	
	var ready: Array<Bool> = [false, false, false, false];
	var joinedPlayers: Array<Int> = [EMPTY_SLOT, EMPTY_SLOT, EMPTY_SLOT, EMPTY_SLOT];
	var joinedMap: Map<Int, Int> = new Map();
	var floatTextMatrix: Array<Mat4> = [new Mat4(), new Mat4(), new Mat4(), new Mat4()];
	
	var countdownMatrix: Mat4;
	var countdownDuration: Int = 3;
	var countdown: Float = 3;
	var countingDown: Bool = false;
	
	public function new() 
	{
		super();
		
		menuState = STATE_MAIN;
		
		prev = Lib.getTimer();
		render = glRender;
		
		renderer = new Renderer();
		simpleProgram = new ShaderProgram("simple", "simple");
		quad = new Mesh(Geometry.quadVertices, Geometry.quadIndices, ["position", "texCoord", "normal"], [3, 2, 3]);
		cam = new Camera();
		
		mainCameraTransform = {
			x: -3.5,
			y: 0.75,
			z: 0,
			pitch: 0,
			yaw: 0
		};
		
		lobbyCameraTransform = {
			x: -8.5, 
			y: 0.75,
			z: -2.5,
			pitch: 0,
			yaw: 0
		};
		
		optionsCameraTransform = {
			x: 8.5, 
			y: 0.75,
			z: -2.5,
			pitch: 0,
			yaw: 0
		};
		
		setCamTransform(mainCameraTransform);
		
		menuCultists = [
			placeCultist(-140),
			placeCultist(-70),
			placeCultist(0),
			placeCultist(70),
			placeCultist(140)
		];
		
		lobbyCultists = [
			placeCultist(-90, -5, -2.5),
			placeCultist(-30, -5, -2.5),
			placeCultist( 30, -5, -2.5),
			placeCultist( 90, -5, -2.5)
		];
		
		Camera.current = cam;
			
		var format: TextFormat = new TextFormat(straightToHellSinner.fontName, 96, 0xCC0000);
		format.align = TextFormatAlign.CENTER;
		
		generateTextureFromText("Our Dark Lord\nis\nBetter Than Yours", format, "menuTitle");
		
		var titleTex: Texture = TextureManager.get("menuTitle");
		titleMatrix = new Mat4().identity().rotate( -90, Vector3D.Y_AXIS).scale(1.0, 2.0, 2.0 * titleTex.width / titleTex.height).translate( -0.5, 2.0, 0);
		
		generateTextureFromText("Keyboard", format, "lobbyKeyboard");
		generateTextureFromText("Gamepad 1", format, "lobbyPad1");
		generateTextureFromText("Gamepad 2", format, "lobbyPad2");
		generateTextureFromText("Gamepad 3", format, "lobbyPad3");
		generateTextureFromText("Gamepad 4", format, "lobbyPad4");
		
		format.color = 0;
		generateTextureFromText("Start", format, "menuStart");
		generateTextureFromText("Options", format, "menuOptions");
		generateTextureFromText("Back", format, "menuBack");
		generateTextureFromText("Exit", format, "menuExit");
		
		for (i in 0...countdownDuration)
		{
			var s: Int = i + 1;
			generateTextureFromText("Starting in " + s + "...", format, "countdown" + s);
		}
		
		var startTex: Texture = TextureManager.get("menuStart");
		var optionsTex: Texture = TextureManager.get("menuOptions");
		var exitTex: Texture = TextureManager.get("menuExit");
		var backTex: Texture = TextureManager.get("menuBack");
		
		menuItemMatrixMap.set("Start",
			new Mat4().identity().rotate( -90, Vector3D.Y_AXIS).scale(1.0, 0.8, 0.8 * startTex.width / startTex.height).translate( -1.5, -0.25, 0)
		);
		menuItemMatrixMap.set("Options",
			new Mat4().identity().rotate( -90, Vector3D.Y_AXIS).scale(1.0, 0.8, 0.8 * optionsTex.width / optionsTex.height).translate( -1.5, -0.25, 0)
		);
		menuItemMatrixMap.set("Exit",
			new Mat4().identity().rotate( -90, Vector3D.Y_AXIS).scale(1.0, 0.8, 0.8 * exitTex.width / exitTex.height).translate( -1.5, -0.25, 0)
		);
		menuItemMatrixMap.set("BackLobby",
			new Mat4().identity().rotate( -90, Vector3D.Y_AXIS).scale(1.0, 0.8, 0.8 * backTex.width / backTex.height).translate( -1.5, -0.25, 0)
		);
		menuItemMatrixMap.set("BackOptions",
			new Mat4().identity().rotate( -90, Vector3D.Y_AXIS).scale(1.0, 0.8, 0.8 * backTex.width / backTex.height).translate( -1.5, -0.25, 0)
		);
		
		selectedOption = menuItems[selectedIndex];
		
		relicMatrix = new Mat4().identity().rotate( -90, Vector3D.Y_AXIS).scale(1.0, 0.5, 0.5).translate(0, -0.25, 0);
		
		var countdownTex: Texture = TextureManager.get("countdown3");
		countdownMatrix = new Mat4().identity().rotate( -90, Vector3D.Y_AXIS).scale(1.0, 0.7, 0.7 * countdownTex.width / countdownTex.height).translate(-6.5, -0.25, -2.5);
		
		renderer.uploadProgram(simpleProgram);
		renderer.uniformi("tex1", 0);
		renderer.uniformi("useFog", 1);
		renderer.uniformf("fogDistance", 6);
		renderer.uniformf("fogRate", 1);
		renderer.uniformf("fogColor", 0.1, 0.1, 0.1, 1.0);
	}
	
	function changeArea(options: String): Void
	{
		var state: Int = -1;
		
		switch(options)
		{
			case "Start":
				state = STATE_LOBBY;
			case "Options":
				state = STATE_OPTIONS;
			case "BackLobby":
				state = STATE_MAIN;
			case "BackOptions":
				state = STATE_MAIN;
			case "Exit":
				#if native
				Sys.exit(0);
				#end
		}
		
		destState = state;
		
		switch(state)
		{
			case STATE_MAIN:
				transitionDuration = 1.0;
				transitionTimer = 0.0;
				transitioning = true;
				destCameraTransform = mainCameraTransform;
				
			case STATE_LOBBY:
				transitionDuration = 1.0;
				transitionTimer = 0.0;
				transitioning = true;
				destCameraTransform = lobbyCameraTransform;
		}
	}
	
	function setCamTransform(transform: CamTransform): Void
	{
		cam.position.x = transform.x;
		cam.position.y = transform.y;
		cam.position.z = transform.z;
		cam.pitch = transform.pitch;
		cam.yaw = transform.yaw;
		
		currentCameraTransform = transform;
	}
	
	function tweenCamTransform(src: CamTransform, dest: CamTransform, t: Float): Void
	{
		cam.position.x = src.x + ((dest.x - src.x) * t);
		cam.position.y = src.y + ((dest.y - src.y) * t);
		cam.position.z = src.z + ((dest.z - src.z) * t);
		
		//TODO Angular tween
	}

	function generateTextureFromText(text: String, format: TextFormat, texName: String)
	{
		var field: TextField = new TextField();
		
		field.text = text;
		field.defaultTextFormat = format;
		field.embedFonts = true;
		field.width = field.textWidth * 1.1;
		field.height = field.textHeight * 1.1;
		
		var data: BitmapData = new BitmapData(Math.ceil(field.width), Math.ceil(field.height), true, 0);
		data.draw(field, null, null, null, null, true);
		
		TextureManager.load(texName, data, GL.LINEAR);	
	}
	
	function placeCultist(angle: Float, x: Float = 0, z: Float = 0): Billboard
	{
		var cultist: Billboard = Billboard.create(Billboard.PERSPECTIVE_MIN);
		cultist.x = x + Math.cos(Utils.toRad(angle)) * 2;
		cultist.z = z + Math.sin(Utils.toRad(angle)) * 2;
		cultist.angleOffset = angle + 180;
		
		return cultist;
	}
	
	var prev: Int;
	function glRender(rect: Rectangle): Void
	{		
		var delta: Float = (Lib.getTimer() - prev) / 1000;
		prev = Lib.getTimer();
		
		Input.update(delta);
		
		if (allReady())
		{
			countingDown = true;
			countdown -= delta;
			if (countdown <= 0)
			{
				startGame();
			}
		}
		else
		{
			countingDown = false;
			countdown = 3;
		}
		
		var leftX: Float = GamepadInput.axis("LEFT_X");
		switch(menuState)
		{
			case STATE_MAIN:
				if (Math.abs(leftX) > 0.8 && axisZero)
				{
					axisZero = false;
					if (leftX < 0)
					{
						selectedIndex--;
						if (selectedIndex == -1) selectedIndex = menuItems.length - 1;
						selectedOption = menuItems[selectedIndex];				
					}
					else
					{
						selectedIndex++;
						if (selectedIndex == menuItems.length) selectedIndex = 0;
						selectedOption = menuItems[selectedIndex];
					}
				}
				else
				{
					if (Math.abs(leftX) < 0.3)
					{
						axisZero = true;
					}
				}
				
				if (Input.isPressed("menu_left"))
				{
					selectedIndex--;
					if (selectedIndex == -1) selectedIndex = menuItems.length - 1;
					selectedOption = menuItems[selectedIndex];
				}
				
				if (Input.isPressed("menu_right"))
				{
					selectedIndex++;
					if (selectedIndex == menuItems.length) selectedIndex = 0;
					selectedOption = menuItems[selectedIndex];
				}
			case STATE_LOBBY:
				
				var backPressed: Bool = Input.isPressed("menu_unjoin");
				if (Input.isPressed("any") && !backPressed)
				{
					playerJoin(-1);
				}
				else
				{
					if (backPressed)
					{
						playerUnjoin( -1);
					}
				}
				if (Input.isPressed("menu_ready"))
				{
					if (joinedMap.exists( -1))
					{
						ready[joinedMap[ -1]] = !ready[joinedMap[ -1]];
						if (allReady())
						{
							countingDown = true;
							countdown = 3;
						}
					}
				}
				if (Input.isPressed("menu_left"))
				{
					selectedIndex--;
					if (selectedIndex == -1) selectedIndex = menuItems.length - 1;
					selectedOption = menuItems[selectedIndex];
				}
				if (Input.isPressed("menu_right"))
				{
					selectedIndex++;
					if (selectedIndex == menuItems.length) selectedIndex = 0;
					selectedOption = menuItems[selectedIndex];
				}
				
				for (i in 0...4)
				{
					var backPressed: Bool = Input.isPressed(i + "menu_unjoin");
					if (Input.isPressed(i + "any") && !backPressed)
					{
						playerJoin(i);
					}
					else
					{
						if (backPressed)
						{
							playerUnjoin(i);
						}
					}
					
					if (Input.isPressed(i + "menu_ready"))
					{
						if (joinedMap.exists(i))
						{
							ready[joinedMap[i]] = !ready[joinedMap[i]];
							
							if (allReady())
							{
								countingDown = true;
								countdown = 3;
							}
						}
					}
				}
		}
		
		if (!transitioning)
		{
			if (Input.isPressed("menu_start_0") || Input.isPressed("menu_start_1"))
			{
				changeArea(selectedOption);
			}
			
			if (Input.isPressed("menu_back_0") || Input.isPressed("menu_back_1"))
			{
				if (menuState == STATE_LOBBY)
				{
					joinedPlayers = [EMPTY_SLOT, EMPTY_SLOT, EMPTY_SLOT, EMPTY_SLOT];
					changeArea("BackLobby");
				}
			}
		}
		else
		{
			transitionTimer += delta;
			
			if (transitionTimer >= transitionDuration)
			{
				transitionTimer = transitionDuration;
				currentCameraTransform = destCameraTransform;
				transitioning = false;
				menuState = destState;
			}
			
			tweenCamTransform(currentCameraTransform, destCameraTransform, transitionTimer / transitionDuration);
		}		
		
		cam.update();
		
		renderer.depthTest(GL.LEQUAL);
		renderer.blend(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		renderer.clear(0.1, 0.1, 0.1);
		
		renderer.uploadProgram(simpleProgram);
		
		renderer.uniformMatrix("view", cam.getView());
		renderer.uniformMatrix("proj", cam.getProjection());
		renderer.uniformf("cameraPos", cam.position.x, cam.position.y, cam.position.z);		
		
		renderer.uploadMesh(quad);
		var mat: Mat4 = new Mat4();		
		renderer.uniformf("tile", 60, 60);
		TextureManager.get("cobble").bind(GL.TEXTURE0);
		renderer.renderMesh(mat.identity().rotate(-90, Vector3D.X_AXIS).scale(30.0, 1.0, 30.0).translate(0, -0.5, 0));	
		
		renderer.uniformf("tile", 1, 1);
		TextureManager.get("circle_1").bind(GL.TEXTURE0);
		renderer.renderMesh(mat.identity().rotate( -90, Vector3D.X_AXIS).scale(2.0, 1.0, 2.0).translate(0, -0.49, 0));
		renderer.renderMesh(mat.identity().rotate( -90, Vector3D.X_AXIS).scale(2.0, 1.0, 2.0).translate(-5.0, -0.49, -2.5));
		
		TextureManager.get("ready").bind(GL.TEXTURE0);
		for (i in 0...4)
		{
			if (ready[i] && joinedPlayers[i] != EMPTY_SLOT)
			{
				var cultist: Billboard = lobbyCultists[i];
				renderer.renderMesh(mat.identity().rotate( -90, Vector3D.X_AXIS).scale(1.0, 1.0, 1.0).translate(cultist.x, -0.48, cultist.z));
			}
		}
		
		TextureManager.get("cultist_sheet").bind(GL.TEXTURE0);
		for (cultist in menuCultists)
		{
			cultist.bind(renderer);
			renderer.renderMesh();
		}
		
		for (i in 0...4)
		{
			if (joinedPlayers[i] != EMPTY_SLOT)
			{
				lobbyCultists[i].bind(renderer);
				renderer.renderMesh();
			}
		}
		
		renderer.uniformf("flipX", 1);
		renderer.uniformf("offset", 0, 0);
		renderer.uniformf("tile", 1, 1);
		renderer.uniformf("tint", 1.0, 1.0, 1.0);		
		
		for (i in 0...4)
		{
			if (joinedPlayers[i] != EMPTY_SLOT)
			{
				TextureManager.get(getInputType(joinedPlayers[i])).bind(GL.TEXTURE0);
				renderer.renderMesh(floatTextMatrix[i]);
			}
		}
		
		TextureManager.get(menuItemRelicMap[selectedOption]).bind(GL.TEXTURE0);
		renderer.renderMesh(relicMatrix);
		
		if (!transitioning)
		{
			TextureManager.get("menuTitle").bind(GL.TEXTURE0);
			renderer.renderMesh(titleMatrix);
			
			TextureManager.get("menu" + selectedOption).bind(GL.TEXTURE0);
			renderer.renderMesh(menuItemMatrixMap[selectedOption]);
			
			if (countingDown && countdown > 0)
			{
				TextureManager.get("countdown" + Math.ceil(countdown)).bind(GL.TEXTURE0);
				renderer.renderMesh(countdownMatrix);
			}
		}
	}
	
	function playerJoin(id: Int)
	{
		var hasJoined: Bool = false;
		for (j in joinedPlayers)
		{
			if (j == id)
			{
				hasJoined = true;
				break;
			}
		}
		
		if (!hasJoined)
		{
			for (i in 0...joinedPlayers.length)
			{
				if (joinedPlayers[i] == EMPTY_SLOT)
				{
					joinedPlayers[i] = id;
					
					joinedMap[id] = i;
					
					var mat: Mat4 = floatTextMatrix[i];
					var cultist: Billboard = lobbyCultists[i];
					var tex: Texture = TextureManager.get(getInputType(i));
					mat.identity().rotate( -90, Vector3D.Y_AXIS).scale(1.0, 0.4, 0.4 * tex.width / tex.height).translate(cultist.x, 1.0, cultist.z);
					
					break;
				}
			}
		}
	}
	
	function getInputType(id: Int): String
	{
		if (id == -1) return "lobbyKeyboard";
		else return "lobbyPad" + (id + 1);	
	}
	
	function playerUnjoin(id: Int)
	{
		for (i in 0...joinedPlayers.length)
		{
			if (joinedPlayers[i] == id)
			{
				joinedPlayers[i] = EMPTY_SLOT;
				joinedMap.remove(id);
				if (allReady())
				{
					countingDown = true;
					countdown = 3;
				}
				break;
			}
		}	
	}
	
	function allReady(): Bool
	{
		var all: Bool = true;
		var numReady: Int = 0;
		for (i in 0...ready.length)
		{
			if (joinedPlayers[i] != EMPTY_SLOT)
			{
				if (!ready[i])
				{
					all = false;
					break;
				}
				else
				{
					numReady++;
				}
			}
		}
		return all && numReady > 0;
	}
	
	function startGame()
	{
		var c: Array<Int> = new Array();
		for (player in joinedPlayers)
		{
			if (player != EMPTY_SLOT)
			{
				c.push(player);
			}
		}
		
		parent.addChild(new Game(c));
		parent.removeChild(this);
	}
}