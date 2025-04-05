import flixel.math.FlxBasePoint;

class CharIcon extends FunkinSprite {
	public var attachedIcon:HealthIcon; // just for positioning purposes

	public var curIcon:String; // current icon name
	public var autoUpdateIcon:Bool = false;
	private var flipped:Bool = false;
	private var isAnim:Bool = false;
	public var curAnim:String;

	// fuck isPlayer, it's basically flipX bullshit
	override public function new(char:String = 'bf', icon:HealthIcon, ?flip:Bool = false) {
		attachedIcon = icon;
		flipped = flip;
		setIcon(char);
		FlxG.state.insert(FlxG.state.members.indexOf(attachedIcon) + 1, this); // adds them for you
	}

	private var bird:Bool = false;
	private var iconFlip:Bool = false;
	override public function update(elapsed:Float) {
		visible = attachedIcon.visible && isAnim;
		super.update(elapsed);
		if (isAnim) {
			if (autoUpdateIcon && curIcon != attachedIcon.curCharacter) setIcon(attachedIcon.curCharacter);
			setPosition(attachedIcon.x, attachedIcon.y);
			scale.set(attachedIcon.scale.x, attachedIcon.scale.y);
			origin.set(attachedIcon.origin.x, attachedIcon.origin.y);
			centerOrigin();
			antialiasing = attachedIcon.antialiasing;
			angle = attachedIcon.angle;
			flipY = attachedIcon.flipY;
			bird = attachedIcon.flipX;
			color = attachedIcon.color;
			if (flipped) bird = !bird;
			if (iconFlip) bird = !bird;
			flipX = bird;
			//playAnim(attachedIcon.animation.curAnim.curFrame, false, 'DANCE');
		}
		cameras = attachedIcon._cameras;
	}

	override public function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		if (isAnim && lastAnimContext == 'DANCE') playAnim(attachedIcon.animation.curAnim.curFrame, true, 'DANCE'); // lol
	}

	private function setVis(isAnim:Bool) {
		if (this.isAnim == isAnim) return; else this.isAnim = isAnim;
		if (isAnim) attachedIcon.kill();
		else attachedIcon.revive();
	}

	public function setIcon(char:String = null) {
		char = char ?? attachedIcon.curCharacter;
		if (curIcon != char) {
			curIcon = char;
			var dir:Array<String> = char.split('/');
			dir.insert(dir.length - 1, 'animated');
			var theDir:String = dir.join('/');

			var json = Paths.getPath('images/icons/' + theDir + '.json');
			if (Assets.exists(json)) {
				json = CoolUtil.parseJson('images/icons/' + theDir + '.json');
				setVis(true);
			} else {
				setVis(false);
				return;
			}
			loadSprite(Paths.image('icons/' + theDir));

			var index:Int = 0;
			if (json.flip != null) iconFlip = json.flip;
			for (info in json.states) {
				// if (index == attachedIcon.frames.frames.length) break;
				if (info.anim != null || info.fps != null || info.loop != null || info.offsets != null || info.offset[0] != null || info.offset[1] != null || info.indices != null)
				XMLUtil.addAnimToSprite(this, {
					name: index,
					anim: info.anim,
					fps: info.fps,
					loop: info.loop,
					animType: 'none',
					x: info.offsets[0],
					y: info.offsets[1],
					indices: info.indices,
					forced: false
				});
				index++;
			}
			if (json.anims != null)
			for (info in json.anims) {
				if (info.name != null || info.anim != null || info.fps != null || info.loop != null || info.offsets != null || info.offset[0] != null || info.offset[1] != null || info.indices != null)
				XMLUtil.addAnimToSprite(this, {
					name: info.name,
					anim: info.anim,
					fps: info.fps,
					loop: info.loop,
					animType: 'none',
					x: info.offsets[0],
					y: info.offsets[1],
					indices: info.indices,
					forced: false
				});
			}
			curAnim = "0";
			playAnim(attachedIcon.animation.curAnim.curFrame, true, 'DANCE');
		}
	}

	override public function playAnim(AnimNum:Int, Force:Bool = false, Context:String = 'NONE', Reversed:Bool = false, Frame:Int = 0) {
		super.playAnim(AnimNum, Force, Context, Reversed, Frame);
		// offset.set(offset.x * (flipped ? -1 : 1), offset.y);
	}
}