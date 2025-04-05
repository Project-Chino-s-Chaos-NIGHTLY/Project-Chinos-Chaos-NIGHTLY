function onPlayAnim(event) {
	if (event.animName == 'hit') event.animName = 'hit' + FlxG.random.int(1, 3);
}

function onPlaySingAnim(event) {
	if (event.animName == 'singLEFT' + event.suffix) event.animName = 'singSIDE' + event.suffix;
	if (event.animName == 'singRIGHT' + event.suffix) event.animName = 'singSIDE' + event.suffix;
}

function update(elapsed:Float) {
	if (!__lockAnimThisFrame && lastAnimContext != 'DANCE') {
		if (lastAnimContext == 'SING') {
			if (getAnimName() == null || isAnimFinished()) {
				lastAnimContext = null;
				dance();
			}
		}
	}
}

function onDance(event) {
	if (lastAnimContext == 'SING') {
		event.cancelled = true;
	}
}