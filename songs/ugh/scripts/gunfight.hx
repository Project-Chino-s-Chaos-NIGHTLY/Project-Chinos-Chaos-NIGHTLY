var doWarning = false;
var killAfter = false;
var shaking = false;
var earlyWindow = false;

var pressedEarly = false;

var shootFrameStart = 8;
var shootFrameEnd = 12;
var curSector = 3;

var warning:FlxSprite;
var early:FlxSprite;
var late:FlxSprite;

var shootSound:FlxSound = FlxG.sound.load(Paths.sound("Gun"));

var defaultPos:{x:Float, y:Float} = {x: 0, y: 0}
function fireGun() {
	shootSound.play();
	camGame.shake(0.005, 0.2);
}
function getStagePath(file:String) {
	return "stages/Vs Tankman/gunfight/" + file;
}
function postCreate() {
	warning = new FlxSprite();
	warning.loadGraphic(Paths.image(getStagePath("warning")));
	warning.antialiasing = true;
	warning.cameras = [camHUD];
	warning.screenCenter();
	warning.alpha = 0;
	add(warning);

	early = new FlxSprite();
	early.loadGraphic(Paths.image(getStagePath("early")));
	early.antialiasing = true;
	early.cameras = [camHUD];
	early.screenCenter();
	early.alpha = 0;
	add(early);

	late = new FlxSprite();
	late.loadGraphic(Paths.image(getStagePath("late")));
	late.antialiasing = true;
	late.cameras = [camHUD];
	late.screenCenter();
	late.alpha = 0;
	add(late);
}
function playSound(name:String, ?volume:Float = 1) {
	if (volume > 1) {
		for (i in 0...Math.round(volume)) {
			playSound(name, 1);
		}
	} else {
		var sound:FlxSound = FlxG.sound.load(Paths.sound(name));
		sound.volume = volume;
		sound.play();
	}
}
var daTween = null;
var daTween2 = null;
function warn(?type) {
	switch (type) {
		case "early":
			early.alpha = 1;
			if (daTween2 != null) {
				daTween2.cancel();
			}
			daTween2 = FlxTween.tween(early, {alpha:0}, 0.3);
		case "late":
			late.alpha = 1;
			if (daTween2 != null) {
				daTween2.cancel();
			}
			daTween2 = FlxTween.tween(late, {alpha:0}, 0.3);
		default:
			playSound("CountTick0", 5);
			warning.alpha = 1;
			if (daTween != null) {
				daTween.cancel();
			}
			daTween = FlxTween.tween(warning, {alpha:0}, 0.3);

	}
}
var stepsToShoot = [128];
function stepHit() {
	//debugPrint(curStep);
	if (stepsToShoot.contains(curStep + 4)) {
		dad.playAnim("shoot", true);
		killAfter = true;
	}
	if (stepsToShoot.contains(curStep + (4*4))) {
		doWarning = true;
	}
	if (stepsToShoot.contains(curStep)) {
		fireGun();
		doWarning = false;
	}
	if (curBeat == curStep / 4) customBeatHit();
}
function customBeatHit() {
	if (!doWarning) return;
	if (curSector == 0) {
		curSector = 3;
	} else {
		//debugPrint(curSector);
		warn();
		curSector--;
		if (curSector == 2) {
			earlyWindow = true;
		}
	}
}
function postUpdate(elasped:Float) {
	if (earlyWindow && FlxG.keys.justPressed.P && !pressedEarly) {
		pressedEarly = true;
		warn("early");
	}
	dad.animation.callback = function(name, frame, index) {
		if (name == "shoot" && frame >= shootFrameStart && frame <= shootFrameEnd) {
			earlyWindow = false;
			if (FlxG.keys.justPressed.P && killAfter && !pressedEarly) {
				killAfter = false;
				boyfriend.playAnim("dodge", true);
			}
		}
		if (name == "shoot" && frame < shootFrameStart && FlxG.keys.justPressed.P) {

		}
		if (name == "shoot" && frame > shootFrameEnd && FlxG.keys.justPressed.P) {
			warn("late");
		}
		if (name == "shoot" && frame == shootFrameEnd+1 && killAfter) {
			boyfriend.playAnim("hit", true);
			health -= 0.5;
			trace("Ouchy");
			pressedEarly = false;
		}
	}
}

function onStartSong() {
	strumLines.members[1].onHit.add((event) -> {
		if (boyfriend.animation.name == "dodge" || boyfriend.animation.name == "hit") {
			event.animCancelled = true;
		}
	});
}
