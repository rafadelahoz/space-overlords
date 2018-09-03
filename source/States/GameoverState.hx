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

        if (session != null)
        {
            var dtext : String = displayText.text;
            dtext += "Today's Production\n";
            dtext += "==================\n";
            dtext += "# Processed: " + text.TextUtils.padWith("" + session.session.items, 5, " ") + "\n";
            dtext += "# Rating: "    + text.TextUtils.padWith("" + session.session.score, 8, " ") + "\n";

            displayText.text = dtext;
        }

        // Top producers
        {
            var gotHighScore : Bool = ProgressData.data.high_score == session.session.score;
            var dtext : String = displayText.text;
            dtext += "\nTOP  PRODUCER  \n";
            dtext += (gotHighScore ? "!" : "#") + " " +
                    text.TextUtils.padWith("" + ProgressData.data.high_score, 8, " ") +
                    "-" + text.TextUtils.padWith("" + ProgressData.data.high_items, 5, " ") +
                    (gotHighScore ? "!" : "#") + " ";
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
