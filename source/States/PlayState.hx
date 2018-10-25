package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;

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
    var ThemeChangeDelay : Float = 1.33;

    var restoredSessionData : Dynamic;

    public var mode : Int;
    public var session : PlaySessionData;

    public var state : Int;

    public var grid : GarbageGrid;
    public var items : FlxGroup;
    var effects : FlxGroup;

    var nextItem : ItemEntity;
    var currentItem : ItemEntity;

    var screenButtons : ScreenButtons;

    var aftermathTimer : FlxTimer;
    var aftermathScoreCounter : Int;
    var aftermathCombo : Int;

    var aftermathTriggers : Array<TriggerData>;

    // Display
    var background : FlxSprite;
    var fxBg : FlxEffectSprite;
    var gridShader : FlxSprite;
    var gridFrame : FlxSprite;
    var topDisplay : TopDisplay;

    // GameOver
    var gameoverTimer : FlxTimer;
    var gameoverLightsout : Bool;

    // Pause
    public var paused : Bool;
    var aftermathTimerActive : Bool;

    // Theme
    var theme : Int;
    var shallChangeBackground : Int;
    var NoChange    : Int = 0;
    var ChangeSide  : Int = 1;
    var ChangeTheme : Int = 2;

    // Debug
    public var debugEnabled : Bool;
    var stateLabel : FlxBitmapText;
    var gridDebugger : GridDebugger;

    public function new(RestoredSessionData : Dynamic)
    {
        super();

        restoredSessionData = RestoredSessionData;
    }

    override public function create()
    {
        if (restoredSessionData == null || restoredSessionData.session == null)
            session = new PlaySessionData();
        else
            session = restoredSessionData.session;
        mode = GameSettings.data.mode;

        Logger.log("==== " + (mode == Constants.ModeEndless ? "PROCESS" : "REFINE") + " session begins");

        FlxG.camera.bgColor = 0xFF000000;

        grid = new GarbageGrid(8, 240 - 9*Constants.TileSize - 8); // Centered: Constants.Width / 2 - 96 /2
        grid.init();

        // TODO: Set initial theme from somewhere? random?
        theme = ThemeManager.GetRandomTheme();
        setupBackground();

        gridShader = new FlxSprite(grid.x-2, grid.y-2);
        gridShader.makeGraphic(grid.columns*Constants.TileSize+4, grid.rows*Constants.TileSize+4, 0xFF181425);
        gridShader.alpha = 0.6;
        add(gridShader);

        add(gridFrame = new FlxSprite(grid.x-8, grid.y-4, "assets/ui/grid-frame.png"));

        gridDebugger = new GridDebugger(this);
        add(gridDebugger);

        items = new FlxGroup();
        add(items);

        effects = new FlxGroup();
        add(effects);

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

        // Setup gameplay
        setupGameplay();

        paused = false;
        aftermathTimerActive = false;

        switchState(StateIntro);

        debugEnabled = false;
        gridDebugger.visible = false;
        stateLabel.visible = false;

        super.create();
    }

    function setupBackground()
    {
        background = new FlxSprite(0, 0).loadGraphic(ThemeManager.GetBackground(theme, ThemeManager.SideA));
        fxBg = new FlxEffectSprite(background);
        var fxWave : FlxWaveEffect = new FlxWaveEffect(FlxWaveMode.ALL, 2);
        fxBg.effects = [fxWave];
        add(fxBg);

        // Setup theme effects
        handleThemeBackgroundChange(false);
    }

    function getInitialFallSpeed() : Int
    {
        var intensity : Int = Std.int(GameSettings.data.intensity / 25);
        return 16 + intensity;
    }

    function setupGameplay()
    {
        // Intensity 0-4
        if (restoredSessionData == null)
        {
            var intensity : Int = Std.int(GameSettings.data.intensity / 25);
            session.fallSpeed = getInitialFallSpeed();

            Logger.log("--- " + intensity + " -> " + session.fallSpeed);

            if (mode == Constants.ModeEndless)
                setupInitialGrid(intensity);
            else if (mode == Constants.ModeTreasure)
            {
                setupCycleGrid();
            }
        }
        else
        {
            Logger.log("--- Restored, fallspeed " + session.fallSpeed);
            grid.loadStoredGridData(this, restoredSessionData.grid);
        }
    }

    public function switchState(Next : Int)
    {
        state = Next;

        switch (state)
        {
            case PlayState.StateIntro:
                background.alpha = 0;
                gridFrame.x = -gridFrame.width;
                gridShader.x = gridFrame.x + 6;
                // screenButtons.color = 0xFF124e89;
                // screenButtons.alpha = 0.8;

                var delay : Float = 1;
                var duration : Float = 0;

                duration = 0.75;
                FlxTween.tween(background, {alpha : 1}, duration, {startDelay: delay, ease: FlxEase.circIn});
                delay += duration;
                delay += 0.5;

                duration = 0.75;
                FlxTween.tween(gridFrame,  {x : grid.x-8}, duration, {startDelay: delay});
                FlxTween.tween(gridShader, {x : grid.x-2}, duration, {startDelay: delay});
                for (itemData in grid.getAll()) {
                    if (itemData != null && itemData.entity != null)
                    {
                        itemData.entity.color = Palette.DarkBlue;
                        itemData.entity.x = gridFrame.x + 8 + itemData.cellX * Constants.TileSize;
                        FlxTween.tween(itemData.entity, {x : grid.x + itemData.cellX * Constants.TileSize}, duration, {startDelay: delay});
                    }
                }
                delay += duration;

                var shakeTween : FlxTween = FlxTween.tween(gridFrame, {y : gridFrame.y+1}, 0.075, {startDelay: delay, type: FlxTween.PINGPONG});
                new FlxTimer().start(delay+0.075*3, function(t:FlxTimer) {
                    shakeTween.cancel();
                });
                delay += 0.5;

                delay += 0.5;
                new FlxTimer().start(delay, function(t:FlxTimer) {
                    topDisplay.start();

                    for (itemData in grid.getAll()) {
                        if (itemData != null && itemData.entity != null)
                        {
                            // itemData.entity.color = 0xFFFFFFFF;
                            flixel.effects.FlxFlicker.flicker(itemData.entity, 0.5, true);
                            FlxTween.color(itemData.entity, 0.5, Palette.DarkBlue, 0xFFFFFFFF, {ease: FlxEase.elasticInOut});
                        }
                    }
                });
                // delay += 1;

                /*duration = 0.5;
                FlxTween.color(screenButtons, duration, Palette.DarkBlue, 0xFFFFFFFF, {startDelay: delay, ease: FlxEase.bounceInOut});
                delay += duration;
                delay += 0.5;*/

                new FlxTimer().start(delay, function(t:FlxTimer) {
                    generateNextItem();
                });

                delay += 2;
                new FlxTimer().start(delay, function(t:FlxTimer) {
                    topDisplay.startScroller();

                    if (mode == Constants.ModeEndless)
                        switchState(StateGenerate);
                    else
                        highlightTargets();

                    topDisplay.showMessage(24, "!WORK  STARTING!", Palette.Green, true);
                });
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
                remove(currentItem);
                currentItem.slave = null;
                currentItem = null;

                aftermathScoreCounter = 0;
                aftermathCombo = 0;

                // Call cleanupo!
                aftermathTimer.start(CleanUpDelay, handleAftermathFalling);
            case PlayState.StateLost:
                Logger.log("==== session ends");

                session.endTime = Date.now().getTime();

                showGameOverNotification();
                topDisplay.handleGameover();
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

        var charTypes : Array<Int> = generateNextItemCharTypes();

        nextItem = new ItemEntity(generationPosition.x, generationPosition.y, charTypes[0], charTypes[1], this);

        // Generate the pair item on top of that
        var slaveItem : ItemEntity = new ItemEntity(generationPosition.x, generationPosition.y, charTypes[2], charTypes[3], this);
        slaveItem.setState(ItemEntity.StateSlave);
        nextItem.setSlave(slaveItem, shape);

        // Go
        nextItem.setState(ItemEntity.StateGenerating);
        add(nextItem);
    }

    public function getNextCharType() : Int
    {
        var next : Int = FlxG.random.int(1, 8);
        return next;
    }

    function getInitialCharType() : Int
    {
        return getNextCharType();
    }

    public function getSpecialCharType() : Int
    {
        var triggerProbability : Int = 20;
        if (mode == Constants.ModeTreasure)
            triggerProbability = 0;
        else if (!grid.contains(ItemData.SpecialTrigger) && (grid.contains(ItemData.SpecialBomb) || grid.contains(ItemData.SpecialChemdust)))
            triggerProbability = 50;

        var bombProbability : Int = -1;
        if (mode == Constants.ModeTreasure)
            bombProbability = 0;
        else
        {
            if (grid.contains(ItemData.SpecialBomb))
                bombProbability = 30;
            else
                bombProbability = 50;
        }

        var targetProbability : Int = 0;
        if (mode == Constants.ModeTreasure)
        {
            targetProbability = 30;
        }

        var chemdustProbabilty : Int = 50;
        if (mode == Constants.ModeTreasure)
            chemdustProbabilty = 0;

        return FlxG.random.getObject([ItemData.SpecialBomb, ItemData.SpecialTrigger, ItemData.SpecialChemdust, ItemData.SpecialTarget], [bombProbability, triggerProbability, chemdustProbabilty, targetProbability]);
    }

    public function getNextItemShape() : ItemEntity.CellPosition
    {
        return FlxG.random.getObject([ItemEntity.CellPosition.Right, ItemEntity.CellPosition.Top]);
    }

    function generateNextItemCharTypes() : Array<Int>
    {
        var weights : Array<Float> = (mode == Constants.ModeEndless ? [80, 2, 2, 5, 5] : [92, 2, 2, 2, 2]);
        var specialItemPosition : Int = FlxG.random.getObject([-1, 0, 1, 2, 3], weights);

        var charTypes : Array<Int> = [];
        for (i in 0...4)
        {
            if (i == specialItemPosition)
                charTypes.push(getSpecialCharType());
            else if (i & 1 == 0 || i & 1 == 1 && (i-1 == specialItemPosition))
                charTypes.push(getNextCharType());
            else
                charTypes.push(-1);
        }

        return charTypes;

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
            case PlayState.StateGenerate:
                stateLabel.text = "Generating";
                if (nextItem != null)
                    finishGeneration();
                handlePause();
            case PlayState.StateWait:
                stateLabel.text = "Waiting";
                if (nextItem == null && !currentItem.inGenerationArea())
                {
                    generateNextItem();
                }
                handlePause();
            case PlayState.StateAftermath:
                stateLabel.text = "Aftermath";
                handlePause();
            case PlayState.StateLost:
                stateLabel.text = "Losing";
            default:
                stateLabel.text = "Unknown state?";
        }

        handleDebug();

        super.update(elapsed);

        items.sort(itemsSorter);
    }

    function handlePause()
    {
		if (GamePad.justReleased(GamePad.Pause))
		{
			onPauseStart();
			openSubState(new PauseSubstate(this, onPauseEnd, onPauseAbort));
		}
    }

    function onPauseStart()
    {
        paused = true;
        aftermathTimerActive = aftermathTimer.active;
        if (aftermathTimer.active)
            aftermathTimer.active = false;

        if (nextItem != null)
            nextItem.onPauseStart();

        topDisplay.onPauseStart();
        effects.forEach(handleEffectPause);

        SfxEngine.play(SfxEngine.SFX.PauseStart);
    }

    function onPauseEnd()
    {
        paused = false;
        if (aftermathTimerActive)
            aftermathTimer.active = true;

        if (nextItem != null)
            nextItem.onPauseEnd();

        topDisplay.onPauseEnd();
        effects.forEach(handleEffectResume);

        SfxEngine.play(SfxEngine.SFX.PauseEnd);
    }

    function onPauseAbort()
    {
        topDisplay.onPauseEnd();
    }

    function handleEffectPause(basic : FlxBasic)
    {
        if (basic != null && Std.is(basic, BombRowEffect))
        {
            cast(basic, BombRowEffect).onPauseStart();
        }
    }

    function handleEffectResume(basic : FlxBasic)
    {
        if (basic != null && Std.is(basic, BombRowEffect))
        {
            cast(basic, BombRowEffect).onPauseEnd();
        }
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

        var chemdustCounter : Int = 0;

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
                    {
                        item.entity.triggerTriggerAnimation();
                        if (item.type == ItemData.SpecialChemdust)
                        {
                            session.items += 1;

                            // Score: 2 x (chemdust number) x 50
                            chemdustCounter += 1;
                            aftermathScoreCounter += 2*chemdustCounter*50;
                        }
                    }
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
                    effects.add(new BombRowEffect(grid.x, grid.y + row * Constants.TileSize, this));
                }
            }

            if (chemdustCounter > 0)
            {
                var comboText = "SPECIAL!";
                topDisplay.showMessage(96-(1+comboText.length)*8, comboText, 0xFF2ce8f5);
                topDisplay.showMessage(96, "+ " + aftermathScoreCounter, 0xFFFEE761);

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
        var bombsTriggered : Bool = false;

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
                        bombsTriggered = true;

                        aftermathScoreCounter += 200;
                    }
                }

                grid.set(trigger.cellX, trigger.cellY, null);
                trigger.entity.triggerDissolve();
            }
        }

        if (somethingTriggered || bombsTriggered)
        {
            aftermathTimer.start(TriggerCleanupDelay, handleAftermathFalling);

            var comboText = "SPECIAL!";
            topDisplay.showMessage(96-(1+comboText.length)*8, comboText, 0xFF2ce8f5);
            topDisplay.showMessage(96, "+ " + aftermathScoreCounter, 0xFFFEE761);
        }
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
            // New item!
            session.items += 1;

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
            SfxEngine.play(SfxEngine.SFX.Pair);
            
            aftermathCombo += 1;

            // Compute matches score
            var matchesScore : Int = computeMatchesScore(matches);
            // Scale by combo
            aftermathScoreCounter += 2*aftermathCombo * matchesScore;

            if (mode == Constants.ModeEndless)
            {
                if (aftermathCombo > 1)
                {
                    var comboText : String = "COMBO";
                    for (i in 1...Std.int(Math.min(aftermathCombo, 3)))
                        comboText += "!";
                    comboText = text.TextUtils.padWith(comboText, 9, " ");
                    topDisplay.showMessage(96-(1+comboText.length)*8, comboText, 0xFF2ce8f5);
                }
                topDisplay.showMessage(96, "+ " + aftermathScoreCounter, 0xFFFEE761);
            }
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

    function computeMatchesScore(matches : Array<ItemData>) : Int
    {
        var score : Int = 0;

        // Item matching is worth less on treasure
        var itemValue : Int = (mode == Constants.ModeEndless ? 10 : 0);
        for (item in matches)
        {
            switch(item.type)
            {
                case ItemData.SpecialBomb:      score += 0;
                case ItemData.SpecialTrigger:   score += 0;
                case ItemData.SpecialChemdust:  score += 0;
                case ItemData.SpecialTarget:    score += 200;
                default:                        score += itemValue;
            }
        }

        return score;
    }

    public function handleAftermathResult(?t:FlxTimer)
    {
        if (aftermathScoreCounter >= 0)
            session.score += aftermathScoreCounter;

        // Lose game
        if (checkForLoseConditions(currentItem))
        {
            // You lost!
            switchState(StateLost);
        }
        else
        {
            // Increase speed?
            if ((session.items - session.lastItemsSpeedIncrease) >= 10)
            {
                session.fallSpeed += (mode == Constants.ModeEndless ? 2 : 1);
                Logger.log("-- fall speed " + session.fallSpeed + " [++] (" + Date.now() + ")");
                session.lastItemsSpeedIncrease = session.items;
                session.timesIncreased += 1;

                if (mode == Constants.ModeEndless)
                    topDisplay.showMessage(80, "!Speed Up!", Palette.Yellow);

                if (mode == Constants.ModeEndless)
                {
                    if (checkForThemeChange())
                        return;
                }
            }

            if (mode == Constants.ModeTreasure)
            {
                if (!grid.contains(ItemData.SpecialTarget))
                {
                    // Finished cycle!
                    for (item in grid.getAll())
                    {
                        if (item.entity != null)
                        {
                            FlxTween.color(item.entity, 0.25, 0xFFFFFFFF, Palette.DarkBlue, {ease : FlxEase.sineInOut});
                        }
                    }

                    aftermathTimer.start(1, function(_) {

                        /*for (row in 2...grid.rows)
                            add(new BombRowEffect(grid.x, grid.y + row * Constants.TileSize, this));*/

                        FlxG.camera.flash(Palette.DarkBlue, 1);

                        session.cycle += 1;
                        setupCycleGrid();

                        // Reset a tad the fall speed when the cycle is cleared
                        // session.fallSpeed = Math.max(session.fallSpeed - 4, getInitialFallSpeed() + session.cycle);
                        // Logger.log("-- fall speed " + session.fallSpeed + " [cycle] (" + Date.now() + ")");

                        for (item in grid.getAll())
                        {
                            if (item.entity != null)
                            {
                                item.entity.color = Palette.DarkBlue;
                            }
                        }

                        for (item in grid.getAll())
                        {
                            if (item.entity != null)
                            {
                                FlxTween.color(item.entity, 0.25, Palette.DarkBlue, 0xFFFFFFFF, {startDelay: 1, ease : FlxEase.sineInOut});
                            }
                        }

                        // Change the side/theme on each clean
                        if (shallChangeBackground == NoChange || shallChangeBackground == ChangeTheme)
                            shallChangeBackground = ChangeSide;
                        else
                            shallChangeBackground = ChangeTheme;

                        aftermathTimer.start(0.01, doThemeChange);
                        /*aftermathTimer.start(2.5, function(_) {
                            switchState(StateGenerate);
                        });*/
                    });

                    return;
                }
            }

            // Go on
            if (aftermathScoreCounter >= 0)
                switchState(StateGenerate);
        }
    }

    function checkForThemeChange() : Bool
    {
        var themeChange : Bool = (session.timesIncreased % 8 == 0);
        var sideChange : Bool = (session.timesIncreased % 4 == 0);

        if (themeChange || sideChange)
        {
            var changeText : String = (themeChange ? "TO NEW LOCATION!!!" : "MOVING FORWARD!!!MOVING FORWARD     ");
            topDisplay.showMessage(24, changeText, 0xFF2ce8f5);
            aftermathTimer.start(ThemeChangeDelay, doThemeChange);
        }

        if (themeChange)
            shallChangeBackground = ChangeTheme;
        else if (sideChange)
            shallChangeBackground = ChangeSide;
        else
            shallChangeBackground = NoChange;


        return (themeChange || sideChange);
    }

    function doThemeChange(_) {
        // Do other things like change graphic set?
        if (shallChangeBackground == ChangeTheme)
        {
            // Each 8 times, new background
            handleThemeBackgroundChange(true);
            flixel.effects.FlxFlicker.flicker(fxBg, ThemeChangeDelay, true, function(_) {
                aftermathTimer.start(ThemeChangeDelay, function(_) {
                    // session.fallSpeed = Math.max(session.fallSpeed - 2, getInitialFallSpeed() + session.timesIncreased / 4);
                    if (mode == Constants.ModeEndless)
                        session.fallSpeed -= 8;
                    else
                        session.fallSpeed = getInitialFallSpeed() + 2*session.cycle;
                    Logger.log("-- fall speed " + session.fallSpeed + " [theme] (" + Date.now() + ")");

                    if (mode == Constants.ModeEndless)
                        switchState(StateGenerate);
                    else
                        highlightTargets();
                });
            });
        }
        else if (shallChangeBackground == ChangeSide)
        {
            // Each 4 times, alt bg
            handleThemeSideChange();
            flixel.effects.FlxFlicker.flicker(fxBg, ThemeChangeDelay, true, function(_) {
                aftermathTimer.start(ThemeChangeDelay, function(_) {
                    // session.fallSpeed = Math.max(session.fallSpeed - 1, getInitialFallSpeed() + session.timesIncreased / 2);
                    if (mode == Constants.ModeEndless)
                        session.fallSpeed -= 4;
                    else
                        session.fallSpeed = getInitialFallSpeed() + 2*session.cycle;
                    Logger.log("-- fall speed " + session.fallSpeed + " [side] (" + Date.now() + ")");

                    if (mode == Constants.ModeEndless)
                        switchState(StateGenerate);
                    else
                        highlightTargets();
                });
            });
        }
    }

    function highlightTargets()
    {
        // Find targets
        var targets : Array<ItemData> = grid.getAll(ItemData.IsTargetFilter);
        for (target in targets)
        {
            // Flash them white? Scale them?
            highlightTarget(target.entity);
        }

        new FlxTimer().start(1, function(_) {
            // After that
            switchState(StateGenerate);
        });
    }

    function highlightTarget(target : ItemEntity, ?times : Int = 2)
    {
        var duration : Float = 0.125;
        if (times > 0 && target != null)
        {
            target.scale.set(0.9, 0.9);
            FlxTween.tween(target.scale, {x: 1.1, y: 1.1}, duration, {ease: FlxEase.circOut, startDelay: 0.1, onComplete: function(_) {
                highlightTarget(target, times-1);
            }});
        }
        else
        {
            new FlxTimer().start(0.05, function(_){
                target.scale.set(1, 1);
            });
        }
    }

    function handleThemeSideChange()
    {
        background.loadGraphic(ThemeManager.GetBackground(theme, ThemeManager.SideB));
    }

    function handleThemeBackgroundChange(cycleTheme : Bool)
    {
        if (cycleTheme)
        {
            theme = theme+1;
            if (theme > 2)
                theme = 1;
        }

        background.loadGraphic(ThemeManager.GetBackground(theme, ThemeManager.SideA));
        if (theme == ThemeManager.ThemeOcean)
        {
            fxBg.effectsEnabled = true;
            fxBg.x = -2;
        }
        else
        {
            fxBg.effectsEnabled = false;
            fxBg.x = 0;
        }
    }

    public function onAftermathFinished()
    {
        switchState(StateGenerate);
    }

    function checkForLoseConditions(currentItem : ItemEntity) : Bool
    {
        return grid.checkForItemsOnTopRows();
    }

    function onGameoverTimer(t:FlxTimer)
    {
        if (!gameoverLightsout)
        {
            var color : Int = Palette.DarkBlue;

            gameoverLightsout = true;
            for (item in grid.getAll())
            {
                if (item.entity != null)
                {
                    item.entity.color = color;
                }
            }
            if (nextItem != null)
            {
                nextItem.color = color;
                if (nextItem.slave != null)
                    nextItem.slave.color = color;
            }

            if (currentItem != null)
            {
                currentItem.color = color;
                if (currentItem.slave != null)
                    currentItem.slave.color = color;
            }

            gridShader.alpha = 0.8;

            gameoverTimer.start(GameoverLightsoutDelay, onGameoverTimer);
        }
        else
        {
            DataServiceClient.SendSessionData(GameSettings.data, session);
            gameoverTimer.start(GameoverLightsoutDelay, function(t:FlxTimer) {
                FlxG.camera.fade(0xFF000000, GameoverLightsoutDelay * 2, false, function() {
                    GameController.GameOver(GameSettings.data.mode, session);
                });
            });
        }
    }

    function showGameOverNotification()
    {
        topDisplay.showMessage(96, "!ERROR!", Palette.Red, showGameOverNotification);
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

    public function getFallSpeed() : Float
    {
        return session.fallSpeed;
    }

    function setupInitialGrid(intensity : Int)
    {
        // Intensity 1-4
        var rows : Int = Std.int(Math.abs(1 - intensity));
        if (intensity == 0)
            rows = 0;

        for (i in 0...rows)
        {
            generateRow(grid.rows-1-i);
        }
    }

    function setupCycleGrid()
    {
        emptyGrid();

        var rows : Int = getTreasureRows(session.cycle);
        var targets : Int = getTreasureTargets(session.cycle);

        for (i in 0...rows)
        {
            generateRow(grid.rows-1-i);
        }

        for (i in 0...targets)
        {
            generateTarget(rows);
        }
    }

    function setupStoredGrid(data : GarbageGrid.GarbageGridData)
    {

    }

    function emptyGrid()
    {
        for (item in grid.getAll())
        {
            if (item.entity != null)
            {
                items.remove(item.entity);
                item.entity.kill();
                item.entity.destroy();
            }
        }

        grid.clear();
    }

    function generateRow(row : Int)
    {
        var surrounding : Array<Int> = [];
        for (col in 0...grid.columns)
        {
            var entity : ItemEntity = null;
            var type : Int = -1;
            surrounding = grid.getSurroundingTypes(col, row);
            while (type == -1 || surrounding.indexOf(type) >= 0)
            {
                 type = getInitialCharType();
            }

            var pos : FlxPoint = grid.getCellPosition(col, row);
            entity = new ItemEntity(pos.x, pos.y, type, this);
            items.add(entity);

            grid.set(col, row, new ItemData(col, row, type, entity));
        }
    }

    function generateTarget(rows : Int)
    {
        var tries : Int = 100;

        // Get random position not touching other target
        var surrounding : Array<Int> = [ItemData.SpecialTarget];
        var cellX : Int = -1;
        var cellY : Int = -1;
        while (tries > 0 && surrounding.indexOf(ItemData.SpecialTarget) > -1)
        {
            cellX = FlxG.random.int(0, grid.columns-1);
            // Avoid generating in the top row (too easy)
            cellY = FlxG.random.int(grid.rows - rows + 1, grid.rows-1);
            surrounding = grid.getSurroundingTypes(cellX, cellY);
            tries--;
        }

        // Remove previous item
        var item : ItemData = grid.get(cellX, cellY);
        items.remove(item.entity);
        item.entity.destroy();

        var pos : FlxPoint = grid.getCellPosition(cellX, cellY);
        var entity : ItemEntity = new ItemEntity(pos.x, pos.y, ItemData.SpecialTarget, this);
        items.add(entity);

        grid.set(cellX, cellY, new ItemData(cellX, cellY, ItemData.SpecialTarget, entity));
    }

    function getTreasureRows(cycle : Int) : Int
    {
        if (cycle >= 12)
            return 5;
        else if (cycle >= 8)
            return 4;
        else if (cycle >= 4)
            return 3;
        else
            return 2;
    }

    function getTreasureTargets(cycle : Int) : Int
    {
        return (Std.int(cycle / 4) + cycle % 4 + 1);
    }

    public function onDeactivate()
    {
        switch (state)
        {
            case PlayState.StateIntro,
                 PlayState.StateGenerate,
                 PlayState.StateWait,
                 PlayState.StateAftermath:
                SaveStateManager.savePlayStateData(this);
            case PlayState.StateLost:
                GameController.ProcessGameoverData(GameSettings.data.mode, session);
        }
    }

    /* DEBUG */

    function handleDebug()
    {
        if (FlxG.keys.justPressed.TAB)
        {
            debugEnabled = !debugEnabled;
            stateLabel.visible = debugEnabled;
            gridDebugger.visible = debugEnabled;
        }

        // if (debugEnabled)
        {
            if (FlxG.keys.justPressed.I)
            {
                trace("Increasing items to " + (session.items+5));
                session.items += 5;
                aftermathScoreCounter = -1;
                handleAftermathResult();
            }
        }
    }
}
