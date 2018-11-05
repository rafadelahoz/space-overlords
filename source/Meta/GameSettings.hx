package;

import flixel.util.FlxSave;

class GameSettings
{
    static var savefile : String = "gamesettings";
    public static var data : GameSettingsData;

    public static function Init()
    {
        if (data == null)
        {
            // Try to load
            data = loadSaveData();

            // If not present, initialize
            if (data == null)
            {
                data = {
                    mode : Constants.ModeEndless,
                    intensity : 0,
                    bgm : 0,
                };
            }

            var currentBgm : Null<Int> = data.bgm;
            if (currentBgm == null)
                data.bgm = 0;
        }
    }

    static function loadSaveData() : GameSettingsData
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        if (save.data.save_data_present)
            return save.data.save_data;
        else
            return null;
    }

    public static function Save()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        save.data.save_data_present = true;
        save.data.save_data = data;

        save.close();
    }
}

typedef GameSettingsData = {
    var mode : Int;
    var intensity : Int;
    var bgm : Int;
};
