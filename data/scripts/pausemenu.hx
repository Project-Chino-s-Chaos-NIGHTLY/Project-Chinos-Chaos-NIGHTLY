function create(event) {
	/**
	 * if true postCreate doesn't run and nothing in the state is created
	 * Even the camera, the music is still made tho
	 */
	// __cancelDefault = false;

	// event.options = ['Resume', 'Restart Song', 'Change Controls', 'Change Options', 'Exit to menu', "Exit to charter"];
}

function postCreate() {
	//
}

function update(elapsed:Float) {
	//
}

function onSelectOption(event) { // NameEvent
	// event.name = 'Restart Song';
}

function onChangeItem(event) {
	//
}

function destroy() {
	//
	PlayState.instance.scripts.call('onGameResume');
}