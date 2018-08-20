package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;

enum SFX {
    None;
    Click;
    Accept;
}

class SfxEngine
{
    static var path : String = "assets/sounds/";

    public static var Enabled : Bool = true;

    static var initialized : Bool = false;

    static var sfx : Map<SFX, FlxSound>;
    static var sfxFiles : Map<SFX, String>;

    public static function init()
    {
        if (initialized)
            return;

        // trace("SFX ENGINE INIT");

        load();

        initialized = true;

        sfxFiles = new Map<SFX, String>();
        sfxFiles.set(SFX.Click,          path + "btn_click.wav");
        sfxFiles.set(SFX.Accept,         path + "accept.wav");

        sfx = new Map<SFX, FlxSound>();
        for (sf in sfxFiles.keys())
        {
            sfx.set(sf, loadSfx(sfxFiles.get(sf)));
        }

        for (sf in sfx.keys())
        {
            sfx.get(sf).persist = true;
        }
    }

    static function loadSfx(name : String) : FlxSound
    {
        return FlxG.sound.load(name);
    }

    public static function enable()
    {
        Enabled = true;
        save();
    }

    public static function disable()
    {
        stopAll();

        Enabled = false;
        save();
    }

    public static function play(sf : SFX, ?volume : Float = 1, ?loop : Bool = false)
    {
        if (Enabled && sfx.exists(sf))
        {
            sfx.set(sf, FlxG.sound.play(sfxFiles.get(sf), volume, loop));
        }
    }

    public static function stopAll()
    {
        for (sf in sfx.keys())
        {
            if (sfx.get(sf).playing)
                stop(sf);
        }
    }

    public static function stop(sf : SFX)
    {
        if (Enabled)
        {
            sfx.get(sf).stop();
        }
    }

    static var savefile : String = "settings";
    public static function save()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        save.data.sfx = Enabled;
        save.close();
    }

    static function load()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        if (save.data.sfx != null)
        {
            Enabled = save.data.sfx;
            // trace("Loaded SFX " + (Enabled ? "ON" : "OFF"));
        }
        else
            Enabled = true;

        save.close();
    }
}
