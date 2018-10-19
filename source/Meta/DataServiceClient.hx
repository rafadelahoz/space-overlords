package;

import flixel.util.FlxTimer;
import haxe.Http;

class DataServiceClient
{
    static var uri : String = "http://api.badladns.com/api/spaceoverlords";
    // static var uri : String = "http://localhost:3000/api/spaceoverlords";

    public static function SendSessionData(settings : GameSettings.GameSettingsData, session : PlaySessionData) : Void
    {
        new FlxTimer().start(0.1, function(_) {
            var req = new Http(uri + "/report");
            // var req = new Http("http://localhost:3000/api/spaceoverlords/report");

            var dataObject = {
                mode: settings.mode,
                intensity: settings.intensity,

                score : session.score,
                items : session.items,
                cycle : session.cycle,
                fallSpeed : session.fallSpeed,
                lastItemsSpeedIncrease: session.lastItemsSpeedIncrease,
                timesIncreased : session.timesIncreased,

                startTime : session.startTime,
                endTime : session.endTime
            };

            req.setParameter("session", haxe.Json.stringify(dataObject));
            req.setParameter("id", ProgressData.data.uuid);

            req.onStatus = function(status) {
                trace("STATUS: " + status);
            }

            req.onError = function(error) {
                trace("ERROR: " + error);
            }

            req.onData = function(data) {
                trace("DATA: " + data);
            }

            req.request(true);
        });
    }

    public static function SendLog() : Void
    {
        #if !html5
        var path : String = Logger.getPath();
        var filename : String = Logger.getFilename();

        if (sys.FileSystem.exists(path + "/" + filename))
        {
            var contents : String = sys.io.File.getContent(path + "/" + filename);

            var req = new Http(uri + "/log");
            req.setParameter("id", ProgressData.data.uuid);
            req.setParameter("contents", contents);

            req.onStatus = function(status) {
                trace("STATUS: " + status);
            }

            req.onError = function(error) {
                trace("ERROR: " + error);
            }

            req.onData = function(data) {
                trace("DATA: " + data);
            }

            req.request(true);
        }
        #end
    }
}
