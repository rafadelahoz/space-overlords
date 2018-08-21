package;

import flixel.FlxGame;

class SpaceGame extends FlxGame
{
    override public function step() : Void
    {
        #if android
        try
        {
            super.step();
        }
        catch (someProblem : Dynamic)
        {
            ErrorReporter.handle(someProblem);
        }
        #else
            super.step();
        #end
    }
}
