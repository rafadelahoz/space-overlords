package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.util.FlxSpriteUtil;

class GameoverState extends GarbageState
{
    var session : PlaySessionData;

    var screen : FlxSprite;
    var displayText : FlxBitmapText;
    var progressBar : FlxSprite;

    override public function new(Session : PlaySessionData)
    {
        super();

        session = Session;
    }

    override public function create()
    {
        FlxG.camera.bgColor = 0xFF0000FF;

        var floor : FlxSprite = new FlxSprite(4, Constants.Height * 0.8);
        floor.makeGraphic(Constants.Width-8, 1, Palette.DarkGray);
        add(floor);

        // Draw a simple screen
        screen = new FlxSprite(8, Constants.Height * 0.25);
        screen.makeGraphic(Constants.Width - 16, Std.int(Constants.Height * 0.3), 0x00000000);
        FlxSpriteUtil.drawRoundRect(screen, 0, 0, screen.width, screen.height, 4, 4, Palette.LightGray);
        FlxSpriteUtil.drawRoundRect(screen, 4, 4, screen.width-8, screen.height-8, 4, 4, Palette.DarkBlue);
        add(screen);

        add(text.PixelText.New(screen.x+10, screen.y+8, "SESSION TERMINATED\n", Palette.Red));
        displayText = text.PixelText.New(screen.x+10, screen.y+24, "", Palette.Yellow);
        add(displayText);

        if (session != null)
        {
            var dtext : String = displayText.text;
            dtext += "Today's Production\n";
            dtext += "==================\n";
            dtext += "# Processed: " + text.TextUtils.padWith("" + session.items, 5, " ") + "\n";
            dtext += "# Rating: "    + text.TextUtils.padWith("" + session.score, 8, " ") + "\n";

            displayText.text = dtext;
        }

        // Top producers
        {
            var gotHighScore : Bool = ProgressData.data.high_score == session.score;
            var dtext : String = displayText.text;
            dtext += "\nTOP  PRODUCER  \n";
            dtext += (gotHighScore ? "!" : "#") + " " +
                    text.TextUtils.padWith("" + ProgressData.data.high_score, 8, " ") +
                    "-" + text.TextUtils.padWith("" + ProgressData.data.high_items, 5, " ") +
                    (gotHighScore ? "!" : "#") + " ";
            displayText.text = dtext;
        }

        // Slave quota
        add(text.PixelText.New(screen.x, screen.y + screen.height + 16, "SLAVE " + ProgressData.data.slave_id + " QUOTA", 0xFFFFFFFF));
        // Progress bar
        var width : Int = Std.int(screen.width * 0.77);
        progressBar = new FlxSprite(Constants.Width/2 - width/2, screen.y + screen.height + 30);
        progressBar.makeGraphic(width, 16, 0x00000000);
        FlxSpriteUtil.drawRect(progressBar, 0, 0, Std.int(width), 16, 0xFFFFFFFF);
        FlxSpriteUtil.drawRect(progressBar, 1, 1, Std.int(width-2), 14, 0xFF000000);
        FlxSpriteUtil.drawRect(progressBar, 1, 1, Std.int(width*0.3), 14, 0xFFFFFFFF);
        add(progressBar);

        // Header
        add(new FlxSprite(0, 0, "assets/ui/title-menu-header.png"));
        var baseY : Float = 36;
        // TODO: Use another header
        var logo : FlxSprite = new FlxSprite(0, baseY, "assets/ui/cell-menu-main.png");
        add(logo);

        var touchArea : TouchArea = new TouchArea(0, 0, Constants.Width, Constants.Height, function() {
            GameController.ToMenu();
        });
        add(touchArea);
    }
}
