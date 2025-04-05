function onNoteHit(event) {
	if (event.noteType == 'Attack Crit') {
		event.healthGain = 0.05;
		if (health - event.healthGain <= 0 && !event.player) {
			health = 0.01;
			event.healthGain = 0;
		}
	}
}