package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import text.PixelText;

class MenuState extends GarbageState
{
	public var tween : FlxTween;

	var touchLabel : FlxBitmapText;
	var yearsLabel : FlxBitmapText;
	var creditsLabel : FlxBitmapText;
	var background : FlxSprite;
	var backgroundShader : FlxSprite;

	var startTouchZone : FlxObject;

	var interactable : Bool;

	var stars : flixel.addons.display.FlxStarField.FlxStarField2D;

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

		var startText : String = "Touch to start";
		touchLabel = PixelText.New(Constants.Width / 2 - (startText.length/2)*8, Std.int(Constants.Height - Constants.Height/4), startText);
		touchLabel.alpha = 0;
		add(touchLabel);

		var vcrOverlay : FlxSprite = new FlxSprite(0, 0, "assets/ui/vcr-overlay.png");
		vcrOverlay.alpha = 0.184;
		add(vcrOverlay);

		var startDelay : Float = 0.35;
		tween = FlxTween.tween(logo, {y : 0}, 0.75, {startDelay: startDelay, onComplete: onLogoPositioned, ease : FlxEase.quartOut });
		FlxG.camera.scroll.set(0, 0);
	}

	public function onLogoPositioned(_t:FlxTween):Void
	{
		interactable = true;

		startTouchZone = new FlxObject(0, 160, Constants.Width, 120);
		add(startTouchZone);

		FlxTween.tween(touchLabel, {alpha : 1}, 1, {ease : FlxEase.cubeInOut});
		startTouchBuzz(null);
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
		if (touchLabel.color != 0xFFFFEC27)
		{
			touchLabel.color = 0xFFFFEC27;
			touchLabel.x += 2;
			touchLabel.y += 2;
			// Testing screenshots on mobile
			// Screenshot.take();
		}
	}

	function onTouchLabelReleased()
	{
		// animation.play("idle");
		if (touchLabel.color != 0xFFFFFFFF)
		{
			touchLabel.color = 0xFFFFFFFF;
			touchLabel.x -= 2;
			touchLabel.y -= 2;
		}
	}

	public function onArcadeButtonPressed() : Void
	{
		FlxG.camera.fade(0xFF000000, 0.5, false, function() {
			GameController.StartEndless();
		});
	}
}
