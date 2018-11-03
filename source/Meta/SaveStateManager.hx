package;

import flixel.util.FlxSave;

class SaveStateManager
{
    static var savefile : String = "savestate";

    public static function savestateExists() : Bool
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);
        var exists : Bool = (save.data.active == 1);
        save.close();

        return exists;
    }

    public static function loadAndErase() : Dynamic
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        var data : Dynamic = null;

        if (save.data.active == 1)
        {
            // Read data
            data = {
                session: save.data.session,
                grid: save.data.grid,
                theme: save.data.theme,
                side: save.data.side
            };
        }

        // Clear data
        save.data.active = 0;
        save.data.session = null;
        save.data.grid = null;
        save.data.theme = -1;
        save.data.side = -1;

        save.close();

        return data;
    }

    public static function savePlayStateData(state : PlayState)
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        var sessionData : PlaySessionData = state.session;
        var gridData : GarbageGrid.GarbageGridData = state.grid.getSaveData();

        save.data.active = 1;
        save.data.session = sessionData;
        save.data.grid = gridData;
        save.data.theme = state.theme;
        save.data.side = state.side;

        save.close();
    }
}
