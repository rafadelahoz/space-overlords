package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class Entity extends FlxSprite
{
    public function new(X : Float, Y : Float)
    {
        super(X, Y);
    }

    function destroyTimer(timer : FlxTimer)
    {
        if (timer != null)
        {
            timer.cancel();
            timer.destroy();
            timer = null;
        }
    }

    function destroyTween(tween : FlxTween)
    {
        if (tween != null)
        {
            tween.cancel();
            tween.destroy();
            tween = null;
        }
    }
}
