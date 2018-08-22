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

    public function findMatches(?baseCell : FlxPoint = null) : Array<ItemData>
    {
        var matches : Array<ItemData> = [];

        // Avoid using the single cell + slave approach for now
        /*if (baseCell != null)
        {
            matches = findMatchesFromBaseCell(baseCell);
        }
        else
        {*/
            matches = findBoardMatches();
        //}

        return matches;
    }

    @Deprecated
    public function findMatchesFromBaseCell(baseCell : FlxPoint) : Array<ItemData>
    {
        var matches : Array<ItemData> = [];

        // baseCell and cell top of baseCell will be checked
        matches = findMatchesFromCell(baseCell.x, baseCell.y);
        var slaveMatches : Array<ItemData> = findMatchesFromCell(baseCell.x, baseCell.y-1);

        for (cell in slaveMatches)
        {
            if (matches.indexOf(cell) < 0)
            {
                matches.push(cell);
            }
        }

        return matches;
    }

    function findBoardMatches() : Array<ItemData>
    {
        var matches : Array<ItemData> = [];

        var all : Array<ItemData> = getAll();
        var singleCellMatches : Array<ItemData> = null;
        for (each in all)
        {
            singleCellMatches = findMatchesFromCell(each.cellX, each.cellY);
            for (cell in singleCellMatches)
            {
                if (matches.indexOf(cell) < 0)
                {
                    matches.push(cell);
                }
            }
        }

        return matches;
    }

    function findMatchesFromCell(col : Float, row : Float) : Array<ItemData>
    {
        var matches : Array<ItemData> = [];

        var baseCol : Int = Std.int(col);
        var baseRow : Int = Std.int(row);

        if (get(baseCol, baseRow) == null)
        {
            throw "Nothing found at " + baseCol + ", " + baseRow;
        }

        var target : Int = get(baseCol, baseRow).type;

        var cell : ItemData = null;

        // Check rightwards
        var col : Int = baseCol+1;
        while (col < columns)
        {
            cell = get(col, baseRow);
            if (cell != null && cell.type == target)
            {
                matches.push(get(col, baseRow));
                col += 1;
            }
            else
                break;
        }

        // Leftwards
        col = baseCol-1;
        while (col >= 0)
        {
            cell = get(col, baseRow);
            if (cell != null && cell.type == target)
            {
                matches.push(get(col, baseRow));
                col -= 1;
            }
            else
                break;
        }

        // Downwards
        var row : Int = baseRow+1;
        while (row < rows)
        {
            cell = get(baseCol, row);
            if (cell != null && cell.type == target)
            {
                matches.push(get(baseCol, row));
                row += 1;
            }
            else
                break;
        }

        // Upwards
        row = baseRow-1;
        while (row >= 2)
        {
            cell = get(baseCol, row);
            if (cell != null && cell.type == target)
            {
                matches.push(get(baseCol, row));
                row -= 1;
            }
            else
                break;
        }

        // If there have been matches, add the current cell
        if (matches.length > 0)
        {
            matches.push(get(baseCol, baseRow));
        }

        return matches;
    }

    public function getLowerFreeCellFrom(cellX : Float, cellY : Float) : FlxPoint
    {
        var col : Int = Std.int(cellX);
        var row : Int = Std.int(cellY);

        while (row < rows)
        {
            row += 1;
            if (get(cellX, row) != null || !isCellValid(cellX, row))
            {
                row -= 1;
                break;
            }
        }

        return new FlxPoint(col, row);
    }

    public function getAll() : Array<ItemData>
    {
        var all : Array<ItemData> = [];

        var col = -1;
        var row = rows-1;
        while (row >= 0)
        {
            col = 0;
            while (col < columns)
            {
                if (get(col, row) != null)
                    all.push(get(col, row));
                col += 1;
            }

            row -= 1;
        }

        return all;
    }

    public function checkForItemsOnTopRows() : Bool
    {
        for (row in 0...1)
        {
            for (col in 0...columns)
            {
                if (get(col, row) != null)
                    return true;
            }
        }

        return false;
    }

    /* DEBUG */
    public function dump()
    {
        var str = "";

        for (row in 0...rows)
        {
            for (col in 0...columns)
            {
                var item : ItemData = get(col, row);
                if (item == null)
                    str += "[ ]";
                else
                    str += "[" + item.type + "]";
            }

            str += "\n";

            // Start zone delimiter
            if (row == 1)
            {
                for (i in 0...columns)
                    str += "---";
                str += "\n";
            }
        }

        trace(str);
    }
}
