package;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class Overlay extends Sprite
{		
	public var playerWins: TextField;
	
	public function new() 
	{	
		super();
		
		playerWins = new TextField();
		playerWins.text = "Player Wins";
		playerWins.width = Lib.current.stage.stageWidth;
		playerWins.height = Lib.current.stage.stageHeight;
		playerWins.embedFonts = true;
		
		var format: TextFormat = new TextFormat(Assets.getFont("fonts/straighttohell.bb.ttf").fontName, 64, 0xCC0000);
		format.align = TextFormatAlign.CENTER;
		playerWins.defaultTextFormat = format;	
		
		addChild(playerWins);
		
		playerWins.visible = false;
	}
	
	public function update(delta: Float, gameInfo: GameInfo): Void
	{
		graphics.clear();
		
		var w: Int = Std.int(Lib.current.stage.stageWidth);
		var h: Int = Std.int(Lib.current.stage.stageHeight);
		graphics.lineStyle(2, 0x000000, 0.5);
		for (viewport in gameInfo.viewports)
		{
			graphics.drawRect(Std.int(w * viewport.x), Std.int(h * (viewport.y)), Std.int(w * viewport.width), Std.int(h * viewport.height));
		}
	}
}