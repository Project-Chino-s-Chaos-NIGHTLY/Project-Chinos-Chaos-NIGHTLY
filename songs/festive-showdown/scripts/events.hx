// Rodney check the bottom extras.hx before commenting on this file.
var dadDefIndex:Int;
var bofDefIndex:Int;
var desiredZoom:Float = 1.05;
var currentZoom:Float = 1.05;

var defX = {dad: 0, bf: 0}

function postCreate() {
    dadDefIndex = members.indexOf(dad);
    bofDefIndex = members.indexOf(boyfriend);
    defX.dad = dad.x;
    defX.bf = boyfriend.x;
}
function onOpponentHit(event) {
    boyfriend.playAnim("block" + ["LEFT", "DOWN", "UP", "RIGHT"][event.direction], true);
    remove(dad);
    remove(boyfriend);
    insert(bofDefIndex, dad);
    insert(dadDefIndex, boyfriend);

    var healthDrain = 0.02;
    if (health - healthDrain > 0) {
        health -= healthDrain;
    } else {
        health = 0.01;
    }
}

function onPlayerHit(event) {
    dad.playAnim("block" + ["LEFT", "DOWN", "UP", "RIGHT"][event.direction], true);
    remove(dad);
    remove(boyfriend);
    insert(dadDefIndex, dad);
    insert(bofDefIndex, boyfriend);
}


function postPreUpdate() {
    camGame.zoom = currentZoom;
}

function update() {
    postPreUpdate();
    currentZoom = lerp(currentZoom, desiredZoom, 0.1);

    var offset = (800) * (health-1);
    boyfriend.x = lerp(boyfriend.x, defX.bf - offset, 0.75);
    dad.x = lerp(dad.x, defX.dad - offset, 0.75);
}
function postUpdate() postPreUpdate();


var steps = [
    256 => ()-> {desiredZoom = 0.3;}
];
function stepHit() { (steps[curStep] ?? ()->{})(); }