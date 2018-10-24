package;

import flixel.FlxG;
import flixel.util.FlxTimer;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

class HomeShip extends Entity
{
    var world : GoingHomeState;

    var Gravity : Float = 50; // pixels per second
    var ThrustSpeed : Float = 50;
    var ThrustSpeedVariance : Float = 0.4;

    var ThrustDelay : Float = 2;
    var ThrustDelayVariance : Float = 0.4;

    var thrustTimer : FlxTimer;
    var delayTimer : FlxTimer;

    var thrustOn : Bool;
    var finishing : Bool;

    public function new(World : GoingHomeState)
    {
        world = World;

        var _width : Int = 14;
        var _height : Int = 16;

        super(Constants.Width/2 - _width/2, Constants.Height * 0.7);

        makeGraphic(_width, _height, Palette.White);

        acceleration.set(0, Gravity);
        thrustTimer = new FlxTimer();
        delayTimer = new FlxTimer();

        thrust(delayTimer);

        thrustOn = false;
        finishing = false;

        initFx();
    }

    function thrust(_)
    {
        velocity.set(FlxG.random.float(-5, 5), -(ThrustSpeed * (1+FlxG.random.float(-ThrustSpeedVariance, ThrustSpeedVariance))));
        angle = velocity.x;
        delayTimer.start(ThrustDelay * (1+FlxG.random.float(-ThrustDelayVariance, ThrustDelayVariance)), thrust);
        thrustTimer.start(ThrustDelay * (1+FlxG.random.float(-ThrustDelayVariance, ThrustDelayVariance)) * FlxG.random.float(0.25, 0.5), thrustOff);
        thrustOn = true;
    }

    function thrustOff(_) {
        thrustOn = false;
    }

    function finalThrust(_)
    {
        velocity.set(FlxG.random.float(-2, 2), -ThrustSpeed*10);
        emitter.start(true);
    }

    override public function update(elapsed : Float)
    {
        if (y < 60 && !finishing)
        {
            finishing = true;

            thrustOff(null);
            delayTimer.cancel();
            thrustTimer.cancel();
            velocity.y *= 0.2;
            // acceleration.set(0, Gravity*0.1);
            // Start vibrating
            delayTimer.start(2, finalThrust);
        }

        if (!finishing && thrustOn)
        {
            velocity.set(FlxG.random.float(-5, 5), -(ThrustSpeed * (1+FlxG.random.float(-ThrustSpeedVariance, ThrustSpeedVariance))));
            angle = velocity.x;
        }

        super.update(elapsed);

        emitter.x = x + width/2 - 5;
        emitter.y = y + height - 1;
    }

    var emitter : FlxEmitter;
    function initFx()
    {
        emitter = new FlxEmitter(x + width/2, y + height*0.9, 50);

        emitter.makeParticles(3, 3, Palette.Yellow, 50);

        // emitter.launchMode = FlxEmitterMode.CIRCLE;
        emitter.launchMode = FlxEmitterMode.SQUARE;
        emitter.velocity.set(0, 10, 0, 30, 0, 0, 0, 2);
        emitter.setSize(10, 2);
        emitter.alpha.set(0.8, 1, 0.0, 0.1);
        emitter.ignoreAngularVelocity = true;
        // emitter.angularVelocity.set()
        emitter.lifespan.set(0.17, 0.3);
        emitter.color.set(Palette.Yellow, Palette.Green, Palette.DarkGreen, Palette.Green);

        world.add(emitter);

        emitter.start(false, 0.005);
    }
}
