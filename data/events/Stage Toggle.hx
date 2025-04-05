function onEvent(event) {
	switch (event.event.name) {
		case 'Stage Toggle':
            scripts.call('toggleStage', []);
	}
}
