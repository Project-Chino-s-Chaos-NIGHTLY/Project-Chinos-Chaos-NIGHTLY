// Restart song without reloading state.

var allowRestart:Bool = false;
function onStartSong() {
    allowRestart = true;
}

function update() {
    if (FlxG.keys.justPressed.Z && allowRestart) {
		// W.I.P.
	}
}