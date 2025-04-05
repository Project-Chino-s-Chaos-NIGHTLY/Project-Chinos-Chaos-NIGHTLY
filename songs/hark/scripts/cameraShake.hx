var isShaking = false;
var defPos = {x: 0, y: 0}
var shakeStrength = 1;

function shakeCamera(duration, strength) {
    isShaking = true;
    defPos = {x: camGame.scroll.x, y: camGame.scroll.y};
    shakeStrength = strength;

    new FlxTimer().start(duration, ()->{
        isShaking = false;
        camGame.scroll.x = defPos.x;
        camGame.scroll.y = defPos.y;
    });
}

function postUpdate() {
    if (isShaking) {
        camGame.scroll.x = defPos.x + FlxG.random.int(-shakeStrength, shakeStrength);
        camGame.scroll.y = defPos.y + FlxG.random.int(-shakeStrength, shakeStrength);
    }
}

function onOpponentHit(event) {
    shakeCamera(0.1, 10);
}