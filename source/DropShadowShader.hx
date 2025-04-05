// typedef SliderShiz = {overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}}
class DropShadowShader {
	public var options = [
		'quality' => 5,
		'size' => 8,
		'strength' => 1,
		'divisions' => 15
	];

	public var shader:CustomShader;

	public function set(name:String, val) {
		options[name] = val;
        updateShader();
	}

	public function new() {
		shader = new CustomShader('DropShadow');
		updateShader();
	}

	public function get(?name:String) {
		if (name == null) {
			return shader;
		} else {
			return options[name];
		}
	}

	public function updateShader() {
		shader.uQuality = options['quality'];
		shader.uSize = options['size'];
		shader.uStrength = options['strength'];
		shader.uDivisions = options['divisions'];
	}
}