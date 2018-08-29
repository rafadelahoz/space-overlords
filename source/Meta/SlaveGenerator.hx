package;

import flixel.FlxG;

class SlaveGenerator
{
    public function new()
    {
        // store current slave data? other data?
    }

    public function generate(data : ProgressData.SaveData)
    {
        data.slave_id = getId();
        data.slave_head = getHead();
        data.slave_detail = getDetail();
        data.slave_color = getColor();
        trace("Generated new slave");
    }

    public function getId()
    {
        return FlxG.random.int(1, 9999999);
    }

    public function getHead() : Int
    {
        return FlxG.random.int(0, 1);
    }

    public function getDetail() : Int
    {
        return FlxG.random.int(0, 2);
    }

    public function getColor() : Int
    {
        return FlxG.random.getObject([0xFFFFFFFF,
            Palette.DarkBlue,
            Palette.DarkPurple,
            Palette.DarkGreen,
            Palette.Brown,
            Palette.DarkGray,
            Palette.LightGray,
            Palette.White,
            Palette.P8Red,
            Palette.Orange,
            Palette.Yellow,
            Palette.Green,
            Palette.Blue,
            Palette.Indigo,
            Palette.Pink,
            Palette.Peach]);
    }
}
