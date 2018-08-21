package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.addons.transition.FlxTransitionableState;

class PlayState extends GarbageState
{
    static var StateIntro       : Int = 1;
    static var StateGenerate    : Int = 2;
    static var StateWait        : Int = 3;
    static var StateAftermath   : Int = 4;
    static var StateLost        : Int = 5;

    var state : Int;

    public var grid : GarbageGrid;
    var items : FlxGroup;
    var currentItem : ItemEntity;

    // Debug
    var stateLabel : FlxBitmapText;
    var gridDebugger : GridDebugger;

    override public function create()
    {
        grid = new GarbageGrid(16, 16);
        grid.init();

        items = new FlxGroup();
        add(items);

        currentItem = null;

        gridDebugger = new GridDebugger(grid);
        add(gridDebugger);

        stateLabel = text.PixelText.New(0, 0, "", Palette.White);
        add(stateLabel);

        switchState(StateIntro);

        super.create();
    }

    public function switchState(Next : Int)
    {
        state = Next;

        switch (state)
        {
            case PlayState.StateGenerate:
                // Generate the next item at a random position
                var generationPosition : FlxPoint = grid.getCellPosition(FlxG.random.int(0, grid.columns-1), 1);
                currentItem = new ItemEntity(generationPosition.x, generationPosition.y, this);

                // Generate the pair item on top of that
                var slaveItem : ItemEntity = new ItemEntity(generationPosition.x, generationPosition.y - Constants.TileSize, this);
                slaveItem.setState(ItemEntity.StateSlave);
                currentItem.setSlave(slaveItem);

                // Go
                currentItem.setState(ItemEntity.StateGenerating);
                add(currentItem);
            case PlayState.StateWait:
                currentItem.setState(ItemEntity.StateFalling);
            case PlayState.StateAftermath:
                items.add(currentItem);
                items.add(currentItem.slave);

                // TODO: Remove items

                // Lose game
                if (checkForLoseConditions(currentItem))
                {
                    // You lost!
                    switchState(StateLost);
                }
                else
                {
                    // Clear current item references
                    currentItem.slave = null;
                    currentItem = null;

                    // Go on
                    switchState(StateGenerate);
                }
            case PlayState.StateLost:
                trace("Game over!");
                FlxG.camera.flash(Palette.Red, function() {
                    GameController.GameOver(Constants.ModeEndless, {});
                });
        }
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case PlayState.StateIntro:
                stateLabel.text = "Intro";
                switchState(StateGenerate);
            case PlayState.StateGenerate:
                stateLabel.text = "Generating";
            case PlayState.StateWait:
                stateLabel.text = "Waiting";
            case PlayState.StateAftermath:
                stateLabel.text = "Aftermath";
            case PlayState.StateLost:
                stateLabel.text = "Losing";
            default:
                stateLabel.text = "Unknown state?";
        }

        super.update(elapsed);
    }

    public function onNextItemGenerated()
    {
        switchState(StateWait);
    }

    public function onCurrentItemPositioned()
    {
        switchState(StateAftermath);
    }

    public function onAftermathFinished()
    {
        switchState(StateGenerate);
    }

    function checkForLoseConditions(currentItem : ItemEntity) : Bool
    {
        // TODO: input currentItem may not be required, check whole grid?
        return (grid.getCellAt(currentItem.x, currentItem.y).y < 2 ||
            grid.getCellAt(currentItem.slave.x, currentItem.slave.y).y < 2);
    }
}
