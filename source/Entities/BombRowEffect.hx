package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class BombRowEffect extends FlxSprite
{
    var GrowTime : Float = 0.25;
    var ExitTime : Float = 0.9;

    var tween : FlxTween;

    public function new(X : Float, Y : Float, Width : Int, Height : Int)
    {
        super(X, Y);

        makeGraphic(Width, Height, 0xFFFFFFFF);
        scale.y = 0;
        tween = FlxTween.tween(this.scale, {y : 1}, GrowTime, {startDelay: 0.9, ease : FlxEase.expoIn, onComplete: function(t:FlxTween) {
            tween = FlxTween.tween(this, {alpha : 0}, ExitTime, {startDelay: 0.4, ease : FlxEase.expoIn, onComplete: function(tt:FlxTween) {
                tt.destroy();
                destroy();
            }});
        }});
    }

    var tweenActive : Bool;
    public function onPauseStart()
    {
        if (tween != null)
        {
            tweenActive = tween.active;
            if (tween.active)
                tween.active = false;
        }
    }

    public function onPauseEnd()
    {
        if (tween != null)
        {
            if (tweenActive)
                tween.active = true;
        }
    }
}
