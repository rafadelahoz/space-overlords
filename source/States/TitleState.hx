package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;

import text.PixelText;

class TitleState extends GarbageState
{
    static var StateLogo : Int = 1;
    static var StateMain : Int = 2;
    static var StateSettings : Int = 3;
    static var StateCredits : Int = 4;

    public var avoidLogo : Bool = false;

    var state : Int;

    var header : FlxSprite;
    var footer : FlxSprite;

    var screen : FlxGroup;

    /* Logo */
    var LogoDelay : Float = 2;
    var logoTimer : FlxTimer;
    var logoTouch : TouchArea;

    /* Main */
    var cursor : FlxSprite;
    var playButton : VcrButton;
    var settingsButton : VcrButton;
    var creditsButton : VcrButton;

    var Blue : Int = 0xFF0000FF;
    var baseY : Int = 36;

    override public function create()
    {
        super.create();

		// Missing a preloader
        GameController.Init();

		bgColor = Blue;

        header = new FlxSprite(0, 0, "assets/ui/title-menu-header.png");
        add(header);
        footer = new FlxSprite(0, 276, "assets/ui/title-menu-footer.png");
        add(footer);
        add(new VcrClock());

        add(screen = new FlxGroup());

        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png"));

        FlxG.camera.fade(Blue, 1, true);
        switchState(avoidLogo ? StateMain : StateLogo);
    }

    function switchState(Next : Int)
    {
        var flashTime : Float = 0.15;
        FlxG.camera.flash(Blue, flashTime);

        new FlxTimer().start(0.01, function(t:FlxTimer) {
            t.destroy();

            state = Next;

            switch (Next)
            {
                case TitleState.StateLogo:
                    clearGroup(screen);
                    screen.add(new FlxSprite(0, baseY, "assets/ui/title-splash.png"));
                    logoTimer = new FlxTimer();
                    logoTimer.start(1 + flashTime + LogoDelay, function(t:FlxTimer) {
                        logoTimer.destroy();
                        logoTimer = null;
                        switchState(StateMain);
                    });
                    var touchArea : TouchArea = new TouchArea(0, 0, Constants.Width, Constants.Height, function() {
                        logoTimer.cancel();
                        switchState(StateMain);
                    });
                    screen.add(touchArea);

                case TitleState.StateMain:
                    if (SaveStateManager.savestateExists())
                    {
                        clearGroup(screen);
                        screen.add(new MessageBox().show("An on-going work session is present. It will be restored", function() {
                            GameController.StartGameplay(false);
                        }));
                    }
                    else
                    {
                        clearGroup(screen);
                        screen.add(new FlxSprite(0, baseY, "assets/ui/title-menu-main.png"));

                        playButton = new VcrButton(26, 119, onPlayHighlighted, onPlayPressed);
                        playButton.loadSpritesheet("assets/ui/title-menu-cellfeed.png", 83, 14);
                        screen.add(playButton);

                        settingsButton = new VcrButton(26, baseY + 107, onSettingsHighlighted, onSettingsPressed);
                        settingsButton.loadSpritesheet("assets/ui/title-menu-settings.png", 83, 14);
                        screen.add(settingsButton);

                        creditsButton = new VcrButton(26, baseY + 131, onCreditsHighlighted, onCreditsPressed);
                        creditsButton.loadSpritesheet("assets/ui/title-menu-credits.png", 83, 14);
                        screen.add(creditsButton);

                        cursor = new FlxSprite(9, playButton.y+1, "assets/ui/title-menu-cursor.png");
                        screen.add(cursor);
                    }
                case TitleState.StateSettings:
                    clearGroup(screen);
                    screen.add(new FlxSprite(0, baseY, "assets/ui/title-settings-main.png"));

                    var backButton : VcrButton = new VcrButton(8, baseY + 47, null, onBackPressed);
                    backButton.loadSpritesheet("assets/ui/title-menu-back.png", 56, 14);
                    screen.add(backButton);

                    var musicSwitch : VcrSwitch = new VcrSwitch(98, baseY + 107, BgmEngine.Enabled, function() {
                        backButton.clearHighlight();
                    }, function(Enabled : Bool) {
                        if (Enabled)
                            BgmEngine.enable();
                        else
                            BgmEngine.disable();
                    });
                    screen.add(musicSwitch);

                    var sfxSwitch : VcrSwitch = new VcrSwitch(98, baseY + 131, SfxEngine.Enabled, function() {
                        backButton.clearHighlight();
                    }, function(Enabled : Bool) {
                        if (Enabled)
                            SfxEngine.enable();
                        else
                            SfxEngine.disable();
                    });
                    screen.add(sfxSwitch);

                    var newSlaveButton : VcrButton = new VcrButton(98, baseY + 131 + 3*12, null, function() {
                        ProgressData.data.slave_id = -1;
                        screen.add(new MessageBox().show("Slave deleted."));
                    });
                    newSlaveButton.loadSpritesheet("assets/ui/gameconfig-intensity-remove.png", 11, 14, true);
                    screen.add(newSlaveButton);

                    var reachQuotaButton : VcrButton = new VcrButton(98 + 3*12, baseY + 131 + 3*12, null, function() {
                        ProgressData.data.quota_current = ProgressData.data.quota_target;
                        screen.add(new MessageBox().show("Quota reached"));
                    });
                    reachQuotaButton.loadSpritesheet("assets/ui/gameconfig-intensity-add.png", 11, 14, true);
                    screen.add(reachQuotaButton);

                case TitleState.StateCredits:
                    clearGroup(screen);
                    screen.add(new FlxSprite(0, baseY, "assets/ui/title-credits-main.png"));

                    var backButton : VcrButton = new VcrButton(8, baseY + 47, null, onBackPressed);
                    backButton.loadSpritesheet("assets/ui/title-menu-back.png", 56, 14);
                    screen.add(backButton);
            }
        });
    }

    /* Button handlers */
    function onPlayPressed()
    {
        GameController.ToMenu();
    }

    function onSettingsPressed()
    {
        switchState(StateSettings);
    }

    function onCreditsPressed()
    {
        switchState(StateCredits);
    }

    function onPlayHighlighted()
    {
        settingsButton.clearHighlight();
        creditsButton.clearHighlight();

        cursor.y = playButton.y+1;
    }

    function onSettingsHighlighted()
    {
        playButton.clearHighlight();
        creditsButton.clearHighlight();

        cursor.y = settingsButton.y+1;
    }

    function onCreditsHighlighted()
    {
        playButton.clearHighlight();
        settingsButton.clearHighlight();

        cursor.y = creditsButton.y+1;
    }

    // Settings

    function onBackPressed() {
        switchState(StateMain);
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case TitleState.StateLogo:

            case TitleState.StateMain:

        }
        super.update(elapsed);
    }

    function clearGroup(group : FlxGroup)
    {
        var iterator  = group.iterator();
        while (iterator.hasNext())
        {
            var item : FlxBasic = iterator.next();
            if (item != null)
            {
                group.remove(item);
                item.kill();
                item.destroy();
            }
        }

        group.clear();
    }
}
