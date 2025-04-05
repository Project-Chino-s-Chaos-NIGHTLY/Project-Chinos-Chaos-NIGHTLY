// typedef SliderShiz = {overlay:{red:Float, green:Float, blue:Float, alpha:Float}, satin:{red:Float, green:Float, blue:Float, alpha:Float}, inner:{red:Float, green:Float, blue:Float, alpha:Float, angle:Float, distance:Float}}
class GaussianBlur {
	public var shader:CustomShader;

	public function new(?func:CustomShader->Void) {
		shader = new CustomShader('GaussianBlur');
		initShader();
		if (func != null)
			func(shader);
	}

	override function update(elapsed:Float) {
		shader.resolution = [200, 200];
	}

	public function setShaderVar(what:String, val:Dynamic) {
		shader[what] = val;
	}

	private function unvertFromPercent(mainValue:Float, maxValue:Float, ?outOf:Float = 100):Float {
		return (mainValue * maxValue) / (outOf ?? 100);
	}

	private function convert255to1(input:Int):Float {
		return unvertFromPercent(input, 1, 255);
	}

	private function initShader() {
		shader.radius = 10;
		shader.dir = [10, 10];
		shader.vColor = [convert255to1(255), convert255to1(255), convert255to1(255), 1];
	}
}