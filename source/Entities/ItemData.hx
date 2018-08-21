package;

class ItemData
{
    public var type : Int;
    public var entity : ItemEntity;

    public var cellX : Int;
    public var cellY : Int;

    public function new(CellX : Float, CellY : Float, Type : Int, ?Entity : ItemEntity = null)
    {
        cellX = Std.int(CellX);
        cellY = Std.int(CellY);
        type = Type;
        entity = Entity;
    }
}
