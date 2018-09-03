package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class VcrQuotaPopup extends FlxGroup
{
    var DisplayAnimTime : Float = 0.25;
    var QuotaIncreaseTime : Float = 0.75;
    var QuotaIncreaseDelay : Float = 0.5;

    var x : Float;
    var y : Float;

    var background : FlxSprite;
    var quotaLabel : FlxBitmapText;
    var currentLabel : FlxBitmapText;
    var progressBar : FlxSprite;

    var data : PlaySessionData.GameOverData;

    var quotaDelta : Int;
    var quotaTotal : Int;

    var callback : Void -> Void;

    var finished : Bool;

    public function new(X : Float, Y : Float, Data : PlaySessionData.GameOverData, Callback : Void -> Void)
    {
        super();

        x = X;
        y = Y;

        data = Data;

        quotaDelta = data.quotaDelta;
        quotaTotal = data.previousQuota;

        background = new FlxSprite(X, Y);
        background.makeGraphic(Constants.Width, 120, Palette.Red);
        add(background);

        background.scale.y = 0;

        callback = Callback;

        FlxTween.tween(background.scale, {y: 1}, DisplayAnimTime, {ease : FlxEase.circOut, onComplete: onDisplayAnimFinished});

        finished = false;
    }

    function onDisplayAnimFinished(t : FlxTween)
    {
        t.destroy();

        var th : Int = 12;

        add(text.PixelText.New(x + 9, y + 1*th, "PROGRESS ASSESSMENT"));
        add(text.PixelText.New(x + 9, y + 3*th, "QUOTA: + "));
        add(quotaLabel = text.PixelText.New(x + 9 + 9*8, y + 3*th, "" + quotaDelta));

        // Slave quota
        add(text.PixelText.New(x+9, y + 4*th, "CURR: "));
        add(currentLabel = text.PixelText.New(x + 9 + 6*9, y + 4*th, quotaTotal + " / " + ProgressData.data.quota_target));
        // Progress bar
        var width : Int = Std.int(10*th);
        progressBar = new FlxSprite(Constants.Width/2 - width/2, y + 6*th);
        progressBar.makeGraphic(width, 14, 0x00000000);
        FlxSpriteUtil.drawRect(progressBar, 0, 0, Std.int(width), 14, 0xFFFFFFFF);
        FlxSpriteUtil.drawRect(progressBar, 1, 1, Std.int(width-2), 12, 0xFF000000);
        FlxSpriteUtil.drawRect(progressBar, 1, 1, Std.int(width*0.3), 12, 0xFFFFFFFF);
        add(progressBar);

        var addedQuota : Int = quotaTotal + quotaDelta;
        FlxTween.tween(this, {quotaDelta: 0, quotaTotal: addedQuota}, QuotaIncreaseTime, {startDelay : QuotaIncreaseDelay,
                        ease : FlxEase.sineInOut, onComplete: onQuotaIncreased});
    }

    function onQuotaIncreased(t : FlxTween)
    {
        if (finished)
            return;

        // Check if quota reached...
        if (quotaTotal > ProgressData.data.quota_target)
        {
            var achievedLabel : FlxBitmapText = text.PixelText.New(Constants.Width/2 - 8*9, y + 8*12, "! QUOTA REACHED !");
            var bg : FlxSprite = new FlxSprite(achievedLabel.x - 1, achievedLabel.y - 1);
            bg.makeGraphic(Std.int(achievedLabel.width+2), Std.int(achievedLabel.height+2), 0xFF0000FF);
            add(bg);
            add(achievedLabel);
            flixel.effects.FlxFlicker.flicker(bg, 0, 0.5, true);
            flixel.effects.FlxFlicker.flicker(achievedLabel, 0, 0.5, true);
        }

        // close, ok button, etc
        add(text.PixelText.New(Constants.Width/2 - 18, y + 9*12, "<OK>"));
        var touchArea : TouchArea = new TouchArea(Constants.Width/2 - 18, y + 9*12, 9*4, 12, closePopup);
        add(touchArea);
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

        FlxTween.tween(background.scale, {y : 0}, DisplayAnimTime, {ease : FlxEase.sineInOut, onComplete: function(t:FlxTween) {
            t.destroy();
            if (callback != null)
                callback();
        }});
    }

    override public function update(elapsed : Float)
    {
        if (!finished)
        {
            if (quotaLabel != null)
            {
                quotaLabel.text = "" + Std.int(quotaDelta);
                currentLabel.text = Std.int(quotaTotal) + " / " + Std.int(ProgressData.data.quota_target);

                FlxSpriteUtil.fill(progressBar, 0x00000000);
                var width : Int = Std.int(progressBar.width);
                FlxSpriteUtil.drawRect(progressBar, 0, 0, Std.int(width), 14, 0xFFFFFFFF);
                FlxSpriteUtil.drawRect(progressBar, 1, 1, Std.int(width-2), 12, 0xFF000000);
                FlxSpriteUtil.drawRect(progressBar, 1, 1, Std.int((quotaTotal / ProgressData.data.quota_target) * width), 12, 0xFFFFFFFF);
            }
        }

        super.update(elapsed);
    }
}
