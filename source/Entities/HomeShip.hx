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

    public function launch()
    {
        launching = true;

        thrustTimer.start(2.5, function(_) {
            initFx();
            SfxEngine.play(SfxEngine.SFX.SetupInitialize);
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

        SfxEngine.stop(SfxEngine.SFX.ShipThrust);
        SfxEngine.play(SfxEngine.SFX.ShipThrust, true);
    }

    function thrustOff(_) {
        thrustOn = false;
        SfxEngine.stop(SfxEngine.SFX.ShipThrust);
        SfxEngine.play(SfxEngine.SFX.ShipThrust, 0.5, true);
    }

    function finalThrust()
    {
        acceleration.set(0, -100);
        velocity.set(FlxG.random.float(-2, 2), -ThrustSpeed*8);
        emitter.start(false, 0.0025, 1050);

        SfxEngine.stop(SfxEngine.SFX.ShipThrust);
        SfxEngine.play(SfxEngine.SFX.ShipFinalThrust);

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

            delayTimer.start(3, handleFinalDecision);
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

    function handleFinalDecision(_)
    {
        world.onFinalDecissionTaken();

        if (FlxG.random.bool(50))
            finalThrust();
        else
            explode();
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

    var flareEmitter : FlxEmitter;
    var shineEmitter : FlxEmitter;
    public function explode()
    {
        velocity.set(0, 0);
        acceleration.set(0, 0);
        world.stars.starVelocityOffset.y = 0.2;

        emitter.kill();

        SfxEngine.play(SfxEngine.SFX.ShipExplosionSmall, FlxG.random.float(0.5, 0.75), true);

        explodeSingle();
        new FlxTimer().start(0.13, function(t:FlxTimer) {
            explodeSingle();
        }, 6);
        new FlxTimer().start(0.13*6, function(_) {
            SfxEngine.stop(SfxEngine.SFX.ShipExplosionSmall);
            SfxEngine.play(SfxEngine.SFX.ShipExplosionBig);
        });
        new FlxTimer().start(0.13*2, function(t:FlxTimer) {
            world.effects.add(new BombRowEffect(0, y - Constants.TileSize + 4, Constants.Width, Constants.TileSize*2));
            t.start(1, function(t : FlxTimer) {
                // Notify of the dire end
                world.onShipDestroyed();
            });
        });
    }

    public function explodeSingle()
    {
        var xx : Float = FlxG.random.float(x-4, x+width-4);
        var yy : Float = FlxG.random.float(y-4, y+height-4);

        //if (flareEmitter == null)
        {
            flareEmitter = new FlxEmitter(xx, yy, 50);
            flareEmitter.setSize(12, 12);
            flareEmitter.alpha.set(0.8, 1, 0.2, 0.5);
            flareEmitter.lifespan.set(0.5, 0.75);
            flareEmitter.color.set(Palette.Yellow, Palette.Red, Palette.Brown, Palette.DarkPurple);
            flareEmitter.blend = flash.display.BlendMode.OVERLAY;
            // flareEmitter.angularAcceleration.set(2, 3, 5, 7);
            flareEmitter.speed.set(8, 15, 2, 4);
            flareEmitter.acceleration.set(-2, -2, 2, 2, -5, 5, -5, 5);
            flareEmitter.scale.set(1, 1, 1.5, 1.5, 2, 2, 3, 3);
            // flareEmitter.angularDrag.set(10, 20, 30, 40);
            flareEmitter.makeParticles(3, 3);
            world.effects.add(flareEmitter);
        }
        flareEmitter.setPosition(xx, yy);
        flareEmitter.start(true);

        //if (shineEmitter == null)
        {
            shineEmitter = new FlxEmitter(xx, yy, 50);
            shineEmitter.setSize(10, 10);
            shineEmitter.alpha.set(0.8, 1, 0.2, 0.5);
            shineEmitter.lifespan.set(0.25, 0.45);
            shineEmitter.color.set(Palette.White, Palette.Yellow, Palette.White, Palette.Yellow);
            shineEmitter.blend = flash.display.BlendMode.OVERLAY;
            // shineEmitter.angularAcceleration.set(2, 3, 5, 7);
            shineEmitter.speed.set(4, 10, 1, 3);
            // shineEmitter.acceleration.set(-2, -2, 2, 2, -5, 5, -5, 5);
            shineEmitter.scale.set(0.3, 0.3, 0.5, 0.5, 1.2, 1.2, 1.6, 1.6);
            // shineEmitter.angularDrag.set(10, 20, 30, 40);
            shineEmitter.makeParticles(4, 4);
            world.effects.add(shineEmitter);
        }
        shineEmitter.setPosition(xx, yy);
        shineEmitter.start(true);
    }
}
