import Type;

class Keyframe {
	public var effectie:Dynamic;
	public var values;

	public function new(Var:Dynamic, Values) {
		effectie = Var;
		values = Values;
	}

	public function trigger(res:Int) {
		var daType = Type.typeof(effectie);
		var flxSprite = Type.typeof(new FlxSprite());

		var fallbackVarFloat:Float = 0;
		var fallbackVarPoint:FlxPoint = FlxPoint.get();
		var fallbackVarColor:FlxColor = 0x00000000;
		var scaleFactor:Float = FlxG.height / res;
		effectie.x != null ? effectie.x = (values.x ?? (effectie.x ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'x' variable found.");
		effectie.y != null ? effectie.y = (values.y ?? (effectie.y ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'y' variable found.");
		effectie.angle != null ? effectie.angle = values.angle ?? (effectie.angle ?? fallbackVarFloat) : trace("Whoops, no 'angle' variable found.");
		effectie.scale.x != null ? effectie.scale.x = (values.scale.x ?? (effectie.scale.x ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'scale.x' variable found.");
		effectie.scale.y != null ? effectie.scale.y = (values.scale.y ?? (effectie.scale.y ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'scale.x' variable found.");
		effectie.alpha != null ? effectie.alpha = values.alpha ?? (effectie.alpha ?? fallbackVarFloat) : trace("Whoops, no 'alpha' variable found.");
		effectie.color != null ? effectie.color = values.color ?? (effectie.color ?? fallbackVarColor) : trace("Whoops, no 'color' variable found.");
	}
}

class Frame {
	public var values = {}

	public function new() {
		// Blank frame :D
	}

	public function trigger() {
		// Blank frame :D
	}
}

class Animation {
	public var keyframes:Array = [];
	public var framerate:Int = 24;
	public var running:Bool = false;
	public var paused:Bool = false;
	public var curFrame:Int = 0;
	public var startFrame:Int = 0;
	public var finishCallback:Void->Void;
	public var originalResolution:Int = 720;

	public function new(?data) {
		if (data != null) {
			keyframes = data.frames ?? [];
			framerate = data.framerate ?? 24;
			startFrame = data.startFrame ?? 0;
			finishCallback = data.finishCallback ?? null;
		}
	}

	public function addKeyframe(keyframe:Keyframe) {
		keyframes.push(keyframe);
	}

	public function addFrame() {
		keyframes.push(new Frame());
	}

	private function frameLoop() {
		if (!running || paused) return;
		if (keyframes[curFrame] == null || keyframes[curFrame].trigger == null) {
			stop();
			if (finishCallback != null) {
				finishCallback();
			}
			return;
		}
		keyframes[curFrame].trigger(originalResolution);
		curFrame++;
		new FlxTimer().start(1 / framerate, function(timer) {
			frameLoop();
		});
	}

	public function pause() {
		paused = true;
	}

	public function resume() {
		paused = false;
		if (running) {
			frameLoop();
		}
	}

	public function stop() {
		running = false;
		paused = false;
		curFrame = 0;
	}

	public function play() {
		stop();
		if (!paused) {
			curFrame = startFrame;
			running = true;
			frameLoop();
		}
	}
}

class LaneUnderlay {
	public var sprite:FlxSprite;

	public function new(X:Float, width:Float, alpha:Int, color:FlxColor) {
		sprite = new FlxSprite(X, 0);
		sprite.makeGraphic(width, FlxG.height, color);
		sprite.antialiasing = true;
		sprite.alpha = alpha / 100;
	}
}

var strumAnims:Array<Array<Animation>> = [];
var underlays:Array<LaneUnderlay> = [];
var colors:Array<FlxColor> = [0xFFc24b99, 0xFF00FFFF, 0xFF12fa05, 0xFFf9393f];
var colorsDark:Array<FlxColor> = [0xFF61264d, 0xFF008080, 0xFF097d03, 0xFF7d1d20];
var fireNote:FlxColor = 0xFFff9600;
var strumers:Array<FlxSprite> = [];
var def:Float = 0.7;

function postCreate() {
	var ind:Int = 0;
	for (strumline in strumLines.members) {
		strumAnims.push([]);
		for (strum in strumline.members) {
			var daAnim:Animation = new Animation();
			def = strum.scale.x;
			daAnim.addKeyframe(new Keyframe(strum, {scale: {x: def * 1.2, y: def * 0.8}}));
			daAnim.addKeyframe(new Keyframe(strum, {scale: {x: def * 1.05, y: def * 0.95}}));
			daAnim.addKeyframe(new Keyframe(strum, {scale: {x: def, y: def}}));
			daAnim.addKeyframe(new Keyframe(strum, {scale: {x: def * 0.95, y: def * 1.05}}));
			daAnim.addKeyframe(new Keyframe(strum, {scale: {x: def, y: def}}));
			strumAnims[ind].push(daAnim);
			var strumClone:FlxSprite = strum.clone();
			strumClone.scale.set(def, def);
			strumClone.updateHitbox();
			strumClone.x = strum.x + (strum.width / 2) - (strumClone.width / 2);
			strumClone.y = strum.y + (strum.height / 2) - (strumClone.height / 2);
			strumers.push(strumClone);

			if (ModOptions.underlayOpacity > 0 && strumLines.members.indexOf(strumline) < 2) {
				var underlay:LaneUnderlay = new LaneUnderlay(strum.x, strum.width, ModOptions.underlayOpacity, (ModOptions.laneTint && !ModOptions.responsiveLanes) ? colorsDark[strumLines.members[strumLines.members.indexOf(strumline)].members.indexOf(strum)] : FlxColor.BLACK);
				underlay.sprite.cameras = [camHUD];
				// if (ModOptions.laneTint) { // && !ModOptions.responsiveLanes
				// underlay.sprite.color = colors[strumLines.members[strumLines.members.indexOf(strumline)].members.indexOf(strum)];
				// }
				insert(strumLines.members.indexOf(strumLines.members[1]) - 1, underlay.sprite);
				// add(underlay.sprite);
				underlays.push(underlay);
			}
		}
		ind += 1;
	}
	// animationTest.addKeyframe(new Keyframe(healthBar, {x: defHeaBarPos.x - 2, y: defHeaBarPos.y + 2}));
	// animationTest.addKeyframe(new Keyframe(healthBar, {x: 13, y: 10}));
	// animationTest.addKeyframe(new Keyframe(healthBar, {x: 16, y: 10}));
	// animationTest.addKeyframe(new Keyframe(healthBar, {x: 28, y: 10}));

	/*
		//     Example Code
		var animation:Animation = new Animation({
			frames: [new Keyframe(object, data)], // You can add all frames at once, or use addKeyframe/addFrame
			framerate: 60, // Animation's framerate, default is 24fps
			startFrame: 0, // Frame to start playing, default is 0
			finishCallback: function() { // Callback when the animation is finished
				trace("Animation finished");
			}
		}) // All values are optional
		animation.addKeyframe(new Keyframe(object, data)) // data is a struct EX: {x: 10, y: 10, angle: 10}
		animation.addFrame() // Adds a frame, like F5 in adobe.
		// ^ also is the same as a blank keyframe.
		animation.play(); // Starts playing the animation.
		animation.stop();
		animation.pause();
		animation.resume(); // Not the same as .play()
	 */
}

function stepHit() {
	// switch (curStep) {
	// 	case 10:
	// 		animationTest.play();
	// }
}

function onPlayerHit(event) {
	var lineIndex:Int = strumLines.members.indexOf(event.note.strumLine);
	var strumerIndex:Int = event.direction + event.note.strumLine.length;
	if (ModOptions.comboNotes) {
		if (combo >= 5 && (combo + 5) % 10 == 0) {
			var strumClone:FlxSprite = strumers[strumerIndex].clone();
			strumClone.animation.play("confirm", true);
			strumClone.scale.set(def, def);
			strumClone.updateHitbox();
			strumClone.x = strumers[strumerIndex].x + (strumers[strumerIndex].width / 2) - (strumClone.width / 2);
			strumClone.y = strumers[strumerIndex].y + (strumers[strumerIndex].height / 2) - (strumClone.height / 2);
			strumClone.cameras = [camHUD];
			strumClone.alpha = 0.5;
			var fuck = FlxTween.tween(strumClone.scale, {x: def + 0.3, y: def + 0.3}, 0.3);
			var fuck2 = FlxTween.tween(strumClone, {alpha: 0}, 0.3, {
				onComplete: function() {
					strumClone.destroy();
				}
			});
			add(strumClone);
		}
	}
	if (ModOptions.noteSquish) {
		if (!event.isSustainNote) {
			strumAnims[lineIndex][event.direction].play();
		}
	}
	if (ModOptions.responsiveLanes && ModOptions.underlayOpacity > 0) {
		if (ModOptions.laneTint && ModOptions.responsiveLanes) {
			underlays[strumerIndex].sprite.makeGraphic(underlays[strumerIndex].sprite.width, FlxG.height, event.noteType != 'Attack' ? colors[event.direction] : fireNote);
			FlxTween.color(underlays[strumerIndex].sprite, 0.3, event.noteType != 'Attack' ? colors[event.direction] : fireNote, FlxColor.BLACK);
			// FlxTween.color(underlays[strumerIndex].sprite, 0.3, FlxColor.GREEN, FlxColor.BLACK);
			// FlxTween.color(underlays[strumerIndex].sprite, 0.3, FlxColor.BLUE, FlxColor.BLACK);
		}
		underlays[strumerIndex].sprite.scale.x = 0.7;
		FlxTween.tween(underlays[strumerIndex].sprite.scale, {x: 1}, 0.3, {
			ease: FlxEase.backOut
		});
	}
}

function onPlayerMiss(event) {
	if (ModOptions.comboNotes) {
		if (combo > 5) {
			var strumerIndex:Int = event.direction + event.note.strumLine.length;
			var strumClone = strumers[strumerIndex].clone();
			strumClone.animation.play("static", true);
			strumClone.scale.set(def, def);
			strumClone.updateHitbox();
			strumClone.x = strumers[strumerIndex].x + (strumers[strumerIndex].width / 2) - (strumClone.width / 2);
			strumClone.y = strumers[strumerIndex].y + (strumers[strumerIndex].height / 2) - (strumClone.height / 2);
			strumClone.cameras = [camHUD];
			strumClone.alpha = 0.5;
			var fuck = FlxTween.tween(strumClone, {y: strumClone.y - 50}, 0.3, {
				ease: FlxEase.sineIn
			});
			var fuck2 = FlxTween.tween(strumClone, {alpha: 0}, 0.3, {
				onComplete: function() {
					strumClone.destroy();
				}
			});
			// var fuck3 = FlxTween.tween(strumClone.scale, {x: def + 0.3, y: def + 0.3}, 0.3);
			add(strumClone);
		}
	}
}

function onDadHit(event) {
	var lineIndex:Int = strumLines.members.indexOf(event.note.strumLine);
	if (ModOptions.noteSquish)
		strumAnims[lineIndex][event.direction].play();
}

function postUpdate(elasped:Float) {
	if (ModOptions.underlayOpacity > 0) {
		for (underlay in underlays) {
			underlay.sprite.alpha = ModOptions.underlayOpacity / 100;
		}
	}
}