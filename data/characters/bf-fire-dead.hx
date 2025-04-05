function createPost() {
	lossSFX = 'Smoke';
}

function onPlayAnim(event) {
	switch (event.animName) {
		case 'firstDeath':
			new FlxTimer().start(23 / animation._animations.get(event.animName).frameRate, (timer:FlxTimer) -> {
				state.subState.camFollow.y += 200;
			});
		case 'deathConfirm':
			new FlxTimer().start(32 / animation._animations.get(event.animName).frameRate, (timer:FlxTimer) -> {
				var stepSound:FlxSound;
				stepSound = FlxG.sound.load(Paths.sound('Smoke2'));
				stepSound.play();
			});
			new FlxTimer().start(45 / animation._animations.get(event.animName).frameRate, (timer:FlxTimer) -> {
				state.subState.camFollow.x -= 200;
				state.subState.camFollow.y -= 100;
			});
	}
}