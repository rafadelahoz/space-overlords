package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;

enum SFX {
    None;

    VcrSelect;
    VcrAccept;

    PauseStart;
    PauseEnd;
    QuotaPopupFanfare;
    RewardFanfare;

    FlipEyeA;
    FlipEyeB;
    FlipRaddishA;
    FlipRaddishB;
    FlipMutantA;
    FlipMutantB;
    FlipPillA;
    FlipPillB;
    FlipChemdust;

    LandEyeA;
    LandEyeB;
    LandRaddishA;
    LandRaddishB;
    LandMutantA;
    LandMutantB;
    LandPillA;
    LandPillB;
    LandChemdust;

    BombTrigger;
    BombExplode;
    ChemdustTrigger;
    ChemdustDissolve;

    Move;
    Pair;

    MechanicButton;

    ScreenOn;
    OverlordSpeakA;
    OverlordSpeakB;

    Flying;

    SpeakerA;
    SpeakerB;
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

        sfxFiles.set(SFX.VcrSelect,      path + "vcr-select.wav");
        sfxFiles.set(SFX.VcrAccept,      path + "vcr-accept.wav");

        sfxFiles.set(SFX.PauseStart,     path + "pause-in.wav");
        sfxFiles.set(SFX.PauseEnd,       path + "pause-end.wav");
        sfxFiles.set(SFX.QuotaPopupFanfare, path + "quota-popup-reached.wav");
        sfxFiles.set(SFX.RewardFanfare,  path + "fanfare.wav");

        sfxFiles.set(SFX.FlipEyeA,       path + "turn-eye-a.wav");
        sfxFiles.set(SFX.FlipEyeB,       path + "turn-eye-b.wav");
        sfxFiles.set(SFX.FlipRaddishA,   path + "turn-raddish-a.wav");
        sfxFiles.set(SFX.FlipRaddishB,   path + "turn-raddish-b.wav");
        sfxFiles.set(SFX.FlipMutantA,    path + "turn-mutant-a.wav");
        sfxFiles.set(SFX.FlipMutantB,    path + "turn-mutant-b.wav");
        sfxFiles.set(SFX.FlipPillA,      path + "turn-pill-a.wav");
        sfxFiles.set(SFX.FlipPillB,      path + "turn-pill-b.wav");
        sfxFiles.set(SFX.FlipChemdust,   path + "flip-chemdust.wav");

        sfxFiles.set(SFX.LandEyeA,       path + "land-eye-a.wav");
        sfxFiles.set(SFX.LandEyeB,       path + "land-eye-b.wav");
        sfxFiles.set(SFX.LandRaddishA,   path + "land-raddish-a.wav");
        sfxFiles.set(SFX.LandRaddishB,   path + "land-raddish-b.wav");
        sfxFiles.set(SFX.LandMutantA,    path + "land-mutant-a.wav");
        sfxFiles.set(SFX.LandMutantB,    path + "land-mutant-b.wav");
        sfxFiles.set(SFX.LandPillA,      path + "land-pill-a.wav");
        sfxFiles.set(SFX.LandPillB,      path + "land-pill-b.wav");
        sfxFiles.set(SFX.LandChemdust,   path + "land-chemdust.wav");

        sfxFiles.set(SFX.BombTrigger,    path + "bomb-trigger.wav");
        sfxFiles.set(SFX.BombExplode,    path + "bomb-explode.wav");
        sfxFiles.set(SFX.ChemdustTrigger,path + "chemdust-trigger.wav");
        sfxFiles.set(SFX.ChemdustDissolve, path + "chemdust-dissolve.wav");

        sfxFiles.set(SFX.Move,           path + "move.wav");
        sfxFiles.set(SFX.Pair,           path + "pair-b.wav");

        sfxFiles.set(SFX.MechanicButton, path + "mechanical-button.wav");

        sfxFiles.set(SFX.ScreenOn,       path + "screen-on.wav");
        sfxFiles.set(SFX.OverlordSpeakA, path + "overlord-a.wav");
        sfxFiles.set(SFX.OverlordSpeakB, path + "overlord-b.wav");

        sfxFiles.set(SFX.Flying,         path + "ship-fly-loop.wav");

        sfxFiles.set(SFX.SpeakerA,       path + "speaker-a.wav");
        sfxFiles.set(SFX.SpeakerB,       path + "speaker-b.wav");

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
