package;

import flixel.util.FlxSave;

class ProgressData
{
    static var savefile : String = "savefile";
    public static var data : SaveData;

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
                    slave_id : -1,
                    slave_head : -1, slave_detail: -1, slave_color: -1,

                    quota_current : -1, quota_target : -1,
                    high_score : -1, high_items : -1
                }
            }
        }
    }

    public static function StartNewGame()
    {
        // Generate a new slave
        new SlaveGenerator().generate(data);

        // Set the quota
        data.quota_target = 1000;
        data.quota_current = 0;

        // Set the first high score
        data.high_score = 3600;
        data.high_items = 28;

        Save();
    }

    static function loadSaveData()
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

typedef SaveData = {
    var slave_id : Int;

    var slave_head: Int;
    var slave_detail: Int;
    var slave_color: Int;

    var quota_current: Int;
    var quota_target : Int;
    // TODO: quotas_met (progress...)

    var high_score : Int;
    var high_items : Int;

    // TODO: Museum...?
};
