import funkin.editors.charter.Charter;
import haxe.Json;
import haxe.io.Path;
function checkFileExists(path:String) {
	return Assets.exists(Paths.getPath(path));
}
var songSkinData;
var jsonData:String = '';
function postCreate() {
    trace(notesGroup);
    //var jsonData:String = '';
    //workingSongName = __song.toLowerCase();
    updateCharterNotes();
}
var selectedNotes = [];
var daTween;
function postUpdate() {
    if (FlxG.mouse.justReleased || FlxG.keys.justPressed.E || FlxG.keys.justPressed.Q) {
        for (i=>note in Charter.instance.selection) {
            //trace(thing);
            if (note.strumLineID != null && note.strumLineID != -1) {
                var skinName = songSkinData.noteSkin.strumSpecific[note.strumLineID].notes;
                if (checkFileExists('images/game/notes/' + skinName + '.json')) {
                    var skinJson = Json.parse(Assets.getText('images/game/notes/' + skinName + '.json'));
                    note.frames = Paths.getSparrowAtlas('game/notes/' + (skinJson.spriteName != null ? Path.withoutExtension(skinJson.spriteName) : skinName));
                    var anim = ['purple', 'blue', 'green', 'red'][note.id];
                    note.animation.addByPrefix('note', anim + '0', 24, true);
                    note.animation.play('note', true);
                    //note.angle = 0;
                    note.frameOffset.x = -skinJson.offsets.notes[0];
                    note.frameOffset.y = skinJson.offsets.notes[1];
                    FlxTween.cancelTweensOf(note);
                    note.angle = 0;
                }
                //daTween?.cancel();
                //note.angle = -90;
                //daTween = FlxTween.tween(note, {angle: 0}, 1, {ease: FlxEase.backOut});
            }
        }
    }
   
    for (note in Charter.instance.selection) {
        //note.angleTween?.cancel();
        //note.angle = 0;
    }
}
function update() {
    for (i=>note in Charter.instance.notesGroup.members) {
        if (note.strumLineID != null && note.strumLineID != -1) {
            note.height = 40;
        }
    }
}


static function updateCharterNotes() {
    if (checkFileExists('songs/' + Charter.instance.__song.toLowerCase() + '/noteskin.json')) {
        jsonData = Assets.getText('songs/' + Charter.instance.__song.toLowerCase() + '/noteskin.json');
    }
    if (jsonData == null || jsonData == '') {
        if (checkFileExists('songs/' + Charter.instance.__song + '/noteskin.json')) {
            jsonData = Assets.getText('songs/' + Charter.instance.__song + '/noteskin.json');
        }
    }
    //trace(jsonData);
    if (jsonData != '') {
        songSkinData = Json.parse(jsonData);
        //trace(songSkinData);
        for (note in notesGroup) {
            //trace(note.strumLineID);
            var skinName = songSkinData.noteSkin.strumSpecific[note.strumLineID].notes;
            if (checkFileExists('images/game/notes/' + skinName + '.json')) {
                var skinJson = Json.parse(Assets.getText('images/game/notes/' + skinName + '.json'));
                note.frames = Paths.getSparrowAtlas('game/notes/' + (skinJson.spriteName != null ? Path.withoutExtension(skinJson.spriteName) : skinName));
                var anim = ['purple', 'blue', 'green', 'red'][note.id];
                note.animation.addByPrefix('note', anim + '0', 24, true);
                note.animation.play('note', true);
                note.angle = 0;
                note.frameOffset.x = -skinJson.offsets.notes[0];
                note.frameOffset.y = skinJson.offsets.notes[1];
                ///trace(skinJson);
            }
        }
    }
}