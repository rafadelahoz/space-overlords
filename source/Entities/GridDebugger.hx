package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxBitmapText;
import flixel.group.FlxGroup;

class GridDebugger extends FlxGroup
{
    var world : PlayState;

    var grid : GarbageGrid;

    var mousePos : FlxPoint;
    var mouseCell : FlxPoint;

    var canvas : FlxSprite;
    var infoLabel : FlxBitmapText;

    var currentType : Int;

    var buttonsBaseX : Int;
    var buttonsBaseY : Int;

    public function new(World : PlayState)
    {
        super();

        world = World;
        grid = world.grid;

        canvas = new FlxSprite(0, 0);
        canvas.makeGraphic(Constants.Width, Constants.Height, 0x00000000);
        add(canvas);

        add(infoLabel = text.PixelText.New(Constants.Width-56, 180, ""));

        buttonsBaseX = Std.int(grid.x+grid.columns*Constants.TileSize+8);
        buttonsBaseY = 196;

        for (type in 1...9)
        {
            createTypeButton(buttonsBaseX + Std.int((type-1)/2)*16,
                             buttonsBaseY + (type & 1 == 1 ? 0 : 16), type);
        }
        for (type in 24...27)
            createTypeButton(buttonsBaseX + (type-24)*16, buttonsBaseY - 32, type);

        currentType = 1;
    }

    function createTypeButton(X : Float, Y : Float, Type : Int)
    {
        var image : FlxSprite = new FlxSprite(X, Y);
        if (Type > 0 && Type < 9)
        {
            image.loadGraphic("assets/images/pieces.png", true, 16, 16);
            image.animation.add("button", [Type-1]);
            image.animation.play("button");
        }
        else if (Type ==  ItemData.SpecialChemdust)
        {
            image.loadGraphic("assets/images/special-0.png", true, 18, 18);
            image.animation.add("idle", [0]);

            image.offset.set(1, 1);
            image.animation.play("idle");
        }
        else if (Type == ItemData.SpecialTrigger)
        {
            image.makeGraphic(Constants.TileSize, Constants.TileSize, 0x00000000, true);
            flixel.util.FlxSpriteUtil.drawTriangle(image, 0, 0, 16, Palette.Yellow, {thickness: 1, color: Palette.White});
        }
        else if (Type == ItemData.SpecialBomb)
        {
            image.makeGraphic(Constants.TileSize, Constants.TileSize, 0x00000000, true);
            flixel.util.FlxSpriteUtil.drawCircle(image, 8, 8, 6, Palette.Green, {thickness: 1, color: Palette.White});
        }

        add(image);

        var type : Int = Type;
        var touchArea : TouchArea = new TouchArea(X, Y, Constants.TileSize, Constants.TileSize, function() {
            trace(type);
            currentType = type;
        });
        add(touchArea);
    }

    override public function update(elapsed : Float)
    {
        mousePos = FlxG.mouse.getPosition();
        mouseCell = grid.getCellAt(mousePos.x, mousePos.y);

        infoLabel.text = Std.int(mouseCell.x) + ", " + Std.int(mouseCell.y);

        if (world.debugEnabled)
        {
            if (grid.isCellValid(mouseCell.x, mouseCell.y)) {
                if (FlxG.mouse.justPressed)
                {
                    spawn(mouseCell, currentType);
                }
            }
        }

        super.update(elapsed);
    }

    function spawn(cell : FlxPoint, type : Int)
    {
        trace("spawn", cell, type);
        if (grid.get(cell.x, cell.y) != null)
        {
            trace("Removing previous tenant of cell", cell);
            type = -1;
            if (grid.get(cell.x, cell.y).entity != null)
            {
                world.items.remove(grid.get(cell.x, cell.y).entity);
                grid.get(cell.x, cell.y).entity.triggerLeave();
            }

            grid.set(cell.x, cell.y, null);
        }
        else
        {
            trace("Creating new item at cell", cell);
            var entity : ItemEntity = null;
            if (type > 0)
            {
                var pos : FlxPoint = grid.getCellPosition(cell.x, cell.y);
                entity = new ItemEntity(pos.x, pos.y, type, world);
                world.items.add(entity);
            }

            grid.set(cell.x, cell.y, new ItemData(cell.x, cell.y, type, entity));
        }
    }

    override public function draw()
    {
        FlxSpriteUtil.fill(canvas, 0x00000000);

        var pos : FlxPoint = null;
        for (c in 0...grid.columns)
            for (r in 0...grid.rows)
            {
                pos = grid.getCellPosition(c, r);
                var tileColor : Int = grid.get(c, r) == null ? 0x00000000 : Palette.DarkBlue;
                var borderColor : Int = (c == mouseCell.x && r == mouseCell.y) ? Palette.Yellow : 0x00000000;

                FlxSpriteUtil.drawRect(canvas, pos.x, pos.y, Constants.TileSize, Constants.TileSize, tileColor, {color: borderColor});
            }

        if (currentType > 0 && currentType < 9)
        {
            var bgColor : Int = 0x00000000;
            FlxSpriteUtil.drawRect(canvas,
                (buttonsBaseX + Std.int((currentType-1)/2)*16),
                buttonsBaseY + (currentType & 1 == 1 ? 0 : 16),
                Constants.TileSize, Constants.TileSize, bgColor,
                {color: Palette.Yellow});
        }
        else if (currentType >= 24 && currentType <= 26)
        {
            var bgColor : Int = 0x00000000;
            FlxSpriteUtil.drawRect(canvas,
                (buttonsBaseX + (currentType-24)*16),
                buttonsBaseY - 32,
                Constants.TileSize, Constants.TileSize, bgColor,
                {color: Palette.Yellow});
        }

        // FlxSpriteUtil.drawRect(this, grid.x, grid.y, grid.columns * Constants.TileSize, grid.rows * Constants.TileSize, 0x00000000, {thickness: 2, color: Palette.White});

        // Separator line?
        // FlxSpriteUtil.drawRect(this, grid.x, grid.y + 2 * Constants.TileSize, grid.columns * Constants.TileSize, 4, Palette.Green, {thickness: 2, color: Palette.Red});
        // FlxSpriteUtil.drawLine(this, grid.x, grid.y + 2*Constants.TileSize - 1, grid.x + grid.columns * Constants.TileSize, grid.y + 2*Constants.TileSize - 1, {thickness: 2, color: Palette.White});

        super.draw();

        // infoLabel.draw();
    }
}
