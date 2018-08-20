package text;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

import openfl.Assets;

/**
 * @author Rafa de la Hoz (@thegraffo) over work of Simon Zeni (Bl4ckb0ne)
 */

class TextBox extends FlxGroup
{
	static var originX : Int = 120;
	static var originY : Int = 64;

	static var borderX : Int = 4;
	static var borderY : Int = 8;

	static var boxWidth : Int = 240;
	static var boxHeight: Int = 32;


	private static var world : FlxState;
	private static var textBox : TextBox;

	public static function Init(World : FlxState, ?OriginX : Float = -1, ?OriginY : Float = -1, ?Width : Int = -1, ?Height : Int = -1)
	{
		world = World;

		if (OriginX > -1)
			originX = Std.int(OriginX);
		if (OriginY > -1)
			originY = Std.int(OriginY);

		if (Width > 0)
			boxWidth = Std.int(Width);
		if (Height > 0)
			boxHeight = Std.int(Height);
	}

	public static function Message(name : String, message : String, ?completeCallback:Dynamic)
	{
		if (textBox == null)
		{
			if (name == null)
				name = "";

			textBox = new TextBox(name);
			textBox._callback = completeCallback;
			textBox.talk(message);
			world.add(textBox);
		}
	}

	private var _background:FlxSprite;
	private var _name:FlxBitmapText;
	private var _typetext:TypeWriter;
	private var _isTalking:Bool;
	private var _skip:FlxBitmapText;
	private var _callback:Dynamic;

	override public function new(Name:String):Void
	{
		super();

		// Initialize the background image, you can use a simple FlxSprite fill with one color
		_background = new FlxSprite(originX, originY).makeGraphic(boxWidth, boxHeight, 0xFF010101);
		_background.scrollFactor.set(0, 0);

	 	// The name of the person who talk, from the arguments
		_name = PixelText.New(originX, originY, Name, 0xffbcbcbc);
		_name.scrollFactor.set(0, 0);

	 	// The skip text, you can change the key
		_skip = PixelText.New(originX + boxWidth - 32, originY + boxHeight - 8, "[OK!]", 0xffbcbcbc);
		_skip.scrollFactor.set(0, 0);

	 	// Initialize all the bools for the TextBox system
		_isTalking = false;
	}

	public function show():Void
	{
		add(_background);
		add(_name);
		add(_skip);
	}

	public function hide():Void
	{
		remove(_background);
		remove(_name);
		remove(_typetext);
		remove(_skip);

		textBox.destroy();
		textBox = null;
	}

	public function talk(Message:String):Void
	{
		if(!_isTalking) {
			_isTalking = true;

			_name.visible = false;
			_skip.visible = false;

			show();

			_background.scale.y = 0;
			FlxTween.tween(_background.scale, {y: 1}, 0.08, {onComplete: function(_t:FlxTween) {
				// Set up a new TypeWriter for each text
				_typetext = new TypeWriter(originX + borderX,
										   originY + borderY,
										   boxWidth - borderX*2,
										   boxHeight - borderY*2,
										   Message, 0xffdedede, 12);

				_typetext.scrollFactor.set();
				// _typetext.showCursor = true;
				// _typetext.cursorBlinkSpeed = 1.0;
				_typetext.setTypingVariation(0.75, true);
				_typetext.useDefaultSound = true;

				// Add it to the screen and start it
				add(_typetext);

				_name.visible = true;
				_skip.visible = true;

				_typetext.start(0.01, onCompleted);
			}});
		}
	}

	public function onCompleted():Void
	{
		_name.visible = false;
		_skip.visible = false;
		_typetext.visible = false;

		FlxTween.tween(_background.scale, {y: 0}, 0.08, {onComplete: function(_t:FlxTween) {
			hide();
			_isTalking = false;

			if (_callback != null)
				_callback();
		}});
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (_typetext != null)
		{
			if (_typetext.finished)
			{
				if (_typetext.thereIsMoreText)
					_skip.text = "[>>]"
				else
					_skip.text = "[Ok]";
			}
			else
			{
				_skip.text = "[{}]";
			}


			if (GamePad.checkButton(GamePad.Shoot))
				_skip.color = 0xFFffb300;
			else
				_skip.color = 0xFFbcbcbc;
		}
	}
}
