package;

import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.ui.Keyboard;

class Main extends Sprite
{
	public function new() 
	{
		super();
		
		GamepadInput.init();
		
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
		
		for (i in 0...3)
		{
			Input.bind(i + "any", i + "_ANY");
			Input.bind(i + "use", i + "_RIGHT_SHOULDER");
			Input.bind(i + "run", i + "_A");
			Input.bind(i + "shoot", i + "_LEFT_SHOULDER");
			Input.bind(i + "start", i + "_START");
		}		
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, KeyboardInput.keyCallback);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyboardInput.keyCallback);		
		
		addChild(new Menu());
	}
}