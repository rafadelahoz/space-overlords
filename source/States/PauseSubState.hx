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
    var callback : Void -> Void;

    var scanlines : Scanlines;
    var background : FlxSprite;
    var resumeButton : VcrButton;

    var x : Float;
    var y : Float;
    var width : Int;
    var height : Int;

    var enabled : Bool;

    public function new(World : PlayState, ?Callback : Void -> Void = null)
    {
        super();

        world = World;
        callback = Callback;
    }

    override public function create()
    {
        x = 0;
        y = Constants.Height * 0.3;
        width = Constants.Width;
        height = Std.int(Constants.Height*0.3);

        scanlines = new Scanlines(0, 0, "assets/ui/vcr-overlay.png", Palette.Red);
        add(scanlines);

        background = new FlxSprite(x, y).makeGraphic(width, height, Palette.Red);
        background.scale.y = 0;
        add(background);

        FlxTween.tween(background.scale, {y: 1}, OpenTime, {ease : FlxEase.sineInOut, onComplete: buildScreen});

        enabled = false;
    }

    function buildScreen(t : FlxTween)
    {
        t.destroy();

        resumeButton = new VcrButton(x + (width/2-35/2), y + height * 0.8, null, onResumePressed);
        resumeButton.loadSpritesheet("assets/ui/gameover-popup-ok.png", 35, 14);
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

    function resumeGame(?t:FlxTween = null)
    {
        if (t != null)
        {
            t.destroy();
        }

        if (callback != null)
        {
            callback();
        }

        close();
    }
}
