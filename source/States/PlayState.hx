package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.addons.transition.FlxTransitionableState;

class PlayState extends GarbageState
{
    public static var StateIntro       : Int = 1;
    public static var StateGenerate    : Int = 2;
    public static var StateWait        : Int = 3;
    public static var StateAftermath   : Int = 4;
    public static var StateLost        : Int = 5;

    // var GenerationDelay : Float = 1;
    var CleanUpDelay : Float = 0.1;
    var ItemLeaveTime : Float = 0.35;
    var ItemFallTime : Float = 0.2;
    var GameoverLightsoutDelay : Float = 0.75;

    public var session : PlaySessionData;

    public var state : Int;

    public var grid : GarbageGrid;
    public var items : FlxGroup;

    var nextItem : ItemEntity;
    var currentItem : ItemEntity;

    var screenButtons : ScreenButtons;

    var lastPositionedCell : FlxPoint;

    var aftermathTimer : FlxTimer;
    var aftermathScoreCounter : Int;
    var aftermathCombo : Int;

    // Display
    var background : FlxSprite;
    var gridShader : FlxSprite;
    var gridFrame : FlxSprite;
    var topDisplay : TopDisplay;

    // GameOver
    var gameoverTimer : FlxTimer;
    var gameoverLightsout : Bool;

    // Debug
    var debugEnabled : Bool;
    var stateLabel : FlxBitmapText;
    var gridDebugger : GridDebugger;

    override public function create()
    {
        session = new PlaySessionData();

        grid = new GarbageGrid(8, 240 - 9*Constants.TileSize - 8); // Centered: Constants.Width / 2 - 96 /2
        grid.init();

        add(background = new FlxSprite(0, 0).loadGraphic("assets/backgrounds/bg01.png"));

        gridShader = new FlxSprite(grid.x-2, grid.y-2);
        gridShader.makeGraphic(grid.columns*Constants.TileSize+4, grid.rows*Constants.TileSize+4, 0xFF181425);
        gridShader.alpha = 0.6;
        add(gridShader);

        add(gridFrame = new FlxSprite(grid.x-8, grid.y-4, "assets/ui/grid-frame.png"));

        gridDebugger = new GridDebugger(grid);
        add(gridDebugger);

        items = new FlxGroup();
        add(items);

        currentItem = null;

        // Add the top part
        topDisplay = new TopDisplay(this);
		add(topDisplay);

        stateLabel = text.PixelText.New(0, 0, "", 0xFFFEE761);
        add(stateLabel);

        screenButtons = new ScreenButtons(0, 0, this, 240);
		add(screenButtons);

        aftermathTimer = new FlxTimer();
        gameoverTimer = new FlxTimer();

        switchState(StateIntro);

        debugEnabled = false;
        gridDebugger.visible = false;
        stateLabel.visible = false;

        super.create();
    }

    public function getNextCharType() : Int
    {
        var next : Int = FlxG.random.int(1, 8);
        return next;
    }

    public function getSpecialCharType() : Int
    {
        return 24;
    }

    public function getNextItemShape() : ItemEntity.CellPosition
    {
        return FlxG.random.getObject([ItemEntity.CellPosition.Right, ItemEntity.CellPosition.Top]);
    }

    public function switchState(Next : Int)
    {
        state = Next;

        switch (state)
        {
            case PlayState.StateGenerate:
                if (nextItem == null)
                {
                    generateNextItem();
                }
                else
                {
                    finishGeneration();
                }
            case PlayState.StateWait:
                currentItem.setState(ItemEntity.StateFalling);
            case PlayState.StateAftermath:
                items.add(currentItem);
                items.add(currentItem.slave);

                // Clear current item references
                currentItem.slave = null;
                currentItem = null;

                aftermathScoreCounter = 0;
                aftermathCombo = 0;

                // Call cleanupo!
                aftermathTimer.start(CleanUpDelay, handleAftermathFalling);
            case PlayState.StateLost:
                trace("Game over!");

                showGameOverNotification();
                topDisplay.bottomLabel.resetText("PRODUCTION TERMINATED!", Palette.Red);
                FlxG.camera.flash(Palette.Red, function() {
                    gameoverLightsout = false;
                    gameoverTimer.start(GameoverLightsoutDelay*2, onGameoverTimer);
                });
        }
    }

    function generateNextItem(?t:FlxTimer)
    {
        // Generate the next item at a random position
        var generationPosition : FlxPoint = grid.getCellPosition(FlxG.random.int(0, grid.columns-1), 1);
        var shape : ItemEntity.CellPosition = getNextItemShape();
        if (shape == ItemEntity.CellPosition.Right && generationPosition.x == grid.getCellPosition(grid.columns-1, 0).x)
        {
            generationPosition.x -= Constants.TileSize;
        }

        var special : Int = FlxG.random.getObject([-1, 0, 1], [3, 94, 3]);

        nextItem = new ItemEntity(generationPosition.x, generationPosition.y,
                                getNextCharType(), (special == -1 ? getSpecialCharType() : null), this);

        // Generate the pair item on top of that
        var slaveItem : ItemEntity = new ItemEntity(generationPosition.x, generationPosition.y,
                                                    getNextCharType(), (special == 1 ? getSpecialCharType() : null), this);
        slaveItem.setState(ItemEntity.StateSlave);
        nextItem.setSlave(slaveItem, shape);

        // Go
        nextItem.setState(ItemEntity.StateGenerating);
        add(nextItem);
    }

