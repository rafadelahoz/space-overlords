package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;

class Scanlines extends FlxObject
{
    var background : FlxSprite;
    var scanlines : FlxEffectSprite;
    var vcrOverlay : FlxSprite;
	var ScanlinesGlitchDelay : Float = 5;
    var ScanlinesGlitchVariation : Float = 0.2;
    var scanlinesGlitchTimer : FlxTimer;

    public function new(X : Float, Y : Float, Graphic : String, ?Color : Int = 0xFFFFFFFF)
    {
        super(0, 0);

        vcrOverlay = new FlxSprite(X, Y, Graphic);
        vcrOverlay.alpha = 0.184;
        vcrOverlay.color = Color;

        background = new FlxSprite(X, Y).makeGraphic(Std.int(vcrOverlay.width), Std.int(vcrOverlay.height), Palette.DarkBlue);
        background.visible = false;

        scanlines = new FlxEffectSprite(vcrOverlay);
        scanlines.setPosition(X, Y);

        var _glitch : FlxGlitchEffect = null;
        scanlines.effects = [_glitch = new FlxGlitchEffect(1, 1, 0.1)];
        _glitch.direction = FlxGlitchDirection.VERTICAL;
        scanlines.effectsEnabled = false;

        scanlinesGlitchTimer = new FlxTimer();
        scanlinesGlitchTimer.start(ScanlinesGlitchDelay*(1+FlxG.random.float(-ScanlinesGlitchVariation, ScanlinesGlitchVariation)), onScanlinesGlitchTimer);
    }

    function onScanlinesGlitchTimer(t:FlxTimer)
    {
        if (scanlines.effectsEnabled)
        {
            scanlines.effectsEnabled = false;
            scanlinesGlitchTimer.start(ScanlinesGlitchDelay*(1+FlxG.random.float(-ScanlinesGlitchVariation, ScanlinesGlitchVariation)), onScanlinesGlitchTimer);
        }
        else
        {
            scanlines.effectsEnabled = true;
            scanlinesGlitchTimer.start(FlxG.random.float(0.1, 0.5), onScanlinesGlitchTimer);
        }
    }

    public function off()
    {
        background.visible = true;
        background.alpha = 1;
        scanlines.effectsEnabled = false;
        scanlinesGlitchTimer.active = false;
    }

    public function on()
    {
        flixel.effects.FlxFlicker.flicker(background);
        flixel.tweens.FlxTween.tween(background, {alpha: 0}, 1, {startDelay: 0.5, ease: flixel.tweens.FlxEase.elasticInOut});
        scanlinesGlitchTimer.active = true;
    }

    override public function update(elapsed : Float)
    {
        scanlines.update(elapsed);
        super.update(elapsed);
    }

    override public function draw()
    {
        if (background.visible)
            background.draw();
        scanlines.draw();
        super.draw();
    }
}
