package;

import flixel.FlxG;
import flixel.FlxSprite;

class VcrBgmSwitch extends FlxSprite
{
    var selected : Int;
    var enabled : Bool;
    var pressed : Bool;

    var highlightCallback : Void -> Void;
    var callback : Int -> Void;

    var allowReleaseOutside : Bool;

    public function new(X : Float, Y : Float, HighlightCallback : Void -> Void, Callback : Int -> Void)
    {
        super(X, Y);

        selected = GameSettings.data.bgm;

        loadGraphic("assets/ui/gameconfig-bgm-switch.png", true, 65, 14);

        animation.add("off", [0]);
        animation.add("a", [1]);
        animation.add("b", [2]);

        handleAnimation();

        enabled = true;

        highlightCallback = HighlightCallback;
        callback = Callback;

        allowReleaseOutside = false;
    }

    function handleAnimation()
    {
        if (selected == 1)
            animation.play("a");
        else if (selected == 2)
            animation.play("b");
        else
            animation.play("off");
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
        selected = (selected + 1) % 3;

        handleAnimation();

        if (callback != null)
            callback(selected);

        SfxEngine.play(SfxEngine.SFX.VcrToggle);
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
