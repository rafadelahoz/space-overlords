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

    var world : PlayState;
    var grid : GarbageGrid;

    var charType : Int;

    var state : Int;
    var scaleTween : FlxTween;
    var horizontalTween : FlxTween;

    var GraceTime : Float = 0.2;
    var graceTimer : FlxTimer;

    var HorizontalMovementDuration : Float = 0.15;
    var vspeed : Float = 15;

    var finishPositioningAfterMovement : Bool;

    public var slave : ItemEntity;

    public function new(X : Float, Y : Float, World : PlayState)
    {
        super(X, Y);

        makeGraphic(Constants.TileSize, Constants.TileSize, Palette.White);

        charType = 1;

        graceTimer = new FlxTimer();

        world = World;
        grid = world.grid;
    }

    override public function destroy()
    {
        destroyTimer(graceTimer);
        destroyTween(scaleTween);
        destroyTween(horizontalTween);
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
                color = Palette.Green;
            case ItemEntity.StateGrace:
                handleGraceState(elapsed);
                color = Palette.DarkGreen;
            case ItemEntity.StatePositioned:
                color = Palette.Blue;
                // Stay still!
            case ItemEntity.StateSlave:
                color = Palette.DarkPurple;
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
                velocity.set(0, vspeed * 4);
            else
                velocity.set(0, vspeed);

            if (horizontalTween == null)
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

        velocity.set(0, 0);

        if (horizontalTween == null)
        {
            if (GamePad.checkButton(GamePad.Left) && canMoveTo(currentCell.x-1, currentCell.y))
            {
                moveHorizontallyToCell(currentCell.x-1, currentCell.y);
            }
            else if (GamePad.checkButton(GamePad.Right) && canMoveTo(currentCell.x+1, currentCell.y))
            {
                moveHorizontallyToCell(currentCell.x+1, currentCell.y);
            }
        }
    }

    function finishPositioning()
    {
        // The piece can stop
        var currentCell : FlxPoint = grid.getCellAt(x, y);
        var targetPos : FlxPoint = grid.getCellPosition(currentCell.x, currentCell.y);
        x = targetPos.x;
        y = targetPos.y;
        velocity.y = 0;

        setState(ItemEntity.StatePositioned);
        grid.set(currentCell.x, currentCell.y, new ItemData(charType, this));
        if (slave != null)
        {
            slave.setState(ItemEntity.StatePositioned);
            grid.set(currentCell.x, currentCell.y-1, new ItemData(slave.charType, slave));
        }

        world.onCurrentItemPositioned();
    }

    function onGraceEnd(t : FlxTimer)
    {
        t.cancel();
        // When the grace period ends...
        if (horizontalTween == null)
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
        horizontalTween = FlxTween.tween(this, {x: grid.getCellPosition(cellX, cellY).x}, HorizontalMovementDuration, {ease: FlxEase.circInOut, onComplete: onHorizontalMovementEnd});
    }

    function onHorizontalMovementEnd(?t : FlxTween = null)
    {
        t.destroy();
        horizontalTween = null;

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
}
