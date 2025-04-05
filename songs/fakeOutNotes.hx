function onNoteCreation(e) {
	onNoteCreationPrePost(e);
}

function onPostNoteCreation(e) {
	// onNoteCreationPrePost(e);
}

function onNoteCreationPrePost(e) {
	if (e.noteType == 'Fakeout') {
		e.note.avoid = true;
		e.note.earlyPressWindow = 0;
		e.note.latePressWindow = 0;
	}
}

function update(elapsed) {
	for (strumLine in strumLines) {
		for (note in strumLine.notes) {
			if (note.noteType == 'Fakeout') {
				if (note.strumTime <= Conductor.songPosition) {
					note.extra['isFrozen'] = true;
				}
				if (note.extra['isFrozen']) {
					note.strumTime = Conductor.songPosition;
					if (note.extra['tween'] == null) {
						// note.frameOffset.y += 1;
						if (note.extra['timer'] == null) {
							note.extra['timer'] = new FlxTimer();
							note.extra['defaultOffsetX'] = note.offset.x;
							note.extra['defaultOffsetY'] = note.offset.y;
							note.extra['timer'].start(0.3, (timer:FlxTimer) -> {
								note.offset.set(note.extra['defaultOffsetX'], note.extra['defaultOffsetY']);
								var amt = (downscroll ? -1 : 1);
								note.extra['tween'] = FlxTween.tween(note.offset, {y: (-(FlxG.height) * amt)}, 0.5, {ease: FlxEase.quartIn});
							});
						} else {
							note.offset.set(note.extra['defaultOffsetX'] + FlxG.random.int(-5, 5), note.extra['defaultOffsetY'] + FlxG.random.int(-5, 5));
						}
					}
					if (note.extra['layered'] == null) {
						note.extra['layered'] = true;
						for (thing0 => strumLiner in strumLines.members) {
							strumID = note.get_strumID();
							direction = note.noteData;
							if (thing0 != 0 && thing0 != 1) {
								strumLiner.members[direction].alpha = 0.0001;
							} else {
								strumLiner.members[direction].alpha = 1;
							}
						}
					}
				}
			}
		}
	}
}

var steps:Map<Int, Void->Void> = [
	1 => function() {
		strumLines.members[3].members[0].alpha = 0.0001;
		strumLines.members[3].members[1].alpha = 0.0001;
		strumLines.members[3].members[2].alpha = 0.0001;
		strumLines.members[3].members[3].alpha = 0.0001;
		trace('Hello');
	}
];

function stepHit() {
	if (steps[curStep] != null)
		steps[curStep]();
}
