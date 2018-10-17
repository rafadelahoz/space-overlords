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
                    uuid: null,

                    slave_count: -1,
                    slave_id : -1,
                    slave_head : -1, slave_detail: -1, slave_color: -1,

                    quota_current : -1, quota_target : -1,
                    endless_high_score : -1, endless_high_items : -1,
                    treasure_high_cycles: -1, treasure_high_score: -1
                }
            }
        }
    }

    public static function StartNewGame()
    {
        data.slave_count = 1;

        // Set the quota
        data.quota_target = 1000;
        data.quota_current = 0;

        // Set the first high score
        data.endless_high_score = 3600;
        data.endless_high_items = 28;

        data.treasure_high_cycles = 5;
        data.treasure_high_score = 1500;

        Save();
    }

    public static function GenerateUUID()
    {
        data.uuid = UUID.uuid();
    }

    public static function GenerateNewSlave()
    {
        // Generate a new slave
        new SlaveGenerator().generate(data);

        // Set the quota
        data.quota_target = 1000; // Std.int(Math.min(data.slave_count*250, 1000));
        data.quota_current = 0;

        Save();
    }

    public static function OnSlaveRewarded()
    {
        data.slave_id = -1;
        data.slave_count++;

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
    var uuid : String;

    var slave_count : Int;

    var slave_id : Int;

    var slave_head: Int;
    var slave_detail: Int;
    var slave_color: Int;

    var quota_current: Int;
    var quota_target : Int;
    // TODO: quotas_met (progress...)

    var endless_high_score : Int;
    var endless_high_items : Int;

    var treasure_high_score : Int;
    var treasure_high_cycles: Int;

    // TODO: Museum...?
};
