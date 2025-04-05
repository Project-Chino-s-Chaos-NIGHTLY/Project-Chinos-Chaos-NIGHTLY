function postCreate() {
	iceShield.playAnim('shield', true);
	iceShield.animation.finishCallback = (name:String) -> {
		switch (name) {
			case 'blast':
				iceShield.alpha = 0.0001;
		}
	}
}

function stepHit(curStep) {
	switch (curStep) {
		case 36:
			iceShield.playAnim('blast', true);
	}
}