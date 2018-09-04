package;

import flixel.FlxG;
import flixel.util.FlxTimer;

class RewardState extends GarbageState
{
    var messages : Array<String>;
    var textBox : text.TypeWriter;

    override public function create()
    {
        super.create();

        FlxG.camera.bgColor = 0xFF000000;

        var msgString : String =
            "GO HOME or SPECIAL HONOR#" +
            "Welcome, welcome, slave " + (FlxG.random.bool(30) ? "uh... " : "") + ProgressData.data.slave_id + "#" +
            FlxG.random.getObject(["Really nice having you here", "Please come in", "..."]) + "#" +
            "Its great you reached your quota. It's thanks to hard working " + FlxG.random.getObject(["inferior beings like you", "friends (I can call you friend, right?)", "slaves like you"]) +
            " that we are " + FlxG.random.getObject(["achieving great things. Great things indeed.", "managing to clean this planet.", "managing to fix the mess this \"humans\" made."]) + "#" +
            "(lore phrase here)#" +
            "Now please, tell me what would you like the best?#" +
            "GO HOME or SPECIAL HONOR";

        textBox = new text.TypeWriter(8, 8, Constants.Width-16, 40, "");
        add(textBox);

        messages = msgString.split("#");
        doMessage();
    }

    function doMessage()
    {
        if (messages.length > 0)
        {
            textBox.resetText(messages.shift());
            textBox.start(0.025, doMessage);
        }
        else
        {
            // DONE!
        }
    }
}
