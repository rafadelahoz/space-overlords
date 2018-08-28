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

    var backButton : VcrButton;
    var playButton : VcrButton;
    var museumButton : VcrButton;
    var rewardButton : VcrButton;
    var cursor : FlxSprite;

    var interactable : Bool;

    var stars : flixel.addons.display.FlxStarField.FlxStarField2D;

    var startLabelBackground : FlxSprite;

    override public function create():Void
    {
        super.create();

        interactable = false;

        bgColor = 0xFF000000;

        stars = new flixel.addons.display.FlxStarField.FlxStarField2D(32, 184, 23, 22, 4);
        stars.starVelocityOffset.set(0.0125, 0);
        add(stars);

        background = new FlxSprite(0, 0, "assets/backgrounds/bgCell.png");
        add(background);

        add(new SlaveCharacter(74, 223, this));

        // Generic header
        add(new FlxSprite(0, 0, "assets/ui/title-menu-header.png"));

        var baseY : Float = 36;

        var logo : FlxSprite = new FlxSprite(0, baseY, "assets/ui/cell-menu-main.png");
        add(logo);

        var footer : FlxSprite = new FlxSprite(0, 276, "assets/ui/title-menu-footer.png");
        add(footer);
        add(new VcrClock());

        var slaveNumber : FlxBitmapText = text.VcrText.New(107, baseY+24, text.TextUtils.padWith("" + FlxG.random.int(1, 9999999), 7, "0"));
        add(slaveNumber);

        backButton = new VcrButton(8, 83, onBackHighlighted, onBackPressed);
        backButton.loadSpritesheet("assets/ui/title-menu-back.png", 56, 14);
        add(backButton);

        playButton = new VcrButton(26, 119, onPlayHighlighted, onArcadeButtonPressed);
        playButton.loadSpritesheet("assets/ui/cell-menu-newgame.png", 137, 14);
        add(playButton);

        museumButton = new VcrButton(26, 143, onMuseumHighlighted, onMuseumPressed);
        museumButton.loadSpritesheet("assets/ui/cell-menu-museum.png", 137, 14);
        add(museumButton);

        cursor = new FlxSprite(9, playButton.y+1, "assets/ui/title-menu-cursor.png");
        add(cursor);

        // VCR effect
        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png"));

        // var startDelay : Float = 0.35;
        // tween = FlxTween.tween(logo, {y : 0}, 0.75, {startDelay: startDelay, onComplete: onLogoPositioned, ease : FlxEase.quartOut });
        onLogoPositioned();
        FlxG.camera.scroll.set(0, 0);
    }

    public function onLogoPositioned(?_t:FlxTween = null):Void
    {
        interactable = true;
    }

    override public function destroy():Void
    {
        super.destroy();
    }

    function onBackHighlighted()
    {
        playButton.clearHighlight();
        museumButton.clearHighlight();
    }

    function onPlayHighlighted()
    {
        backButton.clearHighlight();
        museumButton.clearHighlight();

        cursor.y = playButton.y+1;
    }

    function onMuseumHighlighted()
    {
        backButton.clearHighlight();
        playButton.clearHighlight();

        cursor.y = museumButton.y+1;
    }

    public function onArcadeButtonPressed() : Void
    {
        FlxG.camera.fade(0xFF000000, 0.5, false, function() {
            GameController.StartEndless();
        });
    }

    function onMuseumPressed()
    {
        // Nop!
    }

    public function onBackPressed()
    {
        GameController.ToTitle(true);
    }
}
