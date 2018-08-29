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
    public static var StatusNone : Int = -1;
    public static var StatusNewSlave : Int = 0;
    public static var StatusFromGameover : Int = 1;

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

    var status : Int;

    public function new(?InitialStatus: Int = -1)
    {
        super();

        status = InitialStatus;
    }

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

        initSlave();

        // Generic header
        add(new FlxSprite(0, 0, "assets/ui/title-menu-header.png"));

        var baseY : Float = 36;

        var logo : FlxSprite = new FlxSprite(0, baseY, "assets/ui/cell-menu-main.png");
        add(logo);

        var footer : FlxSprite = new FlxSprite(0, 276, "assets/ui/title-menu-footer.png");
        add(footer);
        add(new VcrClock());

        var slaveNumber : FlxBitmapText = text.VcrText.New(107, baseY+24, text.TextUtils.padWith("" + ProgressData.data.slave_id, 7, "0"));
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

        allowInteraction();

        FlxG.camera.scroll.set(0, 0);
    }

    public function allowInteraction(?_):Void
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

    function initSlave()
    {
        if (status == StatusNone || status == StatusFromGameover)
        {
            // Normally add a slave randomly
            add(new SlaveCharacter(FlxG.random.int(64, Constants.Width-64),
                                   Constants.Height*0.7 + FlxG.random.int(0, 24),
                                   this));
        }
        else if (status == StatusNewSlave)
        {
            // New slaves fall from top
            add(new SlaveCharacter(Constants.Width/2 - 16, -40, this, true));
        }
    }
}
