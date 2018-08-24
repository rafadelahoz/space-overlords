package;

import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;

class ScrollingLabel extends FlxSprite
{
    var label : FlxBitmapText;

    var scrollWidth : Int;
    var currentText : String;

    var baseText : String;
    var buffer : Array<String>;

    var scrollTimer : FlxTimer;
    var scrollHalfTimer : FlxTimer;
    var ScrollDelay : Float = 0.2;

    public function new(X : Float, Y : Float, Width : Int, ?Text : String = null, Color : Int)
    {
        super(X, Y);

        scrollWidth = Width;

        makeGraphic(0, 0, 0x00000000);

        baseText = Text;
        if (baseText == null)
            baseText = "";
        buffer = [];

        // Start full empty
        var startText = "";
        for (i in 0...Width)
        {
            startText += " ";
        }

        currentText = startText;

        label = text.PixelText.New(X, Y, startText, Color);

        scrollTimer = new FlxTimer();
        scrollHalfTimer = new FlxTimer();
        scrollTimer.start(ScrollDelay, onScrollTimer);
        scrollHalfTimer.start(ScrollDelay/2, onScrollHalfTimer);
    }

    public function appendText(text : String)
    {
        buffer.push(text);
    }

    public function setText(text : String)
    {
        baseText = text;
    }

    public function resetText(text : String, Color : Int)
    {
        baseText = text;
        currentText = text;
        buffer = [];

        label.color = Color;
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);
        label.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
        label.draw();
    }

    function onScrollHalfTimer(t:FlxTimer)
    {
        label.x -= 4;
    }

    function onScrollTimer(t:FlxTimer)
    {
        label.x += 4;
        currentText = currentText.substring(1);
        if (currentText.length < scrollWidth-1)
        {
            currentText += " # ";
            if (buffer.length > 0)
            {
                currentText += buffer.shift();
            }
            else
            {
                currentText += baseText;
            }
        }

        label.text = currentText.substring(0, scrollWidth);

        scrollTimer.start(ScrollDelay, onScrollTimer);
        scrollHalfTimer.start(ScrollDelay/2, onScrollHalfTimer);
    }
}
