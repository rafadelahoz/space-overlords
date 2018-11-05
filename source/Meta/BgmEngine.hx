package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;

class BgmEngine
{
    static var FadeTime : Float = 0.5;

    public static var Enabled : Bool = false;

    static var initialized : Bool = false;

    static var tunes : Map<BGM, FlxSound>;
    static var playing : Map<BGM, Bool>;
    public static var current : BGM;
    public static var currentVolume : Float;

    public static function init()
    {
        #if flash
            return;
        #end

        if (initialized)
            return;

        load();

        initialized = true;

        tunes = new Map<BGM, FlxSound>();

        tunes.set(BGM.SpaceTrouble, FlxG.sound.load("assets/music/space-trouble.ogg"));
        tunes.set(BGM.IndustrialWarp, FlxG.sound.load("assets/music/industrial-warp.ogg"));

        playing = new Map<BGM, Bool>();
        for (tune in tunes.keys())
        {
            if (tunes.get(tune) != null)
            {
                tunes.get(tune).persist = true;
                tunes.get(tune).looped = true;
            }
            playing.set(tune, false);
        }

        current = None;
        currentVolume = 0;
    }

    public static function enable(?resumePlaying : Bool = true)
    {
        #if flash
            return;
        #end

        Enabled = true;
        save();

        if (resumePlaying && current != null && tunes.get(current) != null)
        {
            tunes.get(current).fadeIn(FadeTime * 0.5, 0, currentVolume);

            playing.set(current, true);
            current = current;
        }
        else
        {
            playing.set(current, false);
        }
    }

    public static function disable()
    {
        #if flash
            return;
        #end

        Enabled = false;
        save();

        if (current != null && tunes.get(current) != null)
        {
            tunes.get(current).volume = 0;
        }
    }

    public static function play(bgm : BGM, ?volume : Float = 0.75, ?restart : Bool = false)
    {
        #if flash
            return;
        #end

        // Better to stop than to play what we don't want
        if (current != bgm)
        {
            stop(current);
        }

        if (tunes.exists(bgm) && tunes.get(bgm) != null)
        {
            if (volume <= 0)
            {
                stop(bgm);
            }
            else
            {
                if (restart || !playing.get(bgm))
                {
                    // Store the actual requested volume
                    currentVolume = volume;

                    if (tunes.get(bgm).fadeTween != null)
                        tunes.get(bgm).fadeTween.cancel();
                    if (restart)
                        tunes.get(bgm).play(true);

                    if (!Enabled)
                        volume = 0;

                    tunes.get(bgm).fadeIn(FadeTime, 0, volume);

                    playing.set(bgm, true);
                    current = bgm;
                }
                else if (currentVolume != volume)
                {
                    tunes.get(bgm).fadeIn(FadeTime, currentVolume, volume);
                }
            }
        }
    }

    public static function resumeCurrent()
    {
        #if flash
            return;
        #end

        if (tunes.get(current) != null && !tunes.get(current).playing)
            tunes.get(current).resume();
    }

    public static function pauseCurrent()
    {
        #if flash
            return;
        #end

        if (tunes.get(current) != null && tunes.get(current).playing)
            tunes.get(current).pause();
    }

    public static function stopCurrent()
    {
        #if flash
            return;
        #end

        stop(current);
    }

    public static function stop(bgm : BGM)
    {
        #if flash
            return;
        #end

        if (playing.get(bgm))
        {
            if (tunes.get(bgm) != null)
            {
                tunes.get(bgm).fadeOut(FadeTime*2, -10, function(_t:FlxTween) {tunes.get(bgm).stop();});
            }

            playing.set(bgm, false);
            current = None;
            currentVolume = 0;
        }
    }

    public static function fadeCurrent(?time : Float = 2)
    {
        #if flash
            return;
        #end

        fade(current, time);
    }

    public static function fade(bgm : BGM, ?time : Float = 2)
    {
        #if flash
            return;
        #end

        if (playing.get(bgm))
        {
            if (tunes.get(bgm) != null)
            {
                tunes.get(bgm).fadeOut(time, -10);
            }

            currentVolume = 0;
        }
    }

    public static function fadeInCurrent(?time : Float = 2, ?volume : Float = 1)
    {
        #if flash
            return;
        #end

        if (playing.get(current))
        {
            if (tunes.get(current) != null && currentVolume < volume)
            {
                if (Enabled)
                {
                    tunes.get(current).fadeIn(time, 0, volume);
                    currentVolume = volume;
                }
            }


        }
    }

    public static function getBgm(bgmName : String) : BGM
    {
        #if flash
            return null;
        #end

        return BGM.createByName(bgmName);
    }

    static var savefile : String = "settings";
    public static function save()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        save.data.bgm = Enabled;
        save.close();
    }

    static function load()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        if (save.data.bgm != null)
        {
            Enabled = save.data.bgm;
        }
        else
            Enabled = true;

        save.close();
    }
}

enum BGM {
    None;

    SpaceTrouble;
    IndustrialWarp;
}
