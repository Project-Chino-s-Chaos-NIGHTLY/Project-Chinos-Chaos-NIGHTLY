var intensity = 5; // How far the camera moves on press, default is 5
				   // 5 = 50 Pixels
var speed = 66;    // pixelsPerSecond

var alignX = true; // Makes up and down movement 70% of left and right movement, defualt is true

var move = true;   // Do you want the camera to move? default is true (can also be toggled with "toggleMovePress" event)

var doShake = true;// Enable to find out.

var shakeAmount = 10;
























var camTarget:String;
function onCameraMove(event) {
	var tempTarget:String;
	if (event.position.x == dad.getCameraPosition().x && event.position.y == dad.getCameraPosition().y)
		{
			tempTarget = "dad";
		}
	else if (event.position.x == boyfriend.getCameraPosition().x && event.position.y == boyfriend.getCameraPosition().y)
		{
			tempTarget = "boyfriend";
		}

	if (dad.animation.curAnim.name == "idle" && boyfriend.animation.curAnim.name == "idle" && move) {} else
	{
		event.cancel();
	}
	if (camTarget != tempTarget) {
		camTarget = tempTarget;
		pos.x = event.position.x - (FlxG.width/2);
		pos.y = event.position.y - (FlxG.height/2);
		zoomOffset = 0;
	}
}
var inte = intensity*10;
var time = inte / speed;
var inteW = (intensity*10)* (alignX ? 0.7 : 1);
var posOffsets = [
		[-inte, 0],
		[0, inteW],
		[0, -inteW],
		[inte, 0]
	];
var pos = {
	x: 0,
	y: 0
}
var globalOffsets = {
	dad: { x: 0, y: -100 },
	boyfriend: { x: 30, y: 0 }
}
var daTween;
var zoomOffset = 0;
function getOffsets() {
	switch (camTarget) {
		case "dad":
			return globalOffsets.dad;
		case "boyfriend":
			return globalOffsets.boyfriend;
		default:
			return { x: 0, y: 0 }
	}
}
function getTarget() {
	switch (camTarget) {
		case "dad":
			return dad;
		case "boyfriend":
			return boyfriend;
		default:
			return null;
	}
}
var curOffseter = { x: 0, y: 0 }
function onNoteHit(event) {
	if (move) {
		curOffseter.x = posOffsets[event.direction][0];
		curOffseter.y = posOffsets[event.direction][1];
		if (camTarget == "dad")
			{
				if (daTween != null && daTween.active) {
					daTween.cancel();
				}
				//pos.x = dad.getCameraPosition().x + posOffsets[event.direction][0] - (FlxG.width/2)  + globalOffsets.dad.x;
				//pos.y = dad.getCameraPosition().y + posOffsets[event.direction][1] - (FlxG.height/2) + globalOffsets.dad.y;
				//pos.x = dad.getCameraPosition().x + globalOffsets.dad.x;
				//pos.y = dad.getCameraPosition().y + globalOffsets.dad.y;
				/*daTween = FlxTween.tween(camGame.scroll, {
					x: ,
					y:
				}, 0.75, {ease: FlxEase.quadOut, onStart: function() {
					camFollow.setPosition(dad.getCameraPosition().x + globalOffsets.dad.x, dad.getCameraPosition().y + globalOffsets.dad.y);
				}});*/
			}
		else if (camTarget == "boyfriend")
			{
				if (daTween != null && daTween.active) {
					daTween.cancel();
				}
				//pos.x = boyfriend.getCameraPosition().x + posOffsets[event.direction][0] - (FlxG.width/2)  + globalOffsets.boyfriend.x;
				//pos.y = boyfriend.getCameraPosition().y + posOffsets[event.direction][1] - (FlxG.height/2) + globalOffsets.boyfriend.y;
				//pos.x = boyfriend.getCameraPosition().x + globalOffsets.boyfriend.x;
				//pos.y = boyfriend.getCameraPosition().y + globalOffsets.boyfriend.y;
				/*daTween = FlxTween.tween(camGame.scroll, {
					x: boyfriend.getCameraPosition().x + posOffsets[event.direction][0] - (FlxG.width/2)  + globalOffsets.boyfriend.x,
					y: boyfriend.getCameraPosition().y + posOffsets[event.direction][1] - (FlxG.height/2) + globalOffsets.boyfriend.y
				}, 0.75, {ease: FlxEase.quadOut, onStart: function() {
					camFollow.setPosition(boyfriend.getCameraPosition().x + globalOffsets.boyfriend.x, boyfriend.getCameraPosition().y + globalOffsets.boyfriend.y);
				}});*/
				//pos.setPosition(boyfriend.getCameraPosition().x + posOffsets[event.direction][0], boyfriend.getCameraPosition().y + posOffsets[event.direction][1]);
			}
	}
}
var shakeOffsets = { x: 0, y: 0 }
function postUpdate(elasped:Float) {
	camGame.scroll.x = lerp(camGame.scroll.x, pos.x + getOffsets().x + curOffseter.x, time/10) + (shakeOffsets.x/10);
	camGame.scroll.y = lerp(camGame.scroll.y, pos.y + getOffsets().y + curOffseter.y, time/10) + (shakeOffsets.y/10);
	camFollow.setPosition(camGame.scroll.x + (FlxG.width/2), camGame.scroll.y + (FlxG.height/2));
	/*for (item in members) {
		try {
			//if (item.cameras = [camGame]) {
				var defaultOrigin = item.origin;
				var defaultAngle = item.angle != camGame_angle ? camGame_angle : item.angle - camGame_angle;
				item.origin.set((FlxG.width/2) + camGame.scroll.x, (FlxG.height/2) + camGame.scroll.y);
				item.angle = defaultAngle + camGame_angle;
				item.origin.set(defaultOrigin.x, defaultOrigin.y);
		   // }
		} catch (error:Dynamic) {

		}
	}*/
	var customZoomOffset = Math.abs((camGame.scroll.x/300)-0.6);
	lockZoom = false;
	if (!zoomEasing) {
		camGame.zoom = lerp(camGame.zoom, defaultCamZoom + zoomOffset + (customZoomOffset/4), 0.1);
	}
	camHUD.zoom = 1;
	zoomOffset = lerp (zoomOffset, 0, 0.05);
}
var flipA = false;
function doShaker() {
	new FlxTimer().start(0.5, function(timer) {
		flipA = !flipA;
		var flipX = FlxG.random.bool();
		var flipY = FlxG.random.bool();
		FlxTween.tween(shakeOffsets, {x: shakeAmount * (flipX ? -1 : 1), y: shakeAmount * (flipY ? -1 : 1) }, 0.5, {
			ease: FlxEase.sineInOut
		});
		FlxTween.tween(camGame, {angle: FlxG.random.float(0.4, 0.5) * (flipA ? -1 : 1)}, 0.5, {
			ease: FlxEase.sineInOut
		});
		doShaker();
	});
}
var zoomEasing = false;
function beatHit() {
	if (curBeat % 2 == 0) {
		//camGame.zoom = defaultCamZoom + 0.03 + zoomOffset;
		/*FlxTween.tween(camGame, { zoom: defaultCamZoom + 0.05 }, 0.1, {
			ease: FlxEase.quadOut,
			onStart: function() {
				zoomEasing = true;
			},
			onComplete: function() {
				zoomEasing = false;
			}
		});*/
	}
}
function postCreate() {
	doShaker();
}
function toggleMovePress(event) {
	move = !move;
}
function onStartSong() {
	for (i in 0...2) {
		strumLines.members[i].onHit.add((event) -> {
			zoomOffset += 0.1;
		});
	}
}