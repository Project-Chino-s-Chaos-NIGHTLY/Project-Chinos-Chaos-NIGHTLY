// typedef SliderShiz = {overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}}
class SnowShader {
	public var options = [
		"time" => 0.0,
		"wind" => 0.0
	];

	public var shader:CustomShader;

	public function set(name:String, val) {
		options[name] = val;
        updateShader();
	}

	public function new() {
		shader = new CustomShader('Snow');
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
		shader.iTime = options["time"];
		shader.WIND = options["wind"];
	}
}