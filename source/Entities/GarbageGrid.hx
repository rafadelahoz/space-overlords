package;

import flixel.math.FlxPoint;

class GarbageGrid
{
    public var columns : Int = 6;
    public var rows : Int = 9;

    public var data : Array<Array<ItemData>>;

    public var x : Float;
    public var y : Float;

    public function new(X : Float, Y : Float)
    {
        x = X;
        y = Y;

        data = [];
    }

    public function init()
    {
        for (c in 0...columns)
        {
            data[c] = [];
            for (r in 0...rows)
            {
                data[c][r] = null;
            }
        }
    }

    public function get(Column : Float, Row : Float)
    {
        if (isCellValid(Std.int(Column), Std.int(Row)))
        {
            return data[Std.int(Column)][Std.int(Row)];
        }

        return null;
    }

    public function set(Column : Float, Row : Float, ?item : ItemData = null)
    {
        if (isCellValid(Std.int(Column), Std.int(Row)))
        {
            data[Std.int(Column)][Std.int(Row)] = item;
        }
        else
        {
            Logger.log("Setting invalid position " + Column + ", " + Row + " with data: " + item);
        }
    }

    public function clear()
    {
        for (c in 0...columns)
        {
            for (r in 0...rows)
            {
                data[c][r] = null;
            }
        }
    }

    public function isCellValid(Column : Float, Row : Float)
    {
        return Column >= 0 && Column < columns && Row >= 0 && Row < rows;
    }

    public function getCellAt(PosX : Float, PosY : Float) : FlxPoint
    {
        var cell : FlxPoint = new FlxPoint(0, 0);

        cell.x = Std.int((PosX - x) / Constants.TileSize);
        cell.y = Std.int((PosY - y) / Constants.TileSize);

        return cell;
    }

    public function getCellPosition(Column : Float, Row : Float) : FlxPoint
    {
        var point : FlxPoint = new FlxPoint(0, 0);
        point.set(x + Column * Constants.TileSize, y + Row * Constants.TileSize);
        return point;
    }
}
