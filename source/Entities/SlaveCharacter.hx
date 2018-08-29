package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class SlaveCharacter extends FlxSprite
{
    public static var StateFall : Int = 0;
    public static var StateIdle : Int = 1;
    public static var StateWalk : Int = 2;

    var IdleDelayTime : Float = 5;
    var IdleDelayVariation : Float = 0.6;

    var WalkTime : Float = 1.5;
    var WalkTimeVariation : Float = 0.5;

    var world : MenuState;

    var head : FlxSprite;
    var detail : FlxSprite;

    var state : Int;
    var timer : FlxTimer;

    public function new(X : Float, Y : Float, World : MenuState)
    {
        super(X, Y);

        world = World;

        handleGraphic();

        timer = new FlxTimer();

        switchState(StateIdle);
    }

    function handleGraphic()
    {
        var animSpeed : Int = 5;

        loadGraphic("assets/images/slave-body-sheet.png", true, 32, 40);
        animation.add("idle", [0]);
        animation.add("walk", [0, 1, 2, 3], animSpeed, true);
        animation.play("walk");

        var headType : Int = FlxG.random.int(0, 1);
        head = new FlxSprite(x, y);
        head.loadGraphic("assets/images/slave-head-sheet.png", true, 32, 40);
        head.animation.add("idle", [headType*4+0]);
        head.animation.add("walk", [headType*4+0, headType*4+1, headType*4+2, headType*4+3], animSpeed, true);
        head.animation.play("walk");

        var detailType : Int = FlxG.random.int(0, 2);
        detail = new FlxSprite(x, y);
        detail.loadGraphic("assets/images/slave-detail-sheet.png", true, 32, 40);
        detail.animation.add("idle", [detailType*4+0]);
        detail.animation.add("walk", [detailType*4+0, detailType*4+1, detailType*4+2, detailType*4+3], animSpeed, true);
        detail.animation.play("walk");

        var tintColor : Int = FlxG.random.getObject([0xFFFFFFFF, Palette.Red, Palette.Green, Palette.Blue]);
        color = tintColor;
        head.color = tintColor;
        // detail.color = tintColor;
    }

    public function switchState(Next : Int)
    {
        state = Next;
        switch(state)
        {
            case SlaveCharacter.StateIdle:
                timer.start(fuzzyValue(IdleDelayTime, IdleDelayVariation), function(_) {
                    switchState(StateWalk);
                });
            case SlaveCharacter.StateWalk:
                var nextPos : FlxPoint = findNextPosition();

                setFlipX(nextPos.x < x);
                FlxTween.linearMotion(this, x, y, nextPos.x, nextPos.y, fuzzyValue(WalkTime, WalkTimeVariation), true, {ease : FlxEase.sineInOut, onComplete: function(t:FlxTween) {
                    switchState(StateIdle);
                }});

                nextPos.put();
        }
    }

    function findNextPosition() : FlxPoint
    {
        var pos : FlxPoint = FlxPoint.get(-1, -1);
        while (!isPositionValid(pos)) {
            pos.x = fuzzyRange(x, 40);
            pos.y = fuzzyRange(y, 20);
        }

        return pos;
    }

    function isPositionValid(pos : FlxPoint) : Bool
    {
        return (pos.x > 32 && pos.x < Constants.Width - 32 && pos.y > 320*0.7 && pos.y < Constants.Height - 32);
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case SlaveCharacter.StateIdle:
                playAnim("idle");
            case SlaveCharacter.StateWalk:
                playAnim("walk");
        }

        super.update(elapsed);
        head.update(elapsed);
        detail.update(elapsed);

        head.setPosition(x, y);
        detail.setPosition(x, y);
    }

    override public function draw()
    {
        super.draw();
        head.draw();
        detail.draw();
    }

    function playAnim(name : String)
    {
        if (name == "walk")
        {
            animation.play(name);
            head.animation.play(name);
            detail.animation.play(name);

            animation.paused = false;
            head.animation.paused = false;
            detail.animation.paused = false;
        }
        else
        {
            animation.paused = true;
            head.animation.paused = true;
            detail.animation.paused = true;
        }
    }

    function setFlipX(value : Bool)
    {
        flipX = value;
        head.flipX = value;
        detail.flipX = value;
    }

    function fuzzyValue(value : Float, variation : Float) : Float
    {
        return FlxG.random.float(value - (value*variation), value + (value*variation));
    }

    function fuzzyRange(from : Float, radius : Float) : Float
    {
        return FlxG.random.float(from - radius, from + radius);
    }
}
