package;

import flixel.FlxG;
import PlaySessionData.GameOverData;

class GameController
{
	public static function Init()
	{
		// Init subsystems
		text.PixelText.Init();

		BgmEngine.init();
		SfxEngine.init();

		ThemeManager.Init();

		ProgressData.Init();
		GameSettings.Init();

		LoreLibrary.Init();

		if (ProgressData.data.uuid == null)
			ProgressData.GenerateUUID();

		if (ProgressData.data.slave_count < 0)
			ProgressData.StartNewGame();

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

	public static function ToMenu(?fromGameOver : Bool = false)
	{
		SaveStateManager.loadAndErase();

		var menuStatus : Int = -1;
		// ProgressData.data.slave_id = -1;
		if (ProgressData.data.slave_id < 0)
		{
			ProgressData.GenerateNewSlave();
			menuStatus = MenuState.StatusNewSlave;
		}
		else if (fromGameOver)
		{
			menuStatus = MenuState.StatusFromGameover;
		}

		FlxG.switchState(new MenuState(menuStatus));
	}

	public static function ToGameConfiguration()
	{
		FlxG.switchState(new GamePreState());
	}

	public static function StartGameplay(?DontLoad : Bool = true)
	{
		var restoredSessionData : Dynamic = null;
		if (!DontLoad && SaveStateManager.savestateExists())
		{
			// Load previous game
			trace("RESTORING DATA");
			restoredSessionData = SaveStateManager.loadAndErase();
		}
		else
		{
			// Delete stored game
			SaveStateManager.loadAndErase();
		}

		FlxG.switchState(new PlayState(restoredSessionData));
	}

	public static function OnGameplayEnd()
	{
		// Depending on the state, do things?
		ToMenu();
	}

	public static function GameOver(mode : Int, data : PlaySessionData)
	{
		// Prepare game over data
		var goData : GameOverData = ProcessGameoverData(mode, data);

		// Go to game over
		FlxG.switchState(new GameoverState(goData));
	}

	public static function ProcessGameoverData(mode : Int, data : PlaySessionData) : GameOverData
	{
		// Prepare game over data
		var goData : GameOverData = new GameOverData(data);
			// Store quota prior to this session
			goData.previousQuota = ProgressData.data.quota_current;
			// Compute new quota
			goData.quotaDelta = computeQuota(mode, data);
			goData.currentQuota = ProgressData.data.quota_current + goData.quotaDelta;

			// Store scores and totals
			if (mode == Constants.ModeEndless)
			{
				if (data.score > ProgressData.data.endless_high_score)
					ProgressData.data.endless_high_score = data.score;
				if (data.items > ProgressData.data.endless_high_items)
					ProgressData.data.endless_high_items = data.items;
			}
			else if (mode == Constants.ModeTreasure)
			{
				if (data.cycle > ProgressData.data.treasure_high_cycles)
					ProgressData.data.treasure_high_cycles = data.cycle;
			}

		// Store it
		ProgressData.data.quota_current += goData.quotaDelta;
		ProgressData.Save();

		return goData;
	}

	public static function ToReward()
	{
		FlxG.switchState(new RewardState());
	}

	static function computeQuota(mode : Int, data : PlaySessionData) : Int
	{
		if (mode == Constants.ModeEndless)
			return data.items;
		else
			return data.cycle * 100;
	}

	/* DEBUG */

	static function HandleMessageboxDebug()
	{
		var message : String =
            /*"Welcome, welcome, slave " + (FlxG.random.bool(30) ? "uh... " : "") + ProgressData.data.slave_id + "#" +
            FlxG.random.getObject(["Really nice having you here", "Please come in", "..."]) + "#" +
            "Its great you reached your quota. It's thanks to hard working " + FlxG.random.getObject(["inferior beings", "friends", "slaves"]) + " like you" +
            " that we are " + FlxG.random.getObject(["achieving great things. Great things indeed.", "managing to clean this planet."]) + "#" +*/
            LoreLibrary.getLore() /*+ "#" +
            "Anyhow!#" +
            "As you have reached your quota, you can now choose.#" +
            "Would you like to go back home, or a special reward?"*/;
			//"";
		var settings : MessageBox.MessageSettings =
        {
            x : 0, y : 0, w: Constants.Width, h: 88, border: 10,
            bgOffsetX : 0, bgOffsetY: 0, bgGraphic: "assets/ui/overlord-dialog-bg.png",
            color: Palette.Black ,  animatedBackground: false
        };

        FlxG.state.add(new MessageBox().show(message, settings, function() {
			ProgressData.data.slave_count += 1;
            HandleMessageboxDebug();
        }));
	}
}

enum GameState { Loading; Title; Menu; Play; GameOver; }
