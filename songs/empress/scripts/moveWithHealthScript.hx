var defX = {dad: 0, bf: 0}
var offsetFromCenter = 400;

var debugMode = true;
var debugHealth = false;

function postCreate() {
    defX.dad = dad.x;
    defX.bf = boyfriend.x;
}

function postUpdate() {
    var offset = (offsetFromCenter) * (health-1);
    boyfriend.x = lerp(boyfriend.x, defX.bf - offset, 0.75);
    dad.x = lerp(dad.x, defX.dad - offset, 0.75);

    if (debugMode) {
        if (debugHealth) health = 2;
    }
}