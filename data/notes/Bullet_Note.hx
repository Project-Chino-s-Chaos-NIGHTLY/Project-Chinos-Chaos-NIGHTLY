function onNoteHit(event) {
	if (event.noteType == 'Bullet_Note') {
		event.animCancelled = true;
		if (curStep < 664) {
			boyfriend.playAnim("hit", true);
			dad.playAnim("shoot", true);
		} else if (curStep < 848) {
			gf.playAnim("shoot", true);
		} else {
			boyfriend.playAnim("shoot", true);
		}
	}
}