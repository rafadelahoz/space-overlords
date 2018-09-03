package;

class ItemData
{
    public static var SpecialChemdust : Int = 24;
    public static var SpecialTrigger : Int = 25;
    public static var SpecialBomb : Int = 26;
    public static var SpecialTarget : Int = 27;

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

    public static function IsCharTypeSpecial(charType : Int)
    {
        return charType < 1 || charType > 8;
    }

    public static function IsTriggerFilter(item : ItemData) : Bool
    {
        return (item != null && item.type == SpecialTrigger);
    }
}
