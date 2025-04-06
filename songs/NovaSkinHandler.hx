import haxe.Json;
import haxe.Xml;
import haxe.xml.Access;
import haxe.io.Path;

var defaultNext:Array<Bool> = [false, false, false, false, false, false, false, false, false, false, false, false];

var globalStrumOffsets:Array = [];

var songSplashes:Array<String> = [];
static var disablePositioning:Bool = false;

function onStrumCreation(e) {
	globalStrumOffsets.push({
		statics: {x: 0, y: 0},
		confirm: {x: 0, y: 0}
	});
	if (checkFileExists('songs/' + SONG.meta.name + '/noteskin.json')) {
		var jsonData:String = Assets.getText('songs/' + SONG.meta.name + '/noteskin.json');
		var skinData:Dynamic = Json.parse(jsonData);
		if (e.strumID == 0) songSplashes.push("");
		if (skinData.splashSkin) {
			songSplashes[songSplashes.length-1] = skinData.splashSkin;
		}
		if (skinData.noteSkin.strumSpecific[e.player] == null) return;
		var skinName:String = skinData.noteSkin.strumSpecific[e.player].strums;


		if (skinName != null && checkFileExists('images/game/notes/' + skinName + '.json')) {
			songNoteType = skinName;
			var skinData2:Dynamic = Json.parse(Assets.getText('images/game/notes/' + skinName + '.json'));
			e.sprite = 'game/notes/' + (skinData2.spriteName != null ? Path.withoutExtension(skinData2.spriteName) : (skinName ?? 'default'));
			if (skinData2.splashSkin != null && (skinData2.splashSkin.overrideSongSkin ?? false) && e.strumID == 0)
				songSplashes[songSplashes.length-1] = skinData2.splashSkin.name;

			globalStrumOffsets[e.strumID + (e.player * 4)].statics.x = skinData2.offsets.statics[0] ?? 0;
			globalStrumOffsets[e.strumID + (e.player * 4)].statics.y = skinData2.offsets.statics[1] ?? 0;
			globalStrumOffsets[e.strumID + (e.player * 4)].confirm.x = skinData2.offsets.confirm[0] ?? 0;
			globalStrumOffsets[e.strumID + (e.player * 4)].confirm.y = skinData2.offsets.confirm[1] ?? 0;
		}
	}
	// e.sprite = 'game/notes/skinname';
	// e.strum.animation.addByPrefix('animation for with fire note name', 'anim name in xml', 24, false);
}
function onPostStrumCreation(e) {
	if (checkFileExists('songs/' + SONG.meta.name + '/noteskin.json')) {
		var jsonData:String = Assets.getText('songs/' + SONG.meta.name + '/noteskin.json');
		var skinData:Dynamic = Json.parse(jsonData);
		if (skinData.noteSkin.strumSpecific[e.player] == null) return;
		var skinName:String = skinData.noteSkin.strumSpecific[e.player].strums;
		if (skinName != null && checkFileExists('images/game/notes/' + skinName + '.json')) {
			var strumData:Dynamic = Json.parse(Assets.getText('images/game/notes/' + skinName + '.json'));

			var strumsLoop = (strumData != null) ? (strumData.strumsLoop != null ? strumData.strumsLoop : false) : false;
			e.strum.animation.getByName('static').looped = strumsLoop;
			e.strum.updateHitbox();
		}
	}
}

function onNoteCreation(e) {
	if (checkFileExists('songs/' + SONG.meta.name + '/noteskin.json')) {
		var jsonData:String = Assets.getText('songs/' + SONG.meta.name + '/noteskin.json');
		var skinData:Dynamic = Json.parse(jsonData);
		if (skinData.noteSkin.strumSpecific[e.strumLineID] == null) return;

		var skinName:String = skinData.noteSkin.strumSpecific[e.strumLineID].notes;
		var jsonData:String = Assets.getText('images/game/notes/' + skinName + '.json');
		var skinData:Dynamic = Json.parse(jsonData);
		if (!checkFileExists('images/game/notes/' + (skinData.spriteName != null ? Path.withoutExtension(skinData.spriteName) : skinName) + '.png')) {
			return;
		}
		e.noteSprite = 'game/notes/' + ((skinData.spriteName != null ? Path.withoutExtension(skinData.spriteName) : skinName) ?? 'default');
	}
	if (e.noteType != null) {
		if (checkFileExists('images/game/notes/' + e.noteType + '.json')) {
			var jsonData:String = Assets.getText('images/game/notes/' + e.noteType + '.json');
			var skinData:Dynamic = Json.parse(jsonData);
			e.noteSprite = 'game/notes/' + ((skinData.spriteName != null ? Path.withoutExtension(skinData.spriteName) : e.noteType) ?? 'default');
		}
	}
}

