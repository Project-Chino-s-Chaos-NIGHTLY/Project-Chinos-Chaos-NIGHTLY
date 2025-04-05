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
		if (effectie.scale != null && values.scale != null) {
			effectie.scale.x != null ? effectie.scale.x = (values.scale.x ?? (effectie.scale.x ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'scale.x' variable found.");
			effectie.scale.y != null ? effectie.scale.y = (values.scale.y ?? (effectie.scale.y ?? fallbackVarFloat)) * scaleFactor : trace("Whoops, no 'scale.x' variable found.");
		}
		effectie.alpha != null ? effectie.alpha = values.alpha ?? (effectie.alpha ?? fallbackVarFloat) : trace("Whoops, no 'alpha' variable found.");
		effectie.color != null ? effectie.color = values.color ?? (effectie.color ?? fallbackVarColor) : trace("Whoops, no 'color' variable found.");

		effectie.skew != null ? effectie.skew.set(values?.skew?.x ?? fallbackVarFloat, values?.skew?.y ?? fallbackVarFloat) : trace("Whoops, no 'skew' variable found.");
	}
}