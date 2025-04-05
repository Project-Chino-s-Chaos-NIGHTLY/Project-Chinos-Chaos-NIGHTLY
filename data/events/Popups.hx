import funkin.backend.system.RotatingSpriteGroup;

var popupGroup:RotatingSpriteGroup;

function new() {
	popupGroup = new RotatingSpriteGroup();
	popupGroup.maxSize = 5;
	for (content in Paths.getFolderContent('images/game/popups/', true, true))
		graphicCache.cache(Paths.getPath(content));
}

function onEvent(event) {
	switch (event.event.name) {
		case 'Popups':
			makePopup(
				event.event.params[1] ?? 'NaN',
				event.event.params[2] ?? 'NaN',
				event.event.params[0] ?? 0,
				FlxPoint.get(event.event.params[3] ?? 0, event.event.params[4] ?? 0),
				event.event.params[5] ?? 1
			);
	}
}

/**
 * Makes a popup sprite. (might split into 2 functions)
 * @param type The type of popup it is.
 * @param fade How it should fade out.
 * @param index The character it should spawn near.
 * @param offset Spawn offset.
 */
public function makePopup(type:String, fade:String, index:Int, offset:FlxPoint, scale:Float) {
	var popup = popupGroup.recycleLoop(FunkinSprite);
	popup.alpha = 1;
	popup.loadGraphic(Paths.image('game/popups/' + type));
	popup.scale.set(scale, scale);
	popup.antialiasing = ModOptions.antialiasing;

	var char:Character = strumLines.members[index].characters[0];
	var isFacingRight:Bool = !char.playerOffsets; // wip
	if (char.flipX)
		isFacingRight = !isFacingRight;

	var centerPoint:FlxPoint = char.getMidpoint();
	centerPoint.x += (offset.x + char.globalOffset.x) * (isFacingRight ? 1 : -1) - (popup.width / 2);
	centerPoint.y += offset.y + char.globalOffset.y - (popup.height / 2);

	switch (type) {
		case 'Echo':
			popup.setPosition(centerPoint.x, centerPoint.y + (char.height / 4.5));
		case 'Heated Up':
			popup.setPosition(centerPoint.x, centerPoint.y - (char.height / 2));
			char.playAnim('heatup', true);
		case 'Cooled Down':
			popup.setPosition(centerPoint.x, centerPoint.y - (char.height / 2));
			char.playAnim('cooleddown', true);
		case 'Shield Break':
			popup.setPosition(centerPoint.x, centerPoint.y - (char.height / 2));
		case 'Shrapnel':
		default:
			popup.kill();
			offset.put();
			return; // prevent call
	}
	add(popup);

	offset.put();
	scripts.call('popupSpawn', [popup, type]);

	switch (StringTools.replace(fade, 'Fade ', '').toLowerCase()) {
		case 'left':
			FlxTween.tween(popup, {x: popup.x - (186/scale), alpha: 0}, 17 / 24);
		case 'right':
			FlxTween.tween(popup, {x: popup.x + (186/scale), alpha: 0}, 17 / 24);
		case 'up':
			FlxTween.tween(popup, {y: popup.y - (30/scale), alpha: 0}, 17 / 24);
		case 'down':
			FlxTween.tween(popup, {y: popup.y + (30/scale), alpha: 0}, 17 / 24);
		case 'static':
			FlxTween.tween(popup, {alpha: 0}, 17 / 24);
	}
}