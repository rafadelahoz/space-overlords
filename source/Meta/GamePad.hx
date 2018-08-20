package;

import flash.display.BitmapData;

import flixel.FlxG;

class GamePad
{
	static var previousPadState : Map<Int, Bool>;
	static var currentPadState : Map<Int, Bool>;
	static var bufferPadState : Map<Int, Bool>;

	public static function init() : Void
	{
		initState();
	}

	public static function handlePadState() : Void
	{
		previousPadState = currentPadState;

		currentPadState = bufferPadState;
		currentPadState.set(Left, currentPadState.get(Left) || FlxG.keys.pressed.LEFT);
		currentPadState.set(Right, currentPadState.get(Right) || FlxG.keys.pressed.RIGHT);
		currentPadState.set(Down, currentPadState.get(Down) || FlxG.keys.pressed.DOWN);
		currentPadState.set(Shoot, currentPadState.get(Shoot) || FlxG.keys.pressed.A);
		currentPadState.set(Pause, currentPadState.get(Pause) || FlxG.keys.pressed.ESCAPE);

		bufferPadState = initPadState();
	}

	public static function setPressed(button : Int)
	{
		bufferPadState.set(button, true);
	}

	public static function checkButton(button : Int) : Bool
	{
		return currentPadState.get(button);
	}

	public static function justPressed(button : Int) : Bool
	{
		return currentPadState.get(button) && !previousPadState.get(button);
	}

	public static function justReleased(button : Int) : Bool
	{
		return !currentPadState.get(button) && previousPadState.get(button);
	}

	public static function resetInputs() : Void
	{
		initPadState();
	}

	private static function initState() : Void
	{
		bufferPadState = initPadState();
		currentPadState = initPadState();
		previousPadState = initPadState();
	}

	private static function initPadState() : Map<Int, Bool>
	{
		var padState : Map<Int, Bool> = new Map<Int, Bool>();
		padState.set(Left, false);
		padState.set(Right, false);
		padState.set(Down, false);
		padState.set(Shoot, false);
		padState.set(Pause, false);

		return padState;
	}

	public static var Left 	: Int = 0;
	public static var Right : Int = 1;
	public static var Down 	: Int = 4;
	public static var Shoot	: Int = 2;
	public static var Pause : Int = 3;
}
