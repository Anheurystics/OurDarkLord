package;

import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class KeyboardInput
{	
	static var down: Map<Int, Bool> = new Map();
	static var lastUp: Map<Int, Float> = new Map();
	
	static var bindings: Map<String, Int> = new Map();
	
	public static function keyCallback(e: KeyboardEvent)
	{
		if (e.type == KeyboardEvent.KEY_DOWN)
		{
			down.set(e.keyCode, true);
			down.set( -1, true);
		}
		if (e.type == KeyboardEvent.KEY_UP)
		{
			down.set(e.keyCode, false);
			lastUp.set(e.keyCode, 0);
			
			down.set( -1, false);
			lastUp.set( -1, 0);
		}		
	}

	public static function bind(name: String, key: Int): Void
	{
		bindings.set(name, key);
	}
	
	public static function update(delta: Float): Void
	{
		for (key in down.keys())
		{
			if (down.get(key))
			{
				lastUp.set(key, lastUp.exists(key)? lastUp.get(key) + delta : 0);
			}
		}
	}
	
	public static function isPressed(name: String): Bool
	{
		if (!bindings.exists(name)) return false;
		var keyCode: Int = bindings.get(name);
		if (down.get(keyCode) && lastUp.get(keyCode) < 0.1)
		{
			lastUp.set(keyCode, 0.1);
			return true;
		}
		return false;
	}
	
	public static function isDown(name: String): Bool
	{
		if (!bindings.exists(name)) return false;
		var keyCode: Int = bindings.get(name);
		if (down.get(keyCode))
		{
			return true;
		}
		return false;
	}
}