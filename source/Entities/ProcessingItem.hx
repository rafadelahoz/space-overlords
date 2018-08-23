package;

import flixel.FlxSprite;

class ProcessingItem extends FlxSprite
{
    var charType : Int;

    var moving : Bool;
    var finishCallback : ProcessingItem -> Void;

    public function new(X : Float, Y : Float, CharType : Int)
    {
        super(X, Y);

        charType = CharType;

        handleGraphic();
    }

    function handleGraphic(?doMakeGraphic : Bool = true)
    {
        loadGraphic("assets/images/pieces.png", true, 16, 16);
        animation.add("idle", [charType-1]);
        animation.play("idle");
        // TODO: Add small animations per type
        // TODO: Extract this to be reusable
    }

    public function startMoving(speed : Float, ?callback : ProcessingItem -> Void = null)
    {
        moving = true;
        velocity.set(speed, 0);
        finishCallback = callback;
    }

    override public function update(elapsed : Float)
    {
        if (x >= Constants.Width)
        {
            if (finishCallback != null)
                finishCallback(this);
            kill();
            destroy();
        }
        else
        {
            super.update(elapsed);
        }
    }
}
