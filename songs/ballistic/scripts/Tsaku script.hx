//hope you don't mind put a separate script for this song
var tween1;
var tween2;
function stepHit() {
	switch (curStep) {
		case 144: FlxTween.tween(camGame, {zoom:1}, .5, {ease: FlxEase.quadOut});
		FlxTween.tween(FlxG.camera.scroll, {x: -400},.5, {ease: FlxEase.quadOut});
		case 152:
			tween1 = FlxTween.tween(camGame, {zoom:0.8}, 0.6, {ease: FlxEase.quadOut});
			tween2 = FlxTween.tween(FlxG.camera.scroll, {x:400},0.6, {ease: FlxEase.quadOut});
		case 160:
			tween1.cancel();
			tween2.cancel();
			camGame.zoom = 0.6;
			FlxG.camera.scroll.x = 0;
			FlxG.camera.snapToTarget();
	}
}
