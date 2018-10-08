package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
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

    var backgroundTween : FlxTween;

    var touchArea : TouchArea;

    public function show(Message : String, ?Settings : MessageSettings = null, ?Callback : Void -> Void = null) : MessageBox
    {
        var bgColor : Int = Palette.DarkBlue;
        var textColor : Int = 0xFFFFFFFF;
        var animatedBackground : Bool = false;

        if (Settings != null)
        {
            x = Settings.x;
            y = Settings.y;
            width = Settings.w;
            height = Settings.h;
            border = Settings.border;
            textColor = Settings.color;
            animatedBackground = Settings.animatedBackground;
        }
        else
        {
            x = 0;
            y = Constants.Height/2 - 24;
            width = Constants.Width;
            height = 48;
            border = 8;
        }

        if (!animatedBackground)
        {
            background = new FlxSprite(x, y).makeGraphic(Std.int(width), Std.int(height), bgColor);
        }
        else
        {
            background = new FlxSprite(x, y, "assets/ui/overlord-dialog-bg.png");
        }
        background.scale.y = 0;
        add(background);

        textBox = new text.TypeWriter(x+border, y+border, Std.int(width-2*border), Std.int(height-2*border), "", textColor);
        add(textBox);

        callback = Callback;

        messages = Message.split("#");

        // touchArea = new TouchArea(x, y, Std.int(width), Std.int(height), function() {
        touchArea = new TouchArea(x, y, Constants.Width, Constants.Height, function() {
            GamePad.setPressed(GamePad.Shoot);
        });
        add(touchArea);

        FlxTween.tween(background.scale, {y: 1}, OpenTime, {ease : FlxEase.circInOut, onComplete: function(_) {
            doMessage();
            if (animatedBackground)
                doBackgroundAnimation();
        }});

        return this;
    }

    function doBackgroundAnimation(?tween : FlxTween = null)
    {
        // if (tween != null) tween.destroy();
        var startDelay : Float = (FlxG.random.bool(30) ? FlxG.random.float(0.5, 0.8) : FlxG.random.float(0.01, 0.05));

        background.scale.set(1.01, 1.01);
        backgroundTween = FlxTween.tween(background.scale, {x: 0.99, y: 0.99}, FlxG.random.float(0.05, 0.1),
                        {startDelay: startDelay, ease: FlxEase.backInOut, onComplete: doBackgroundAnimation});
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
            if (backgroundTween != null)
            {
                backgroundTween.cancel();
                backgroundTween.destroy();
                backgroundTween = null;
            }

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

typedef MessageSettings = {
    var x : Float;
    var y : Float;
    var w : Float;
    var h : Float;
    var border : Int;
    var color : Int;
    var animatedBackground : Bool;
};
