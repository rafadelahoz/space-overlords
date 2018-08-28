package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class TextNotice extends FlxSprite
{
    var textDelta : FlxPoint;

    var originalColor : Int;
    var border : Int;
    var pxtext : FlxBitmapText;
    var background : FlxSprite;
    var colorTween : FlxTween;

    var longer : Bool;

    var callback : Void -> Void;

    public function new(X : Float, Y : Float, Text : String, ?Color : Int = -1, ?Longer : Bool = false, ?borderless : Bool = false, ?Callback : Void -> Void = null)
    {
        super(X, Y);

        longer = Longer;

        // Initial displacement
        y += 0;

        originalColor = Color;
        callback = Callback;

        pxtext = text.PixelText.New(X, Y, Text, Color);
        pxtext.x = X;
        pxtext.y = Y;

        border = 0;

        background = new FlxSprite(pxtext.x - border/2, pxtext.y - border/2);
        background.makeGraphic(Std.int(pxtext.width + border), Std.int(pxtext.height + border), (borderless ? 0x00000000 : 0xFF262b44));

        textDelta = FlxPoint.get(pxtext.x - x, pxtext.y - y);

        scale.y = 0;
        FlxTween.tween(this.scale, {y: 1}, 0.1, {ease: FlxEase.circOut, startDelay: 0, onComplete: onAppeared});

        doColor(null);
    }

    function doColor(t : FlxTween)
    {
        if (t != null)
            t.destroy();

        var targetColor : Int = 0;
        var delay : Float = 0;
        if (pxtext.color == originalColor)
        {
            targetColor = 0xFF2ce8f5;
            delay = 0.05;
        }
        else
            targetColor = originalColor;

        colorTween = FlxTween.color(pxtext, 0.075, pxtext.color, targetColor, {startDelay: delay, onComplete: doColor});
    }

    override public function destroy()
    {
        textDelta.put();
        pxtext.destroy();
        if (colorTween != null)
        {
            colorTween.cancel();
            colorTween.destroy();
        }

        super.destroy();
    }

    function onAppeared(t:FlxTween)
    {
        FlxTween.tween(this.scale, {y: 0}, 0.1, {ease: FlxEase.circOut, startDelay: 1 + (longer ? 1 : 0), onComplete: onDisapeared});
    }

    function onDisapeared(t:FlxTween)
    {
        if (callback != null)
            callback();

        if (t != null)
            t.cancel();

        destroy();
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);

        pxtext.alpha = alpha;
        pxtext.scale.set(scale.x, scale.y);
        pxtext.x = x + textDelta.x;
        pxtext.y = y + textDelta.y;
        pxtext.update(elapsed);

        background.alpha = alpha;
        background.scale.set(scale.x, scale.y);
        background.x = pxtext.x - border/2;
        background.y = pxtext.y - border/2;
    }

    override public function draw()
    {
        // super.draw();
        background.draw();
        pxtext.draw();
    }
}
