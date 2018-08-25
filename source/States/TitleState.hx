package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;

import text.PixelText;

class TitleState extends GarbageState
{
    static var StateLogo : Int = 1;
    static var StateMain : Int = 2;
    static var StateSettings : Int = 3;
    static var StateCredits : Int = 4;

    var state : Int;

    var header : FlxSprite;
    var footer : FlxSprite;

    var screen : FlxGroup;

    /* Logo */
    var LogoDelay : Float = 0.5;

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
		BgmEngine.init();
		SfxEngine.init();

		bgColor = Blue;

        header = new FlxSprite(0, 0, "assets/ui/title-menu-header.png");
        add(header);
        footer = new FlxSprite(0, 276, "assets/ui/title-menu-footer.png");
        add(footer);
        add(new VcrClock());

        add(screen = new FlxGroup());

        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png"));

        FlxG.camera.fade(Blue, 1, true);
        switchState(StateLogo);
    }

    function switchState(Next : Int)
    {
        var flashTime : Float = 0.15;
        FlxG.camera.flash(Blue, flashTime);

        state = Next;

        switch (Next)
        {
            case TitleState.StateLogo:
                clearGroup(screen);
                screen.add(new FlxSprite(0, baseY, "assets/ui/title-splash.png"));
                new FlxTimer().start(1 + flashTime + LogoDelay, function(t:FlxTimer) {
                    t.destroy();
                    switchState(StateMain);
                });
            case TitleState.StateMain:
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
    }

    function onPlayPressed()
    {
        GameController.ToMenu();
    }

    function onSettingsPressed()
    {

    }

    function onCreditsPressed()
    {

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
