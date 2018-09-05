package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;

class ItemEntity extends Entity
{
    public static var StateNone         : Int = -1;
    public static var StateGenerating   : Int = 0;
    public static var StateFalling      : Int = 1;
    public static var StateGrace        : Int = 2;
    public static var StatePositioned   : Int = 3;
    public static var StateSlave        : Int = 4;
    public static var StateLeaving      : Int = 5;
    public static var StateDissolving   : Int = 6;

    var GenerationTime : Float = 0.2;
    var FlipTime : Float = 0.1;
    var GraceTime : Float = 0.1;
    var HorizontalMovementDuration : Float = 0.15;
    var LeaveTime : Float = 0.3;
    var ForcedFallTime : Float = 0.1;
    var SpeedUpFactor : Float = 5;

    var DissolveGrowTime : Float = 0.2;
    var DissolveExitTime : Float = 0.4;

    var QuickFallScore : Float = 0.2;

    var world : PlayState;
    var grid : GarbageGrid;

    public var charType : Int;
    var charTypeA : Int;
    var charTypeB : Int;
    var flipCharTypeTween : FlxTween;

    public var state : Int;

    var scaleTween : FlxTween;
    var movementTween : FlxTween;

    var graceTimer : FlxTimer;

    var vspeed : Float;

    var finishPositioningAfterMovement : Bool;

    var leaveCallback : Void -> Void;

    public var slave : ItemEntity;
    var slaveOffset : FlxPoint;
    var slaveCellOffset : FlxPoint;

    var pieceScore : Float;

    public function new(X : Float, Y : Float, CharType : Int, ?AltCharType : Int = -1, World : PlayState)
    {
        super(X, Y);

        handlePairCharTypes(CharType, AltCharType);

        handleGraphic();

        graceTimer = new FlxTimer();

        world = World;
        grid = world.grid;
    }

    function handlePairCharTypes(CharType : Int, AltCharType : Int)
    {
        charTypeA = CharType;
        charTypeB = AltCharType;

        if (charTypeB < 1)
            charTypeB = (charTypeA & 1 == 1 ? charTypeA+1 : charTypeA-1);

        charType = charTypeA;
    }

    function handleGraphic(?doMakeGraphic : Bool = true)
    {
        if (charType ==  ItemData.SpecialChemdust)
        {
            // if (doMakeGraphic)
            {
                loadGraphic("assets/images/special-0.png", true, 18, 18);
                animation.add("idle", [0]);
            }

            offset.set(1, 1);
            animation.play("idle");
        }
        else if (charType == ItemData.SpecialTrigger)
        {
            loadGraphic("assets/images/trigger.png");
            offset.set(1, 1);
        }
        else if (charType == ItemData.SpecialBomb)
        {
            loadGraphic("assets/images/bomb-sheet.png", true, 16, 16);
            animation.add("idle", [0]);
            animation.add("open", [0, 1, 2], 6, false);
            animation.play("idle");
        }
        else if (charType == ItemData.SpecialTarget)
        {
            makeGraphic(Constants.TileSize, Constants.TileSize, 0x00000000);
            flixel.util.FlxSpriteUtil.drawRect(this, 1, 1, 14, 14, Palette.Red);
        }
        else
        {
            // if (doMakeGraphic)
            {
                loadGraphic("assets/images/pieces.png", true, 16, 16);
                animation.add("idle", [charType-1]);
            }
            // else
            //     animation.getByName("idle").frames = [charType-1];

            offset.set(0, 0);
            animation.play("idle");
        }

        // TODO: Add small animations per type
        // TODO: Extract this to be reusable
    }

    override public function destroy()
    {
        destroyTimer(graceTimer);
        destroyTween(scaleTween);
        destroyTween(movementTween);
        destroyTween(flipCharTypeTween);

        super.destroy();
    }

