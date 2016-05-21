package;

import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;

class GamepadInput
{	
	static var down: Map<String, Bool> = new Map();
	static var lastUp: Map<String, Float> = new Map();
	
	static var bindings: Map<String, String> = new Map();
	static var axes: Map<String, Float> = new Map();

	static var numConnected: Int = 0;
	static var connectedPads: Array<Gamepad> = [null, null, null, null];
	
	public static function init()
	{		
		for (device in Gamepad.devices)
		{
			addPad(device);
		}
		
		Gamepad.onConnect.add(function(pad:Gamepad): Void
		{
			addPad(pad);
		});
	}

	static function addPad(pad: Gamepad)
	{		
		if (numConnected < 4)
		{
			var pointer: Int = 0;
			
			while (true)
			{
				if (connectedPads[pointer] == null)
				{
					connectedPads[pointer] = pad;
					break;
				}
				
				pointer += 1;
				pointer %= 4;
			}
			
			numConnected += 1;
			
			pad.onButtonDown.add(function(button: GamepadButton): Void
			{
				down.set("ANY", true);
				down.set(button.toString(), true);
				down.set(findPadIndex(pad) + "_" + button.toString(), true);
				down.set(findPadIndex(pad) + "_ANY", true);
			});
			
			pad.onButtonUp.add(function(button: GamepadButton): Void
			{
				var index: Int = findPadIndex(pad);
				down.set(index + "_" + button.toString(), false);
				lastUp.set(index + "_" + button.toString(), 0);
				down.set(index + "_ANY", false);
				lastUp.set(index + "_ANY", 0);
				down.set("ANY", false);
				lastUp.set("ANY", 0);
				down.set(button.toString(), true);
				lastUp.set(button.toString(), 0);
			});				
			
			pad.onAxisMove.add(function(axis: GamepadAxis, value: Float): Void
			{
				var index: Int = findPadIndex(pad);
				axes.set(index + axis.toString(), value);	
				axes.set(axis.toString(), value);
			});
			
			pad.onDisconnect.add(function(): Void
			{
				for (i in 0...connectedPads.length)
				{
					if (connectedPads[i] == pad)
					{
						connectedPads[i] = null;
						numConnected -= 1;
						pointer = 0;
						break;
					}
				}
			});
		}
	}
	
	static function findPadIndex(pad: Gamepad): Int
	{
		for (i in 0...connectedPads.length)
		{
			if (connectedPads[i] == pad)
			{
				return i;
			}
		}
		return -1;
	}

	public static function bind(name: String, key: String): Void
	{
		bindings.set(name, key);
	}
	
	public static function axis(name: String): Float
	{
		if (!axes.exists(name)) return 0;
		return axes.get(name);
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
		
		var keyCode: String = bindings.get(name);
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
		var keyCode: String = bindings.get(name);
		if (down.get(keyCode))
		{
			return true;
		}
		return false;
	}
}