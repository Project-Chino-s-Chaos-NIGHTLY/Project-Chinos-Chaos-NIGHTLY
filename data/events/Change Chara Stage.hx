function new() {
}

function onEvent(event) {
	switch (event.event.name) {
		case 'Change Chara Stage':
			scripts.call("changeStage", [event.event.params[0]]);
	}
}
