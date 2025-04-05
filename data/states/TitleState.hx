import hxvlc.flixel.FlxVideoSprite;

var video = new FlxVideoSprite();

function postCreate() {
	playMenuSong(ModOptions.menuTrack);
	video.bitmap.onFormatSetup.add(function() {
		var scaleFactor = FlxG.width / 1920;
		video.antialiasing = true;
		video.scale.set(scaleFactor, scaleFactor);
		video.updateHitbox();
		video.alpha = 1;
	});
	video.autoPause = true;
	video.load(Assets.getPath(Paths.video('startAnimation')), [':no-audio']);

	// video.screenCenter(FlxAxes.X);
	video.bitmap.onEndReached.add(function() {
		skipIntro();
		video.visible = false;
	});
	video.bitmap.onTimeChanged.add(function(time) {
		if (time <= 150) {
			for (sound in FlxG.sound.list.members) {
				sound?.time = 0;
			}
			FlxG.sound.music.time = 0;
		}
	});
	add(video);
	video.play();
}
var tweenStarted = false;
function postUpdate(elapsed:Float) {
	if (skippedIntro) {
		video.visible = false;
		if (!tweenStarted) {
			titleScreenSprites.members[1].y = -titleScreenSprites.members[1].height;
			FlxTween.tween(titleScreenSprites.members[1], { y: 0 }, 2, { ease: FlxEase.backOut });
			tweenStarted = true;
		}
	} else {
		titleScreenSprites.members[1].y = -titleScreenSprites.members[1].height;
	}
	titleScreenSprites.members[0].updateHitbox();
	titleScreenSprites.members[0].screenCenter(FlxAxes.XY);
	titleScreenSprites.members[1].updateHitbox();
	titleScreenSprites.members[1].screenCenter(FlxAxes.X);
}