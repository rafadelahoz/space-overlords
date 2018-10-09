package;

import flixel.util.FlxTimer;
import haxe.Http;

class DataServiceClient
{
    public static function SendSessionData(settings : GameSettings.GameSettingsData, session : PlaySessionData) : Void
    {
        new FlxTimer().start(0.1, function(_) {
            var req = new Http("http://badladns.com/api/spaceoverlords/report");

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
            req.setParameter("id", "102292");

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
}
