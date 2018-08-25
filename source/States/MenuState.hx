package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;

import text.PixelText;

class MenuState extends GarbageState
{
	public var tween : FlxTween;

	var touchLabel : FlxSprite;
	var yearsLabel : FlxBitmapText;
	var creditsLabel : FlxBitmapText;
	var background : FlxSprite;
	var backgroundShader : FlxSprite;

	var startTouchZone : FlxObject;

	var interactable : Bool;

	var stars : flixel.addons.display.FlxStarField.FlxStarField2D;

    var scanlines : FlxEffectSprite;
	var ScanlinesGlitchDelay : Float = 5;
    var ScanlinesGlitchVariation : Float = 0.2;
    var scanlinesGlitchTimer : FlxTimer;

	var startLabelBackground : FlxSprite;

	override public function create():Void
	{
		super.create();

		// Missing a preloader
		BgmEngine.init();
		SfxEngine.init();

		GameController.Init();

		// Set scale mode?

		interactable = false;

		FlxG.camera.fade(0xFF000000, 1, true);

		bgColor = 0xFF000000;

		stars = new flixel.addons.display.FlxStarField.FlxStarField2D(32, 184, 23, 22, 4);
		stars.starVelocityOffset.set(0.0125, 0);
		add(stars);

		background = new FlxSprite(0, 0, "assets/backgrounds/bgCell.png");
		add(background);

		var slaveNumberBg : FlxSprite = new FlxSprite(57, 33).makeGraphic(117, 14, 0xFF9e2835);
		add(slaveNumberBg);

		var logo : FlxSprite = new FlxSprite(0, 0, "assets/ui/title.png");
		add(logo);

		var bottom : FlxSprite = new FlxSprite(0, Constants.Height-42, "assets/ui/title-bottom.png");
		add(bottom);

		var slaveNumber : FlxBitmapText = text.VcrText.New(111, 34, text.TextUtils.padWith("" + FlxG.random.int(1, 9999999), 7, "0"));
		add(slaveNumber);

		startLabelBackground = new FlxSprite(27, 88).makeGraphic(141, 16, 0xFF9e2835);
		startLabelBackground.visible = false;
		add(startLabelBackground);

		touchLabel = new FlxSprite(0, 72, "assets/ui/tmp-start-label.png");
		touchLabel.alpha = 0;
		add(touchLabel);

		// VCR effect
			var _vcrOverlay : FlxSprite = new FlxSprite(0, 0, "assets/ui/vcr-overlay.png");
			_vcrOverlay.alpha = 0.184;

			scanlines = new FlxEffectSprite(_vcrOverlay);

			var _glitch : FlxGlitchEffect = null;
	        scanlines.effects = [_glitch = new FlxGlitchEffect(1, 1, 0.1)];
	        _glitch.direction = FlxGlitchDirection.VERTICAL;
	        scanlines.effectsEnabled = false;

	        add(scanlines);

			scanlinesGlitchTimer = new FlxTimer();
	        scanlinesGlitchTimer.start(ScanlinesGlitchDelay*(1+FlxG.random.float(-ScanlinesGlitchVariation, ScanlinesGlitchVariation)), onScanlinesGlitchTimer);

		var startDelay : Float = 0.35;
		tween = FlxTween.tween(logo, {y : 0}, 0.75, {startDelay: startDelay, onComplete: onLogoPositioned, ease : FlxEase.quartOut });
		FlxG.camera.scroll.set(0, 0);
	}

	public function onLogoPositioned(_t:FlxTween):Void
	{
		interactable = true;

		startTouchZone = new FlxObject(0, 72, Constants.Width, 32);
		add(startTouchZone);

		FlxTween.tween(touchLabel, {alpha : 1}, 0.2, {ease : FlxEase.bounceInOut});
		// startTouchBuzz(null);
	}

	function startTouchBuzz(_t:FlxTween)
	{
		var touchLabelBaseY = touchLabel.y;
		FlxTween.tween(touchLabel, {y : touchLabelBaseY-4}, 0.2, {ease: FlxEase.circOut, startDelay: 2, onComplete: continueTouchBuzz});
	}

	function continueTouchBuzz(_t:FlxTween)
	{
		var touchLabelBaseY = touchLabel.y;
		FlxTween.tween(touchLabel, {y : touchLabelBaseY+4}, 0.5, {ease: FlxEase.elasticOut, onComplete: startTouchBuzz});
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.O)
			Screenshot.take();

		if (interactable)
		{
			#if (!mobile)
			if (startTouchZone.getHitbox().containsPoint(FlxG.mouse.getPosition()))
			{
		        if (FlxG.mouse.pressed)
		        {
					onTouchLabelPressed();
		        }
		        else if (FlxG.mouse.justReleased)
		        {
		            onTouchLabelReleased();
					onArcadeButtonPressed();
		        }
			}
	        #else
	        for (touch in FlxG.touches.list)
			{
	            if (touch.overlaps(startTouchZone))
	            {
	    			if (touch.pressed)
	    			{
	    				onTouchLabelPressed();
	                }
	                else if (touch.justReleased)
	                {
	                    onTouchLabelReleased();
	                    onArcadeButtonPressed();
	                    break ;
	                }
	            }
				else if (touchLabel.color != 0xFFFFFFFF)
				{
					if (touch.justReleased)
	                {
						onTouchLabelReleased();
	                    break ;
	                }
				}
	        }
	        #end
		}

		super.update(elapsed);
	}

	function onTouchLabelPressed()
	{
		// animation.play("pressed");
		/*if (touchLabel.color != 0xFFFFEC27)
		{
			touchLabel.color = 0xFFFFEC27;
			touchLabel.x += 2;
			touchLabel.y += 2;
			// Testing screenshots on mobile
			// Screenshot.take();
		}*/

		startLabelBackground.visible = true;
	}

	function onTouchLabelReleased()
	{
		// animation.play("idle");
		/*if (touchLabel.color != 0xFFFFFFFF)
		{
			touchLabel.color = 0xFFFFFFFF;
			touchLabel.x -= 2;
			touchLabel.y -= 2;
		}*/

		startLabelBackground.visible = false;
	}

	public function onArcadeButtonPressed() : Void
	{
		FlxG.camera.fade(0xFF000000, 0.5, false, function() {
			GameController.StartEndless();
		});
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
}
