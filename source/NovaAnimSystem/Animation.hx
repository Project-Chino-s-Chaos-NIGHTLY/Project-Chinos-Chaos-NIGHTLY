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

		var fallbackVarFloat = 0.0;
		var fallbackVarPoint = new FlxPoint();
		var fallbackVarColor = 0x00000000;
		var scaleFactor = FlxG.height / res;
		effectie.x != null ? effectie.x = (values.x ?? (effectie.x ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'x' variable found.");
		effectie.y != null ? effectie.y = (values.y ?? (effectie.y ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'y' variable found.");
		effectie.angle != null ? effectie.angle = values.angle ?? (effectie.angle ?? fallbackVarFloat) : trace("Whoops, no 'angle' variable found.");
		effectie.scale.x != null ? effectie.scale.x = (values.scale.x ?? (effectie.scale.x ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'scale.x' variable found.");
		effectie.scale.y != null ? effectie.scale.y = (values.scale.y ?? (effectie.scale.y ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'scale.x' variable found.");
		effectie.alpha != null ? effectie.alpha = values.alpha ?? (effectie.alpha ?? fallbackVarFloat) : trace("Whoops, no 'alpha' variable found.");
		effectie.color != null ? effectie.color = values.color ?? (effectie.color ?? fallbackVarColor) : trace("Whoops, no 'color' variable found.");

		effectie.skew != null ? effectie.skew.set(values?.skew?.x ?? fallbackVarFloat, values?.skew?.y ?? fallbackVarFloat) : trace("Whoops, no 'skew' variable found.");
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
	public var finishCallback;
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