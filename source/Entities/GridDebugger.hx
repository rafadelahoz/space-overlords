package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxBitmapText;

class GridDebugger extends FlxSprite
{
    var grid : GarbageGrid;

    var mousePos : FlxPoint;
    var mouseCell : FlxPoint;

    var infoLabel : FlxBitmapText;

    public function new(Grid : GarbageGrid)
    {
        super(0, 0);
        grid = Grid;

        infoLabel = text.PixelText.New(Constants.Width-72, 32, "");

        makeGraphic(Constants.Width, Constants.Height, 0x00000000);
    }

    override public function update(elapsed : Float)
    {
        mousePos = FlxG.mouse.getPosition();
        mouseCell = grid.getCellAt(mousePos.x, mousePos.y);

        infoLabel.text = Std.int(mouseCell.x) + ", " + Std.int(mouseCell.y);

        if (mousePos.x > grid.x && mousePos.y > grid.y &&
            mousePos.x < grid.x + grid.columns * Constants.TileSize &&
            mousePos.y < grid.x + grid.rows * Constants.TileSize)
        {
            if (FlxG.mouse.justPressed)
            {
                grid.set(mouseCell.x, mouseCell.y, new ItemData(mouseCell.x, mouseCell.y, 0, null));
            }
        }

        infoLabel.update(elapsed);

        super.update(elapsed);
    }

    override public function draw()
    {
        FlxSpriteUtil.fill(this, 0x00000000);
        FlxSpriteUtil.drawRect(this, grid.x, grid.y, grid.columns * Constants.TileSize, grid.rows * Constants.TileSize, Palette.Black, {thickness: 2, color: Palette.LightGray});

        // Separator line?
        // FlxSpriteUtil.drawRect(this, grid.x, grid.y + 2 * Constants.TileSize, grid.columns * Constants.TileSize, 4, Palette.Green, {thickness: 2, color: Palette.Red});

        var pos : FlxPoint = null;
        for (c in 0...grid.columns)
            for (r in 0...grid.rows)
            {
                pos = grid.getCellPosition(c, r);
                var tileColor : Int = grid.get(c, r) == null ? Palette.Black : Palette.DarkBlue;
                var borderColor : Int = (c == mouseCell.x && r == mouseCell.y) ? Palette.Yellow : Palette.DarkGray;

                FlxSpriteUtil.drawRect(this, pos.x, pos.y, Constants.TileSize, Constants.TileSize, tileColor, {color: borderColor});
            }

        super.draw();

        infoLabel.draw();
    }
}
