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
    var doorOpenFx : FlxSprite;
    var backgroundShader : FlxSprite;

    var slave : SlaveCharacter;

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

        doorOpenFx = new FlxSprite(0, 152);
        doorOpenFx.loadGraphic("assets/backgrounds/bgCellDoorOpen.png", true, 180, 152);
        doorOpenFx.animation.add("idle", [0]);
        doorOpenFx.animation.add("open", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 16, false);
        doorOpenFx.animation.play("idle");
        add(doorOpenFx);

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
        // museumButton.loadSpritesheet("assets/ui/cell-menu-museum.png", 137, 14);
        // add(museumButton);

        rewardButton = new VcrButton(26, 143 /*+ 12*2*/, onRewardHighlighted, onRewardPressed);
        rewardButton.loadSpritesheet("assets/ui/cell-menu-reward.png", 137, 14);
        if (ProgressData.data.quota_current >= ProgressData.data.quota_target)
            add(rewardButton);

        cursor = new FlxSprite(9, playButton.y+1, "assets/ui/title-menu-cursor.png");
        add(cursor);

        // VCR effect
        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png"));

        hideButtons();

        FlxG.camera.scroll.set(0, 0);
    }

    public function hideButtons()
    {
        backButton.exists = false;
        playButton.exists = false;
        museumButton.exists = false;
        rewardButton.exists = false;

        cursor.visible = false;
    }

    public function showButtons()
    {
        backButton.exists = true;
        playButton.exists = true;
        museumButton.exists = true;
        rewardButton.exists = true;

        cursor.visible = true;

        backButton.alpha = 0;
        playButton.alpha = 0;
        museumButton.alpha = 0;
        rewardButton.alpha = 0;
        FlxTween.tween(backButton, {alpha: 1}, 0.25, {ease: FlxEase.circInOut});
        FlxTween.tween(playButton, {alpha: 1}, 0.25, {ease: FlxEase.circInOut});
        // FlxTween.tween(museumButton, {alpha: 1}, 0.25, {ease: FlxEase.circInOut});
        FlxTween.tween(rewardButton, {alpha: 1}, 0.25, {ease: FlxEase.circInOut});

        allowInteraction();
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
        rewardButton.clearHighlight();
    }

    function onPlayHighlighted()
    {
        backButton.clearHighlight();
        museumButton.clearHighlight();
        rewardButton.clearHighlight();

        cursor.y = playButton.y+1;
    }

    function onMuseumHighlighted()
    {
        backButton.clearHighlight();
        playButton.clearHighlight();
        rewardButton.clearHighlight();

        cursor.y = museumButton.y+1;
    }

    function onRewardHighlighted()
    {
        backButton.clearHighlight();
        playButton.clearHighlight();
        museumButton.clearHighlight();

        cursor.y = rewardButton.y+1;
    }

    public function onArcadeButtonPressed() : Void
    {
        disableButtons();

        // Walk towards door
        var doorPosition : FlxPoint = new FlxPoint(Constants.Width - 80, Constants.Height*0.7);
        slave.walkTo(doorPosition);

        FlxG.camera.fade(0xFF000000, 0.25, false, function() {
            GameController.ToGameConfiguration();
        });
    }

    function onMuseumPressed()
    {
        // Nop!
    }

    function onRewardPressed()
    {
        disableButtons();

        var message : String =
                /*"Slave " + ProgressData.data.slave_id + "!#" +
                "You have reached your quota, and are going to be rewarded#" +
                "You will have the honour of meeting our space overlord" +
                "And then you get to choose your reward#" +
                "Congratulations#" +*/
                "Please, proceed";
        add(new MessageBox().show(message, function() {
            // Door opening
            doorOpenFx.animation.finishCallback = function(_) {
                var doorPosition : FlxPoint = new FlxPoint(126, 204);
                slave.walkTo(doorPosition, function() {
                    slave.switchState(SlaveCharacter.StateNone);
                    var color : Int = slave.color;
                    FlxTween.color(slave, 0.5, color, 0xFF000000, {onComplete: function(_) {
                        FlxG.camera.fade(0xFF000000, 0.25, false, function() {
                            GameController.ToReward();
                        });
                    }});
                });
            };
            doorOpenFx.animation.play("open");
        }));
    }

    public function onBackPressed()
    {
        disableButtons();

        GameController.ToTitle(true);
    }

    function initSlave()
    {
        if (status == StatusNone || status == StatusFromGameover)
        {
            // Normally add a slave randomly
            add(slave = new SlaveCharacter(FlxG.random.int(64, Constants.Width-64),
                                   Constants.Height*0.7 + FlxG.random.int(0, 24),
                                   this, (status == StatusFromGameover ? SlaveCharacter.StateReturn : -2)));
            new FlxTimer().start(0.2, afterSlaveEntry);
        }
        else if (status == StatusNewSlave)
        {
            new FlxTimer().start(2, function(t : FlxTimer) {
                // New slaves fall from top
                add(slave = new SlaveCharacter(Constants.Width/2 - 16, -40, this, SlaveCharacter.StateFall));
                t.start(4.5, afterSlaveEntry);
            });
        }
    }

    function afterSlaveEntry(t:FlxTimer)
    {
        t.destroy();
        showButtons();
    }

    function disableButtons()
    {
        backButton.disable();
        playButton.disable();
        // museumButton.disable();
        rewardButton.disable();

        cursor.visible = false;

        playButton.visible = false;
        rewardButton.visible = false;
    }
}
