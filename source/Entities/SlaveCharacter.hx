package;

import flixel.FlxG;
import flixel.FlxSprite;

class SlaveCharacter extends FlxSprite
{
    var world : MenuState;

    var head : FlxSprite;
    var detail : FlxSprite;

    public function new(X : Float, Y : Float, World : MenuState)
    {
        super(X, Y);

        world = World;

        handleGraphic();
    }

    function handleGraphic()
    {
        var animSpeed : Int = 6;

        loadGraphic("assets/images/slave-body-sheet.png", true, 32, 40);
        animation.add("walk", [0, 1, 2, 3], animSpeed, true);
        animation.play("walk");

        var headType : Int = FlxG.random.int(0, 1);
        head = new FlxSprite(x, y);
        head.loadGraphic("assets/images/slave-head-sheet.png", true, 32, 40);
        head.animation.add("walk", [headType*4+0, headType*4+1, headType*4+2, headType*4+3], animSpeed, true);
        head.animation.play("walk");

        var detailType : Int = FlxG.random.int(0, 2);
        detail = new FlxSprite(x, y);
        detail.loadGraphic("assets/images/slave-detail-sheet.png", true, 32, 40);
        detail.animation.add("walk", [detailType*4+0, detailType*4+1, detailType*4+2, detailType*4+3], animSpeed, true);
        detail.animation.play("walk");

        var tintColor : Int = FlxG.random.getObject([0xFFFFFFFF, Palette.Red, Palette.Green, Palette.Blue]);
        color = tintColor;
        head.color = tintColor;
        // detail.color = tintColor;
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);
        head.update(elapsed);
        detail.update(elapsed);

        head.setPosition(x, y);
        detail.setPosition(x, y);
    }

    override public function draw()
    {
        super.draw();
        head.draw();
        detail.draw();
    }
}
