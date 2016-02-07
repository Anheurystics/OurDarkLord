package;

class Input
{
	public static function bind(name: String, key: Dynamic): Void
	{
		if (Std.is(key, Int))
		{
			KeyboardInput.bind(name, cast key);
		}
		if (Std.is(key, String))
		{
			GamepadInput.bind(name, cast key);
		}
	}
	
	public static function isPressed(name: String): Bool
	{
		return KeyboardInput.isPressed(name) || GamepadInput.isPressed(name);
	}
	
	public static function isDown(name: String): Bool
	{
		return KeyboardInput.isDown(name) || GamepadInput.isDown(name);
	}
	
	public static function update(delta): Void
	{
		KeyboardInput.update(delta);
		GamepadInput.update(delta);
	}
}