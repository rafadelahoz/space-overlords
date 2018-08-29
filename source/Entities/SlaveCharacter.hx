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

    var shadow : FlxSprite;

    var head : FlxSprite;
    var detail : FlxSprite;

    var state : Int;
    var timer : FlxTimer;

    public function new(X : Float, Y : Float, World : MenuState, ?Falling : Bool = false)
    {
        super(X, Y);

        world = World;

        handleGraphic();

        timer = new FlxTimer();

        if (!Falling)
        {
            if (FlxG.random.bool(50))
                switchState(StateIdle);
            else
                switchState(StateWalk);
        }
        else
        {
            switchState(StateFall);
        }
    }

    function handleGraphic()
    {
        var animSpeed : Int = 5;

        loadGraphic("assets/images/slave-body-sheet.png", true, 32, 40);
        animation.add("idle", [0]);
        animation.add("walk", [0, 1, 2, 3], animSpeed, true);
        animation.add("fall", [0, 2], 4, true);
        animation.play("walk");

        var headType : Int = ProgressData.data.slave_head;
        head = new FlxSprite(x, y);
        head.loadGraphic("assets/images/slave-head-sheet.png", true, 32, 40);
        head.animation.add("idle", [headType*4+0]);
        head.animation.add("walk", [headType*4+0, headType*4+1, headType*4+2, headType*4+3], animSpeed, true);
        head.animation.add("fall", [headType*4+0, headType*4+2], 4, true);
        head.animation.play("walk");

        var detailType : Int = ProgressData.data.slave_detail;
        detail = new FlxSprite(x, y);
        detail.loadGraphic("assets/images/slave-detail-sheet.png", true, 32, 40);
        detail.animation.add("idle", [detailType*4+0]);
        detail.animation.add("walk", [detailType*4+0, detailType*4+1, detailType*4+2, detailType*4+3], animSpeed, true);
        detail.animation.add("fall", [detailType*4+0, detailType*4+2], 4, true);
        detail.animation.play("walk");

        var tintColor : Int = ProgressData.data.slave_color;
        color = tintColor;
        head.color = tintColor;
        // detail.color = tintColor;

        shadow = new FlxSprite(x, y);
        shadow.makeGraphic(Std.int(width), 8, 0x00000000);
        flixel.util.FlxSpriteUtil.drawEllipse(shadow, 4, 0, width-8, 6, Palette.DarkBlue);
    }

    public function switchState(Next : Int)
    {
        state = Next;
        switch(state)
        {
            case SlaveCharacter.StateFall:
                playAnim("fall");
                FlxTween.linearMotion(this, x, y, x, Constants.Height*0.7+8, 3.5, true, {ease: FlxEase.bounceOut, onComplete: function(_) {
                    pauseAnim(true);
                    timer.start(0.5, function(_) {
                        switchState(StateIdle);
                    });
                }});
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
        return (pos.x > 32 && pos.x < Constants.Width - width - 32 &&
                pos.y > Constants.Height*0.7 && pos.y < Constants.Height - 16 - height);
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case SlaveCharacter.StateFall:
                // playAnim("fall");
            case SlaveCharacter.StateIdle:
                playAnim("idle");
            case SlaveCharacter.StateWalk:
                playAnim("walk");
        }

        super.update(elapsed);
        shadow.update(elapsed);
        head.update(elapsed);
        detail.update(elapsed);

        head.setPosition(x, y);
        detail.setPosition(x, y);

        switch (state)
        {
            case SlaveCharacter.StateFall:
                var targetY : Float = Constants.Height*0.7+8;
                shadow.setPosition(x, targetY+height-6);

                var scaleX : Float = Math.max(0.75, y / targetY);
                var scaleY : Float = Math.max(0.4, y / targetY);
                shadow.scale.set(scaleX, scaleY);
            case SlaveCharacter.StateIdle, SlaveCharacter.StateWalk:
                shadow.setPosition(x, y+height-6);
        }
    }

    override public function draw()
    {
        shadow.draw();
        if (state == StateFall)
        {
            y += 6;
            head.y += 6;
            detail.y += 6;
        }

        super.draw();
        head.draw();
        detail.draw();

        if (state == StateFall)
        {
            y -= 6;
            head.y -= 6;
            detail.y -= 6;
        }
    }

    function pauseAnim(paused : Bool)
    {
        animation.paused = paused;
        head.animation.paused = paused;
        detail.animation.paused = paused;
    }

    function playAnim(name : String)
    {
        if (name == "fall")
        {
            animation.play(name);
            head.animation.play(name);
            detail.animation.play(name);

            pauseAnim(false);

            angle = -90;
            head.angle = -90;
            detail.angle = -90;
        }
        else if (name == "walk")
        {
            animation.play(name);
            head.animation.play(name);
            detail.animation.play(name);

            pauseAnim(false);

            angle = 0;
            head.angle = 0;
            detail.angle = 0;
        }
        else if (name == "idle")
        {
            pauseAnim(true);

            angle = 0;
            head.angle = 0;
            detail.angle = 0;
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
