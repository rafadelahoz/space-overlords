package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class MessageBox extends FlxGroup
{
    var OpenTime : Float = 0.35;

    var x : Float;
    var y : Float;
    var width : Float;
    var height : Float;
    var border : Int;

    var background : FlxSprite;

    var messages : Array<String>;
    var textBox : text.TypeWriter;
    var callback : Void -> Void;

    var touchArea : TouchArea;

    public function show(Message : String, ?Callback : Void -> Void = null) : MessageBox
    {
        x = 0;
        y = Constants.Height/2 - 24;
        width = Constants.Width;
        height = 48;
        border = 8;

        var bgColor : Int = Palette.DarkBlue;

        background = new FlxSprite(x, y).makeGraphic(Std.int(width), Std.int(height), bgColor);
        background.scale.y = 0;
        add(background);

        textBox = new text.TypeWriter(x+border, y+border, Std.int(width-2*border), Std.int(height-2*border), "");
        add(textBox);

        callback = Callback;

        messages = Message.split("#");

        touchArea = new TouchArea(x, y, Std.int(width), Std.int(height), function() {
            GamePad.setPressed(GamePad.Shoot);
        });
        add(touchArea);

        FlxTween.tween(background.scale, {y: 1}, OpenTime, {ease : FlxEase.circInOut, onComplete: function(_) {
            doMessage();
        }});

        return this;
    }

    function doMessage()
    {
        if (messages.length > 0)
        {
            textBox.resetText(messages.shift());
            textBox.start(0.025, doMessage);
        }
        else if (messages != null)
        {
            messages = null;
            remove(textBox);
            textBox.destroy();

            FlxTween.tween(background.scale, {y: 0}, OpenTime, {ease : FlxEase.circInOut, onComplete: function(_) {
                remove(background);
                background.destroy();

                // DONE!
                if (callback != null)
                    callback();
            }});
        }
    }
}
