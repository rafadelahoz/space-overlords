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

class GamePreState extends GarbageState
{
    var background : FlxSprite;

    var backButton : VcrButton;
    var playButton : VcrButton;

    override public function create():Void
    {
        super.create();

        bgColor = 0xFF000000;

        background = new FlxSprite(0, 0, "assets/backgrounds/bgGameConfig.png");
        add(background);

        initSlave();

        backButton = new VcrButton(8, 83, onBackHighlighted, onBackPressed);
        backButton.loadSpritesheet("assets/ui/title-menu-back.png", 56, 14);
        add(backButton);

        var modeSwitch : VcrSwitch = new VcrSwitch(0, 108, true, function() {
            playButton.clearHighlight();
            backButton.clearHighlight();
        }, function(on : Bool) {
            // If on: mode = endless
        });
        modeSwitch.setupGraphic("assets/ui/gameconfig-mode-switch.png", 180, 36);
        add(modeSwitch);

        playButton = new VcrButton(107, 203, onPlayHighlighted, onArcadeButtonPressed);
        playButton.loadSpritesheet("assets/ui/gameconfig-start.png", 65, 14);
        add(playButton);

        // Generic header
        add(new FlxSprite(0, 0, "assets/ui/title-menu-header.png"));

        var baseY : Float = 36;

        var logo : FlxSprite = new FlxSprite(0, baseY, "assets/ui/gameconfig-main.png");
        add(logo);

        var slaveNumber : FlxBitmapText = text.VcrText.New(107, baseY+24, text.TextUtils.padWith("" + ProgressData.data.slave_id, 7, "0"));
        add(slaveNumber);

        add(new VcrClock());

        // VCR effect
        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png"));

        FlxG.camera.scroll.set(0, 0);
    }

    override public function destroy():Void
    {
        super.destroy();
    }

    function onBackHighlighted()
    {
        playButton.clearHighlight();
    }

    function onPlayHighlighted()
    {
        backButton.clearHighlight();
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
        GameController.ToMenu();
    }

    function initSlave()
    {
        add(new SlaveCharacter(-32, 235, this, SlaveCharacter.StateRight));
    }
}
