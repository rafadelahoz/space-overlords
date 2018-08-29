package;

class PlaySessionData
{
    public var score : Int;
    public var items : Int;

    public var fallSpeed : Float;
    public var lastItemsSpeedIncrease : Int;

    public function new(?Score : Int = 0, ?Items : Int = 0)
    {
        score = Score;
        items = Items;

        fallSpeed = 0;
        lastItemsSpeedIncrease = 0;
    }
}
