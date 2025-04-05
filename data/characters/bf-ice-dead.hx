function onPlayAnim(event) {
	switch (event.animName) {
		case 'firstDeath':
			new FlxTimer().start(29 / animation._animations.get(event.animName).frameRate, (timer:FlxTimer) -> {
				state.subState.camFollow.x += 150;
				state.subState.camFollow.y += 200;
			});
		case 'deathConfirm':
			new FlxTimer().start(32 / animation._animations.get(event.animName).frameRate, (timer:FlxTimer) -> {
				var stepSound:FlxSound;
				stepSound = FlxG.sound.load(Paths.sound("Freeze2"));
				stepSound.play();
			});
			new FlxTimer().start(37 / animation._animations.get(event.animName).frameRate, (timer:FlxTimer) -> {
				state.subState.camFollow.x -= 200;
				state.subState.camFollow.y -= 100;
			});
	}
}