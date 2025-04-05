class LuaSprite extends FunkinSprite {
	public var stringID:String;
	public function setID(id:String) {
		stringID = id;
	}

	public function set(properties:Array<String>, value:Dynamic) {
		switch (properties[1]) {
			case "x":
				this.x = value;
			case "y":
				this.y = value;
			case "alpha":
				this.alpha = value;
			case "angle":
				this.angle = value;
			case "visible":
				this.visible = value;
			case "scale":
				if (properties[2] != null) {
					if (properties[2] == "x") {
						this.scale.x = value;
					} else if (properties[2] == "y") {
						this.scale.y = value;
					}
				}
			default:
				trace("Unknown or Unimplemented property: \"" + properties[1] + "\"");
		}
	}

	public function get(properties:Array<String>) {
		switch (properties[1]) {
			case "x":
				return this.x;
			case "y":
				return this.y;
			case "alpha":
				return this.alpha;
			case "angle":
				return this.angle;
			case "visible":
				return this.visible;
			case "scale":
				if (properties[2] != null) {
					if (properties[2] == "x") {
						return this.scale.x;
					} else if (properties[2] == "y") {
						return this.scale.y;
					}
				}
			default:
				trace("Unknown or Unimplemented property: \"" + properties[1] + "\"");
		}
	}
}