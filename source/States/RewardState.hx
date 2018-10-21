package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxSpriteGroup;

class RewardState extends GarbageState
{
    var slave : SlaveCharacter;

    var messages : Array<String>;
    var textBox : text.TypeWriter;

    var overlord : FlxSprite;
    var overlordBg : FlxSprite;

    var responseReward : VcrButton;
    var responseHome : VcrButton;

    var rewardBot : FlxSprite;
    var rewardMinislave : FlxSpriteGroup;

    override public function create()
    {
        super.create();

        FlxG.camera.bgColor = 0xFF000000;

        add(new FlxSprite(0, 0, "assets/backgrounds/overlord-background.png"));

        overlordBg = new FlxSprite(14, 127);
        overlordBg.makeGraphic(152, 87, 0xFFe8b796);
        add(overlordBg);
        overlordBg.scale.y = 0;
        overlord = new FlxSprite(13, 127);
        overlord.loadGraphic("assets/images/overlord-anim-sprite.png", true, 153, 87);
        overlord.animation.add("idle", [0]);
        overlord.animation.add("talk", [0, 1, 2, 3, 4, 5], 6, true);
        overlord.animation.add("open", [0, 6, 7], 8, false);
        overlord.animation.add("drama", [8, 9, 10], 20, true);
        overlord.animation.add("gulp", [11, 12, 0], 1, false);
        overlord.animation.play("idle");
        overlord.scale.y = 0;
        add(overlord);

        // Minislave added here to be behind scanlines
        rewardMinislave = new FlxSpriteGroup(154, 174);
        add(rewardMinislave);

        add(new Scanlines(14, 127, "assets/ui/overlord-scanlines.png", Palette.Yellow));

        slave = new SlaveCharacter(Constants.Width, 235, this, SlaveCharacter.StateNone);
        add(slave);
        var color : Int = slave.color;
        FlxTween.color(slave, 1, 0xFF000000, color, {onComplete: function(_) {
            slave.walkTo(new FlxPoint(Constants.Width/2 + 24, 235), onSlavePositioned);
        }});
    }

    function onSlavePositioned()
    {
        slave.switchState(SlaveCharacter.StateNone);
        FlxTween.tween(overlordBg.scale, {y : 1}, 0.5, {ease: FlxEase.circOut,
            onComplete: function(_) {
                showMainMessage();
                // showSlaveResponses();
            }
        });
        FlxTween.tween(overlord.scale, {y : 1}, 0.5, {ease: FlxEase.circOut});
    }

    function showMainMessage()
    {
        var message : String =
            /*"Welcome, welcome, slave " + (FlxG.random.bool(30) ? "uh... " : "") + ProgressData.data.slave_id + "#" +
            FlxG.random.getObject(["Really nice having you here", "Please come in", "..."]) + "#" +
            "Its great you reached your quota. It's thanks to hard working " + FlxG.random.getObject(["inferior beings", "friends", "slaves"]) + " like you" +
            " that we are " + FlxG.random.getObject(["achieving great things. Great things indeed.", "managing to clean this planet."]) + "#" +
            LoreLibrary.getLore() + "#" +
            "Anyhow!#" +
            "As you have reached your quota, you can now choose. " +*/
            "Would you like to go back home, or a special reward?";

        showMessage(message, showSlaveResponses);
    }

    function showMessage(message : String, callback : Void -> Void)
    {
        overlord.animation.play("talk");

        var settings : MessageBox.MessageSettings =
        {
            x : 0, y : 0, w: Constants.Width, h: 88, border: 10,
            color: Palette.Black, animatedBackground: true
        };

        add(new MessageBox().show(message, settings, function() {
            overlord.animation.play("idle");
            callback();
        }));
    }

    function showSlaveResponses()
    {
        // DEBUG: Iterate on messages
        // ProgressData.data.slave_count += 1;
        // showMainMessage();
        // return;

        responseHome = new VcrButton(101, 186, onResponseHomeHighlighted, onResponseHomeSelected);
        responseHome.loadSpritesheet("assets/images/slave-answer-home.png", 72, 44);
        // responseHome.invertWhilePressed = false;
        add(responseHome);
        makeResponseAppear(responseHome);

        responseReward = new VcrButton(39, 210, onResponseRewardHighlighted, onResponseRewardSelected);
        responseReward.loadSpritesheet("assets/images/slave-answer-reward.png", 72, 40);
        // responseReward.invertWhilePressed = false;
        add(responseReward);
        makeResponseAppear(responseReward);
    }

    function makeResponseAppear(response : VcrButton)
    {
        var duration : Float = 0.5;
        response.scale.set(1, 0);
        response.alpha = 0;
        FlxTween.tween(response.scale, {y: 1}, duration, {ease: FlxEase.bounceOut});
        FlxTween.tween(response, {alpha: 1}, duration, {ease: FlxEase.circInOut});

        FlxTween.tween(response, {y : response.y-4},
                       2*FlxG.random.float(duration, duration*1.1),
                       {
                           ease : FlxEase.quintInOut,
                           loopDelay: FlxG.random.float(duration*0.9, duration*1.1),
                           type: FlxTween.PINGPONG
                       });
    }

    function onResponseHomeHighlighted()
    {
        responseReward.clearHighlight();
    }

    function onResponseRewardHighlighted()
    {
        responseHome.clearHighlight();
    }

    function onResponseHomeSelected()
    {
        hideSelectedResponse(responseHome, handleHomeEnding);
        hideOtherResponse(responseReward);
    }

    function onResponseRewardSelected()
    {
        hideSelectedResponse(responseReward, handleRewardEnding);
        hideOtherResponse(responseHome);
    }

