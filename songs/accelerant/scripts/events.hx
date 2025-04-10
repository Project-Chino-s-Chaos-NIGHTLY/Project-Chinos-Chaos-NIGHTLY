var theAlpha:Float = 0;
var defPositions = [];
var offset = 0;
var sundayActive = false;
function postCreate() {
    for (si => strumLine in strumLines.members) {
        //if (si == 0) {
            var positions = [];
            for (i=>strum in strumLine.members) {
                positions.push({x: strum.x, y: strum.y});
            }
            defPositions.push(positions);
            trace(defPositions);
        //}
    }
    gf.animation.finishCallback = function(name) {
        if (name == "carol") gf.visible = false;
    }
}
function postUpdate() {
    camFollow.x = FlxG.width/2;
    camFollow.y = FlxG.height/2;
    camGame.scroll.x = 0;
    camGame.scroll.y = 0;
}
function sundayToggle() { 
    sundayActive = !sundayActive;
    if (!sundayActive) {
        new FlxTimer().start(2, ()->{ disablePositioning = false; });
    }
}
var stepEvents = [
	664 => ()-> {
        sundayToggle();
	},
	744 => ()-> {
        sundayToggle();
	},
	818 => ()-> {
        sundayToggle();
	},
	832 => ()-> {
        sundayToggle();
	},
	856 => ()-> {
        sundayToggle();
	},
	928 => ()-> {
        sundayToggle();
        gf.playAnim('carol', true);
	},
];
function stepHit() { (stepEvents[curStep] ?? ()->{})(); }

function onStartSong() {
	strumLines.members[1].onHit.add((event) -> {
        if (event.noteType == "Scream") {
            event.animCancelled = true;
            boyfriend.playAnim("scream", true, "SING");
            dad.playAnim("shook", true, "SING");
        }
    });
}