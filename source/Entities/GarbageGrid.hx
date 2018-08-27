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

    public function checkTriggers() : Array<TriggerData>
    {
        var list : Array<TriggerData> = [];

        var triggers : Array<ItemData> = getAll(ItemData.IsTriggerFilter);
        var triggerData : TriggerData = null;
        for (trigger in triggers)
        {
            var matches : Array<ItemData> = findMatchesFromCell(trigger.cellX, trigger.cellY, triggerMatch);
            if (matches.length > 0)
            {
                // Flood for chemdusts
                for (match in matches)
                {
                    if (match.type == ItemData.SpecialChemdust)
                    {
                        mergeArrays(matches, floodMatch(match, matches));
                    }
                }
                
                triggerData = new TriggerData(trigger.cellX, trigger.cellY, trigger.type, trigger.entity);
                triggerData.setTriggeredEntities(matches);
                list.push(triggerData);
            }
        }

        return list;
    }

    function mergeArrays(aa : Array<ItemData>, bb : Array<ItemData>)
    {
        for (b in bb)
        {
            if (aa.indexOf(b) < 0)
                aa.push(b);
        }
    }

    function floodMatch(item : ItemData, flooded : Array<ItemData>) : Array<ItemData>
    {
        if (flooded == null)
            flooded = [];

        // Check all sides and flood
        var other : ItemData = null;

        var others = [get(item.cellX-1, item.cellY), get(item.cellX+1, item.cellY),
                      get(item.cellX, item.cellY-1), get(item.cellX, item.cellY+1)];
        for (other in others)
        {
            if (other != null && flooded.indexOf(other) < 0 && other.type == item.type)
            {
                flooded.push(other);
                mergeArrays(flooded, floodMatch(other, flooded));
            }
        }

        return flooded;
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

    function findMatchesFromCell(col : Float, row : Float, ?matcher : ItemData -> ItemData -> Bool = null) : Array<ItemData>
    {
        var matches : Array<ItemData> = [];

        if (matcher == null)
            matcher = cellsMatch;

        var baseCol : Int = Std.int(col);
        var baseRow : Int = Std.int(row);

        if (get(baseCol, baseRow) == null)
        {
            throw "Nothing found at " + baseCol + ", " + baseRow;
        }

        var target : ItemData = get(baseCol, baseRow);

        var cell : ItemData = null;

        // Check rightwards
        var col : Int = baseCol+1;
        while (col < columns)
        {
            cell = get(col, baseRow);
            if (matcher(cell, target))
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
            if (matcher(cell, target))
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
            if (matcher(cell, target))
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
            if (matcher(cell, target))
            {
                matches.push(get(baseCol, row));
                row -= 1;
            }
            else
                break;
        }

        // For the default match method,
        // if there have been matches, add the current cell
        if (matches.length > 0 && matcher == cellsMatch)
        {
            matches.push(get(baseCol, baseRow));
        }

        return matches;
    }

    function cellsMatch(cellA : ItemData, cellB : ItemData) : Bool
    {
        var match : Bool = false;
        if (cellA != null && cellB != null)
        {
            if (!ItemData.IsCharTypeSpecial(cellA.type) && !ItemData.IsCharTypeSpecial(cellB.type)) {
                match = cellA.type == cellB.type;
            }
            else
            {
                // Special items cases
                if (cellA.type == cellB.type && (cellA.type == ItemData.SpecialTrigger || cellA.type == ItemData.SpecialBomb))
                {
                    match = true;
                }
            }
        }

        return match;
    }

    function triggerMatch(cellA : ItemData, trigger : ItemData) : Bool
    {
        var match : Bool = false;

        if (trigger != null && cellA != null)
        {
            if (cellA.type == ItemData.SpecialChemdust || cellA.type == ItemData.SpecialBomb)
            {
                match = true;
            }
        }

        return match;
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

    public function getAll(?filter : ItemData -> Bool = null) : Array<ItemData>
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
                {
                    if (filter == null || (filter(get(col, row))))
                        all.push(get(col, row));
                }
                col += 1;
            }

            row -= 1;
        }

        return all;
    }

    public function checkForItemsOnTopRows() : Bool
    {
        for (row in 0...2)
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
