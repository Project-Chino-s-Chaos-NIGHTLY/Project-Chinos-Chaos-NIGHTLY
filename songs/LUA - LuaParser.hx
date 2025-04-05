import haxe.Log;
import sys.FileSystem;
import sys.io.File;
import flixel.system.debug.log.LogStyle;
import funkin.backend.scripting.HScript;
import funkin.backend.system.Logs;
import novalua.Converter;
import novalua.LuaPath;
import novalua.LuaSprite;

var converter = new Converter();
var luaScripts = [];

var luaSprites = [];

public function luaCall(name, ?parameter) {
	for (i in 0...luaScripts.length) {
		luaScripts[i].call(name, parameter);
	}
}
public function luaSet(variable:String, value:Dynamic) {
	for (script in luaScripts) {
		script.set(variable, value);
	}
}
public function luaSetCallback(variable:String, value:Dynamic) {
	luaSet(variable, value);
}
public function getLuaSprite(tag) {
	for (spriteIndex in 0...luaSprites.length) {
		if (luaSprites[spriteIndex].stringID == tag) {
			return luaSprites[spriteIndex];
		}
	}
}
public function getCharacterLowestGroupIndex() {
	var lowestCharIndex:Int = 999999;
	var lowestChar;
	var characters = [dad, boyfriend, girlfriend];
	for (char in characters) {
		if (members.indexOf(char) < lowestCharIndex) {
			lowestCharIndex = members.indexOf(char);
			lowestChar = char;
		}
	}
	return { character: lowestChar, index: lowestCharIndex }
}
function initCallbacks() {
	luaSetCallback("makeLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0) {
		var tempSprite = new LuaSprite(x, y).loadGraphic(Paths.image(image));
		tempSprite.stringID = tag;
		luaSet(tag, tempSprite);
		luaSprites.push(tempSprite);
	});
	luaSetCallback("makeAnimatedLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0) {
		var tempSprite = new LuaSprite(x, y);
		tempSprite.frames = Paths.getSparrowAtlas(image);
		tempSprite.stringID = tag;
		luaSet(tag, tempSprite);
		luaSprites.push(tempSprite);
	});
	luaSetCallback("makeGraphic", function(obj:String, ?width:Int = 256, ?height:Int = 256, ?color:String = 'FFFFFF') {
		if (!StringTools.startsWith(color, "#")) {
			color = "#" + color;
		}
		var finalColor = FlxColor.fromString(color);
		getLuaSprite(obj).makeGraphic(width, height, finalColor);
	});
	luaSetCallback("addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			var obj:LuaSprite = getLuaSprite(obj);
			if(obj != null && obj.animation != null)
			{
				obj.animation.addByPrefix(name, prefix, framerate, loop);
				if(obj.animation.curAnim == null)
				{
					if(obj.playAnim != null) obj.playAnim(name, true);
					else obj.animation.play(name, true);
				}
				return true;
			}
			return false;
	});
	luaSetCallback("addAnimation", function(obj:String, name:String, frames:Array<Int>, framerate:Int = 24, loop:Bool = true) {
		var obj:LuaSprite = getLuaSprite(obj);
		if(obj != null && obj.animation != null)
		{
			obj.animation.add(name, frames, framerate, loop);
			if(obj.animation.curAnim == null) {
				obj.animation.play(name, true);
			}
			return true;
		}
		return false;
	});
	luaSetCallback("playAnim", function(obj:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0) {
		var obj:LuaSprite = getLuaSprite(obj);
		if(obj.playAnim != null)
		{
			obj.playAnim(name, forced, reverse, startFrame);
			return true;
		}
		else
		{
			if(obj.anim != null) obj.anim.play(name, forced, reverse, startFrame); //FlxAnimate
			else obj.animation.play(name, forced, reverse, startFrame);
			return true;
		}
		return false;
	});
	luaSetCallback("addLuaSprite", function(tag:String, front:Bool = false) {
		//trace(getLuaSprite(tag));
		var obj:LuaSprite = getLuaSprite(tag);
		if (front) {
			add(getLuaSprite(tag));
		} else {
			insert(getCharacterLowestGroupIndex().index, getLuaSprite(tag));
		}
	});
	luaSetCallback("setProperty", function(prop:String, value:Dynamic) {
		var props = prop.split(".");
		var objName = props[0];
		switch (objName) {
			case "girlfriend":
				if (props[1] == "x") {
					gf.x = value;
				} else if (props[1] == "y") {
					gf.y = value;
				} else if (props[1] == "angle") {
					gf.angle = value;
				} else if (props[1] == "alpha") {
					gf.alpha = value;
				} else if (props[1] == "visible") {
					gf.visible = value;
				}
			case "boyfriend":
				if (props[1] == "x") {
					boyfriend.x = value;
				} else if (props[1] == "y") {
					boyfriend.y = value;
				} else if (props[1] == "angle") {
					boyfriend.angle = value;
				} else if (props[1] == "alpha") {
					boyfriend.alpha = value;
				} else if (props[1] == "visible") {
					boyfriend.visible = value;
				}
			case "dad":
				if (props[1] == "x") {
					dad.x = value;
				} else if (props[1] == "y") {
					dad.y = value;
				} else if (props[1] == "angle") {
					dad.angle = value;
				} else if (props[1] == "alpha") {
					dad.alpha = value;
				} else if (props[1] == "visible") {
					dad.visible = value;
				}
			default:
				getLuaSprite(objName).set(props, value);
		}
	});
	luaSetCallback("getProperty", function(prop:String) {
		var props = prop.split(".");
		var objName = props[0];
		switch (objName) {
			case "girlfriend":
				if (props[1] == "x") {
					return gf.x;
				} else if (props[1] == "y") {
					return gf.y;
				} else if (props[1] == "angle") {
					return gf.angle;
				} else if (props[1] == "alpha") {
					return gf.alpha;
				} else if (props[1] == "visible") {
					return gf.visible;
				}
			case "boyfriend":
				if (props[1] == "x") {
					return boyfriend.x;
				} else if (props[1] == "y") {
					return boyfriend.y;
				} else if (props[1] == "angle") {
					return boyfriend.angle;
				} else if (props[1] == "alpha") {
					return boyfriend.alpha;
				} else if (props[1] == "visible") {
					return boyfriend.visible;
				}
			case "dad":
				if (props[1] == "x") {
					return dad.x;
				} else if (props[1] == "y") {
					return dad.y;
				} else if (props[1] == "angle") {
					return dad.angle;
				} else if (props[1] == "alpha") {
					return dad.alpha;
				} else if (props[1] == "visible") {
					return dad.visible;
				}
			default:
				return getLuaSprite(objName).get(props);
		}
	});
	luaSetCallback("runTimer", function(tag:String, duration:Float) {
		callbackTrace("Ran Timer");
		new FlxTimer().start(duration, (timer) -> {
			callbackTrace("Timer Completed: " + tag);
			luaCall("onTimerCompleted", [tag]);
		});
	});
	luaSetCallback("lerp", lerp);
	luaSetCallback("debugPrint", debugPrint);
	luaSetCallback("runHaxeCode", function(code:String) {
		var hscript:HScript = new HScript().loadFromString(code);
		hscript.fileName = "runHaxeCode";
		hscript.load();
	});
}
var lvl = {
	INFO: 0,
	WARNING: 1,
	ERROR: 2,
	TRACE: 3,
	VERBOSE: 4
}
function parserTrace(text:String, ?level:Int) {
	Logs.trace("[LUA PARSER]: " + text, level ?? lvl.TRACE);
}
function callbackTrace(text:String, ?level:Int) {
	Logs.trace("[LUA CALLER]: " + text, level ?? lvl.TRACE);
}
function create() {
	var files = Paths.getFolderContent("songs/", true);
	var songScripts = Paths.getFolderContent("songs/" + SONG.meta.name + "/scripts/", true);
	files = files.concat(songScripts);
	var filesNoPath = Paths.getFolderContent("songs/");
	var songScripts = Paths.getFolderContent("songs/" + SONG.meta.name + "/scripts/");
	filesNoPath = filesNoPath.concat(songScripts);
	parserTrace("Searching \"songs/\" for Lua Scripts");
	parserTrace("Searching \"songs/" + SONG.meta.name + "/scripts/\" for Lua Scripts");
	var scriptPaths = [];
	for (fileI in 0...files.length) {
		var file = files[fileI];
		var fileName = filesNoPath[fileI];
		if (StringTools.endsWith(file, ".lua")) {
			var modRoot = StringTools.replace(Paths.getAssetsRoot(), "./", "") + "/";
			var combinedPathMod = modRoot + file;
			var combinedPathAsset = "assets/" + file;
			if (FileSystem.exists(combinedPathMod)) {
				parserTrace("Lua Script Found at \"" + combinedPathMod + "\"");
				scriptPaths.push(new LuaPath(combinedPathMod, fileName));
			}
			if (FileSystem.exists(combinedPathAsset)) {
				parserTrace("Lua Script Found at \"" + combinedPathAsset + "\"");
				scriptPaths.push(new LuaPath(combinedPathAsset, fileName));
			}
		}
	}
	for (path in scriptPaths) {
		parserTrace("Lua Script Loading from: \"" + path.path + "\"");
		var fileContent = File.getContent(path.path);
		if (fileContent == "") {
			//trace(new LogStyle().ERROR);
			parserTrace("Lua Script \"" + path.name + "\" is blank; Skipping Lua Script", lvl.WARNING);
		} else {
			if (StringTools.startsWith(fileContent, "skipFile = true")) {
				parserTrace("Lua Script \"" + path.name + "\" is a skip file, skipping");
			} else {
				var code = converter.convertToHaxe(fileContent);
				var hscript:HScript = new HScript().loadFromString(code);
				hscript.fileName = path.name;
				hscript.load();
				hscript.call("onLoaded");
				luaScripts.push(hscript);
				parserTrace("Lua Script \"" + path.name + "\" Loaded Successfully; Yipee!");
			}
		}
	}
	initCallbacks();
	onCreate();
}

function onCreate() {
	luaCall("onCreate");
	luaCall("create");
}

function postCreate() {
	luaSet("defaultBoyfriendX", boyfriend.x);
	luaSet("defaultBoyfriendY", boyfriend.y);
	luaSet("boyfriend", boyfriend);

	luaCall("onCreatePost");
	luaCall("postCreate");
}

function beatHit() {
	luaCall("onBeatHit");
	luaCall("beatHit");
}

function stepHit() {
	luaCall("onStepHit");
	luaCall("stepHit");
}

function update(elapsed) {
	luaSet("stage", stage);
	luaSet("curBeat", curBeat);
	luaSet("curStep", curStep);

	luaSet("boyfriend", boyfriend);

	luaCall("onUpdate", [elapsed]);
	luaCall("update", [elapsed]);
}
function onStartSong() {
	strumLines.members[0].onHit.add((event) -> {
		luaCall("opponentNoteHit", [event.direction, event.direction, event.noteType, event.isSustainNote]);
	});
	strumLines.members[1].onHit.add((event) -> {
		luaCall("goodNoteHit", [event.direction+4, event.direction, event.noteType, event.isSustainNote]);
	});
	luaCall("onSongStart");
	luaCall("onStartSong");
}
