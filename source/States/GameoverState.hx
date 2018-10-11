package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxSpriteUtil;

class GameoverState extends GarbageState
{
    var session : PlaySessionData.GameOverData;

    var screen : FlxSprite;
    var currentSessionText : FlxBitmapText;
    var highScoreText : FlxBitmapText;
    var highScoreLabelGroup : FlxGroup;

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
        currentSessionText = text.PixelText.New(18, 146, "", Palette.Yellow);
        add(currentSessionText);

        highScoreText = text.PixelText.New(18, 146 + 5*8, "", Palette.Yellow);
        add(highScoreText);

        highScoreLabelGroup = new FlxGroup();
        add(highScoreLabelGroup);

        var endless : Bool = GameSettings.data.mode == Constants.ModeEndless;

        if (session != null)
        {
            var dtext : String = currentSessionText.text;
            dtext += "Today's " + (endless ? "Production" : "Refinement") + "\n";
            dtext += "==================\n";
            if (endless)
            {
                dtext += "# Processed: " + text.TextUtils.padWith("" + session.session.items, 5, " ") + "\n";
                dtext += "# Rating: "    + text.TextUtils.padWith("" + session.session.score, 8, " ") + "\n\n";
            }
            else
            {
                dtext += "# Cycles:    " + text.TextUtils.padWith("" + session.session.cycle, 5, " ") + "\n\n";
            }

            currentSessionText.text = dtext;
        }

        // Top producers
        {
            var gotHighScore : Bool = false;

            if (endless)
                gotHighScore = (session.session.score >= ProgressData.data.endless_high_score);
            else
                gotHighScore = (session.session.cycle >= ProgressData.data.treasure_high_cycles);

            var dtext : String = "";
            dtext += "TOP " + (endless ? "PRODUCER" : "REFINER") + "\n";// " " + (gotHighScore ? "!YOU!" : "     ") + "\n";
            dtext += "==================\n";
            if (gotHighScore)
            {
                showHighScoreLabel();
                highScoreText.color = Palette.Green;
            }

            if (endless)
            {
                dtext += "# Rating: " +    text.TextUtils.padWith("" + ProgressData.data.endless_high_score, 8, " ") + "\n";
            }
            else
            {
                dtext += "# Cycles:    " + text.TextUtils.padWith("" + ProgressData.data.treasure_high_cycles, 5, " ") + "\n";
            }

            highScoreText.text = dtext;
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

    function showHighScoreLabel()
    {
        highScoreLabelGroup.add(new TextNotice(18 + 13*8, 146 + 5*8, "!YOU!", Palette.Green, false, showHighScoreLabel));
    }

    function onPopupClosed()
    {
        if (popup != null)
        {
            popup.kill();
            popup.destroy();
        }

        againButton = new VcrButton(Constants.Width - 8 - 64, 36 + 47, onAgainHighlighted, onAgainPressed);
        againButton.loadSpritesheet("assets/ui/gameover-btn-again.png", 64, 14);
        add(againButton);

        backButton = new VcrButton(8, 36 + 47, onBackHighlighted, onBackPressed);
        backButton.loadSpritesheet("assets/ui/title-menu-back.png", 56, 14);
        add(backButton);
    }

    function onBackHighlighted()
    {
        againButton.clearHighlight();
    }

    function onAgainHighlighted()
    {
        backButton.clearHighlight();
    }

    function onAgainPressed()
    {
        GameController.StartGameplay();
    }

    function onBackPressed()
    {
        GameController.ToMenu(true);
    }
}
