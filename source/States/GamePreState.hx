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
import flixel.util.FlxSpriteUtil;
import flixel.addons.transition.FlxTransitionableState;

import text.PixelText;

class GamePreState extends GarbageState
{
    var background : FlxSprite;

    var backButton : VcrButton;
    var playButton : VcrButton;
    var lessButton : VcrButton;
    var moreButton : VcrButton;
    var intensityBar : FlxSprite;

    var intensity : Int;

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

        var intensityBg : FlxSprite = new FlxSprite(9, modeSwitch.y + modeSwitch.height + 10, "assets/ui/gameconfig-intensity-bg.png");
        add(intensityBg);

        lessButton = new VcrButton(9*3-1, intensityBg.y + 23, onLessHighlighted, onLessPressed, false);
        lessButton.loadSpritesheet("assets/ui/gameconfig-intensity-remove.png", 11, 14, true);
        add(lessButton);

        moreButton = new VcrButton(intensityBg.x + intensityBg.width + 8, intensityBg.y + 23, onMoreHighlighted, onMorePressed, false);
        moreButton.loadSpritesheet("assets/ui/gameconfig-intensity-add.png", 11, 14, true);
        add(moreButton);

        intensityBar = new FlxSprite(9+36, intensityBg.y + 24);
        intensityBar.makeGraphic(90, 12, 0x00000000);
        add(intensityBar);

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

        intensity = 40;
    }

    override public function destroy():Void
    {
        super.destroy();
    }

    override public function update(elapsed : Float)
    {
        // Update intensity bar
        intensity = Std.int(flixel.math.FlxMath.bound(intensity, 0, 100));
        FlxSpriteUtil.fill(intensityBar, 0x00000000);
        FlxSpriteUtil.drawRect(intensityBar, 0, 0, (intensity / 100) * intensityBar.width, 12, 0xFFFFFFFF);

        super.update(elapsed);
    }

    function onBackHighlighted()
    {
        playButton.clearHighlight();
        lessButton.clearHighlight();
        moreButton.clearHighlight();
    }

    function onPlayHighlighted()
    {
        backButton.clearHighlight();
        lessButton.clearHighlight();
        moreButton.clearHighlight();
    }

    function onLessHighlighted()
    {
        playButton.clearHighlight();
        backButton.clearHighlight();
        moreButton.clearHighlight();
    }

    function onMoreHighlighted()
    {
        backButton.clearHighlight();
        playButton.clearHighlight();
        lessButton.clearHighlight();
    }

    function onLessPressed()
    {
        playButton.clearHighlight();
        backButton.clearHighlight();

        intensity -= 20;
    }

    function onMorePressed()
    {
        playButton.clearHighlight();
        backButton.clearHighlight();

        intensity += 20;
    }

    public function onArcadeButtonPressed() : Void
    {
        FlxG.camera.fade(0xFF000000, 0.5, false, function() {
            GameController.StartEndless();
        });
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
