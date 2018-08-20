package;

class Logger
{
    public static function log(line : String) {

        var path = getPath();
        var filepath = path + "/" + getFilename();

        trace(line);

        try
        {
            #if (!flash)
                sys.FileSystem.createDirectory(path);
                var file : sys.io.FileOutput = sys.io.File.append(filepath, false);
                file.writeString(line + "\n");
                file.close();
            #end
        }
        catch (e : Dynamic)
        {
            trace("Couldn't write log in " + path + " due to: " + e);
        }
    }

    static function getPath() : String
    {
        var path = ".";

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

        return path;
    }

    static function getFilename() : String
    {
        var now : Date = Date.now();
        var filename : String = "spaceoverlords-" + now.getFullYear() + "-" + (now.getMonth()+1) + "-" + now.getDate() + ".log";

        return filename;
    }

    static var batchLines : Array<String>;
    public static function batch(line : String)
    {
        if (batchLines == null)
            batchLines = [];

        batchLines.push(line);
    }

    public static function done()
    {
        log(batchLines.join("\n"));
        batchLines = [];
    }
}
