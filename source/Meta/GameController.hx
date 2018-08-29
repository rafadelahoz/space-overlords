package;

import flixel.FlxG;

class GameController
{
	public static function Init()
	{
		// Init subsystems
		BgmEngine.init();
		SfxEngine.init();

		ProgressData.Init();

		// FlxG.autoPause = false;
		#if (!mobile)
			FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();

			var sprite : flixel.FlxSprite= new flixel.FlxSprite();
			sprite.makeGraphic(20, 20, 0x00FFFFFF);
			flixel.util.FlxSpriteUtil.drawCircle(sprite, 10, 10, 7, 0x00FFFFFF, {color: Palette.Black, thickness: 2});
			flixel.util.FlxSpriteUtil.drawCircle(sprite, 10, 10, 8, 0x00FFFFFF, {color: Palette.White, thickness: 2});

			// Load the sprite's graphic to the cursor
			FlxG.mouse.load(sprite.pixels, 1, -10, -10);
		#end
	}

	public static function ToTitle(?avoidLogo : Bool = false)
	{
		var titleState : TitleState = new TitleState();
		titleState.avoidLogo = true;
		FlxG.switchState(titleState);
	}

	public static function ToMenu()
	{
		var menuStatus : Int = -1;
		if (ProgressData.data.slave_id < 0)
		{
			ProgressData.StartNewGame();
			menuStatus = MenuState.StatusNewSlave;
		}

		FlxG.switchState(new MenuState(menuStatus));
	}

	public static function StartEndless(?DontLoad : Bool = false)
	{
		// Start endless
		// Load previous game?
		FlxG.switchState(new PlayState());
	}

	public static function OnGameplayEnd()
	{
		// Depending on the state, do things?
		ToMenu();
	}

	public static function GameOver(mode : Int, data : PlaySessionData)
	{
		// Handle GameOver, store data, go to results screen?
		FlxG.switchState(new GameoverState(data));
	}
}

enum GameState { Loading; Title; Menu; Play; GameOver; }
