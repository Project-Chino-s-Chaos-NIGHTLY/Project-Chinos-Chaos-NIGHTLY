// Rodney check the bottom extras.hx before commenting on this file.
var dadDefIndex:Int;
var bofDefIndex:Int;
var desiredZoom:Float = 1.05;
var currentZoom:Float = 1.05;

function postCreate() {
    dadDefIndex = members.indexOf(dad);
    bofDefIndex = members.indexOf(boyfriend);
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