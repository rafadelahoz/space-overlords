package;

import flixel.FlxG;

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

    public static function Random() : PlaySessionData
    {
        var data : PlaySessionData = new PlaySessionData();
        data.cycle = FlxG.random.int(0, 20);
        data.endTime = Date.now().getTime() + FlxG.random.int(60, 500);
        data.startTime = Date.now().getTime();
        data.fallSpeed = FlxG.random.int(12, 25);
        data.items = FlxG.random.int(10, 600);
        data.lastItemsSpeedIncrease = 0;
        data.score = FlxG.random.int(20, 26000);
        data.timesIncreased = FlxG.random.int(1, 20);

        return data;
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
