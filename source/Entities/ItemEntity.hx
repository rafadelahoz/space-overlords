package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class ItemEntity extends Entity
{
    public static var StateNone         : Int = -1;
    public static var StateGenerating   : Int = 0;
    public static var StateFalling      : Int = 1;
    public static var StateGrace        : Int = 2;
    public static var StatePositioned   : Int = 3;
    public static var StateSlave        : Int = 4;
    public static var StateLeaving      : Int = 5;

    var FlipTime : Float = 0.1;
    var GraceTime : Float = 0.2;
    var HorizontalMovementDuration : Float = 0.15;
    var LeaveTime : Float = 0.3;
    var ForcedFallTime : Float = 0.25;

    var world : PlayState;
    var grid : GarbageGrid;

    var charType : Int;
    var flipCharTypeTween : FlxTween;

    var state : Int;
    var scaleTween : FlxTween;
    var movementTween : FlxTween;

    var graceTimer : FlxTimer;

    var vspeed : Float = 35;

    var finishPositioningAfterMovement : Bool;

    var leaveCallback : Void -> Void;

    public var slave : ItemEntity;

    public function new(X : Float, Y : Float, CharType : Int, World : PlayState)
    {
        super(X, Y);

        charType = CharType;

        handleGraphic();

        graceTimer = new FlxTimer();

        world = World;
        grid = world.grid;
    }

    function handleGraphic(?doMakeGraphic : Bool = true)
    {
        loadGraphic("assets/images/pieces.png", true, 16, 16);
        animation.add("idle", [charType-1]);
        animation.play("idle");
        // TODO: Add small animations per type
    }

    override public function destroy()
    {
        destroyTimer(graceTimer);
        destroyTween(scaleTween);
        destroyTween(movementTween);
        destroyTween(flipCharTypeTween);

        super.destroy();
    }

    public function setState(Next : Int)
    {
        state = Next;
        // Extra actions?
        switch (Next)
        {
            case ItemEntity.StateGenerating:
                if (scaleTween != null)
                {
                    scaleTween.destroy();
                }

                scale.set(0, 0);
                scaleTween = FlxTween.tween(this.scale, {x : 1, y: 1}, 0.5, {onComplete: onGenerationFinished});
                // Apply the same for the slave, if any
                if (slave != null)
                {
                    slave.scale.set(0, 0);
                    FlxTween.tween(slave.scale, {x : 1, y: 1}, 0.5);
                }
            case ItemEntity.StateFalling:
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
            default:
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
            slave.x = x;
            slave.y = y - Constants.TileSize;
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
        var currentCell : FlxPoint = grid.getCellAt(x, y);
        var nextFallingCell : FlxPoint = grid.getCellAt(x, y+height);
        var nextData : ItemData = grid.get(nextFallingCell.x, nextFallingCell.y);

        if (canMoveTo(nextFallingCell.x, nextFallingCell.y)) {
            // Go down, allow movement
            if (GamePad.checkButton(GamePad.Down))
            {
                velocity.set(0, vspeed * 4);
                scale.x = flixel.math.FlxMath.lerp(scale.x, 0.8, 0.2);
                if (slave != null)
                    slave.scale.x = flixel.math.FlxMath.lerp(slave.scale.x, 0.8, 0.2);
            }
            else
            {
                velocity.set(0, vspeed);
                scale.x = flixel.math.FlxMath.lerp(scale.x, 1, 0.4);
                if (slave != null)
                    slave.scale.x = flixel.math.FlxMath.lerp(slave.scale.x, 1, 0.4);
            }

            if (movementTween == null)
            {
                if (GamePad.checkButton(GamePad.Left) && canMoveTo(currentCell.x-1, currentCell.y) && canMoveTo(nextFallingCell.x-1, nextFallingCell.y))
                {
                    moveHorizontallyToCell(currentCell.x-1, currentCell.y);
                }
                else if (GamePad.checkButton(GamePad.Right) && canMoveTo(currentCell.x+1, currentCell.y) && canMoveTo(nextFallingCell.x+1, nextFallingCell.y))
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
            setState(StateGrace);
        }
    }

    function handleGraceState(elapsed : Float)
    {
        var currentCell : FlxPoint = grid.getCellAt(x, y);

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
            else if (GamePad.checkButton(GamePad.Right) && canMoveTo(currentCell.x+1, currentCell.y))
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
        var currentCell : FlxPoint = grid.getCellAt(x, y);
        var targetPos : FlxPoint = grid.getCellPosition(currentCell.x, currentCell.y);

        x = targetPos.x;
        velocity.y = 0;

        /* Hacky effect begins, pay no mind */
        // Add a little bounce for positioning
        y = targetPos.y-4;
        FlxTween.tween(this, {y: targetPos.y}, 0.1, {ease: FlxEase.bounceOut, onComplete: function(t:FlxTween) {
            y = targetPos.y;
        }});
        if (slave != null)
        {
            // Add a little bounce for positioning the slave
            slave.y = targetPos.y-Constants.TileSize-4;
            FlxTween.tween(slave, {y: targetPos.y-Constants.TileSize}, 0.1, {ease: FlxEase.bounceOut, onComplete: function(t:FlxTween) {
                // The slave reference may be null at this point!
                if (slave != null)
                    slave.y = targetPos.y-Constants.TileSize;
            }});
        }
        /* End of hacky effect */

        setState(ItemEntity.StatePositioned);
        grid.set(currentCell.x, currentCell.y, new ItemData(currentCell.x, currentCell.y, charType, this));
        if (slave != null)
        {
            slave.setState(ItemEntity.StatePositioned);
            grid.set(currentCell.x, currentCell.y-1, new ItemData(currentCell.x, currentCell.y-1, slave.charType, slave));
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
            var currentCell : FlxPoint = grid.getCellAt(x, y);
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

    public function setSlave(Slave : ItemEntity)
    {
        slave = Slave;
    }

    public function flipCharType()
    {
        flipCharTypeTween = FlxTween.tween(this.scale, {x : 0}, FlipTime * 0.5, {onComplete: function(t : FlxTween) {
            t.destroy();

            if (charType & 1 == 1)
            {
                charType += 1;
            }
            else
            {
                charType -= 1;
            }

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
        var currentCell : FlxPoint = grid.getCellAt(x, y);
        var targetCell : FlxPoint = grid.getLowerFreeCellFrom(currentCell.x, currentCell.y);
        var targetPos : FlxPoint = grid.getCellPosition(targetCell.x, targetCell.y);

        if (currentCell.y != targetCell.y)
        {
            // Switch positions
            grid.set(currentCell.x, currentCell.y, null);
            grid.set(targetCell.x, targetCell.y, new ItemData(targetCell.x, targetCell.y, charType, this));

            // And go
            movementTween = FlxTween.tween(this, {y: targetPos.y}, ForcedFallTime, {ease: FlxEase.circIn});

            return true;
        }
        else
        {
            return false;
        }
    }
}
