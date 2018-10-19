package;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class VcrResumePopup extends FlxGroup
{
    var OpenTime : Float = 0.3;

    var x : Float;
    var y : Float;

    var background : FlxSprite;

    var callback : Void -> Void;

    var finished : Bool;

    public function new(Callback : Void -> Void)
    {
        super();

        x = 0;
        y = 96;

        callback = Callback;

        background = new FlxSprite(x, y, "assets/ui/session-restore-background.png");
        background.scale.y = 0;
        add(background);

        var slaveNumber : flixel.text.FlxBitmapText = text.VcrText.New(x + 70, y + 32, text.TextUtils.padWith("" + ProgressData.data.slave_id, 7, "0"));
        add(slaveNumber);

        finished = false;

        FlxTween.tween(background.scale, {y: 1}, OpenTime, {ease : FlxEase.sineInOut, onComplete: buildScreen});
    }

    function buildScreen(t : FlxTween)
    {
        t.destroy();

        // close, ok button, etc
        var okButton : VcrButton = new VcrButton(x+70, y+107, null, closePopup);
        okButton.loadSpritesheet("assets/ui/gameover-popup-ok.png", 35, 14);
        add(okButton);
    }

    function closePopup()
    {
        if (finished)
            return;

        finished = true;

        forEachExists(function(basic : FlxBasic) {
            if (basic != background)
            {
                remove(basic);
                // basic.destroy();
            }
        });

        FlxTween.tween(background.scale, {y : 0}, OpenTime, {ease : FlxEase.sineInOut, onComplete: function(t:FlxTween) {
            t.destroy();
            if (callback != null)
                callback();
        }});
    }
}
