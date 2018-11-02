package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class SlaveCharacter extends FlxSprite
{
    public static var StateNone : Int = -1;
    public static var StateFall : Int = 0;
    public static var StateIdle : Int = 1;
    public static var StateWalk : Int = 2;
    public static var StateRight : Int = 3;
    public static var StateLeft : Int = 4;
    public static var StateReturn : Int = 5;

    var IdleDelayTime : Float = 5;
    var IdleDelayVariation : Float = 0.6;

    var WalkTime : Float = 1.5;
    var WalkTimeVariation : Float = 0.5;

    var TraverseSpeed : Float = 15;
    var TraverseVariation : Float = 0.15;

    var world : GarbageState;

    public var shadow : FlxSprite;

    var head : FlxSprite;
    var detail : FlxSprite;

    var state : Int;
    var timer : FlxTimer;

    var motionTween : FlxTween;

    var forcedColorize : Bool;
    var bounced : Bool;

    public function new(X : Float, Y : Float, World : GarbageState, ?State : Int = -2)
    {
        super(X, Y);

        world = World;
        forcedColorize = false;

        handleGraphic();

        timer = new FlxTimer();
        motionTween = null;

        if (State < -1)
        {
            switchState(StateWalk);
        }
        else
        {
            switchState(State);
        }
    }

    function handleGraphic()
    {
        var animSpeed : Int = 5;

        loadGraphic("assets/images/slave-body-sheet.png", true, 32, 40);
        animation.add("idle", [0]);
        animation.add("walk", [1, 2, 3, 4], animSpeed, true);
        animation.add("fall", [1, 3], 2, true);
        animation.play("walk");

        animation.callback = animationCallback;

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
        flixel.util.FlxSpriteUtil.drawEllipse(shadow, 4, 0, width-8, 6, Palette.AlmostBlack);
    }

    public function switchState(Next : Int, ?Destination : FlxPoint = null, ?Special : Bool = false, ?Callback : Void -> Void = null)
    {
        state = Next;
        switch(state)
        {
            case SlaveCharacter.StateNone:
                // nop!
                if (timer != null && timer.active)
                    timer.cancel();
            case SlaveCharacter.StateFall:
                playAnim("fall");
                cancelTween(motionTween);
                bounced = false;
                motionTween = FlxTween.linearMotion(this, x, y, x, Constants.Height*0.7+8, 3.5, true, {ease: FlxEase.bounceOut, onComplete: function(_) {
                    pauseAnim(true);
                    timer.start(1, function(_) {
                        SfxEngine.play(SfxEngine.SFX.FlipMutantB);
                        switchState(StateIdle);
                    });
                }});
            case SlaveCharacter.StateIdle:
                timer.start(fuzzyValue(IdleDelayTime, IdleDelayVariation), function(_) {
                    switchState(StateWalk);
                });
            case SlaveCharacter.StateWalk:
                var nextPos : FlxPoint = Destination;
                if (nextPos == null)
                    nextPos = findNextPosition();

                setFlipX(nextPos.x < x);
                cancelTween(motionTween);
                if (timer != null && timer.active)
                    timer.cancel();

                motionTween = FlxTween.linearMotion(this, x, y, nextPos.x, nextPos.y, fuzzyValue(WalkTime, WalkTimeVariation), true, {ease : FlxEase.sineInOut, onComplete: function(t:FlxTween) {
                    if (Callback != null)
                        Callback();
                    else
                        switchState(StateIdle);
                }});

                nextPos.put();
            case SlaveCharacter.StateRight, SlaveCharacter.StateLeft:
                setFlipX(state == StateLeft);
                cancelTween(motionTween);
                var speed : Float = (Special ? 6 : 1) * fuzzyValue(TraverseSpeed, TraverseVariation);
                motionTween = FlxTween.linearMotion(this, x, y, (state == StateRight ? Constants.Width : -width), y, speed, false);
                state = StateWalk;
            case SlaveCharacter.StateReturn:
                setFlipX(true);
                motionTween = FlxTween.linearMotion(this, Constants.Width, y - 8, x, y, fuzzyValue(TraverseSpeed, TraverseVariation), false, {startDelay: 0.5, ease : FlxEase.sineInOut, onComplete: function(t:FlxTween) {
                    switchState(StateIdle);
                }});
                state = StateWalk;
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
                pos.y > Constants.Height*0.7 && pos.y < 276 - height);
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case SlaveCharacter.StateFall:
                // playAnim("fall");
            case SlaveCharacter.StateIdle, SlaveCharacter.StateNone:
                playAnim("idle");
            case SlaveCharacter.StateWalk, SlaveCharacter.StateRight, SlaveCharacter.StateLeft:
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

                if (!bounced && Math.abs(targetY - y) < 4)
                {
                    bounced = true;
                    SfxEngine.play(SfxEngine.SFX.SlaveStepC);
                }
                else if (Math.abs(targetY - y) > 4)
                {
                    bounced = false;
                }

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

        head.color = color;
        if (canColorizeDetail())
            detail.color = color;

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
        angle = 0;
        head.angle = 0;
        detail.angle = 0;

        animation.play(name);
        head.animation.play(name);
        detail.animation.play(name);

        if (name == "fall")
        {
            pauseAnim(false);

            angle = -90;
            head.angle = -90;
            detail.angle = -90;
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

    function cancelTween(tween : FlxTween)
    {
        if (tween != null && tween.active)
        {
            tween.cancel();
        }
    }

    public function walkTo(destination : FlxPoint, ?duration : Float = 0, ?callback : Void->Void = null)
    {
        var oldWalkTime : Float = WalkTime;
        if (duration > 0)
            WalkTime = duration;
        switchState(StateWalk, destination, callback);
        if (duration > 0)
            WalkTime = oldWalkTime;
    }

    public function colorize(targetColor : Int, duration : Float, ?callback : Void -> Void = null)
    {
        forcedColorize = true;
        var currentColor : Int = color;
        FlxTween.color(this, duration, currentColor, targetColor, {onComplete: function(_) {
            if (callback != null)
                callback();
            }
        });
    }

    function canColorizeDetail() : Bool
    {
        return forcedColorize || ProgressData.data.slave_detail > 2;
    }

    function animationCallback(name : String, frameNumber : Int, frameIndex : Int)
    {
        if (name == "walk")
        {
            if (frameIndex == 2 || frameIndex == 4)
            {
                SfxEngine.play(FlxG.random.getObject([SfxEngine.SFX.SlaveStepA, SfxEngine.SFX.SlaveStepB,
                            SfxEngine.SFX.SlaveStepC, SfxEngine.SFX.SlaveStepD, SfxEngine.SFX.SlaveStepE]), 0.25);
            }
        }
    }
}
