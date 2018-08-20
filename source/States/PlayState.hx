package;

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
                var generationPosition : FlxPoint = grid.getCellPosition(0, 0);
                currentItem = new ItemEntity(generationPosition.x, generationPosition.y, this);
                currentItem.setState(ItemEntity.StateGenerating);
                add(currentItem);
            case PlayState.StateWait:
                currentItem.setState(ItemEntity.StateFalling);
            case PlayState.StateAftermath:
                items.add(currentItem);
                currentItem = null;
                // Other things?
                switchState(StateGenerate);
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
}
