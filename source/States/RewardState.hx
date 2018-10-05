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

    override public function create()
    {
        super.create();

        FlxG.camera.bgColor = 0xFF000000;

        // TODO: Reward bg
        add(new FlxSprite(0, 0, "assets/backgrounds/bgGameOver.png"));

        slave = new SlaveCharacter(Constants.Width, 235, this, SlaveCharacter.StateNone);
        add(slave);
        var color : Int = slave.color;
        FlxTween.color(slave, 1, 0xFF000000, color, {onComplete: function(_) {
            slave.walkTo(new FlxPoint(Constants.Width/2, 235), onSlavePositioned);
        }});
    }

    function onSlavePositioned()
    {
        slave.switchState(SlaveCharacter.StateNone);
        showMessage();
    }

    function showMessage()
    {
        var message : String =
            "Welcome, welcome, slave " + (FlxG.random.bool(30) ? "uh... " : "") + ProgressData.data.slave_id + "#" +
            FlxG.random.getObject(["Really nice having you here", "Please come in", "..."]) + "#" +
            "Its great you reached your quota. It's thanks to hard working " + FlxG.random.getObject(["inferior beings like you", "friends (I can call you friend, right?)", "slaves like you"]) +
            " that we are " + FlxG.random.getObject(["achieving great things. Great things indeed.", "managing to clean this planet.", "managing to fix the mess this \"humans\" made."]) + "#" +
            "(lore phrase here)#" +
            "Now please, tell me what would you like the best?#" +
            "GO HOME or SPECIAL HONOR";

        var settings : MessageBox.MessageSettings =
        {
            x : 4, y : 4, w: Constants.Width-8, h: Constants.Height/4, border: 4,
            color: -1, animatedBackground: true
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
