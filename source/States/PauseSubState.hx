package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;

import flixel.util.FlxSpriteUtil;

import flixel.addons.ui.FlxButtonPlus;

import text.PixelText;

class PauseSubstate extends FlxSubState
{
    var OpenTime : Float = 0.3;

    var world : PlayState;
    var resumeCallback : Void -> Void;
    var abortCallback : Void -> Void;

    var scanlines : Scanlines;
    var background : FlxSprite;
    var top : FlxSprite;
    var musicSwitch : VcrSwitch;
    var sfxSwitch : VcrSwitch;

    var resumeButton : VcrButton;
    var abortButton : VcrButton;

    var x : Float;
    var y : Float;

    var enabled : Bool;

    public function new(World : PlayState, ResumeCallback : Void -> Void, AbortCallback : Void -> Void)
    {
        super();

        world = World;
        resumeCallback = ResumeCallback;
        abortCallback = AbortCallback;
    }

    override public function create()
    {
        x = 0;
        y = 96;

        scanlines = new Scanlines(0, 0, "assets/ui/vcr-overlay.png", Palette.Red);
        add(scanlines);

        background = new FlxSprite(x, y, "assets/ui/pause-background.png");
        background.scale.y = 0;
        add(background);

        top = new FlxSprite(0, -36).makeGraphic(Constants.Width, 36, 0xFF0000FF);
        add(top);

        FlxTween.tween(background.scale, {y: 1}, OpenTime, {ease : FlxEase.sineInOut, onComplete: buildScreen});
        FlxTween.tween(top, {y: 0}, OpenTime, {ease : FlxEase.sineIn, onComplete: buildScreen});

        enabled = false;
    }

    function buildScreen(t : FlxTween)
    {
        t.destroy();

        abortButton = new VcrButton(x + 17, y + 107, onAbortHighlighted, onAbortPressed);
        abortButton.loadSpritesheet("assets/ui/pause-abort.png", 61, 14);
        add(abortButton);

        resumeButton = new VcrButton(x + 93, y + 107, onResumeHighlighted, onResumePressed);
        resumeButton.loadSpritesheet("assets/ui/pause-resume.png", 70, 14);
        add(resumeButton);

        musicSwitch = new VcrSwitch(17, 11, BgmEngine.Enabled, function() {
            // backButton.clearHighlight();
        }, function(Enabled : Bool) {
            if (Enabled)
            {
                BgmEngine.enable(true);
                BgmEngine.pauseCurrent();
            }
            else
                BgmEngine.disable();
        });
        musicSwitch.setupGraphic("assets/ui/pause-bgm-switch.png", 65, 14);
        add(musicSwitch);

        sfxSwitch = new VcrSwitch(98, 11, SfxEngine.Enabled, function() {
            // backButton.clearHighlight();
        }, function(Enabled : Bool) {
            if (Enabled)
                SfxEngine.enable();
            else
                SfxEngine.disable();
        });
        sfxSwitch.setupGraphic("assets/ui/pause-sfx-switch.png", 65, 14);
        add(sfxSwitch);

        enabled = true;
    }

    function clean()
    {
        if (resumeButton != null)
        {
            resumeButton.exists = false;
            remove(resumeButton);
            // resumeButton.destroy();
        }

        if (abortButton != null)
        {
            abortButton.exists = false;
            remove(abortButton);
        }

        if (musicSwitch != null)
        {
            musicSwitch.exists = false;
            remove(musicSwitch);
        }

        if (sfxSwitch != null)
        {
            sfxSwitch.exists = false;
            remove(sfxSwitch);
        }
    }

    function onResumeHighlighted()
    {
        abortButton.clearHighlight();
    }

    function onAbortHighlighted()
    {
        resumeButton.clearHighlight();
    }

    function onResumePressed()
    {
        if (enabled)
        {
            enabled = false;

            // TODO: Disable buttons

            clean();
            clear();
            add(background);
            add(top);
            FlxTween.tween(background.scale, {y : 0}, OpenTime, {ease : FlxEase.sineInOut, onComplete: resumeGame});
            FlxTween.tween(top, {y: -36}, OpenTime, {ease : FlxEase.sineInOut});
        }
    }

    function onAbortPressed()
    {
        if (enabled)
        {
            enabled = false;

            // What to do?
            clean();
            clear();
            add(background);
            add(top);
            FlxTween.tween(background.scale, {y : 0}, OpenTime, {ease : FlxEase.sineInOut, onComplete: endGame});
            FlxTween.tween(top, {y: -36}, OpenTime, {ease : FlxEase.sineInOut});
        }
    }

    function endGame(?t:FlxTween = null)
    {
        if (t != null)
            t.destroy();

        if (abortCallback != null)
            abortCallback();

        world.switchState(PlayState.StateLost);

        close();
    }

    function resumeGame(?t:FlxTween = null)
    {
        if (t != null)
            t.destroy();

        if (resumeCallback != null)
            resumeCallback();

        close();
    }
}
