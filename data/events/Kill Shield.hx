function new() {
}

function onEvent(event) {
	switch (event.event.name) {
		case 'Kill Shield':
			scripts.call("killShield", [event.event.params[0] ?? '']);
	}
}