    function finishGeneration()
    {
        currentItem = nextItem;
        nextItem = null;
        switchState(StateWait);
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
                if (nextItem != null)
                    finishGeneration();
            case PlayState.StateWait:
                stateLabel.text = "Waiting";
                if (nextItem == null && !currentItem.inGenerationArea())
                {
                    generateNextItem();
                }
            case PlayState.StateAftermath:
                stateLabel.text = "Aftermath";
            case PlayState.StateLost:
                stateLabel.text = "Losing";
            default:
                stateLabel.text = "Unknown state?";
        }

        handleDebug();

        super.update(elapsed);
    }

    public function onNextItemGenerated()
    {
        if (state == StateGenerate)
            finishGeneration();
        // else notify somehow? Using nextItem for now
    }

    public function onCurrentItemPositioned(cell : FlxPoint)
    {
        lastPositionedCell = cell;
        switchState(StateAftermath);
    }

    function handleAftermathFalling(?t:FlxTimer)
    {
        var somethingFell : Bool = false;

        // Make all items fall down
        // grid.getAll shall return things from bottom to top
        for (itemData in grid.getAll())
        {
            if (itemData.entity != null)
            {
                if (itemData.entity.fallToFreePosition())
                    somethingFell = true;
            }
        }

        // If something fell, we need to recompute the matches
        if (somethingFell)
            aftermathTimer.start(ItemFallTime, handleAftermathCleanup);
        else
            aftermathTimer.start(0.01, handleAftermathCleanup);
    }

    public function handleAftermathCleanup(?t:FlxTimer)
    {
        // Check and remove items
        var matches : Array<ItemData> = grid.findMatches( /*lastPositionedCell*/ );
        lastPositionedCell = null;

        var lastCharType : Int = -1;
        for (itemData in matches)
        {
            // Clear the cell occupied by the item
            grid.set(itemData.cellX, itemData.cellY, null);
            // Make the entity leave
            if (itemData.entity != null)
                itemData.entity.triggerLeave(
                    // Make sure to add the item to the processing queue
                    // Grouping pairs!
                    (itemData.type == lastCharType) ? null :
                    function() {
                        topDisplay.addItem(itemData.type);
                    }
                );
            // Hacky thing to group pairs
            if (lastCharType != itemData.type)
                lastCharType = itemData.type;
            else
                lastCharType = -1;
        }

        if (matches.length > 0)
        {
            aftermathCombo += 1;
            aftermathScoreCounter += 2*aftermathCombo*10*matches.length;

            if (aftermathCombo > 1)
            {
                var comboText : String = "COMBO";
                for (i in 1...Std.int(Math.min(aftermathCombo, 3)))
                    comboText += "!";
                comboText = text.TextUtils.padWith(comboText, 9, " ");
                topDisplay.notifications.add(new TextNotice(96-(1+comboText.length)*8, 16, comboText, 0xFF2ce8f5));
            }
            topDisplay.notifications.add(new TextNotice(96, 16, "+ " + aftermathScoreCounter, 0xFFFEE761));
        }

        // Wait a bit if things are leaving, otherwise finish now
        if (matches.length > 0)
        {
            aftermathTimer.start(ItemLeaveTime, handleAftermathFalling);
        }
        else
        {
            aftermathTimer.start(0.01, handleAftermathResult);
        }
    }

    public function handleAftermathResult(?t:FlxTimer)
    {
        session.score += aftermathScoreCounter;

        // Lose game
        if (checkForLoseConditions(currentItem))
        {
            // You lost!
            switchState(StateLost);
        }
        else
        {
            // Go on
            switchState(StateGenerate);
        }
    }

    public function onAftermathFinished()
    {
        switchState(StateGenerate);
    }

    function checkForLoseConditions(currentItem : ItemEntity) : Bool
    {
        // TODO: input currentItem may not be required, check whole grid?
        return grid.checkForItemsOnTopRows();
    }

    function onGameoverTimer(t:FlxTimer)
    {
        if (!gameoverLightsout)
        {
            gameoverLightsout = true;
            for (item in grid.getAll())
            {
                if (item.entity != null)
                {
                    item.entity.color = 0xFF262b44;
                }
            }

            gridShader.alpha = 0.8;

            gameoverTimer.start(GameoverLightsoutDelay, onGameoverTimer);
        }
        else
        {
            gameoverTimer.start(GameoverLightsoutDelay, function(t:FlxTimer) {
                FlxG.camera.fade(0xFF000000, GameoverLightsoutDelay * 2, false, function() {
                    GameController.GameOver(Constants.ModeEndless, session);
                });
            });
        }
    }

    function showGameOverNotification()
    {
        topDisplay.notifications.add(new TextNotice(96, 16, "!ERROR!", Palette.Red, showGameOverNotification));
    }

    /* DEBUG */

    function handleDebug()
    {
        if (FlxG.keys.justPressed.TAB || GamePad.justPressed(GamePad.Pause))
        {
            debugEnabled = !debugEnabled;
            stateLabel.visible = debugEnabled;
            gridDebugger.visible = debugEnabled;
        }
    }
}
