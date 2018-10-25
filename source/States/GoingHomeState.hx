package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxStarField.FlxStarField2D;

class GoingHomeState extends GarbageState
{
    public var stars : FlxStarField2D;
    var ship : HomeShip;
    var tower : FlxSprite;
    public var effects : FlxGroup;

    var button : VcrButton;

    var overlay : FlxSprite;

    var pressed : Bool;
    var colorTween : FlxTween;

    override public function create()
    {
        super.create();

        FlxG.camera.bgColor = 0xFF000000;

        stars = new FlxStarField2D(0, 0, Constants.Width, Constants.Height, 34);
        stars.starVelocityOffset.set(0.005, 0);
        add(stars);

        tower = new FlxSprite(Constants.Width/2 - 7, 228, "assets/images/home-tower.png");
        add(tower);

        ship = new HomeShip(this);
        add(ship);

        effects = new FlxGroup();
        add(effects);

        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png", Palette.Red));

        overlay = new FlxSprite(0, 0, "assets/ui/home-overlay.png");
        add(overlay);

        button = new VcrButton(Constants.Width, Constants.Height-51, null, onButtonPressed, false);
        button.loadSpritesheet("assets/ui/home-button.png", 124, 51);
        button.invertWhilePressed = false;
        add(button);
        pressed = false;

        FlxTween.tween(button, {x : Constants.Width - 124}, 0.5, {ease : FlxEase.circInOut});
    }

    function onButtonPressed()
    {
        if (pressed)
            return;

        pressed = true;

        colorTween = FlxTween.color(overlay, 0.5, Palette.White, Palette.Red, {type : FlxTween.PINGPONG, ease: FlxEase.cubeInOut, startDelay: 0.25, loopDelay: 0.25});

        FlxTween.tween(button, {x : Constants.Width}, 0.5, {ease : FlxEase.circInOut});
        FlxG.camera.shake(0.005, 2, function() {
            ship.launch();
            FlxG.camera.shake(0.005, 10);
        });
    }

    public function onLaunch()
    {
        FlxTween.tween(tower, {y : tower.y + tower.height}, 0.35);
    }

    public function onFinalDecissionTaken()
    {
        FlxG.camera.shake(0.0085, 100);
        colorTween.cancel();
        var c : Int = overlay.color;
        //FlxTween.color(overlay, 0.5, c, Palette.White, {ease: FlxEase.cubeInOut, startDelay: 0.25});
        FlxTween.color(overlay, 0.25, Palette.White, Palette.Red, {type : FlxTween.PINGPONG, ease: FlxEase.cubeInOut, startDelay: 0.125, loopDelay: 0.125});
    }

    public function onShipLeftForHome()
    {
        ship.exists = false;
        remove(ship);

        FlxG.camera.shake(0, 0.1);

        colorTween = FlxTween.color(overlay, 0.5, Palette.White, Palette.Green, {type : FlxTween.PINGPONG, ease: FlxEase.cubeInOut, startDelay: 0.25, loopDelay: 0.25});

        new FlxTimer().start(1, function(_) {
            ProgressData.OnSlaveRewarded();
            FlxG.camera.fade(Palette.Black, 2, false, function() {
                // Return with success!
                FlxG.switchState(new RewardState(1));
            });
        });
    }

    public function onShipDestroyed()
    {
        ship.exists = false;
        remove(ship);

        new FlxTimer().start(4, function(_) {
            ProgressData.OnSlaveRewarded();
            FlxG.camera.fade(Palette.Black, 3, false, function() {
                // Return with failure!
                FlxG.switchState(new RewardState(0));
            });
        });
    }
}
