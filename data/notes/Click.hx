function onNoteHit(event) {
	if (event.noteType == 'Click') {
		event.healthGain = 0.04;
		if (health - event.healthGain <= 0 && !event.player) {
			health = 0.01;
			event.healthGain = 0;
		}
	}
}