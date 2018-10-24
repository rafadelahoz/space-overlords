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
    var launching : Bool;
    var finishing : Bool;

    var callback : Void -> Void;

    public function new(World : GoingHomeState)
    {
        world = World;

        var _width : Int = 16;
        var _height : Int = 16;

        super(Constants.Width/2 - _width/2, 228-_height);

        loadGraphic("assets/images/home-ship.png");

        thrustTimer = new FlxTimer();
        delayTimer = new FlxTimer();

        thrustOn = false;
        finishing = false;

        emitter = new FlxEmitter(x + width/2, y + height*0.9, 50);
        world.add(emitter);

        launching = false;
    }

    public function launch(Callback : Void -> Void)
    {
        callback = Callback;
        launching = true;

        thrustTimer.start(2.5, function(_) {
            initFx();
        });
        delayTimer.start(5, function(_){
            launching = false;
            acceleration.set(0, Gravity);

            thrust(delayTimer);

            world.onLaunch();
        });
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
        acceleration.set(0, -100);
        velocity.set(FlxG.random.float(-2, 2), -ThrustSpeed*8);
        emitter.start(false, 0.0025, 1050);

        world.stars.starVelocityOffset.set(world.stars.starVelocityOffset.x, 8);

        flixel.tweens.FlxTween.tween(world.stars.starVelocityOffset, {y : 0.005}, 0.7, {startDelay: 0.8, ease : flixel.tweens.FlxEase.expoOut});
    }

    override public function update(elapsed : Float)
    {
        if (y < 90 && !finishing)
        {
            finishing = true;

            thrustOff(null);
            delayTimer.cancel();
            thrustTimer.cancel();
            velocity.y *= 0.25;
            acceleration.set(0, Gravity*0.45);
            // Start vibrating
            delayTimer.start(3, finalThrust);

            callback();
        } else if (y >= 232) {
            thrustOff(null);
            delayTimer.cancel();
            thrustTimer.cancel();
            thrust(null);
        }

        if (launching || finishing)
        {
            angle = FlxG.random.float(-10, 10);
        }

        if (!finishing && thrustOn)
        {
            velocity.set(FlxG.random.float(-5, 5), -(ThrustSpeed * (1+FlxG.random.float(-ThrustSpeedVariance, ThrustSpeedVariance))));
            angle = velocity.x;
        }

        if (!finishing)
        {
            if (velocity.y < 0)
                world.stars.starVelocityOffset.y = -velocity.y*0.025;
            else
                world.stars.starVelocityOffset.y = 0;
        }
        else
        {
            if (acceleration.y > 0)
                world.stars.starVelocityOffset.y = 0.1;
        }

        if (finishing && y < -150)
        {
            // done!
            world.onShipLeftForHome();
        }

        super.update(elapsed);

        emitter.x = x + width/2 - 2;
        emitter.y = y + height - 1;
    }

    var emitter : FlxEmitter;
    function initFx()
    {
        emitter.makeParticles(3, 3, Palette.Yellow, 150);

        // emitter.launchMode = FlxEmitterMode.CIRCLE;
        emitter.launchMode = FlxEmitterMode.SQUARE;
        emitter.velocity.set(0, 10, 0, 30, 0, 0, 0, 2);
        emitter.setSize(3, 2);
        emitter.alpha.set(0.8, 1, 0.0, 0.1);
        emitter.ignoreAngularVelocity = true;
        // emitter.angularVelocity.set()
        emitter.lifespan.set(0.17, 0.3);
        emitter.color.set(Palette.Yellow, Palette.Green, Palette.DarkGreen, Palette.Green);

        emitter.start(false, 0.005);
    }
}
