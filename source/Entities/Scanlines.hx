package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;

class Scanlines extends FlxObject
{
    var scanlines : FlxEffectSprite;
	var ScanlinesGlitchDelay : Float = 5;
    var ScanlinesGlitchVariation : Float = 0.2;
    var scanlinesGlitchTimer : FlxTimer;

    public function new(X : Float, Y : Float, Graphic : String, ?Color : Int = 0xFFFFFFFF)
    {
        super(0, 0);

        var _vcrOverlay : FlxSprite = new FlxSprite(X, Y, Graphic);
        _vcrOverlay.alpha = 0.184;
        _vcrOverlay.color = Color;

        scanlines = new FlxEffectSprite(_vcrOverlay);
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

    override public function update(elapsed : Float)
    {
        scanlines.update(elapsed);
        super.update(elapsed);
    }

    override public function draw()
    {
        scanlines.draw();
        super.draw();
    }
}
