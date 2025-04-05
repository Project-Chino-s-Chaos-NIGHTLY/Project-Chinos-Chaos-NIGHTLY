import flixel.addons.display.FlxBackdrop;

var wallOfHeads:FlxBackdrop;

function postCreate() {
	PauseSubState.script = 'data/scripts/pausemenu'; // makes the pause menu script to be this script
	if (ModOptions.wallOfHeads) {
		wallOfHeads = new FlxBackdrop(Paths.image('game/wall of heads'), FlxAxes.XY);
		wallOfHeads.velocity.set(700, 700);
		wallOfHeads.cameras = [FlxG.camera];
		wallOfHeads.scale.set(0.3, 0.3);
		wallOfHeads.updateHitbox();
	}

	if (ModOptions.hideComboGroup)
		comboGroup.visible = false;

	FlxG.mouse.visible = false;
}

function postUpdate(elapsed:Float) {
	if (ModOptions.wallOfHeads) {
		wallOfHeads.update(elapsed);
	}
}

function postDraw(event) {
	if (ModOptions.wallOfHeads)
		wallOfHeads.draw();
}

function onStartSong() {
	strumLines.members[0].onHit.add((event) -> {
		scripts.call("onOpponentHit", [event]);
	});
	strumLines.members[1].onHit.add((event) -> {
		scripts.call("onPlayerHit", [event]);
	});
}