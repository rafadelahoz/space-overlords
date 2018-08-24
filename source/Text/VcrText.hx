package text;

import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;

import openfl.Assets;

class VcrText
{
	// VCR pixel font
	public static var font : FlxBitmapFont;

	static var initialized : Bool;

	public static function Init()
	{
		// if (!initialized)
		{
			// Monospace
			var monospaceLetters = "0123456789";
			font = FlxBitmapFont.fromMonospace("assets/fonts/vcr-numbers.png", monospaceLetters, FlxPoint.get(9, 12));

			initialized = true;
		}
	}

	public static function New(X : Float, Y : Float, Text : String, ?Color : Int = 0xFFFFFFFF, ?Width : Int = -1) : FlxBitmapText
	{
		Init();

		var text : FlxBitmapText = new FlxBitmapText(font);
		text.x = X;
		text.y = Y;
		text.text = Text;
		text.color = Color;
		text.useTextColor = false;

		if (Width > 0)
		{
			text.wordWrap = true;
			/*text.autoSize = false;
			text.width = Width;*/
			text.multiLine = true;
		}

		return text;
	}
}
