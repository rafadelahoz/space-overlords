package;

import flixel.addons.transition.FlxTransitionableState;

class GarbageState extends FlxTransitionableState
{
    override public function create()
    {
        GamePad.init();
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);

        GamePad.handlePadState();
    }
}
