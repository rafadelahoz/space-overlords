package;

import flixel.FlxG;

class Screenshot
{
    public static function take(?fname : String = null) : String
    {
        #if (!flash && !html5)
        var b : flash.display.Bitmap = flixel.addons.plugin.screengrab.FlxScreenGrab.grab();
        return save(b, fname);
        #else
        return "";
        #end
    }

    public static function save(bitmap : flash.display.Bitmap, ?fname : String = null) : String
    {
        if (fname == null)
            fname = "space-overlords-" + Date.now().getTime();

        fname += ".png";

        var path : String = ".";

        #if android
            #if !lime_legacy
            path = lime.system.System.userDirectory;
            #else
            path = openfl.utils.SystemPath.userDirectory;
            #end

            // path += "/SOAP ALLEY/screenshots";
        #end

        #if iphone
            #if !lime_legacy
                path = lime.system.System.applicationStorageDirectory;
            #else
                path = openfl.utils.SystemPath.applicationStorageDirectory;
            #end
        #end

        try
        {
            #if (!flash && !html5)
                sys.FileSystem.createDirectory(path);
                // trace("Saving to " + sys.FileSystem.absolutePath(path));
                var ba : openfl.utils.ByteArray = bitmap.bitmapData.encode(bitmap.bitmapData.rect, new openfl.display.PNGEncoderOptions());
                var fo : sys.io.FileOutput = sys.io.File.write(path + "/" + fname, true);
                fo.writeBytes(ba, 0, ba.length);
                fo.close();
            #end
        } catch (e:Dynamic) {
            // trace("Save failed");
            trace(e);
        }

        return path + "/" + fname;
    }

    public static function memtake() : openfl.display.BitmapData
    {
        #if (!flash && !html5)
            return flixel.addons.plugin.screengrab.FlxScreenGrab.grab().bitmapData;
        #else
            return null;
        #end
    }
}
