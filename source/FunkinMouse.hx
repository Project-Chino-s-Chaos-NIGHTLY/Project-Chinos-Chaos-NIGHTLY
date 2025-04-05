class FunkinMouse {
	public var skin:String = 'cui/base';
	/* function set_skin(value) {
		reload();
		return skin = value;
	} */

	public var sprite:FunkinSprite;

	public var visible:Bool = true;
	/* function set_visible(value) {
		if (skin == 'base') FlxG.mouse.visible = value;
		else sprite.visible = value;
		return visible = value;
	} */

	public function new() {
		reload();
	}

	public function reload():Void {
		if (sprite == null) {
			sprite = new FunkinSprite('cui/base');
			sprite.scrollFactor.set();
			sprite.zoomFactor = 0;
		}
	}
}