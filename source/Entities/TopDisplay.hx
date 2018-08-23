package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;

class TopDisplay extends FlxGroup
{
    var world : PlayState;

    var background : FlxSprite;
    var belts : FlxGroup;
    var items : FlxGroup;
    var topFrame : FlxSprite;

    var scoreLabel : FlxBitmapText;
    var bottomLabel : ScrollingLabel;

    var baseBeltY : Float;

    var beltShakeTimer : FlxTimer;
    var BeltShakeTime : Float = 0.05;
    var BeltShakeVariation : Float = 0.0;

    var processingQueue : Array<ProcessingItem>;

    var BeltSpeed : Float = 6;

    public function new(World : PlayState)
    {
        super();

        world = World;

        var bgColor : Int = 0xFF3f2832;
        background = new FlxSprite(0, 0).makeGraphic(Constants.Width, 80, bgColor);
        add(background);

        // Screen Background
        add(new FlxSprite(16, 10).makeGraphic(148, 30, 0xFF262b44));

        belts = new FlxGroup();
        add(belts);

        items = new FlxGroup();
        add(items);

        baseBeltY = 62;
        for (i in 0...3)
        {
            var belt = new FlxSprite(-32 + (i*80), baseBeltY + FlxG.random.int(0, 0));
            belt.loadGraphic("assets/images/belt-sheet.png", true, 80, 8);
            belt.animation.add("go", [0, 1, 2], 4, true);
            belt.animation.play("go");
            belts.add(belt);
        }
        beltShakeTimer = new FlxTimer();
        onBeltShakeTimer(beltShakeTimer);

        add(new FlxSprite(24, 16, "assets/ui/rating-marker.png"));
        scoreLabel = text.PixelText.New(48, 16, " 9999", 0xFFFFFFFF);
        add(scoreLabel);

        bottomLabel = new ScrollingLabel(20, 24, 18, "PRODUCTION IS OK", 0xFFFEE761);
        add(bottomLabel);

        topFrame = new FlxSprite(0, 0, "assets/ui/gameplay-ui-top.png");
        add(topFrame);

        processingQueue = [];
    }

    override public function update(elapsed : Float)
    {
        if (processingQueue.length > 0 && thereIsRoomForNewItem())
        {
            var next : ProcessingItem = processingQueue.shift();
            next.startMoving(BeltSpeed, function(item : ProcessingItem) {
                items.remove(item);
            });
            items.add(next);
        }

        scoreLabel.text = text.TextUtils.padWith(""+world.session.score, 5, " ");

        // DEBUG: Bottom label queue density
        var itemsInBelt : Int = items.countLiving();
        if (itemsInBelt >= 10)
            bottomLabel.setText("PRODUCTION IS AS EXPECTED");
        else if (itemsInBelt >= 6)
            bottomLabel.setText("PRODUCTION IS AVERAGE");
        else if (itemsInBelt >= 4)
            bottomLabel.setText("PRODUCTION IS LOW");
        else
            bottomLabel.setText("PRODUCTION IS UNACCEPTABLE");

        super.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
    }

    public function addItem(charType : Int)
    {
        var item : ProcessingItem = new ProcessingItem(-16, 46, charType);
        processingQueue.push(item);
    }

    function thereIsRoomForNewItem() : Bool
    {
        var iterator = items.iterator();
        var item : ProcessingItem = null;
        while (iterator.hasNext())
        {
            var next : FlxBasic = iterator.next();
            if (next != null)
            {
                item = cast(next, ProcessingItem);
                if (item.x <= 0)
                    return false;
            }
        }

        return true;
    }

    function onBeltShakeTimer(t:FlxTimer)
    {
        // Disable this for now
        return;
        belts.forEachAlive(function(beltBasic : FlxBasic) {
            var belt : FlxSprite = cast(beltBasic, FlxSprite);

            if (belt.y == baseBeltY)
                belt.y += 0.5;
            else
                belt.y -= 0.5;
        });

        var time : Float = BeltShakeTime * 1+(FlxG.random.float(-BeltShakeVariation, BeltShakeVariation));
        beltShakeTimer.start(time, onBeltShakeTimer);
    }
}
