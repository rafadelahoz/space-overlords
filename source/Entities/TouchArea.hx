package;

import flixel.FlxG;
import flixel.FlxObject;

class TouchArea extends FlxObject
{
    var pressed : Bool;
    var callback : Void -> Void;
    var allowReleaseOutside : Bool;

    public function new(X : Float, Y : Float, Width : Float, Height : Float, Callback : Void -> Void)
    {
        super(X, Y);

        setSize(Width, Height);

        callback = Callback;

        allowReleaseOutside = false;
    }

    override public function update(elapsed : Float)
    {
        var wasPressed : Bool = pressed;

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

        /*if (!wasPressed && pressed)
            onPressed();
        else if (pressed)
            whilePressed();
        */
        if (wasPressed && !pressed)
            if (callback != null)
                callback();
        /*else if (!pressed)
            whileReleased();*/

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

        super.update(elapsed);
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
