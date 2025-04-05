// typedef SliderShiz = {overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}}
class RTXLighting {
	public var shader:CustomShader;

	public var values:{overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}} = {
		overlay: {red: 0, green: 0, blue: 0, alpha: 0},
		satin: {red: 0, green: 0, blue: 0, alpha: 0},
		inner: {red: 0, green: 0, blue: 0, alpha: 0, angle: 0, distance: 0}
	}

	private function get_values():{overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}} {
		return values;
	}

	private function set_values(value:{overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}}):{overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}} {
		values = value;
		updateShader();
		return value;
	}

	public function new(?func:CustomShader->Void) {
		shader = new CustomShader('RTXLighting');
		updateShader();
		if (func != null)
			func(shader);
		updateShader();
	}

	public function setProfile(profile:String) {
		values = getProfile(profile);
		updateShader();
	}

	public function getProfile(profile:String):{overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}} {
		return switch (profile) {
			case 'blank': {
					overlay: {red: 0, green: 0, blue: 0, alpha: 0},
					satin: {red: 0, green: 0, blue: 0, alpha: 0},
					inner: {red: 0, green: 0, blue: 0, alpha: 0, angle: 0, distance: 0}
				}
			case 'Heated Up': {
					overlay: {red: 0, green: 0, blue: 0, alpha: 0},
					satin: {red: 0, green: 0, blue: 0, alpha: 0},
					inner: {red: 255, green: 50, blue: 0, alpha: 0.1, angle: 90, distance: 30}
				}
			case 'Sneaky Bombs': {
					overlay: {red: 0, green: 0, blue: 0, alpha: 0},
					satin: {red: 0, green: 0,blue: 0, alpha: 0.3},
					inner: {red: -150, green: -150, blue: -150, alpha: 0.5, angle: -90, distance: 10}
				}
			case 'Hex Fight Stage': {
					overlay: {red: 0, green: 0, blue: 0, alpha: 0},
					satin: {red: 255, green: 0, blue: 0, alpha: 0.3},
					inner: {red: 255, green: 0, blue: 0, alpha: 0.2, angle: -50, distance: 10}
				}
			default: values;
		}
	}

	private function unvertFromPercent(mainValue:Float, maxValue:Float, ?outOf:Float = 100):Float {
		return (mainValue * maxValue) / (outOf ?? 100);
	}

	private function convert255to1(input:Int):Float {
		return unvertFromPercent(input, 1, 255);
	}

	public function updateShader() {
		shader.overlayColor = [
			convert255to1(values.overlay.red ?? 0),
			convert255to1(values.overlay.green ?? 0),
			convert255to1(values.overlay.blue ?? 0),
			values.overlay.alpha ?? 0
		];
		shader.satinColor = [
			convert255to1(values.satin.red ?? 0),
			convert255to1(values.satin.green ?? 0),
			convert255to1(values.satin.blue ?? 0),
			values.satin.alpha ?? 0
		];
		shader.innerShadowColor = [
			convert255to1(values.inner.red ?? 0),
			convert255to1(values.inner.green ?? 0),
			convert255to1(values.inner.blue ?? 0),
			values.inner.alpha ?? 0
		];
		shader.innerShadowAngle = (values.inner.angle ?? 0) * (Math.PI / 180);
		shader.innerShadowDistance = values.inner.distance ?? 0;
	}
}