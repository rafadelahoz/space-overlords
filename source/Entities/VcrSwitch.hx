package;

import flixel.FlxG;
import flixel.FlxSprite;

class VcrSwitch extends FlxSprite
{
    var status : Bool;
    var enabled : Bool;
    var pressed : Bool;

    var highlightCallback : Void -> Void;
    var callback : Bool -> Void;

    public function new(X : Float, Y : Float, On : Bool, HighlightCallback : Void -> Void, Callback : Bool -> Void)
    {
        super(X, Y);

        status = On;

        loadGraphic("assets/ui/title-settings-switch.png", true, 56, 14);

        animation.add("on", [0]);
        animation.add("off", [1]);
        animation.play(status ? "on" : "off");

        enabled = true;

        highlightCallback = HighlightCallback;
        callback = Callback;
    }

    override public function update(elapsed : Float)
    {
        var wasPressed : Bool = pressed;

        if (enabled)
        {
            #if (!mobile)
            if (mouseOver())
            {
                if (FlxG.mouse.pressed)
                {
                    pressed = true;
                }
                else if (FlxG.mouse.justReleased)
                {
                    pressed = false;
                }
            }
            #else
            for (touch in FlxG.touches.list)
            {
                if (touch.overlaps(this))
                {
                    if (touch.pressed)
                    {
                        pressed = true;
                        break;
                    }
                    else if (touch.justReleased)
                    {
                        pressed = false;
                        break ;
                    }
                }
            }

            // Check for release outside of button
            if (pressed && allowReleaseOutside)
            {
                for (touch in FlxG.touches.list)
                {
                    if (!touch.overlaps(this))
                    {
                        if (touch.justReleased)
                        {
                            pressed = false;
                            break ;
                        }
                    }
                }
            }
            #end

            if (pressed)
                color = 0xFF9e2835;
            else
                color = 0xFFFFFFFF;

            if (!wasPressed && pressed)
                if (highlightCallback != null)
                    highlightCallback();

            if (wasPressed && !pressed)
                handleRelease();

            // Post callback state handling?
            #if !mobile
            if (pressed && FlxG.mouse.justReleased)
            {
                pressed = false;
            }
            #else
            if (pressed)
                for (touch in FlxG.touches.list)
                {
                    if (touch.justReleased)
                    {
                        pressed = false;
                        break;
                    }
                }
            #end
        }

        super.update(elapsed);
    }

    function handleRelease()
    {
        status = !status;
        animation.play(status ? "on" : "off");

        if (callback != null)
            callback(status);
    }

    function mouseOver()
    {
        var mouseX : Float = FlxG.mouse.x;
        var mouseY : Float = FlxG.mouse.y;

        if (scrollFactor.x == 0)
            mouseX = FlxG.mouse.screenX;

        if (scrollFactor.y == 0)
            mouseY = FlxG.mouse.screenY;

        return mouseX >= x && mouseX < (x + width) &&
               mouseY >= y && mouseY < (y + height);
    }
}
