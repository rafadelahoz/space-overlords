package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import text.PixelText;

class MenuState extends GarbageState
{
    public var tween : FlxTween;

    var touchLabel : FlxSprite;
    var yearsLabel : FlxBitmapText;
    var creditsLabel : FlxBitmapText;
    var background : FlxSprite;
    var backgroundShader : FlxSprite;

    var startTouchZone : FlxObject;

    var interactable : Bool;

    var stars : flixel.addons.display.FlxStarField.FlxStarField2D;

    var startLabelBackground : FlxSprite;

    override public function create():Void
    {
        super.create();

        // Missing a preloader

        interactable = false;

        bgColor = 0xFF000000;

        stars = new flixel.addons.display.FlxStarField.FlxStarField2D(32, 184, 23, 22, 4);
        stars.starVelocityOffset.set(0.0125, 0);
        add(stars);

        background = new FlxSprite(0, 0, "assets/backgrounds/bgCell.png");
        add(background);

        var slaveNumberBg : FlxSprite = new FlxSprite(57, 33).makeGraphic(117, 14, 0xFF9e2835);
        add(slaveNumberBg);

        var logo : FlxSprite = new FlxSprite(0, 0, "assets/ui/title.png");
        add(logo);

        var footer : FlxSprite = new FlxSprite(0, 276, "assets/ui/title-menu-footer.png");
        add(footer);
        add(new VcrClock());

        var slaveNumber : FlxBitmapText = text.VcrText.New(111, 34, text.TextUtils.padWith("" + FlxG.random.int(1, 9999999), 7, "0"));
        add(slaveNumber);

        var backButton : VcrButton = new VcrButton(8, logo.height + 12, null, onBackPressed);
        backButton.loadSpritesheet("assets/ui/title-menu-back.png", 56, 14);
        add(backButton);

        startLabelBackground = new FlxSprite(27, 88+32).makeGraphic(141, 16, 0xFF9e2835);
        startLabelBackground.visible = false;
        add(startLabelBackground);

        touchLabel = new FlxSprite(0, 72+32, "assets/ui/tmp-start-label.png");
        touchLabel.alpha = 0;
        add(touchLabel);

        // VCR effect
        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png"));

        var startDelay : Float = 0.35;
        tween = FlxTween.tween(logo, {y : 0}, 0.75, {startDelay: startDelay, onComplete: onLogoPositioned, ease : FlxEase.quartOut });
        FlxG.camera.scroll.set(0, 0);
    }

    public function onLogoPositioned(_t:FlxTween):Void
    {
        interactable = true;

        startTouchZone = new FlxObject(0, 72+32, Constants.Width, 32);
        add(startTouchZone);

        FlxTween.tween(touchLabel, {alpha : 1}, 0.2, {ease : FlxEase.bounceInOut});
        // startTouchBuzz(null);
    }

    function startTouchBuzz(_t:FlxTween)
    {
        var touchLabelBaseY = touchLabel.y;
        FlxTween.tween(touchLabel, {y : touchLabelBaseY-4}, 0.2, {ease: FlxEase.circOut, startDelay: 2, onComplete: continueTouchBuzz});
    }

    function continueTouchBuzz(_t:FlxTween)
    {
        var touchLabelBaseY = touchLabel.y;
        FlxTween.tween(touchLabel, {y : touchLabelBaseY+4}, 0.5, {ease: FlxEase.elasticOut, onComplete: startTouchBuzz});
    }

    override public function destroy():Void
    {
        super.destroy();
    }

    override public function update(elapsed:Float):Void
    {
        if (FlxG.keys.justPressed.O)
            Screenshot.take();

        if (interactable)
        {
            #if (!mobile)
            if (startTouchZone.getHitbox().containsPoint(FlxG.mouse.getPosition()))
            {
                if (FlxG.mouse.pressed)
                {
                    onTouchLabelPressed();
                }
                else if (FlxG.mouse.justReleased)
                {
                    onTouchLabelReleased();
                    onArcadeButtonPressed();
                }
            }
            #else
            for (touch in FlxG.touches.list)
            {
                if (touch.overlaps(startTouchZone))
                {
                    if (touch.pressed)
                    {
                        onTouchLabelPressed();
                    }
                    else if (touch.justReleased)
                    {
                        onTouchLabelReleased();
                        onArcadeButtonPressed();
                        break ;
                    }
                }
                else if (touchLabel.color != 0xFFFFFFFF)
                {
                    if (touch.justReleased)
                    {
                        onTouchLabelReleased();
                        break ;
                    }
                }
            }
            #end
        }

        super.update(elapsed);
    }

    function onTouchLabelPressed()
    {
        startLabelBackground.visible = true;
    }

    function onTouchLabelReleased()
    {
        startLabelBackground.visible = false;
    }

    public function onArcadeButtonPressed() : Void
    {
        FlxG.camera.fade(0xFF000000, 0.5, false, function() {
            GameController.StartEndless();
        });
    }

    public function onBackPressed()
    {
        GameController.ToTitle(true);
    }
}
