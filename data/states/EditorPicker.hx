import funkin.editors.EditorTreeMenu;
import flixel.effects.FlxFlicker;

var skinIndex;
function create() {
    //options.push();
	skinIndex = options.length;
    options.push({
		name: "Noteskin Editor",
		iconID: 3,
		state: ModState
	});

}

function postCreate() {
	var width = sprites[sprites.length-1].iconSpr.width;
	sprites[sprites.length-1].iconSpr.loadGraphic(Paths.image("editors/noteskin"));
	sprites[sprites.length-1].iconSpr.setGraphicSize(width);
	sprites[sprites.length-1].iconSpr.updateHitbox();
}

var overrodeFlicker = false;
function update() {
	if (skinIndex <= -1 || overrodeFlicker) return;

	if (curSelected == skinIndex && selected && FlxFlicker.isFlickering(sprites[skinIndex].label)) {
		FlxFlicker._boundObjects[sprites[skinIndex].label].completionCallback = function(flick) {
			subCam.fade(0xFF000000, 0.25, false, function() {
				var state = new EditorTreeMenu();
				state.scriptName = "noteSkinEditor/selector/SkinSelector"; // OVERRIDING NEW AIANT GON STOP ME OPTIONS.TREEMENU
				FlxG.switchState(state);
			});
		}
		overrodeFlicker = true;
	}
}