    public function setState(Next : Int, ?initialize : Bool = true)
    {
        state = Next;
        // Extra actions?
        if (initialize)
        {
            switch (Next)
            {
                case ItemEntity.StateGenerating:
                    if (scaleTween != null)
                    {
                        scaleTween.destroy();
                    }

                    scale.set(0, 0);
                    scaleTween = FlxTween.tween(this.scale, {x : 1, y: 1}, GenerationTime, {onComplete: onGenerationFinished});
                    // Apply the same for the slave, if any
                    if (slave != null)
                    {
                        slave.scale.set(0, 0);
                        FlxTween.tween(slave.scale, {x : 1, y: 1}, GenerationTime);
                    }
                case ItemEntity.StateFalling:
                    pieceScore = 0;
                    vspeed = world.getFallSpeed();
                case ItemEntity.StateGrace:
                    finishPositioningAfterMovement = false;
                    graceTimer.start(GraceTime, onGraceEnd);
                case ItemEntity.StateLeaving:
                    scaleTween = FlxTween.tween(this.scale, {x: 0, y: 0}, LeaveTime, {ease: FlxEase.quadOut, onComplete: function(t:FlxTween) {
                        world.items.remove(this);
                        kill();
                        destroy();

                        if (leaveCallback != null)
                            leaveCallback();
                    }});
                case ItemEntity.StateDissolving:

                default:
            }
        }
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case ItemEntity.StateNone:
                // ?
            case ItemEntity.StateGenerating:
                // Scale?
            case ItemEntity.StateFalling:
                handleFallingState(elapsed);
                // color = Palette.Green;
            case ItemEntity.StateGrace:
                handleGraceState(elapsed);
                // color = Palette.DarkGreen;
            case ItemEntity.StatePositioned:
                // color = Palette.Blue;
                // Stay still!
            case ItemEntity.StateSlave:
                // color = Palette.DarkPurple;
            case ItemEntity.StateLeaving:
                // nopes?
        }

        super.update(elapsed);

