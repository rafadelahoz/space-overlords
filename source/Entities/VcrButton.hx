package;

import flixel.FlxG;
import flixel.FlxSprite;

class VcrButton extends FlxSprite
{
    static var StateIdle : Int = 0;
    static var StateHighlighted : Int = 1;

    public var state : Int;

    public var highlightCallback : Void -> Void;
    public var callback : Void -> Void;
    public var onPressCallback : Void -> Void;
    public var whilePressedCallback : Void -> Void;

    public var allowReleaseOutside : Bool;

    var hasGraphic : Bool;
    var pressed : Bool;
    var enabled : Bool;

    var highlightable : Bool;

    public function new(X : Float, Y : Float, HighlightCallback : Void -> Void, Callback : Void -> Void, ?Highlightable : Bool = true)
    {
        super(X, Y);

        state = StateIdle;

        highlightCallback = HighlightCallback;
        callback = Callback;
        hasGraphic = false;
        enabled = true;
        allowReleaseOutside = false;
        highlightable = Highlightable;
    }

    public function loadSpritesheet(Sprite : String, Width : Float, Height : Float, ?SingleImage : Bool = false)
    {
        if (SingleImage)
        {
            loadGraphic(Sprite);

            animation.add("idle", [0]);
            animation.add("highlighted", [0]);
            animation.play("idle");
        }
        else
        {
            loadGraphic(Sprite, true, Std.int(Width), Std.int(Height));

            animation.add("idle", [0]);
            animation.add("highlighted", [1]);
            animation.play("idle");
        }

        hasGraphic = true;
    }

    public function clearHighlight()
    {
        state = StateIdle;
    }

    override public function update(elapsed:Float)
    {
        var wasPressed : Bool = pressed;

        if (hasGraphic)
            animation.play(state == StateIdle ? "idle" : "highlighted");
        else
            visible = false;

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

            if (!wasPressed && pressed)
                onPressed();
            else if (pressed)
                whilePressed();

            if (wasPressed && !pressed)
                onReleased();
            else if (!pressed)
                whileReleased();

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

    function onPressed() : Void
    {
        if (onPressCallback != null)
            onPressCallback();
    }

    function whilePressed() : Void
    {
        if (whilePressedCallback != null)
            whilePressedCallback();

        if (hasGraphic)
            animation.play("highlighted");

        color = 0xFF9e2835;
    }

    function onReleased() : Void
    {
        if (highlightable && state == StateIdle)
        {
            state = StateHighlighted;
            if (highlightCallback != null)
                highlightCallback();
        }
        else if (!highlightable || state == StateHighlighted)
        {
            if (callback != null)
                callback();
        }
    }

    function whileReleased() : Void
    {
        color = 0xFFFFFFFF;
    }

    public function enable()
    {
        enabled = true;
    }

    public function disable()
    {
        enabled = false;
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
