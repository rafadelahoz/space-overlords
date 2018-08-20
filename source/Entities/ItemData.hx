package;

class ItemData
{
    public var type : Int;
    public var entity : ItemEntity;

    public function new(Type : Int, ?Entity : ItemEntity = null)
    {
        type = Type;
        entity = Entity;
    }
}
