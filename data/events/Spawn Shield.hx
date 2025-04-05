function new() {
}

function onEvent(event) {
	switch (event.event.name) {
		case 'Spawn Shield':
			scripts.call("spawnShield", [event.event.params[0] ?? '']);
	}
}