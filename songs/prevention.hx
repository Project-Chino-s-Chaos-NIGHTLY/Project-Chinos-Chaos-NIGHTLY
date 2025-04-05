public var prevented:{healthGain:Bool, camZooming:Bool} = {
	healthGain: (SONG.meta.customValues?.preventHealthGain == 'true') ?? false,
	camZooming: (SONG.meta.customValues?.preventCamZooming == 'true') ?? false
}

function onNoteHit(event) {
	if (!event.note.strumLine.opponentSide && prevented.healthGain)
		if (event.noteType != 'Attack' && event.noteType != 'Attack Crit') // attack notes ignore prevention
			event.healthGain = 0;
	if (prevented.camZooming)
		event.enableCamZooming = false;
	if (SONG.meta.name.toLowerCase() == "ballistic") {
		event.healthGain = 0.03;
		if (health - event.healthGain <= 0 && !event.player) {
			health = 0.01;
			event.healthGain = 0;
		}
	}
}