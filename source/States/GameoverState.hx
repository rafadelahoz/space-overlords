package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.util.FlxSpriteUtil;

class GameoverState extends GarbageState
{
    var session : PlaySessionData.GameOverData;

    var screen : FlxSprite;
    var displayText : FlxBitmapText;

    var touchArea : TouchArea;
    var popup : VcrQuotaPopup;

    var backButton : VcrButton;
    var againButton : VcrButton;

    override public function new(Session : PlaySessionData.GameOverData)
    {
        super();

        session = Session;
    }

    override public function create()
    {
        FlxG.camera.bgColor = 0xFF0000FF;

        add(new FlxSprite(0, 0, "assets/backgrounds/bgGameOver.png"));

        add(text.PixelText.New(18, 130, "SESSION TERMINATED\n", Palette.Red));
        displayText = text.PixelText.New(18, 146, "", Palette.Yellow);
        add(displayText);

        var endless : Bool = GameSettings.data.mode == Constants.ModeEndless;
        var highScore = (endless ? ProgressData.data.endless_high_score : ProgressData.data.treasure_high_score);

        if (session != null)
        {
            var dtext : String = displayText.text;
            dtext += "Today's " + (endless ? "Production" : "Refinement") + "\n";
            dtext += "==================\n";
            if (endless)
                dtext += "# Processed: " + text.TextUtils.padWith("" + session.session.items, 5, " ") + "\n";
            else
                dtext += "# Cycles:    " + text.TextUtils.padWith("" + session.session.cycle, 5, " ") + "\n";
            dtext +=     "# Rating: "    + text.TextUtils.padWith("" + session.session.score, 8, " ") + "\n\n";

            displayText.text = dtext;
        }

        // Top producers
        {
            var gotHighScore : Bool = highScore == session.session.score;
            var dtext : String = displayText.text;
            dtext += "TOP PRODUCER " + (gotHighScore ? "!YOU!" : "     ") + "\n";
            if (endless)
                dtext += "# Processed: " + text.TextUtils.padWith("" + ProgressData.data.endless_high_items, 5, " ") + "\n";
            else
                dtext += "# Cycles:    " + text.TextUtils.padWith("" + ProgressData.data.treasure_high_cycles, 5, " ") + "\n";
            dtext += "# Rating: " +    text.TextUtils.padWith("" + highScore, 8, " ") + "\n";
            displayText.text = dtext;
        }

        // Add slave
        add(new SlaveCharacter(Constants.Width, 235, this, SlaveCharacter.StateLeft));

        // Header
        add(new FlxSprite(0, 0, "assets/ui/title-menu-header.png"));
        var baseY : Float = 36;

        var logo : FlxSprite = new FlxSprite(0, baseY, "assets/ui/gameover-main.png");
        add(logo);

        var slaveNumber : FlxBitmapText = text.VcrText.New(107, baseY+24, text.TextUtils.padWith("" + ProgressData.data.slave_id, 7, "0"));
        add(slaveNumber);

        add(new VcrClock());

        // VCR effect
        add(new Scanlines(0, 0, "assets/ui/vcr-overlay.png"));

        touchArea = new TouchArea(0, 0, Constants.Width, Constants.Height, function() {
            touchArea.kill();
            remove(touchArea);
            add(popup = new VcrQuotaPopup(0, Constants.Height * 0.3, session, onPopupClosed));
        });
        add(touchArea);
    }

    function onPopupClosed()
    {
        if (popup != null)
        {
            popup.kill();
            popup.destroy();
        }

        /*againButton = new VcrButton(8, 36 + 47, onBackHighlighted, onBackPressed);
        againButton.loadSpritesheet("assets/ui/title-menu-back.png", 56, 14);
        add(againButton);*/

        backButton = new VcrButton(8, 36 + 47, onBackHighlighted, onBackPressed);
        backButton.loadSpritesheet("assets/ui/title-menu-back.png", 56, 14);
        add(backButton);
    }

    function onBackHighlighted()
    {
        // againButton.clearHighlight...
    }

    function onBackPressed()
    {
        GameController.ToMenu(true);
    }
}
