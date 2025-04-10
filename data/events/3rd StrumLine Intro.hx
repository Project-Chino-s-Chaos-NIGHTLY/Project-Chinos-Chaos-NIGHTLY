// strum poses
var startPositions:Array<Array<Float>> = [];

// main shit
var startRevealed:Bool;
var isRevealed:String;

// offset shits
var xOffset:Float = 175;
var yOffset:Float = -1000;

// speed shit
var overallSpeed:Float = 1;

// camera shit
var offsetZoom:Float = 1;
var finalZoom:Float = 1;

var index3rd:Int = strumLines.length > 3 ? 3 : 2;
public var allow3rdIntroLerps:Bool = true;

function onEvent(event):Void {
	switch (event.event.name) {
		case '3rd StrumLine Intro':
			disablePositioningX = true;
			disablePositioningY = true;
			var shRe:Bool = event.event.params[0];
			var spe:Float = event.event.params[1] ?? 1;
			var sR:Bool = event.event.params[2];

			if (!sR && isRevealed != shRe) {
				isRevealed = shRe;
				overallSpeed = spe;
				offsetZoom = shRe ? (5 / 6) : 1;
			}
	}
}

function postCreate():Void {
	for (event in events)
		if (event.name == '3rd StrumLine Intro' && event.params[2])
			isRevealed = startRevealed = event.params[2];

	if (startRevealed)
		offsetZoom = 5 / 6;

	for (index => strumLine in strumLines.members) {
		var positions:Array<Float> = [];
		for (strum in strumLine) {
			var strumY:Float = 50;
			try { // fuck random bullshit
				strumY = SONG?.strumLines[index]?.strumPos[1] ?? 50;
			} catch(e:Dynamic) {}
			positions.push({x: strum.x, y: strumY});
		}
		startPositions.push(positions);

		if (startRevealed)
			switch (index) {
				case 0:
					for (i => strum in strumLine.members)
						strum.x = startPositions[index][i].x - xOffset;
				case 1:
					for (i => strum in strumLine.members)
						strum.x = startPositions[index][i].x + xOffset;
			}
		else
			switch (index) {
				case index3rd:
					for (i => strum in strumLine.members) {
						FlxTween.cancelTweensOf(strum, ['y', 'alpha']);
						strum.y = startPositions[index][i].y + yOffset;
						strum.alpha = 0;
					}
			}
	}

	preventCamNoteZoom = true;
	camNotes.zoom = camHUD.zoom * finalZoom;
}

function postUpdate(elapsed:Float):Void {
	if (allow3rdIntroLerps)
		for (index => strumLine in strumLines.members) {
			switch (index) {
				case 0:
					for (i => strum in strumLine.members)
						strum.x = lerp(strum.x, startPositions[index][i].x - (isRevealed ? xOffset : 0), 0.05 / overallSpeed);
				case 1:
					for (i => strum in strumLine.members)
						strum.x = lerp(strum.x, startPositions[index][i].x + (isRevealed ? xOffset : 0), 0.05 / overallSpeed);
				case index3rd:
					for (i => strum in strumLine.members) {
						strum.y = lerp(strum.y, startPositions[index][i].y + (isRevealed ? 0 : yOffset), 0.04 / overallSpeed);
						if (Math.round(strum.y*10)/10 == Math.round((startPositions[index][i].y + (isRevealed ? 0 : yOffset))*10)/10) {
							disablePositioningY = false;
						}
						strum.alpha = lerp(strum.alpha, isRevealed ? 1 : 0, 0.2 / overallSpeed);
					}
			}
		}

	if (disablePositioningY)
		camNotes.y = lerp(camNotes.y, -40, 0.05 / overallSpeed);
	finalZoom = lerp(finalZoom, offsetZoom, 0.05 / overallSpeed);
	camNotes.zoom = camHUD.zoom * finalZoom;
}