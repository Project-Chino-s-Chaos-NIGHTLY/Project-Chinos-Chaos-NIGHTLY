public var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
var camOther:FlxCamera;

function create() {
	camOther = new FlxCamera();
	camOther.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(camOther, false);
	luaDebugGroup = new FlxTypedGroup();
	luaDebugGroup.cameras = [camOther];
	add(luaDebugGroup);
}

public function debugPrint(?text1:String, ?text2:String, ?text3:String, ?text4:String, ?text5:String) {
	var finalText = (text1 ?? '' + text2 ?? '' + text3 ?? '' + text4 ?? '' + text5 ?? '');
	addTextToDebug(finalText, FlxColor.WHITE);
	trace("debugPrint: " + finalText);
}

public function debugPrintSystem(text:Dynamic) {
	addTextToDebug(text, FlxColor.WHITE);
}

import flixel.text.FlxTextBorderStyle;

class DebugLuaText extends FlxText {
	public var parentGroup:FlxTypedGroup<DebugLuaText>;

	public function new(text:String, parentGroup:FlxTypedGroup<DebugLuaText>, color:FlxColor) {
		this.parentGroup = parentGroup;
		this.x = 10;
		this.y = 10;
		this.fieldWidth = 0;
		this.text = text;
		this.size = 16;
		setFormat(Paths.font("vcr.ttf"), 16, color, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollFactor.set();
		borderSize = 1;
	}
}

function addTextToDebug(text:String, color:FlxColor) {
	// trace("Ran The Shit");
	luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
		spr.y += 20;
	});

	if (luaDebugGroup.members.length > 34) {
		var blah = luaDebugGroup.members[34];
		// blah.destroy();
		luaDebugGroup.remove(blah);
	}
	var theSprite = new DebugLuaText(text, luaDebugGroup, color);
	luaDebugGroup.insert(0, theSprite);
	FlxTween.tween(theSprite, {alpha: 0}, 1, {
		onComplete: function() {
			theSprite.destroy();
			luaDebugGroup.remove(theSprite);
		},
		startDelay: 3
	});
}