        if (slave != null)
        {
            slave.x = x + slaveOffset.x;
            slave.y = y + slaveOffset.y;
            slave.update(elapsed);
        }
    }

    override public function draw()
    {
        super.draw();
        if (slave != null)
        {
            slave.draw();
        }
    }

    function onGenerationFinished(t : FlxTween)
    {
        t.destroy();
        scaleTween = null;

        world.onNextItemGenerated();
    }

    function handleFallingState(elapsed : Float)
    {
        var currentCell : FlxPoint = getCurrentCell();
        var nextFallingCell : FlxPoint = getFallToCell();
        var nextData : ItemData = grid.get(nextFallingCell.x, nextFallingCell.y);

        if (canMoveTo(nextFallingCell.x, nextFallingCell.y) && canMoveTo(nextFallingCell.x + (slave != null ? slaveCellOffset.x : 0), nextFallingCell.y)) {
            // Go down, allow movement
            if (GamePad.checkButton(GamePad.Down))
            {
                pieceScore += QuickFallScore;
                world.session.score += Std.int(pieceScore);
                pieceScore -= Std.int(pieceScore);

                velocity.set(0, vspeed * SpeedUpFactor);
                if (canSquish())
                    scale.x = flixel.math.FlxMath.lerp(scale.x, 0.8, 0.2);
                if (slave != null && slave.canSquish())
                    slave.scale.x = flixel.math.FlxMath.lerp(slave.scale.x, 0.8, 0.2);
            }
            else
            {
                velocity.set(0, vspeed);
                scale.x = flixel.math.FlxMath.lerp(scale.x, 1, 0.4);
                if (slave != null)
                    slave.scale.x = flixel.math.FlxMath.lerp(slave.scale.x, 1, 0.4);
            }

            if (world.paused)
            {
                velocity.set(0, 0);
            }

            // DEBUG!
            if (world.debugEnabled)
            {
                velocity.set(0, 0);
            }

            if (movementTween == null)
            {
                if (GamePad.checkButton(GamePad.Left) && canMoveTo(currentCell.x-1, currentCell.y) && canMoveTo(nextFallingCell.x-1, nextFallingCell.y))
                {
                    moveHorizontallyToCell(currentCell.x-1, currentCell.y);
                }
                else if (GamePad.checkButton(GamePad.Right) && canMoveTo(currentCell.x+(slave != null ? slaveCellOffset.x : 0)+1, currentCell.y) && canMoveTo(currentCell.x+(slave != null ? slaveCellOffset.x : 0)+1, nextFallingCell.y))
                {
                    moveHorizontallyToCell(currentCell.x+1, currentCell.y);
                }
            }

            if (GamePad.justPressed(GamePad.Shoot))
            {
                flipCharType();
                slave.flipCharType();
            }
        }
        else
        {
            // finishPositioning();
            velocity.set(0, 0);
            setState(StateGrace);
        }
    }

    function handleGraceState(elapsed : Float)
    {
        var currentCell : FlxPoint = getCurrentCell();

        scale.x = 1;
        if (slave != null)
            slave.scale.x = 1;
        velocity.set(0, 0);

        if (movementTween == null)
        {
            if (GamePad.checkButton(GamePad.Left) && canMoveTo(currentCell.x-1, currentCell.y))
            {
                moveHorizontallyToCell(currentCell.x-1, currentCell.y);
            }
            // Note: special "(slave != null ? slaveCellOffset.x : 0)" check here for moving right correctly
            else if (GamePad.checkButton(GamePad.Right) && canMoveTo(currentCell.x+(slave != null ? slaveCellOffset.x : 0)+1, currentCell.y))
            {
                moveHorizontallyToCell(currentCell.x+1, currentCell.y);
            }

            if (GamePad.justPressed(GamePad.Shoot))
            {
                flipCharType();
                slave.flipCharType();
            }
        }
    }

    function finishPositioning()
    {
        // The piece can stop
        var currentCell : FlxPoint = getCurrentCell();
        // Fallback if we are too low
        if (grid.get(currentCell.x, currentCell.y) != null)
        {
            currentCell.y -= 1;
        }

        var targetPos : FlxPoint = grid.getCellPosition(currentCell.x, currentCell.y);

        x = targetPos.x;
        // y = targetPos.y;
        scale.set(1, 1);
        velocity.y = 0;

        if (slave != null)
        {
            slave.x = targetPos.x + slaveOffset.x;
            // slave.y = targetPos.y + slaveOffset.y;
            slave.scale.set(1, 1);
        }

        /* Hacky effect begins, pay no mind */
        // Add a little bounce for positioning
        y = targetPos.y-4;
        FlxTween.tween(this, {y: targetPos.y}, 0.1, {ease: FlxEase.bounceOut, onComplete: function(t:FlxTween) {
            y = targetPos.y;
        }});
        if (slave != null)
        {
            // Add a little bounce for positioning the slave
            slave.y = targetPos.y + slaveOffset.y - 4;
            FlxTween.tween(slave, {y: targetPos.y + slaveOffset.y}, 0.1, {ease: FlxEase.bounceOut, onComplete: function(t:FlxTween) {
                // The slave reference may be null at this point!
                if (slave != null)
                    slave.y = targetPos.y + slaveOffset.y;
            }});
        }
        /* End of hacky effect */

        setState(ItemEntity.StatePositioned);
        grid.set(currentCell.x, currentCell.y, new ItemData(currentCell.x, currentCell.y, charType, this));
        if (slave != null)
        {
            slave.setState(ItemEntity.StatePositioned);
            var slaveCell : FlxPoint = new FlxPoint(currentCell.x + slaveCellOffset.x, currentCell.y + slaveCellOffset.y);
            grid.set(slaveCell.x, slaveCell.y, new ItemData(slaveCell.x, slaveCell.y, slave.charType, slave));
        }

        world.onCurrentItemPositioned(currentCell);
    }

    function onGraceEnd(t : FlxTimer)
    {
        t.cancel();
        // When the grace period ends...
        if (movementTween == null)
        {
            // ...if the piece is not currently moving horizontally,
            // finsih right now
            finishPositioning();
        }
        else
        {
            // ...if the piece is currently moving horizontally,
            // let the movement callback handle the notification
            finishPositioningAfterMovement = true;
        }
    }

    function canMoveTo(cellX : Float, cellY : Float) : Bool
    {
        return grid.get(cellX, cellY) == null && grid.isCellValid(cellX, cellY);
    }

    function moveHorizontallyToCell(cellX : Float, cellY : Float)
    {
        movementTween = FlxTween.tween(this, {x: grid.getCellPosition(cellX, cellY).x}, HorizontalMovementDuration, {ease: FlxEase.circInOut, onComplete: onHorizontalMovementEnd});
    }

    function onHorizontalMovementEnd(?t : FlxTween = null)
    {
        t.destroy();
        movementTween = null;

        if (finishPositioningAfterMovement)
        {
            // Check if we can still fall when the timer ends
            var currentCell : FlxPoint = getCurrentCell();
            if (canMoveTo(currentCell.x, currentCell.y+1))
            {
                setState(StateFalling);
            }
            else
            {
                finishPositioning();
            }
        }
    }

    public function setSlave(Slave : ItemEntity, Position : CellPosition)
    {
        slave = Slave;
        if (slave != null)
        {

            switch (Position)
            {
                case CellPosition.Right:
                    slaveCellOffset = new FlxPoint(1, 0);
                case CellPosition.Top:
                    slaveCellOffset = new FlxPoint(0, -1);
            }

            slaveOffset = new FlxPoint(slaveCellOffset.x * Constants.TileSize, slaveCellOffset.y * Constants.TileSize);
        }
    }

    public function flipCharType()
    {
        if (charType == charTypeA)
        {
            charType = charTypeB;
        }
        else
        {
            charType = charTypeA;
        }

        flipCharTypeTween = FlxTween.tween(this.scale, {x : 0}, FlipTime * 0.5, {onComplete: function(t : FlxTween) {
            t.destroy();

            handleGraphic(false);

            flipCharTypeTween = FlxTween.tween(this.scale, {x : 1}, FlipTime * 0.5, {onComplete: destroyTween});
        }});
    }

    public function triggerLeave(?callback : Void -> Void = null)
    {
        leaveCallback = callback;
        setState(StateLeaving);
    }

    public function fallToFreePosition() : Bool
    {
        var currentCell : FlxPoint = getCurrentCell();
        var targetCell : FlxPoint = grid.getLowerFreeCellFrom(currentCell.x, currentCell.y);
        var targetPos : FlxPoint = grid.getCellPosition(targetCell.x, targetCell.y);

        if (currentCell.y != targetCell.y)
        {
            // Switch positions
            grid.set(currentCell.x, currentCell.y, null);
            grid.set(targetCell.x, targetCell.y, new ItemData(targetCell.x, targetCell.y, charType, this));

            // And go
            movementTween = FlxTween.tween(this, {y: targetPos.y}, ForcedFallTime, {ease: FlxEase.sineIn});

            return true;
        }
        else
        {
            return false;
        }
    }

    public function inGenerationArea() : Bool
    {
        var inArea : Bool = false;
        // Check self
        inArea = (y <= grid.getCellPosition(0, 2).y);
        // Check slave when positioned on top
        if (!inArea && slave != null && slaveCellOffset.y < 0)
        {
            inArea = (slave.y <= grid.getCellPosition(0, 2).y);
        }

        return inArea;
    }

    public function getCurrentCell() : FlxPoint
    {
        return grid.getCellAt(x + width/2, y + height/2);
    }

    public function getFallToCell() : FlxPoint
    {
        return grid.getCellAt(x + width/2, y + height);
    }

    public function triggerTriggerAnimation()
    {
        FlxFlicker.flicker(this, 0, true, true);
        if (charType == ItemData.SpecialBomb)
            animation.play("open");
    }

    public function triggerDissolve(?leaveCallback : Void -> Void = null)
    {
        setState(StateDissolving);

        FlxFlicker.flicker(this, 0.01, 0.001, true, true);

        FlxTween.color(this, DissolveGrowTime, 0xFFFFFFFF, 0xFF000000, {startDelay: 0.1, ease : FlxEase.expoIn, onComplete: function(t:FlxTween) {
            t.destroy();
            FlxTween.tween(this, {alpha : 0}, DissolveExitTime, {startDelay: 0.2, ease : FlxEase.expoIn, onComplete: function(tt:FlxTween) {
                tt.destroy();

                world.items.remove(this);
                kill();
                destroy();

                if (leaveCallback != null)
                    leaveCallback();
            }});
        }});
    }

    public function canSquish() : Bool
    {
        return charType != ItemData.SpecialBomb && charType != ItemData.SpecialTrigger;
    }

    var graceTimerActive : Bool;
    var movementTweenActive : Bool;

    public function onPauseStart()
    {
        graceTimerActive = graceTimer.active;
        if (graceTimer.active)
            graceTimer.active = false;

        movementTweenActive = false;
        if (movementTween != null)
        {
            movementTweenActive = movementTween.active;
            movementTween.active = false;
        }
    }

    public function onPauseEnd()
    {
        if (graceTimerActive)
            graceTimer.active = true;

        if (movementTween != null)
        {
            if (movementTweenActive)
                movementTween.active = movementTweenActive;
        }
    }
}

enum CellPosition {Top; Right;}
