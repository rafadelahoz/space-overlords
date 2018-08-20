package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class ItemEntity extends FlxSprite
{
    public static var StateNone : Int = -1;
    public static var StateGenerating : Int = 0;
    public static var StateFalling : Int = 1;
    public static var StatePositioned : Int = 2;

    var world : PlayState;
    var grid : GarbageGrid;

    var charType : Int;

    var state : Int;
    var scaleTween : FlxTween;
    var horizontalTween : FlxTween;

    var HorizontalMovementDuration : Float = 0.15;
    var vspeed : Float = 15;

    public function new(X : Float, Y : Float, World : PlayState)
    {
        super(X, Y);

        makeGraphic(Constants.TileSize, Constants.TileSize, Palette.White);

        charType = 1;

        world = World;
        grid = world.grid;
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
            case ItemEntity.StateFalling:
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
            case ItemEntity.StatePositioned:
                // Stay still!
        }

        super.update(elapsed);
    }

    function onGenerationFinished(t : FlxTween)
    {
        t.destroy();
        scaleTween = null;

        world.onNextItemGenerated();
    }

    function handleFallingState(elapsed : Float)
    {
        var currentPos : FlxPoint = grid.getCellAt(x, y);
        var nextPos : FlxPoint = grid.getCellAt(x, y+height);
        var nextData : ItemData = grid.get(nextPos.x, nextPos.y);

        if (canMoveTo(nextPos.x, nextPos.y)) {
            // Go down, allow movement
            if (GamePad.checkButton(GamePad.Down))
                velocity.set(0, vspeed * 4);
            else
                velocity.set(0, vspeed);

            if (horizontalTween == null)
            {
                if (GamePad.checkButton(GamePad.Left) && canMoveTo(currentPos.x-1, currentPos.y) && canMoveTo(nextPos.x-1, nextPos.y))
                {
                    // TODO: Check position
                    horizontalTween = FlxTween.tween(this, {x: x-Constants.TileSize}, HorizontalMovementDuration, {ease: FlxEase.circInOut, onComplete: function(t:FlxTween) {
                        t.destroy();
                        horizontalTween = null;
                    }});
                }
                else if (GamePad.checkButton(GamePad.Right) && canMoveTo(currentPos.x+1, currentPos.y) && canMoveTo(nextPos.x+1, nextPos.y))
                {
                    // TODO: Check position
                    horizontalTween = FlxTween.tween(this, {x: x+Constants.TileSize}, HorizontalMovementDuration, {ease: FlxEase.circInOut, onComplete: function(t:FlxTween) {
                        t.destroy();
                        horizontalTween = null;
                    }});
                }
            }
        }
        else
        {
            trace("next data" + nextData);
            // The piece can stop
            var currentCell : FlxPoint = grid.getCellAt(x, y);
            var targetPos : FlxPoint = grid.getCellPosition(currentCell.x, currentCell.y);
            x = targetPos.x;
            y = targetPos.y;
            velocity.y = 0;

            setState(ItemEntity.StatePositioned);
            grid.set(currentCell.x, currentCell.y, new ItemData(charType, this));

            world.onCurrentItemPositioned();
        }
    }

    function canMoveTo(cellX : Float, cellY : Float) : Bool
    {
        return grid.get(cellX, cellY) == null && grid.isCellValid(cellX, cellY);
    }
}
