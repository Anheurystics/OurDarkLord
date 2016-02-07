package;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.ui.Keyboard;

//TODO improve this shit ASAP
class Menu extends Sprite
{
	var title: TextField;
	
	var straightToHell: Font;
	var previousUpdate: Int;
	
	var joinPlayerCounter: Int;
	var joinedPlayers: Array<Int> = [ -2, -2, -2, -2];
	
	var players: Array<TextField> = [null, null, null, null];
	var ready: Array<Bool> = [false, false, false, false];
	
	public function new() 
	{
		super();
		
		previousUpdate = Lib.getTimer();
		addEventListener(Event.ENTER_FRAME, update);		
		
		straightToHell = Assets.getFont("fonts/straighttohell.bb.ttf");
		
		title = new TextField();
		title.text = "Our Dark Lord\nis\nBetter Than Yours";
		title.width = Lib.current.stage.stageWidth;
		title.height = Lib.current.stage.stageHeight;
		title.x = 0;
		title.selectable = false;
		title.embedFonts = true;
		var format: TextFormat = new TextFormat(straightToHell.fontName, 96, 0xCC0000);
		format.align = TextFormatAlign.CENTER;
		title.defaultTextFormat = format;	
		
		for (i in 0...players.length)
		{
			players[i] = playerTextField("Player " + (i + 1));
			players[i].x = 80;
			players[i].y = 400 + (i * 50);
			addChild(players[i]);
		}

		addChild(title);
	}
	
	
	function playerTextField(label: String): TextField
	{
		var field: TextField = new TextField();
		field.text = label + ": ";
		field.width = Lib.current.stage.stageWidth;
		field.height = 50;
		field.embedFonts = true;
		var format: TextFormat = new TextFormat(straightToHell.fontName, 48, 0xCC0000);
		format.align = TextFormatAlign.LEFT;
		field.defaultTextFormat = format;
		
		return field;
	}
	
	function update(_)
	{
		var delta: Float = (Lib.getTimer() - previousUpdate) / 1000;
		previousUpdate = Lib.getTimer();
		
		Input.update(delta);
		
		if (Input.isPressed("start"))
		{
			for (i in 0...joinedPlayers.length)
			{
				if (joinedPlayers[i] == -1)
				{
					ready[i] = !ready[i];
					players[i].textColor = ready[i]? 0x00CC00 : 0xCC0000;
					
					if (allReadyCheck())
					{
						startGame();
					}					
				}
			}
		}
		
		for (i in 0...3)
		{
			if (Input.isPressed(i+"start"))
			{
				for (j in 0...joinedPlayers.length)
				{
					if (joinedPlayers[j] == i)
					{
						ready[j] = !ready[j];
						players[j].textColor = ready[j]? 0x00CC00 : 0xCC0000;
						
						if (allReadyCheck())
						{
							startGame();
						}	
					}
				}
			}
		}		
		
		if (Input.isPressed("any"))
		{
			playerJoin(-1);
		}
		
		for (i in 0...3)
		{
			if (Input.isPressed(i + "any"))
			{
				playerJoin(i);
			}
		}
	}
	
	function startGame()
	{
		var c: Array<Int> = new Array();
		for (jp in joinedPlayers)
		{
			if (jp != -2)
			{
				c.push(jp);
			}
		}
		
		removeChild(title);
		for (p in players)
		{
			removeChild(p);
		}
		
		removeEventListener(Event.ENTER_FRAME, update);	
		
		parent.addChild(new Game(c));
		parent.removeChild(this);
	}
	
	function allReadyCheck(): Bool
	{
		for (i in 0...ready.length)
		{
			if (!ready[i] && joinedPlayers[i] != -2) return false;
		}
		return true;
	}
	
	function playerJoin(inputID: Int)
	{
		if (joinedPlayers.indexOf(inputID) == -1)
		{
			for (i in 0...joinedPlayers.length)
			{
				if (joinedPlayers[i] == -2)
				{
					joinedPlayers[i] = inputID;
					players[i].text += inputMethod(inputID);
					players[i].type = TextFieldType.INPUT;
					break;
				}
			}
		}
	}
	
	function inputMethod(id: Int): String
	{
		if (id == -1) return "Keyboard";
		if (id >= 0 && id <= 2) return "Gamepad " + (id + 1);
		return "";
	}
}