package text;

class TextUtils
{
    /* Pads the provided string with the given character */
	public static function padWith(string : String, length : Int, ?char : String = " ") : String
	{
		while (string.length < length)
		{
			string = char + string;
		}

		return string;
	}

	static var MAX_TIME : UInt = 3599999;

    public static function formatTime(seconds : UInt) : String
    {
		if (seconds > MAX_TIME)
			seconds = MAX_TIME;

		var str : String = "";
        var minutes = Std.int(seconds / 60);
		var hours = Std.int(minutes / 60);
		minutes = minutes % 60;
		seconds = seconds % 60;

        if (hours > 0)
            str += hours + ":";
        if (minutes > 0 || hours > 0)
            str += padWith("" + minutes, 2, "0") + ":";
        str += padWith("" + seconds, 2, "0") + "\"";

        return str;
    }
}
