package;

import flash.display.Sprite;
/*import flash.display.StageAlign;
import flash.display.StageScaleMode;*/
import flash.events.Event;
import flash.Lib;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;

class Main extends Sprite
{
	var gameWidth:Int = 180; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 320; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = 1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	var game : SpaceGame;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		Lib.current.stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
	}

	private function onDeactivate(?E:Event):Void
	{
		// Save here!
	}

	private function onResize(?E:Event) : Void
	{
		#if android
		Lib.current.stage.displayState = openfl.display.StageDisplayState.FULL_SCREEN_INTERACTIVE;
		#end
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		setupTransitions();

		addChild(game = new SpaceGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
	}

	private function setupTransitions()
	{
		FlxTransitionableState.defaultTransIn = new TransitionData(TransitionType.FADE, 0xFF000000, 0.2);
		FlxTransitionableState.defaultTransOut = new TransitionData(TransitionType.FADE, 0xFF000000, 0.2);
	}
}
