function new() {
	scripts.set("hexAttackTarget", "NaN");
}

function onEvent(event) {
	switch (event.event.name) {
		case 'Choose Hex Attack Target':
			setAttackTarget(event.event.params[0] ?? 'NaN', event.event.params[1] ?? 'NaN');
	}
}

public function setAttackTarget(who:String, fors:String) {
	trace("Switching 'hexAttackTarget' for '" + fors + "' from '" + hexAttackTarget + "' to '" + who + "'");
	scripts.set("hexAttackTarget", who);
	scripts.call("onHexTargetChange", [who]);
}