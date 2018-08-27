package;

class TriggerData extends ItemData
{
    var triggeredEntities : Array<ItemData>;

    public function new(CellX : Float, CellY : Float, Type : Int, ?Entity : ItemEntity = null)
    {
        super(CellX, CellY, Type, Entity);
        triggeredEntities = [];
    }

    public function setTriggeredEntities(list : Array<ItemData>)
    {
        triggeredEntities = list;
    }

    public function getTriggeredEntities()
    {
        return triggeredEntities;
    }
}
