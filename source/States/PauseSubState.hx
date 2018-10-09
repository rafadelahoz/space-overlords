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

        FlxTween.tween(background.scale, {y: 1}, OpenTime, {ease : FlxEase.sineInOut, onComplete: buildScreen});

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

        enabled = true;
    }

    function clean()
    {
        if (resumeButton != null)
        {
            resumeButton.kill();
            remove(resumeButton);
            // resumeButton.destroy();
        }

        if (abortButton != null)
        {
            abortButton.kill();
            remove(abortButton);
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
            FlxTween.tween(background.scale, {y : 0}, OpenTime, {ease : FlxEase.sineInOut, onComplete: resumeGame});
        }
    }

    function onAbortPressed()
    {
        if (enabled)
        {
            enabled = false;

            // What to do?
            clean();

            FlxTween.tween(background.scale, {y : 0}, OpenTime, {ease : FlxEase.sineInOut, onComplete: endGame});
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
