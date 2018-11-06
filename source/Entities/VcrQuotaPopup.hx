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

        quotaDelta = 5; // data.quotaDelta;
        quotaTotal = data.previousQuota;

        background = new FlxSprite(X, Y, "assets/ui/gameover-popup-bg.png");
        add(background);

        background.scale.y = 0;

        callback = Callback;

        SfxEngine.play(SfxEngine.SFX.PauseStart);

        FlxTween.tween(background.scale, {y: 1}, DisplayAnimTime, {ease : FlxEase.circOut, onComplete: onDisplayAnimFinished});

        finished = false;
    }

    function onDisplayAnimFinished(t : FlxTween)
    {
        t.destroy();

        var th : Int = 12;

        add(quotaLabel = text.VcrText.New(x + 9 + 9*8, y + 3*th, "" + quotaDelta));

        // Slave quota
        add(currentLabel = text.VcrText.New(x + 54, y + 54, "" + quotaTotal));
        add(text.VcrText.New(x+117, y+54, "" + ProgressData.data.quota_target));

        // Progress bar
        var width : Int = 128;
        progressBar = new FlxSprite(x+26, y+71);
        progressBar.makeGraphic(width, 14, 0x00000000);
        add(progressBar);

        var addedQuota : Int = quotaTotal + quotaDelta;
        FlxTween.tween(this, {quotaDelta: 0, quotaTotal: addedQuota}, QuotaIncreaseTime * (quotaDelta < 10 ? 0.2 : 1),
                    {startDelay : QuotaIncreaseDelay,
                        ease : FlxEase.sineInOut, onComplete: onQuotaIncreased, onStart: function(_) {
                            if (quotaDelta > 0)
                            {
                                SfxEngine.play(SfxEngine.SFX.FlipRaddishA, true);
                            }
                        }
                    });
    }

    function onQuotaIncreased(t : FlxTween)
    {
        if (finished)
            return;

        SfxEngine.stop(SfxEngine.SFX.FlipRaddishA);

        // Check if quota reached...
        if (quotaTotal > ProgressData.data.quota_target)
        {
            var achievedLabel : FlxSprite = new FlxSprite(x+17, y+89, "assets/ui/gameover-popup-quotareached.png");
            add(achievedLabel);
            flixel.effects.FlxFlicker.flicker(achievedLabel, 0, 0.5, true);

            SfxEngine.play(SfxEngine.SFX.QuotaPopupFanfare);
        }

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

        SfxEngine.play(SfxEngine.SFX.PauseEnd);

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
                currentLabel.text = text.TextUtils.padWith("" + Std.int(quotaTotal), 4, " ");

                FlxSpriteUtil.fill(progressBar, 0x00000000);
                var width : Int = Std.int(progressBar.width);
                FlxSpriteUtil.drawRect(progressBar, 1, 1, Std.int((quotaTotal / ProgressData.data.quota_target) * width), 12, 0xFFFFFFFF);
            }
        }

        super.update(elapsed);
    }
}
