package;

import haxe.CallStack;

class ErrorReporter
{
    public static function handle(error : Dynamic)
    {
        // trace(error);
        var stack : String = CallStack.toString(CallStack.exceptionStack());
        // trace(stack);

        Logger.batch("### ERROR @ " + Date.now().toString() + " ###");
        Logger.batch(error);
        Logger.batch(">> STACK");
        Logger.batch(stack);
        Logger.done();

        /*Share.init(Share.TWITTER);
        Share.share(error + "\n" + stack, "Exception occurred", null, null, "the@badladns.com");*/
    }
}
