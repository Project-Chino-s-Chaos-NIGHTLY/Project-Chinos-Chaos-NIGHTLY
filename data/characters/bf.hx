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