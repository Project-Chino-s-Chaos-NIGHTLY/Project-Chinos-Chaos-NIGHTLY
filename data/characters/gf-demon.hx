function onPlaySingAnim(event) {
	if (event.animName == 'singLEFT' + event.suffix) event.animName = 'singDOWN' + event.suffix;
	if (event.animName == 'singUP' + event.suffix) event.animName = 'singRIGHT' + event.suffix;
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