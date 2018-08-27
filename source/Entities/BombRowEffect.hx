package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class BombRowEffect extends FlxSprite
{
    var GrowTime : Float = 0.25;
    var ExitTime : Float = 0.9;

    var world : PlayState;

    var tween : FlxTween;

    public function new(X : Float, Y : Float, World : PlayState)
    {
        super(X, Y);

        world = World;

        makeGraphic(world.grid.columns*Constants.TileSize, Constants.TileSize, 0xFFFFFFFF);
        scale.y = 0;
        tween = FlxTween.tween(this.scale, {y : 1}, GrowTime, {startDelay: 0.2, ease : FlxEase.expoIn, onComplete: function(t:FlxTween) {
            tween = FlxTween.tween(this, {alpha : 0}, ExitTime, {startDelay: 0.4, ease : FlxEase.expoIn, onComplete: function(tt:FlxTween) {
                tt.destroy();
                destroy();
            }});
        }});
    }
}
