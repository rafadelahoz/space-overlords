package;

import flixel.FlxSprite;
import flixel.text.FlxBitmapText;

class VcrClock extends FlxSprite
{
    var background : FlxSprite;
    var label : FlxBitmapText;

    public function new()
    {
        super(103, 302-4);
        makeGraphic(1, 1, 0x00000000);

        // background = new FlxSprite(x-1, y-1).makeGraphic(72, 12, 0xFF0000FF);
        label = text.VcrText.New(x, y, "", 0xFFFFFFFF);
    }

    override public function update(elapsed : Float)
    {
        var now : Date = Date.now();
        label.text = text.TextUtils.padWith("" + now.getHours(), 2, "0") + ":" +
                     text.TextUtils.padWith("" + now.getMinutes(), 2, "0") + ":" +
                     text.TextUtils.padWith("" + now.getSeconds(), 2, "0");

        super.update(elapsed);
        // background.update(elapsed);
        label.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
        // background.draw();
        label.draw();
    }
}
