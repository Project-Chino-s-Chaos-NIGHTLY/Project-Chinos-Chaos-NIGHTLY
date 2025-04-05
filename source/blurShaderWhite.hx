// typedef SliderShiz = {overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}}
class BlurShaderWhite {
	public var options = [
		'blur' => ['amount' => 1, 'steps' => 1],
		'outline' => ['size' => [10, 10], 'color' => [255, 0, 0, 1]]
	];

	public var shader:CustomShader;
	public var shaderBlur:CustomShader;
	public var shaderRGB:CustomShader;

	private function get_options() {
		return options;
	}

	private function set_options(opts) {
		options = opts;
		updateShader();
		return value;
	}

	public function new(?func:CustomShader->Void) {
		shader = new CustomShader('Outline');
		shaderBlur = new CustomShader('blur-colored');
		shaderRGB = new CustomShader('RGBPallete');
		updateShader();
		if (func != null)
			func(shader);
		updateShader();
	}

	public function setShaderVar(parent:String, child:String, val:Dynamic) {
		options[parent][child] = val;
		updateShader();
	}

	public function setProfile(profile:String) {
		options = getProfile(profile);
		updateShader();
	}

	public function getProfile(profile:String):{overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}} {
		return switch (profile) {
			default: options;
		}
	}

	private function unvertFromPercent(mainValue:Float, maxValue:Float, ?outOf:Float = 100):Float {
		return (mainValue * maxValue) / (outOf ?? 100);
	}

	private function convert255to1(input:Int):Float {
		return unvertFromPercent(input, 1, 255);
	}

	public function updateShader() {
		shaderBlur.amount = options['blur']['amount'];
		shaderBlur.steps = options['blur']['steps'];
		shaderBlur._amount = options['blur']['amount'];

		shader.size = options['outline']['size'];
		shader.color = options['outline']['color'];

		var col = [
			options['outline']['color'][0],
			options['outline']['color'][1],
			options['outline']['color'][2],
			options['outline']['color'][3]
		];
		// var gre = [options['outline']['color'][1], options['outline']['color'][1], options['outline']['color'][1]];
		// var blu = [options['outline']['color'][2], options['outline']['color'][2], options['outline']['color'][2]];

		shaderRGB.color = col;
		shaderRGB.uMix = 1;
	}
}