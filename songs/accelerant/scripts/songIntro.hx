import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

static var preventCamNoteZoom:Bool = false;
static var camNotes:HudCamera;
static var camOther:FlxCamera;
var title:FlxText;

introSounds = introSprites = [];
introLength = 3;

function create():Void {
	camNotes = new HudCamera();
	camNotes.bgColor = FlxColor.TRANSPARENT;
	camNotes.zoom = 1;
}

function postCreate():Void {
	PauseSubState.script = 'data/scripts/pausemenu';

	if (SONG.meta.customValues?.background == 'bill') return;
	if (SONG.meta.displayName == 'Sparkles') camNotes.alpha = 0;
	FlxG.cameras.add(camNotes, false);
	camOther = new FlxCamera();
	camOther.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(camOther, false);

	title = new FlxText(0, 0, null, SONG.meta.displayName);
	title.cameras = [camOther];
	title.setFormat(getFont(SONG.meta.customValues?.vinyl), 80, FlxColor.WHITE, 'CENTER', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	title.antialiasing = true;
	title.screenCenter();
	title.y += 25;
	title.alpha = 0;
	//if (SONG.meta.displayName != 'Mystery Twins') add(title);

	for (strumLine in strumLines)
		strumLine.cameras = [camNotes];
}

function postUpdate(elapsed:Float):Void {
	camNotes.downscroll = downscroll;
	if (!preventCamNoteZoom)
		camNotes.zoom = camHUD.zoom;
}

function onSongStart():Void {
	if (SONG.meta.customValues?.background == 'bill') return;
	FlxTween.tween(title, {alpha: 1}, 1, {startDelay: 1});
	FlxTween.tween(title, {alpha: 0}, 1, {startDelay: 4});
}

function getFont(vinyl:String):String {
	if (vinyl == null) return;
	return Paths.font(switch (vinyl.toLowerCase()) {
		case 'toh': 'toh_episode_font.ttf';
		default: 'vcr.ttf';
	});
}

function destroy():Void {
	preventCamNoteZoom = false;
}