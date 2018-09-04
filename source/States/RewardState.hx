package;

import flixel.FlxG;

class RewardState extends GarbageState
{
    override public function create()
    {
        super.create();

        FlxG.camera.bgColor = 0xFF000000;

        var msgString : String =
            "Welcome, welcome, slave " + (FlxG.random.bool(50) ? "uh... " : "") + ProgressData.data.slave_id + "\n" +
            FlxG.random.getObject(["Really nice having you here", "Please come", "..."]) + "\n" +
            "Its great you reached your quota. It's thanks to hard working " + FlxG.random.getObject(["inferior beings", "friends (I can call you friend, right?)", "slaves like you"]) +
            " that we are " + FlxG.random.getObject(["achieving great things. Great things indeed.", "managing to clean this planet.", "managing to fix the mess this \"humans\" made."]) + "\n" +
            "(lore phrase here)\n" +
            "Now please, tell me what would you like the best?\n" +
            "GO HOME or SPECIAL HONOR";

        var msg : text.TypeWriter = new text.TypeWriter(8, 8, Constants.Width-16, 40, msgString);
        add(msg);
        msg.start(0.025);
    }
}
