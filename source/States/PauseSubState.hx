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

    var x : Float;
    var y : Float;

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

        background = new FlxSprite(x, y).makeGraphic(Constants.Width, Std.int(Constants.Height*0.3), Palette.Red);
        background.scale.y = 0;
        add(background);

        FlxTween.tween(background.scale, {y: 1}, OpenTime, {ease : FlxEase.sineInOut, onComplete: buildScreen});
    }

    function buildScreen(t : FlxTween)
    {
        t.destroy();

        
    }
}