var preloadedSplashes = [];

function onPostNoteCreation(e) {
	if (e.noteType != null) {
		if (checkFileExists('images/game/notes/' + e.noteType + '.json')) {
			var noteProperties:Dynamic = Json.parse(Assets.getText('images/game/notes/' + e.noteType + '.json'));
			if (noteProperties.offsets != null) {
				if (e.note.isSustainNote) {
					if (noteProperties.offsets.sustains != null) {
						e.note.frameOffset.x -= noteProperties.offsets.sustains[0] ?? 0;
						e.note.frameOffset.y -= noteProperties.offsets.sustains[1] ?? 0;
					}
				} else {
					if (noteProperties.offsets.notes != null) {
						e.note.frameOffset.x -= noteProperties.offsets.notes[0] ?? 0;
						e.note.frameOffset.y = noteProperties.offsets.notes[1] ?? 0;
					}
				}
			}
			if (noteProperties.splashSkin != null && noteProperties.splashSkin.name != null) {
				var splashXML = Xml.parse(Assets.getText('data/splashes/' + noteProperties.splashSkin.name + '.xml'));
				for (node in splashXML.firstElement().attributes()) {
					if (node == 'sprite') {
						var data = splashXML.firstElement().get(node);
						if (!preloadedSplashes.contains(data)) {
							preloadedSplashes.push(data);
							new FlxSprite(0, 0).loadGraphic(Paths.image(data));
						}
					}
				}
			}
		}
	}
	if (checkFileExists('songs/' + SONG.meta.name + '/noteskin.json')) {
		var jsonData:String = Assets.getText('songs/' + SONG.meta.name + '/noteskin.json');
		var skinData:Dynamic = Json.parse(jsonData);
		if (skinData.noteSkin.strumSpecific[e.strumLineID] == null) return;
		var skinName:String = skinData.noteSkin.strumSpecific[e.strumLineID].notes;
		if (skinName != null && checkFileExists('images/game/notes/' + skinName + '.json')) {
			var noteProperties:Dynamic = Json.parse(Assets.getText('images/game/notes/' + skinName + '.json'));
			if (noteProperties.offsets != null) {
				if (e.note.isSustainNote) {
					if (noteProperties.offsets.sustains != null) {
						e.note.frameOffset.x -= noteProperties.offsets.sustains[0] ?? 0;
						e.note.frameOffset.y -= noteProperties.offsets.sustains[1] ?? 0;
					}
				} else {
					if (noteProperties.offsets.notes != null) {
						e.note.frameOffset.x -= noteProperties.offsets.notes[0] ?? 0;
						e.note.frameOffset.y = noteProperties.offsets.notes[1] ?? 0;
					}
				}
			}
		}
	}

}

function checkFileExists(path:String) {
	return Assets.exists(Paths.getPath(path));
}

class CachableFrames extends FlxSprite {
	public var tag:String;
}

var cachedFrames = [];

function cacheFrames(frames:CachableFrames) {
	cachedFrames.push(frames);
}

function getFrames(type:String) {
	for (i in 0...cachedFrames.length)
		if (cachedFrames[i].tag == type)
			return cachedFrames[i].frames;

	var framesToCache = new CachableFrames();
	framesToCache.tag = type;
	framesToCache.frames = Paths.getSparrowAtlas('game/notes/' + type);
	cacheFrames(framesToCache);
	return framesToCache.frames;
}

var defaultStrumPoses = [];
function di(num) {
	if (downscroll) {
		return num * -1;
	} else {
		return num;
	}
	return num * (downscroll ? -1 : 1);
}
function postUpdate(elasped:Float) {
	for (si=> strumLine in strumLines.members) {
		for (i=> strumLine in strumLine.members) {
			if (strumLine.animation.name == 'static') {
				if (!disablePositioning) strumLine.x = defaultStrumPoses[i + (4 * si)].x + globalStrumOffsets[i + (4 * si)].statics.x;
				strumLine.y = defaultStrumPoses[i + (4 * si)].y + globalStrumOffsets[i + (4 * si)].statics.y;
			}
		}
	}
}

