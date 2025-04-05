import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import funkin.editors.charter.Charter;
import funkin.editors.ui.UIDropDown;
import funkin.editors.ui.UIText;

var noteSkinJson;
var noteSkinSample = '{
    "noteSkin": {
        "strumSpecific": []
    },
    "splashSkin": "vanilla"
}';
function getNewStrumData(name) {
    return { strums: name, notes: name }
}
function checkFileExists(path:String) {
	return Assets.exists(Paths.getPath(path));
}
//var workingSongName:String;
function postCreate() {
    var strumLines = Charter.instance.strumLines;
    var jsonData:String = '';
    //workingSongName = Charter.instance.__song.toLowerCase();
    if (checkFileExists('songs/' + Charter.instance.__song.toLowerCase() + '/noteskin.json')) {
        jsonData = Assets.getText('songs/' + Charter.instance.__song.toLowerCase() + '/noteskin.json');
    }
    if (jsonData == null || jsonData == '') {
        if (checkFileExists('songs/' + Charter.instance.__song + '/noteskin.json')) {
            jsonData = Assets.getText('songs/' + Charter.instance.__song + '/noteskin.json');
        }
    }
    if (jsonData == null || jsonData == '') {
        jsonData = noteSkinSample;
    }
    var skinData:Dynamic = Json.parse(jsonData);
    if (skinData.noteSkin.strumSpecific.length != strumLines.members.length) {
        for (strumline in strumLines.members) {
            skinData.noteSkin.strumSpecific.push(getNewStrumData('default'));
            if (skinData.noteSkin.strumSpecific.length == strumLines.members.length) break;
        }
    }
    //trace(Charter.instance.get_chart().meta.name);

    function addLabelOn(ui:UISprite, text:String)
        add(new UIText(ui.x, ui.y - 24, 0, text));

    var modsList = getNoteList(true);

	noteSkinList = [];
	for (skin in (modsList.length == 0 ? getNoteList(false) : modsList)) {
		if (skin == 'default') {
			noteSkinList.insert(0, skin);
		} else {
			noteSkinList.push(skin);
		}
	}

    var spriteDropdown = new UIDropDown(stagePositionDropdown.x, vocalsSuffixDropDown.y, 200, 32, noteSkinList, noteSkinList.indexOf(skinData.noteSkin.strumSpecific[strumLineID].strums));
    spriteDropdown.onChange = function(to) {
		trace('Crazy');
        skinData.noteSkin.strumSpecific[strumLineID].strums = spriteDropdown.options[to];
        skinData.noteSkin.strumSpecific[strumLineID].notes = spriteDropdown.options[to];
        trace(skinData);
    }
    add(spriteDropdown);

    addLabelOn(spriteDropdown, "Note Skin");

    var oldSave = onSave;
    onSave = function(?strumLine) {
        if (oldSave != null) oldSave(strumLine);
        var modRoot = StringTools.replace(Paths.getAssetsRoot(), "./", "") + "/";
        File.saveContent(modRoot + 'songs/' + Charter.instance.__song.toLowerCase() + '/noteskin.json', Json.stringify(skinData, null, '    '));
        updateCharterNotes();
    }
}
static function getNoteList(mods) {
	return [
		for (path in Paths.getFolderContent('images/game/notes/', true, mods ? false : null)) // BOTH: null | MODS: false
			if (Path.extension(path) == "json") Path.withoutDirectory(Path.withoutExtension(path))
	];
}
