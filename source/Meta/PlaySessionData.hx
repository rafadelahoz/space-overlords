package;

class PlaySessionData
{
    public var score : Int;
    public var items : Int;

    public var cycle : Int;

    public var fallSpeed : Float;
    public var lastItemsSpeedIncrease : Int;
    public var timesIncreased : Int;

    public var startTime : Float;
    public var endTime : Float;

    public function new(?Score : Int = 0, ?Items : Int = 0)
    {
        score = Score;
        items = Items;

        cycle = 0;

        fallSpeed = 0;
        lastItemsSpeedIncrease = 0;
        timesIncreased = 0;

        startTime = Date.now().getTime();
        endTime = -1;
    }
}

class GameOverData
{
    public var session : PlaySessionData;

    public var previousQuota : Int;
    public var currentQuota : Int;
    public var quotaDelta : Int;

    public function new(Session : PlaySessionData)
    {
        session = Session;
    }
}
