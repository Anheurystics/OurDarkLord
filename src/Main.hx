package;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class Main extends Sprite
{
	function loadInputs(): Void
	{
		GamepadInput.init();
		
		//Keyboard inputs
		Input.bind("any", -1);
		Input.bind("forward", Keyboard.W);
		Input.bind("back", Keyboard.S);
		Input.bind("strafe_left", Keyboard.A);
		Input.bind("strafe_right", Keyboard.D);
		Input.bind("turn_left", Keyboard.LEFT);
		Input.bind("turn_right", Keyboard.RIGHT);
		Input.bind("use", Keyboard.E);
		Input.bind("run", Keyboard.SHIFT);
		Input.bind("shoot",	Keyboard.CONTROL);
		Input.bind("start",	Keyboard.ENTER);
		Input.bind("select",	Keyboard.BACKSPACE);
		
		//Gamepad inputs
		for (i in 0...4)
		{
			Input.bind(i + "any", i + "_ANY");
			Input.bind(i + "use", i + "_RIGHT_SHOULDER");
			Input.bind(i + "run", i + "_A");
			Input.bind(i + "shoot", i + "_LEFT_SHOULDER");
			Input.bind(i + "start", i + "_START");
			Input.bind(i + "select", i + "_BACK");
			Input.bind(i + "menu_left", i + "_DPAD_LEFT");
			Input.bind(i + "menu_right", i + "_DPAD_RIGHT");
			Input.bind(i + "menu_unjoin", i + "_B");
			Input.bind(i + "menu_ready", i + "_START");
		}
		
		//Load menu bindings of keyboard and gamepads
		Input.bind("menu_start_0", Keyboard.ENTER);
		Input.bind("menu_start_1", Keyboard.SPACE);
		Input.bind("menu_back_0", Keyboard.BACKSPACE);
		Input.bind("menu_unjoin", Keyboard.SHIFT);
		Input.bind("menu_left", Keyboard.LEFT);
		Input.bind("menu_right", Keyboard.RIGHT);
		Input.bind("menu_ready", Keyboard.ENTER);
		
		Input.bind("menu_start_0", "START");
		Input.bind("menu_start_1", "A");
		Input.bind("menu_back_0", "BACK");
		Input.bind("menu_left", "DPAD_LEFT");
		Input.bind("menu_right", "DPAD_RIGHT");
		
		//Add listeners
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, KeyboardInput.keyCallback);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyboardInput.keyCallback);		
	}
	
	function loadTextures()
	{
		//Level textures
		TextureManager.load("cobble", "graphics/cobble.png");
		TextureManager.load("circle_1", "graphics/circle_1.png");
		TextureManager.load("circle_2", "graphics/circle_2.png");
		TextureManager.load("ready", "graphics/ready.png");
		
		//Relic textures
		TextureManager.load("black_candle", "graphics/black_candle.png");
		TextureManager.load("suggestive_book", "graphics/suggestive_book.png");
		TextureManager.load("donut", "graphics/donut.png");
		TextureManager.load("dummy", "graphics/dummy.png");
		TextureManager.load("moms_spaghetti", "graphics/moms_spaghetti.png");
		TextureManager.load("rabbit", "graphics/rabbit.png");
		TextureManager.load("small_loan", "graphics/small_loan.png");
		TextureManager.load("spork", "graphics/spork.png");
		
		//Player textures
		TextureManager.load("cultist_sheet", "graphics/cultist_sheet.png");
		
		//UI Textures
		TextureManager.load("stamina", "graphics/stamina.png");
		TextureManager.load("summon", "graphics/summon.png");		
	}
	
	public function new() 
	{
		super();
		
		loadInputs();
		loadTextures();
		
		addChild(new GLMenu());
	}
}