    function handleHomeEnding()
    {
        var message : String =
            "Ok! You are going home then!#" +
            "We will prepare a ship for you immediately#" +
            "Thank you for the good work!";
        showMessage(message, function() {
            var tempMsg : String = "OK SO THE SLAVE WENT BACK TO ITS PLANET AND NOBODY WAS KILLED IN ANY WAY!#NOW YOU GET A NEW SLAVE";
            add(new MessageBox().show(tempMsg, {
                x : 0, y : Constants.Height/2-Constants.Height/4, w: Constants.Width, h: Constants.Height/2, border: 10,
                color: Palette.White, animatedBackground: false
            }, function() {
                GameController.ToMenu();
            }));
        });
    }

    function handleRewardEnding()
    {
        var message : String =
            "Oh! It's a great honor to receive the special reward!#" +
            "You are a very lucky slave!#" +
            "Please, stay still for a second.";
        showMessage(message, startRewardSequence);
    }

    function startRewardSequence()
    {
        rewardBot = new FlxSprite(slave.x-2 , -100);
        rewardBot.loadGraphic("assets/images/reward-robot-arm.png", true, 36, 51);
        rewardBot.animation.add("go", [0, 1], FlxG.random.int(2, 6));
        rewardBot.animation.play("go");
        add(rewardBot);

        trace("Start at : " + rewardBot.x + ", " + rewardBot.y);

        FlxTween.linearMotion(rewardBot, rewardBot.x, -50, rewardBot.x, 195, 4, true, {ease: FlxEase.sineInOut, onComplete: function(_) {
            FlxTween.linearMotion(rewardBot, rewardBot.x, rewardBot.y,
                                             rewardBot.x, rewardBot.y + 8, 0.5,
                                             true, {ease: FlxEase.elasticIn, onComplete: rewardGrabSlave});
        }});
    }

    function rewardGrabSlave(_)
    {
        FlxG.camera.shake(0.005);
        var offset : FlxPoint = FlxPoint.get(slave.x - rewardBot.x, slave.y - rewardBot.y);
        new FlxTimer().start(0.5, function(_) {
            FlxTween.linearMotion(rewardBot, rewardBot.x, rewardBot.y,
                                            rewardBot.x, rewardBot.y - 60, 2,
                                            true, {ease: FlxEase.quartInOut,
                onUpdate: function(_) {
                    slave.x = rewardBot.x + offset.x;
                    slave.y = rewardBot.y + offset.y;
                },
                onComplete: function(t:FlxTween) {
                    new FlxTimer().start(0.5, function(_) {
                        FlxTween.linearMotion(rewardBot, rewardBot.x, rewardBot.y,
                                            -200, rewardBot.y, 2,
                                            true,
                        {ease: FlxEase.backIn,
                            onUpdate: function(_) {
                                slave.x = rewardBot.x + offset.x;
                                slave.y = rewardBot.y + offset.y;
                                slave.shadow.x = slave.x;
                            },
                            onComplete: rewardFeedSlave
                        });
                    });
                }
            });
        });
    }

    function rewardFeedSlave(_)
    {
        overlord.animation.play("open");
        overlord.animation.finishCallback = function(_) {
            // FlxG.camera.shake(0.01,10);
            overlord.animation.play("drama");
        }

        new FlxTimer().start(1, function(_) {
            // FlxG.camera.shake(0.02,10);

            // Spawn small slave
            var minislaveColor : FlxSprite = new FlxSprite(0, 0);
            minislaveColor.loadGraphic("assets/images/reward-slave-color.png", true, 12, 18);
            minislaveColor.animation.add("wiggle", [0, 1, 2, 3], 4, true);
            minislaveColor.animation.play("wiggle");
            minislaveColor.color = slave.color;
            rewardMinislave.add(minislaveColor);

            var minislaveBorder : FlxSprite = new FlxSprite(0, 0);
            minislaveBorder.loadGraphic("assets/images/reward-slave-border.png", true, 12, 18);
            minislaveBorder.animation.add("wiggle", [0, 1, 2, 3], 4, true);
            minislaveBorder.animation.play("wiggle");
            rewardMinislave.add(minislaveBorder);

            // Move it to mouth
            FlxTween.linearMotion(rewardMinislave, rewardMinislave.x, rewardMinislave.y, 96, rewardMinislave.y, 6, true, {onComplete: rewardEatSlave});
        });
    }

    function rewardEatSlave(_)
    {
        new FlxTimer().start(1.5, function(_) {
            FlxG.camera.shake(0.05);
            // Flash red
            FlxG.camera.flash(Palette.Red, 0.25);
            // Close mouth
            rewardMinislave.visible = false;
            rewardMinislave.destroy();
            overlord.animation.play("gulp");
            overlord.animation.finishCallback = function(name : String) {
                overlord.animation.play("idle");
                showMessage("Now get me another slave!", onSceneEnd);
            }
        });
    }

    function hideSelectedResponse(response : VcrButton, callback : Void -> Void)
    {
        var duration : Float = 0.75;
        FlxTween.tween(response, {y : response.y - 32, alpha : 0}, duration, {ease: FlxEase.expoOut, onComplete: function(_) {
            response.destroy();
            if (callback != null)
                callback();
        }});
    }

    function hideOtherResponse(response : VcrButton)
    {
        var duration : Float = 0.45;
        FlxTween.tween(response, {y : response.y + 32, alpha : 0}, duration, {ease: FlxEase.quadIn});
        FlxTween.tween(response.scale, {y: 0}, duration, {ease: FlxEase.bounceInOut, onComplete: function(_) {
            response.destroy();
        }});
    }

    function onSceneEnd()
    {
        ProgressData.OnSlaveRewarded();
        FlxG.camera.fade(Palette.Black, 2, false, function() {
            GameController.ToMenu();
        });
    }
}