function postCreate() {
	for (strumLine in strumLines.members) {
		for (strum in strumLine) {
			defaultStrumPoses.push({
				x: strum.x,
				y: strum.y,
				width: strum.width,
				height: strum.height
			});
		}
	}
}
var songSkinData;
function checkSongSkinData(si) {
	if (songSkinData == null) return null;
	return songSkinData?.noteSkin?.strumSpecific[si]?.strums;
}
function onStartSong() {
	if (checkFileExists('songs/' + SONG.meta.name + '/noteskin.json')) {
		var songSkinText = Assets.getText('songs/' + SONG.meta.name + '/noteskin.json');
		songSkinData = Json.parse(songSkinText);
	}
	for (si=> strumLine in strumLines.members) {
		strumLines.members[si].onHit.add((e) -> {
			var additiveNum = 4;
			var dirs = ['left', 'down', 'up', 'right'];
			if (e.noteType != null || checkSongSkinData(si) != null) {
				var daType = e.noteType != null ? e.noteType : checkSongSkinData(si);
				if (checkFileExists('images/game/notes/' + daType + '.json')) {
					skinData = Json.parse(Assets.getText(Paths.getPath('images/game/notes/' + daType + '.json')));
					e.note.splash = songSplashes[si] != '' ? (songSplashes[si] ?? (skinData.splashSkin != null && skinData.splashSkin.name != null ? skinData.splashSkin.name : 'default')) : ('default');
					var strumsLoop = (skinData != null) ? (skinData.strumsLoop != null ? skinData.strumsLoop : false) : false;
					strumLines.members[si].members[e.direction].frames = getFrames((skinData.spriteName != null ? Path.withoutExtension(skinData.spriteName) : daType));
					strumLines.members[si].members[e.direction].animation.addByPrefix('static', 'arrow' + dirs[e.direction].toUpperCase(), 24, strumsLoop);
					strumLines.members[si].members[e.direction].animation.addByPrefix('confirm', dirs[e.direction] + ' confirm', 24, false);
					strumLines.members[si].members[e.direction].animation.addByPrefix('pressed', dirs[e.direction] + ' press', 24, false);
					strumLines.members[si].members[e.direction].extra.set('type', daType);
					if (!disablePositioning) strumLines.members[si].members[e.direction].x = defaultStrumPoses[e.direction + (additiveNum * si)].x;
					strumLines.members[si].members[e.direction].y = defaultStrumPoses[e.direction + (additiveNum * si)].y;

					defaultNext[e.direction + (additiveNum * si)] = skinData.defaultAfterPress;

					strumLines.members[si].members[e.direction].updateHitbox();
					if (!disablePositioning) strumLines.members[si].members[e.direction].x += skinData.offsets.confirm[0] ?? 0;
					strumLines.members[si].members[e.direction].y += di(skinData.offsets.confirm[1] ?? 0);
				}
				// e.cancelStrumGlow();
			} else {
				if (defaultNext[e.direction + (additiveNum * si)]) {
					strumLines.members[si].members[e.direction].frames = getFrames('default');
					strumLines.members[si].members[e.direction].animation.addByPrefix('static', 'arrow' + dirs[e.direction].toUpperCase(), 24, false);
					strumLines.members[si].members[e.direction].animation.addByPrefix('confirm', dirs[e.direction] + ' confirm', 24, false);
					strumLines.members[si].members[e.direction].animation.addByPrefix('pressed', dirs[e.direction] + ' press', 24, false);
					strumLines.members[si].members[e.direction].extra.set('type', e.noteType);
					strumLines.members[si].members[e.direction].updateHitbox();
					defaultNext[e.direction + (additiveNum * si)] = false;
				}
				strumLines.members[si].members[e.direction].x = (defaultStrumPoses[e.direction + (additiveNum * si)].x) + globalStrumOffsets[e.direction + (si * 4)].statics.x;
				strumLines.members[si].members[e.direction].y = (defaultStrumPoses[e.direction + (additiveNum * si)].y) + globalStrumOffsets[e.direction + (si * 4)].statics.y;
			}
		});
	}
}