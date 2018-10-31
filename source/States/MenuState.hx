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
    var cellSpeaker : FlxSprite;
    var speechTimer : FlxTimer;

    var slave : SlaveCharacter;

    var backButton : VcrButton;
    var playButton : VcrButton;
    var cameraButton : VcrButton;
    var rewardButton : VcrButton;
    var cursor : FlxSprite;

    var logo : FlxSprite;
    var footer : FlxSprite;
    var clock : VcrClock;

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

        cellSpeaker = new FlxSprite(140, 89);
        cellSpeaker.loadGraphic("assets/images/cell-speaker-sheet.png", true, 33, 27);
        cellSpeaker.animation.add("idle", [0]);
        cellSpeaker.animation.add("speak", [0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1], 5, true);
        cellSpeaker.animation.play("idle");
        add(cellSpeaker);

        initSlave();

        // Generic header
        add(new FlxSprite(0, 0, "assets/ui/title-menu-header.png"));

        var baseY : Float = 36;

        logo = new FlxSprite(0, baseY, "assets/ui/cell-menu-main.png");
        add(logo);

        footer = new FlxSprite(0, 276, "assets/ui/title-menu-footer.png");
        add(footer);
        clock = new VcrClock();
        add(clock);

        var slaveNumber : FlxBitmapText = text.VcrText.New(107, baseY+24, text.TextUtils.padWith("" + ProgressData.data.slave_id, 7, "0"));
        add(slaveNumber);

        backButton = new VcrButton(8, 83, onBackHighlighted, onBackPressed);
        backButton.loadSpritesheet("assets/ui/title-menu-back.png", 56, 14);
        add(backButton);

        playButton = new VcrButton(26, 119, onPlayHighlighted, onArcadeButtonPressed);
        playButton.loadSpritesheet("assets/ui/cell-menu-newgame.png", 137, 14);
        add(playButton);

        cameraButton = new VcrButton(Constants.Width - 16, 276 - 16, onCameraHighlighted, onCameraPressed);
        cameraButton.loadSpritesheet("assets/ui/gameconfig-intensity-add.png", 11, 14);
        // add(cameraButton);

        rewardButton = new VcrButton(26, 143 /*+ 12*2*/, onRewardHighlighted, onRewardPressed);
        rewardButton.loadSpritesheet("assets/ui/cell-menu-reward.png", 137, 14);
        if (ProgressData.data.quota_current >= ProgressData.data.quota_target)
            add(rewardButton);

        cursor = new FlxSprite(9, playButton.y+1, "assets/ui/title-menu-cursor.png");
        add(cursor);

        // VCR effect
        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png"));

        hideButtons();

        speechTimer = new FlxTimer();

        FlxG.camera.scroll.set(0, 0);
    }

    public function hideButtons()
    {
        backButton.exists = false;
        playButton.exists = false;
        cameraButton.exists = false;
        rewardButton.exists = false;

        cursor.visible = false;
    }

    public function showButtons()
    {
        backButton.exists = true;
        playButton.exists = true;
        cameraButton.exists = true;
        rewardButton.exists = true;

        cursor.visible = true;

        backButton.alpha = 0;
        playButton.alpha = 0;
        cameraButton.alpha = 0;
        rewardButton.alpha = 0;
        FlxTween.tween(backButton, {alpha: 1}, 0.25, {ease: FlxEase.circInOut});
        FlxTween.tween(playButton, {alpha: 1}, 0.25, {ease: FlxEase.circInOut});
        FlxTween.tween(cameraButton, {alpha: 1}, 0.25, {ease: FlxEase.circInOut});
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
        cameraButton.clearHighlight();
        rewardButton.clearHighlight();
    }

    function onPlayHighlighted()
    {
        backButton.clearHighlight();
        cameraButton.clearHighlight();
        rewardButton.clearHighlight();

        cursor.y = playButton.y+1;
    }

    function onCameraHighlighted()
    {
        backButton.clearHighlight();
        playButton.clearHighlight();
        rewardButton.clearHighlight();

        // cursor.y = cameraButton.y+1;
    }

    function onRewardHighlighted()
    {
        backButton.clearHighlight();
        playButton.clearHighlight();
        cameraButton.clearHighlight();

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

    function onCameraPressed()
    {
        disableButtons();
        #if !mobile
            FlxG.mouse.visible = false;
        #end
        new FlxTimer().start(0.01, function(_) {
            draw();
            // Screenshot.take("so-" + Date.now().getTime());
            FlxG.camera.flash(Palette.White, 2, function() {
                ShareManager.share("Greetings from slave " + ProgressData.data.slave_id + " from the #spaceoverlords mothership.");
                enableButtons();
                #if !mobile
                    FlxG.mouse.visible = true;
                #end
            });

        });
    }

    function doSpeechSfx(_)
    {
        SfxEngine.play(FlxG.random.getObject([SfxEngine.SFX.SpeakerA, SfxEngine.SFX.SpeakerB]), 0.5);
        speechTimer.start(FlxG.random.float(0.08, 0.22), doSpeechSfx);
    }

    function onRewardPressed()
    {
        disableButtons();
        cellSpeaker.animation.play("speak");

        SfxEngine.play(SfxEngine.SFX.RewardFanfare);

        doSpeechSfx(speechTimer);

        new FlxTimer().start(0.1, function(_) {

            var settings : MessageBox.MessageSettings =
            {
                x : 0, y : 143, w: Constants.Width, h: 68, border: 10,
                bgOffsetX : 0, bgOffsetY: 25, bgGraphic: "assets/ui/cell-speaker-dialog-bg.png",
                color: Palette.Black, animatedBackground: true
            };

            var message : String =
                    "Slave " + ProgressData.data.slave_id + "!#" +
                    "You have reached your quota, and are going to be rewarded.#" +
                    "You will now have the honor of meeting our space overlord.#" +
                    "Suspicious behaviour or rebellious acts will result in the termination of your being.#" +
                    "You have been warned.#" +
                    "Please, proceed through the door.#" +
                    "Congratulations.";
            add(new MessageBox().show(message, settings, function() {
                speechTimer.cancel();

                SfxEngine.play(SfxEngine.SFX.PauseEnd);

                // Door opening
                doorOpenFx.animation.finishCallback = function(_) {
                    var doorPosition : FlxPoint = new FlxPoint(126, 204);
                    slave.walkTo(doorPosition, function() {
                        slave.switchState(SlaveCharacter.StateNone);
                        slave.colorize(0xFF000000, 0.5, function() {
                            FlxG.camera.fade(0xFF000000, 0.25, false, function() {
                                GameController.ToReward();
                            });
                        });
                    });
                };
                doorOpenFx.animation.play("open");
                SfxEngine.play(SfxEngine.SFX.QuotaPopupFanfare);
            }, function() {
                doSpeechSfx(speechTimer);
            }, function() {
                speechTimer.cancel();
            }));
        });
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
            add(slave = new SlaveCharacter(Constants.Width/2 - 16, -40, this, SlaveCharacter.StateNone));
            slave.visible = false;
            new FlxTimer().start(2, function(t : FlxTimer) {
                // New slaves fall from top
                slave.visible = true;
                slave.switchState(SlaveCharacter.StateFall);
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
        cameraButton.disable();
        rewardButton.disable();

        cursor.visible = false;
        backButton.visible = false;
        playButton.visible = false;
        cameraButton.visible = false;
        rewardButton.visible = false;
    }

    function enableButtons()
    {
        backButton.enable();
        playButton.enable();
        cameraButton.disable();
        rewardButton.enable();

        cursor.visible = true;
        backButton.visible = true;
        playButton.visible = true;
        cameraButton.visible = true;
        rewardButton.visible = true;
    }
}
