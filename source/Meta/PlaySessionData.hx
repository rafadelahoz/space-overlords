package;

class PlaySessionData
{
    public var score : Int;
    public var items : Int;

    public var fallSpeed : Float;
    public var lastItemsSpeedIncrease : Int;

    public function new()
    {
        score = 0;
        items = 0;

        fallSpeed = 0;
        lastItemsSpeedIncrease = 0;
    }
}
