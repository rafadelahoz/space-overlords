package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class RewardState extends GarbageState
{
    var slave : SlaveCharacter;

    var messages : Array<String>;
    var textBox : text.TypeWriter;

    var overlord : FlxSprite;
    var overlordBg : FlxSprite;

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
        overlord.animation.play("idle");
        overlord.scale.y = 0;
        add(overlord);

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
                showMessage();
            }
        });
        FlxTween.tween(overlord.scale, {y : 1}, 0.5, {ease: FlxEase.circOut});
    }

    function showMessage()
    {
        overlord.animation.play("talk");

        var message : String =
            "Welcome, welcome, slave " + (FlxG.random.bool(30) ? "uh... " : "") + ProgressData.data.slave_id + "#" +
            FlxG.random.getObject(["Really nice having you here", "Please come in", "..."]) + "#" +
            "Its great you reached your quota. It's thanks to hard working " + FlxG.random.getObject(["inferior beings like you", "friends (I can call you friend, right?)", "slaves like you"]) +
            " that we are " + FlxG.random.getObject(["achieving great things. Great things indeed.", "managing to clean this planet.", "managing to fix the mess this \"humans\" made."]) + "#" +
            "You know this weird material that is scattered around the whole planet?#The science team says it's not a natural resource! Turns out HOMINS produced it!#They used it for everything. It was named something like PLASTIX.#They must have really liked it, because they didn't develop a way to dispose of it.#It's literally everywhere!#" +
            "Now please, tell me what would you like the best?#" +
            "GO HOME or SPECIAL HONOR";

        var settings : MessageBox.MessageSettings =
        {
            x : 0, y : 0, w: Constants.Width, h: 88, border: 10,
            color: Palette.Black, animatedBackground: true
        };

        add(new MessageBox().show(message, settings, function() {
            // DONE!
            FlxG.camera.flash(Palette.Red, 0.75, function() {
                ProgressData.OnSlaveRewarded();
                GameController.ToMenu();
            });
        }));
    }
}
