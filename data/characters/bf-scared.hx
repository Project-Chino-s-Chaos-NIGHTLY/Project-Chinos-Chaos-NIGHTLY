function onDance(event) {
	if (getAnimName() == 'idle' || getAnimName() == ('idle' + idleSuffix)) {
		event.cancelled = true;
	}
}