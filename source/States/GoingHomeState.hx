package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxStarField.FlxStarField2D;

class GoingHomeState extends GarbageState
{
    var ship : HomeShip;

    override public function create()
    {
        super.create();

        FlxG.camera.bgColor = 0xFF000000;

        var stars : FlxStarField2D = new FlxStarField2D(0, 0, Constants.Width, Constants.Height, 34);
        stars.starVelocityOffset.set(0.005, 0);
        add(stars);

        ship = new HomeShip(this);
        add(ship);

        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png", Palette.Red));
    }
}
