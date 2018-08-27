package;

import flixel.FlxG;
import flixel.FlxBasic;
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

    var TriggerAnimationTime : Float = 1;
    var TriggerBombsAnimationTime : Float = 2;
    var TriggerCleanupDelay : Float = 1;
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

    var aftermathTimer : FlxTimer;
    var aftermathScoreCounter : Int;
    var aftermathCombo : Int;

    var aftermathTriggers : Array<TriggerData>;

    // Display
    var background : FlxSprite;
    var gridShader : FlxSprite;
    var gridFrame : FlxSprite;
    var topDisplay : TopDisplay;

    // GameOver
    var gameoverTimer : FlxTimer;
    var gameoverLightsout : Bool;

    // Debug
    public var debugEnabled : Bool;
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

        gridDebugger = new GridDebugger(this);
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
        var triggerProbability : Int = 0;
        if (!grid.contains(ItemData.SpecialTrigger) && (grid.contains(ItemData.SpecialBomb) || grid.contains(ItemData.SpecialChemdust)))
            triggerProbability = 30;

        var bombProbability : Int = 50;
        if (grid.contains(ItemData.SpecialBomb))
            bombProbability = 5;

        return FlxG.random.getObject([ItemData.SpecialBomb, ItemData.SpecialTrigger, ItemData.SpecialChemdust], [bombProbability, triggerProbability, 60]);
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

        #if work
            var special : Int = FlxG.random.getObject([-1, 0, 1], [30, 30, 30]);
        #else
            var special : Int = FlxG.random.getObject([-1, 0, 1], [5, 90, 5]);
        #end

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

        items.sort(itemsSorter);
    }

    public function onNextItemGenerated()
    {
        if (state == StateGenerate)
            finishGeneration();
        // else notify somehow? Using nextItem for now
    }

    public function onCurrentItemPositioned(cell : FlxPoint)
    {
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
            aftermathTimer.start(ItemFallTime, handleAftermathTriggers);
        else
            aftermathTimer.start(0.01, handleAftermathTriggers);
    }

    public function handleAftermathTriggers(?t:FlxTimer)
    {
        var bombsTriggered : Bool = false;

        // Play trigger animation
        var triggers : Array<TriggerData> = grid.checkTriggers();

        if (triggers.length > 0)
        {
            aftermathTriggers = triggers;
            var clearRows : Array<Int> = [];
            for (trigger in triggers)
            {
                // Handle trigger effects
                if (trigger.entity != null)
                    trigger.entity.triggerTriggerAnimation();
                // Also bombs and chemdust effects
                for (item in trigger.getTriggeredEntities())
                {
                    if (item.entity != null)
                        item.entity.triggerTriggerAnimation();
                    if (item.type == ItemData.SpecialBomb)
                    {
                        bombsTriggered = true;
                        if (clearRows.indexOf(item.cellY) < 0)
                            clearRows.push(item.cellY);
                        if (clearRows.indexOf(trigger.cellY) < 0)
                            clearRows.push(trigger.cellY);
                    }
                }

                for (row in clearRows)
                {
                    // HEY: Adding directly to playstate for effect to be on top
                    /*items.*/add(new BombRowEffect(grid.x, grid.y + row * Constants.TileSize, this));
                }
            }

            aftermathTimer.start((bombsTriggered ? TriggerBombsAnimationTime : TriggerAnimationTime), handleAftermathTriggersCleanup);
        }
        else
        {
            aftermathTimer.start(0.01, handleAftermathCleanup);
        }
    }

    function handleAftermathTriggersCleanup(t:FlxTimer)
    {
        var triggers : Array<TriggerData> = aftermathTriggers;
        aftermathTriggers = [];

        var somethingTriggered : Bool = false;

        // Remove resolved triggers and their related entities to avoid matching with them
        for (trigger in triggers)
        {
            if (trigger.getTriggeredEntities().length > 0)
            {
                for (item in trigger.getTriggeredEntities())
                {
                    grid.set(item.cellX, item.cellY, null);
                    // Handle triggering
                    if (item.type == ItemData.SpecialChemdust)
                    {
                        item.entity.triggerDissolve();
                        somethingTriggered = true;
                    }
                    else if (item.type == ItemData.SpecialBomb)
                    {
                        item.entity.triggerDissolve();

                        // Also remove the rest of the row
                        handleBombRowRemoval(item);
                        // And the rest of the trigger row
                        handleBombRowRemoval(trigger);

                        somethingTriggered = true;
                    }
                }

                grid.set(trigger.cellX, trigger.cellY, null);
                trigger.entity.triggerDissolve();
            }
        }

        if (somethingTriggered)
            aftermathTimer.start(TriggerCleanupDelay, handleAftermathFalling);
        else
            aftermathTimer.start(0.01, handleAftermathCleanup);
    }

    function handleBombRowRemoval(bombItem : ItemData)
    {
        for (col in 0...grid.columns)
        {
            var condemned : ItemData = grid.get(col, bombItem.cellY);
            if (condemned != null && condemned.entity != null)
            {
                grid.set(col, bombItem.cellY, null);
                condemned.entity.triggerLeave();
            }
        }
    }

    public function handleAftermathCleanup(?t:FlxTimer)
    {
        var matches : Array<ItemData> = grid.findMatches();

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

    function itemsSorter(order : Int, a : FlxBasic, b : FlxBasic) : Int
    {
        if (a == null)
            return -1;
        if (b == null)
            return 1;

        if (Std.is(a, BombRowEffect))
            return 1;
        else if (Std.is(b, BombRowEffect))
            return -1;
        else
        {
            if (Std.is(a, ItemEntity) && Std.is(b, ItemEntity))
            {
                if (cast(a, ItemEntity).state == ItemEntity.StateDissolving)
                    return -1;
                else if (cast(b, ItemEntity).state == ItemEntity.StateDissolving)
                    return 1;
                if (ItemData.IsCharTypeSpecial(cast(a, ItemEntity).charType))
                    return 1;
                else if (ItemData.IsCharTypeSpecial(cast(b, ItemEntity).charType))
                    return -1;
                else return 0;
            }
        }

        return 0;
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
