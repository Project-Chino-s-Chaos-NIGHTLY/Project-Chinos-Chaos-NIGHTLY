import flixel.effects.FlxFlicker;
import flixel.ui.FlxBar;
import flixel.ui.FlxBarFillDirection;
import hxvlc.flixel.FlxVideoSprite;

var endPart = new FlxVideoSprite();

public var hexIsShielded:Bool = false;
public var playersArePossessed:Bool = false;
public var ignorePlayerDamage:Bool = false;
public var bfIsShielded:Bool = false;
public var whittyHeated:Bool = false;
public var hexIsPossessed:Bool = false;

// Attack References.
var gfSlashRef:FunkinSprite;
var whittyFireRef:FunkinSprite;
var carolFireRef:FunkinSprite;
var bfRef:FunkinSprite;
var hexRef:FunkinSprite;
var robotRef:FunkinSprite;
// Other stuff ig.
var shockingBf:FunckinSprite;
var bfShield:FunkinSprite;
var gridLeft:FunkinSprite;
var gridRight:FunkinSprite;

var robotSkewValues = [
	FlxPoint.get(0, 10),
	FlxPoint.get(0, 10),
	FlxPoint.get(0, 10),
	FlxPoint.get(0, 20)
];

// HealthBars
var healthBarHex:FlxBar;
var healthBarGF:FlxBar;
var healthBarBF:FlxBar;
var healthBarCarol:FlxBar;
var healthBarWhitty:FlxBar;

var playerHealthBars:Array<FlxBar> = [];
var playerHealths:Array<Float> = [];
var playerHealthIcons:Array<HealthIcon> = [];

// Debug Stuff
var _debugMode = true;
var _debugRef = hexRef;
var _debugChar = dad;
var _dadDebugAnim = 'singLEFT';
var _electricityDebugAnim = 'left-carol';
var _debugZoom = 0.6;


var _isShaking = false;
var _shakeAxes = FlxAxes.XY;
var _shakeIntensity = 0;
var _shakeCamera:FlxCamera = new FlxCamera();
	_shakeCamera.bgColor = FlxColor.TRANSPARENT;

function getStagePath(file:String) {
	return 'stages/Vs Hex/detected/' + file;
}
//var __camGame:FlxCamera;

function createBarBG(x:Float):FlxSprite {
	var bg = new FlxSprite(x - 5).makeGraphic(30, 210, FlxColor.BLACK);
	bg.screenCenter(FlxAxes.Y); bg.y -= 5;
	bg.cameras = [camHUD];
	return bg;
}

function createHealthBar(bg:FlxSprite, startColor:Int):FlxBar {
	var bar:FlxBar = new FlxBar(bg.x + 5, bg.y + 5, FlxBarFillDirection.BOTTOM_TO_TOP, 20, 200, null, '', 0, 1, false);
	bar.createFilledBar(0xFF161616, startColor ?? FlxColor.BLUE);
	bar.cameras = [camHUD];
	bar.value = 0.5;
	bar.numDivisions = FlxG.height;
	return bar;
}

var them:{ // shortcut
	ghost:{char:Character, strumLine:StrumLine},
	hex:{char:Character, strumLine:StrumLine},
	bf:{char:Character, strumLine:StrumLine},
	gf:{char:Character, strumLine:StrumLine},
	whitty:{char:Character, strumLine:StrumLine},
	carol:{char:Character, strumLine:StrumLine},
	robot:{char:Character, strumLine:StrumLine}
}

function themStupid(strumLine:StrumLine, ?charIndex:Int, ?runAlphaCode:Bool):{char:Character, strumLine:StrumLine} {
	if (runAlphaCode ?? true) {
		var theFunc:Dynamic->Void = (event) -> {
			for (strumLine in strumLines) {
				strumLine.ghostTapping = true;
				if (strumLines.members.indexOf(strumLine) != 0)
					strumLine.members[event.note.noteData].alpha = 0.0001;
			}
			strumLine.ghostTapping = ghostTapping;
			strumLine.members[event.note.noteData].alpha = 1;
		}
		strumLine.onHit.add(theFunc);
		strumLine.onMiss.add(theFunc);
	}
	return {
		strumLine: strumLine,
		char: strumLine.characters[charIndex ?? 0]
	}
}
function onChangeCharacter(oldChar, newChar, strumIndex, memberIndex, updateBar) {
	if (updateBar) {
		if (strumIndex > 0) {
			playerHealthBars[strumIndex-1].createColoredFilledBar(newChar.iconColor ?? FlxColor.BLUE, false, null);
			playerHealthIcons[strumIndex].setIcon(newChar.icon);
		}
	}
}
function postCreate() {
	them = {
		ghost: themStupid(strumLines.members[0], 1, false),
		hex: themStupid(strumLines.members[0], 0, false),
		bf: themStupid(strumLines.members[1]),
		gf: themStupid(strumLines.members[2]),
		whitty: themStupid(strumLines.members[3]),
		carol: themStupid(strumLines.members[4]),
		robot: themStupid(strumLines.members[5])
	}

	for (strumLine in strumLines) {
		if (strumLines.members.indexOf(strumLine) != 0)
			for (strum in strumLine)
				strum.alpha = 0.0001;
		if (!strumLine.opponentSide)
			strumLine.ghostTapping = true;
	}
	them.bf.strumLine.ghostTapping = ghostTapping;
	for (strum in them.bf.strumLine)
		strum.alpha = 1;

	//FlxG.cameras.remove(camGame);
	//__camGame = new FlxCamera();
	//__camGame.bgColor = FlxColor.TRANSPARENT;
	//__camGame.x = 200;
	//FlxG.cameras.add(__camGame, true);
	FlxG.cameras.add(_shakeCamera, false);

	var spacing:Float = 20;
	insert(members.indexOf(strumLines), healthBarHex = createHealthBar(insert(members.indexOf(strumLines) - 1, createBarBG(spacing)), them.hex.char.iconColor));
	insert(members.indexOf(strumLines), healthBarGF = createHealthBar(insert(members.indexOf(strumLines) - 1, createBarBG(FlxG.width - (spacing * 4) - (20 * 4))), them.gf.char.iconColor));
	insert(members.indexOf(strumLines), healthBarBF = createHealthBar(insert(members.indexOf(strumLines) - 1, createBarBG(FlxG.width - (spacing * 3) - (20 * 3))), them.bf.char.iconColor));
	insert(members.indexOf(strumLines), healthBarCarol = createHealthBar(insert(members.indexOf(strumLines) - 1, createBarBG(FlxG.width - (spacing * 2) - (20 * 2))), them.carol.char.iconColor));
	insert(members.indexOf(strumLines), healthBarWhitty = createHealthBar(insert(members.indexOf(strumLines) - 1, createBarBG(FlxG.width - spacing - 20)), them.whitty.char.iconColor));

	playerHealthBars.push(healthBarBF);
	playerHealths.push(0.5);
	playerHealthBars.push(healthBarGF);
	playerHealths.push(0.5);
	playerHealthBars.push(healthBarWhitty);
	playerHealths.push(0.5);
	playerHealthBars.push(healthBarCarol);
	playerHealths.push(0.5);

	for (i=> strumline in strumLines.members) {
		if (strumline.characters[0].icon != 'robot') {
			var icon:HealthIcon = new HealthIcon(strumline.characters[0].icon);
			icon.antialiasing = true;
			icon.cameras = [camHUD];
			icon.scale.set(0.3, 0.3);
			icon.screenCenter(FlxAxes.Y);
			icon.updateHitbox();
			icon.y -= (210/2) - icon.height;
			if (i != 0) {
				icon.flipX = true;
				icon.x = (playerHealthBars[i-1].x + (playerHealthBars[i-1].width/2)) - (icon.width/2);
			} else {
				icon.x = (healthBarHex.x + (healthBarHex.width/2)) - (icon.width/2);
			}
			trace(strumline.characters[0].icon);
			insert(members.indexOf(strumLines), icon);
			playerHealthIcons.push(icon);
		}
	}

	addPreloadItem(function() {
		gfSlashRef = new FunkinSprite(0, 0);
		gfSlashRef.frames = Paths.getSparrowAtlas(getStagePath('attacks/girlfriend'));
		gfSlashRef.animation.addByPrefix('left', 'GF Slash Left',  24, false);
		gfSlashRef.animation.addByPrefix('down', 'GF Slash Down',  24, false);
		gfSlashRef.animation.addByPrefix('up', 'GF Slash Up',  24, false);
		gfSlashRef.animation.addByPrefix('right', 'GF Slash Right',  24, false);
		gfSlashRef.addOffset('left', 50, -50);
		gfSlashRef.addOffset('down', 50, -100);
		gfSlashRef.addOffset('up', 50, 0);
		gfSlashRef.addOffset('right', 50, -50);
		gfSlashRef.scale.set(1.5, 1.5);
		gfSlashRef.antialiasing = true;
	}, 'GF Slash Sprite');

	addPreloadItem(function() {
		carolFireRef = new FunkinSprite(0, 0);
		carolFireRef.frames = Paths.getSparrowAtlas(getStagePath('attacks/carol'));
		carolFireRef.animation.addByPrefix('left', 'blast',  24, false);
		carolFireRef.animation.addByPrefix('down', 'blast',  24, false);
		carolFireRef.animation.addByPrefix('up', 'blast',  24, false);
		carolFireRef.animation.addByPrefix('right', 'blast',  24, false);
		carolFireRef.animation.addByIndices('left-bullet', 'blast', [0], '', 24, false);
		carolFireRef.animation.addByIndices('down-bullet', 'blast', [0], '', 24, false);
		carolFireRef.animation.addByIndices('up-bullet', 'blast', [0], '', 24, false);
		carolFireRef.animation.addByIndices('right-bullet', 'blast', [0], '', 24, false);
		for (i in ['left', 'down', 'up', 'right']) {
			carolFireRef.addOffset(i, 275, 203);
			carolFireRef.addOffset(i + '-bullet', 275, 203);
		}

		var globalOffsetX = 50;
		carolFireRef.animation.addByPrefix('left-smoke', 'smoke',  24, false);
		carolFireRef.animation.addByPrefix('down-smoke', 'smoke',  24, false);
		carolFireRef.animation.addByPrefix('up-smoke', 'smoke',  24, false);
		carolFireRef.animation.addByPrefix('right-smoke', 'smoke',  24, false);
		carolFireRef.addOffset('left-smoke', -155 + globalOffsetX, -33);
		carolFireRef.addOffset('down-smoke', -172 + globalOffsetX, -103);
		carolFireRef.addOffset('up-smoke', -167 + globalOffsetX, 46);
		carolFireRef.addOffset('right-smoke', -203 + globalOffsetX, -19);

		carolFireRef.antialiasing = true;
	}, 'Carol Attack Sprite');

	addPreloadItem(function() {
		robotRef = new FunkinSprite(0, 0);
		robotRef.frames = Paths.getSparrowAtlas(getStagePath('attacks/robot'));
		robotRef.animation.addByPrefix('top-f', 'Laser Top Full',  24, false);
		robotRef.animation.addByPrefix('mid-f', 'Laser Mid Full',  24, false);
		robotRef.animation.addByPrefix('mid-h', 'Laser Mid Half',  24, false);
		robotRef.animation.addByPrefix('bottom-f', 'Laser Bottom Full',  24, false);
		robotRef.scale.set(1.5, 1.5);
		robotRef.addOffset('top-f', 334, 93);
		robotRef.addOffset('mid-f', 329, 33);
		robotRef.addOffset('mid-h', -330, 37);
		robotRef.addOffset('bottom-f', 332, 26);
		robotRef.antialiasing = true;
	}, 'Robot Attack Sprite');

	addPreloadItem(function() {
		whittyFireRef = new FunkinSprite(0, 0);
		var globalOffsetX = 50;
		whittyFireRef.frames = Paths.getSparrowAtlas(getStagePath('attacks/whitty'));
		whittyFireRef.animation.addByPrefix('left', 'Left',  24, false);
		whittyFireRef.animation.addByPrefix('down', 'Down',  24, false);
		whittyFireRef.animation.addByPrefix('up', 'Up',  24, false);
		whittyFireRef.animation.addByPrefix('right', 'Right',  24, false);
		whittyFireRef.addOffset('left', 45 + globalOffsetX, -27);
		whittyFireRef.addOffset('down', 49 + globalOffsetX, -100);
		whittyFireRef.addOffset('up', 54 + globalOffsetX, 62);
		whittyFireRef.addOffset('right', 45 + globalOffsetX, 18);

		whittyFireRef.animation.addByIndices('left-bullet', 'Left', [0], '', 24, false);
		whittyFireRef.animation.addByIndices('down-bullet', 'Down', [0], '', 24, false);
		whittyFireRef.animation.addByIndices('up-bullet', 'Up', [0], '', 24, false);
		whittyFireRef.animation.addByIndices('right-bullet', 'Right', [0], '', 24, false);
		whittyFireRef.addOffset('left-bullet', 0, -50);
		whittyFireRef.addOffset('down-bullet', 0, -100);
		whittyFireRef.addOffset('up-bullet', 0, 0);
		whittyFireRef.addOffset('right-bullet', 0, -50);

		//var blastIndices = [ for (i in 1...9) i ];
		whittyFireRef.animation.addByIndices('left-blast', 'Left', [1,2,3,4,5,6,7,8,9], '', 24, false);
		whittyFireRef.animation.addByIndices('down-blast', 'Down', [1,2,3,4,5,6,7,8,9], '', 24, false);
		whittyFireRef.animation.addByIndices('up-blast', 'Up', [1,2,3,4,5,6,7,8,9], '', 24, false);
		whittyFireRef.animation.addByIndices('right-blast', 'Right', [1,2,3,4,5,6,7,8,9], '', 24, false);
		whittyFireRef.addOffset('left-blast', 45 + globalOffsetX, -27);
		whittyFireRef.addOffset('down-blast', 49 + globalOffsetX, -100);
		whittyFireRef.addOffset('up-blast', 54 + globalOffsetX, 62);
		whittyFireRef.addOffset('right-blast', 45 + globalOffsetX, 18);

		whittyFireRef.animation.addByPrefix('left-smoke', 'Smoke',  24, false);
		whittyFireRef.animation.addByPrefix('down-smoke', 'Smoke',  24, false);
		whittyFireRef.animation.addByPrefix('up-smoke', 'Smoke',  24, false);
		whittyFireRef.animation.addByPrefix('right-smoke', 'Smoke',  24, false);
		whittyFireRef.addOffset('left-smoke', -155 + globalOffsetX, -33);
		whittyFireRef.addOffset('down-smoke', -172 + globalOffsetX, -103);
		whittyFireRef.addOffset('up-smoke', -167 + globalOffsetX, 46);
		whittyFireRef.addOffset('right-smoke', -203 + globalOffsetX, -19);

		whittyFireRef.scale.set(2.5, 2.5);
		whittyFireRef.antialiasing = true;
	}, 'Whitty Fire Sprite');




	addPreloadItem(function() {
		hexRef = new FunkinSprite(dad.x, dad.y);
		hexRef.frames = Paths.getSparrowAtlas(getStagePath('attacks/hex'));
		hexRef.animation.addByPrefix('left-Boyfriend-Shield', 'Hex Attack Left BF Shield',  24, false);
		hexRef.animation.addByPrefix('down-Boyfriend-Shield', 'Hex Attack Down BF Shield',  24, false);
		hexRef.animation.addByPrefix('up-Boyfriend-Shield', 'Hex Attack Up BF Shield',  24, false);
		hexRef.animation.addByPrefix('right-Boyfriend-Shield', 'Hex Attack Right BF Shield',  24, false);
		hexRef.addOffset('up-Boyfriend-Shield', 125, 150);
		hexRef.addOffset('left-Boyfriend-Shield', 200, -50);
		hexRef.addOffset('down-Boyfriend-Shield', 30, -100);
		hexRef.addOffset('right-Boyfriend-Shield', -200, 15);

		hexRef.animation.addByPrefix('left-Boyfriend', 'Hex Attack Left BF0',  24, false);
		hexRef.animation.addByPrefix('down-Boyfriend', 'Hex Attack Down BF0',  24, false);
		hexRef.animation.addByPrefix('up-Boyfriend', 'Hex Attack Up BF0',  24, false);
		hexRef.animation.addByPrefix('right-Boyfriend', 'Hex Attack Right BF0',  24, false);
		hexRef.addOffset('up-Boyfriend', 125, 150);
		hexRef.addOffset('left-Boyfriend', 200, -50);
		hexRef.addOffset('down-Boyfriend', 30, -100);
		hexRef.addOffset('right-Boyfriend', -200, 15);

		hexRef.animation.addByPrefix('left-Girlfriend', 'Hex Attack Left GF',  24, false);
		hexRef.animation.addByPrefix('down-Girlfriend', 'Hex Attack Down GF',  24, false);
		hexRef.animation.addByPrefix('up-Girlfriend', 'Hex Attack Up GF',  24, false);
		hexRef.animation.addByPrefix('right-Girlfriend', 'Hex Attack Right GF',  24, false);
		hexRef.addOffset('up-Girlfriend', 138, 144);
		hexRef.addOffset('left-Girlfriend', 262, 52);
		hexRef.addOffset('down-Girlfriend', 23, 52);
		hexRef.addOffset('right-Girlfriend', -233, 76);

		hexRef.animation.addByPrefix('left-Carol', 'Hex Attack Left Carol',  24, false);
		hexRef.animation.addByPrefix('down-Carol', 'Hex Attack Down Carol',  24, false);
		hexRef.animation.addByPrefix('up-Carol', 'Hex Attack Up Carol',  24, false);
		hexRef.animation.addByPrefix('right-Carol', 'Hex Attack Right Carol',  24, false);
		hexRef.addOffset('left-Carol', 231, 125);
		hexRef.addOffset('down-Carol', 19, 128);
		hexRef.addOffset('up-Carol', 131, 169);
		hexRef.addOffset('right-Carol', -236, 165);

		hexRef.animation.addByPrefix('left-Robot', 'Hex Attack Left Carol',  24, false);
		hexRef.animation.addByPrefix('down-Robot', 'Hex Attack Down Carol',  24, false);
		hexRef.animation.addByPrefix('up-Robot', 'Hex Attack Up Carol',  24, false);
		hexRef.animation.addByPrefix('right-Robot', 'Hex Attack Right Carol',  24, false);
		hexRef.addOffset('left-Robot', 241, 92);
		hexRef.addOffset('down-Robot', 25, 97);
		hexRef.addOffset('up-Robot', 139, 118);
		hexRef.addOffset('right-Robot', -246, 195);

		hexRef.animation.addByPrefix('left-Whitty', 'Hex Attack Left Whitty',  24, false);
		hexRef.animation.addByPrefix('down-Whitty', 'Hex Attack Down Whitty',  24, false);
		hexRef.animation.addByPrefix('up-Whitty', 'Hex Attack Up Whitty',  24, false);
		hexRef.animation.addByPrefix('right-Whitty', 'Hex Attack Right Whitty',  24, false);
		hexRef.addOffset('left-Whitty', 256, 24);
		hexRef.addOffset('down-Whitty', 22, 22);
		hexRef.addOffset('up-Whitty', 135, 149);
		hexRef.addOffset('right-Whitty', -221, 78);

		hexRef.animation.addByPrefix('possess-all', 'Hex Possess instance 1',  24, false);
		hexRef.addOffset('possess-all', -28, 181);

		hexRef.animation.addByPrefix('possess-bf', 'Possess BF instance 1',  24, false);
		hexRef.addOffset('possess-bf', -38, 71);

		hexRef.animation.addByPrefix('possess-gf', 'Possess GF instance 1',  24, false);
		hexRef.addOffset('possess-gf', -40, 81);

		hexRef.animation.addByPrefix('possess-carol', 'Possess CAROL instance 1',  24, false);
		hexRef.addOffset('possess-carol', -48, 170);
		//_electricityDebugAnim = 'possess-carol';

		hexRef.animation.addByPrefix('possess-whitty', 'Possess WHITTY instance 1',  24, false);
		hexRef.addOffset('possess-whitty', -48, 75);

		hexRef.scale.set(2, 2);
		hexRef.antialiasing = true;
	}, 'Hex Attack Sprite');


	addPreloadItem(function() {
		gridRight = new FunkinSprite(600, -100);
		gridRight.frames = Paths.getSparrowAtlas(getStagePath('visuals/lightningGridBf'));
		gridRight.animation.addByPrefix('idle', 'Electric shield', 12, true);
		gridRight.playAnim('idle', true);
		//bfShield.scale.set(2.5, 2.5);
		gridRight.antialiasing = true;
		gridRight.visible = false;
		insert(members.indexOf(them.bf.char)+1, gridRight);
	}, 'Light Grid Right');

	addPreloadItem(function() {
		gridLeft = new FunkinSprite(0, -100);
		gridLeft.frames = Paths.getSparrowAtlas(getStagePath('visuals/lightningGridHex'));
		gridLeft.animation.addByPrefix('idle', 'Electric shield', 12, true);
		gridLeft.playAnim('idle', true);
		//bfShield.scale.set(2.5, 2.5);
		gridLeft.antialiasing = true;
		gridLeft.visible = false;
		add(gridLeft);
	}, 'Light Grid Left');

	addPreloadItem(function() {
		shockingBf = new FunkinSprite(boyfriend.x - 150, boyfriend.y + 250);
		shockingBf.frames = Paths.getSparrowAtlas(getStagePath('visuals/electricity'));
		shockingBf.animation.addByPrefix('spawn', 'Electricity copy', 24, false);
		shockingBf.scale.set(1, 1);
		shockingBf.visible = false;
		shockingBf.animation.finishCallback = (name) -> {
			shockingBf.visible = false;
		}
		//bfShield.scale.set(2.5, 2.5);
		shockingBf.antialiasing = true;
		insert(members.indexOf(boyfriend)-1, shockingBf);
	}, 'Bf Electricity Effect');

	addPreloadItem(function() {
		bfRef = new FunkinSprite(dad.x, dad.y);
		bfRef.frames = Paths.getSparrowAtlas(getStagePath('attacks/boyfriend'));
		bfRef.animation.addByPrefix('left', 'Spark Mid',  24, false);
		bfRef.animation.addByPrefix('down', 'Spark Lower',  24, false);
		bfRef.animation.addByPrefix('up', 'Spark Upper',  24, false);
		bfRef.animation.addByPrefix('right', 'Spark Mid',  24, false);
		bfRef.addOffset('left', -30, -25);
		bfRef.addOffset('down', 0 + 20, -100);
		bfRef.addOffset('up', -50 + 20, 0);
		bfRef.addOffset('right', -30, -25);
		//bfRef.scale.set(1, 1);
		bfRef.scale.set(2, 2);
		bfRef.antialiasing = true;
		add(bfRef);
	}, 'Bf Attack Electricity');

	addPreloadItem(function() {
		bfShield = new FunkinSprite(525, -150);
		bfShield.frames = Paths.getSparrowAtlas(getStagePath('visuals/shield'));
		bfShield.animation.addByPrefix('spawn', 'Shield0', 12, false);
		bfShield.addOffset('spawn', 310, 0);
		bfShield.alpha = 0.8;
		bfShield.scale.set(1, 0.95);
		bfShield.animation.addByPrefix('idle', 'Shield Exist', 12, true);
		bfShield.animation.finishCallback = function (name) {
			if (name == 'spawn') {
				bfShield.playAnim('idle', true);
			}
		}
		//bfShield.scale.set(2.5, 2.5);
		bfShield.antialiasing = true;
		bfShield.visible = false;
		bfShield.playAnim('spawn', true);
		insert(members.indexOf(stage.getSprite('attackLayer')), bfShield);
	}, 'Fire Shield Sprite');

	addPreloadItem(function() {
		endPart.bitmap.onFormatSetup.add(function() {
			endPart.updateHitbox();
			var scaleFactor = (FlxG.width / endPart.width);
			endPart.antialiasing = true;
			endPart.scale.set(scaleFactor, scaleFactor);
			endPart.updateHitbox();
			endPart.screenCenter();
			endPart.alpha = 1;
		});
		endPart.visible = false;
		endPart.autoPause = true;
		endPart.load(Assets.getPath(Paths.video('hexEnding')), [':no-audio']);
		// video.screenCenter(FlxAxes.X);
		endPart.play();
		endPart.pause();

		endPart.cameras = [camHUD];
		insert(0, endPart);
	}, "Ending Animation");

	remove(them.ghost.char);
	insert(members.indexOf(them.hex.char), them.ghost.char);
}
function popupSpawn(spr, type) {
	var funcs = [
		"Heated Up" => function() {
			whittyHeated = true;
		},
		"Echo" => function() {
			shakeCameraSilly(1, 0.2, FlxAxes.Y);
		}
	][type]();
}
//var _shakeTween:FlxTween;
function shakeCameraSilly(intensity, duration, ?axes:FlxAxes = FlxAxes.XY, ?onComplete = ()->{}) {
	//_shakeTween = FlxTween.shake(FlxG.camera.scroll, intensity, duration, axes ?? FlxAxes.XY);
	_isShaking = true;
	//_shakeCamera.shake(intensity/100, duration, onComplete, true, axes);
	_shakeIntensity = intensity;
	new FlxTimer().start(duration, (t)->{
		_isShaking = false;
	});
}
function spawnShield(whatShield) {
	//var whatShield = w;
	switch (whatShield) {
		case 'Boyfriend Fire':
			them.whitty.char.playAnim('snap');
			them.whitty.char.animation.callback = function (name, frame, index) {
				if (name == 'snap' && frame == 4) {
					bfShield.playAnim('spawn');
					bfShield.visible = true;
					bfIsShielded = true;
					ignorePlayerDamage = true;
				}
			}
		case 'Boyfriend Grid':
			bfIsShielded = true;
			ignorePlayerDamage = true;
			FlxFlicker.flicker(gridRight, (0.5)/1.5, (0.25 * 0.25)/1.5, true);
		case 'Hex Grid':
			FlxFlicker.flicker(gridLeft, (0.5)/1.5, (0.25 * 0.25)/1.5, true);
	}
	trace(whatShield);
}

function killShield(whatShield) {
	switch (whatShield) {
		case 'Boyfriend Fire':
			bfIsShielded = false;
			ignorePlayerDamage = false;
			var div = 1.5;
			FlxFlicker.flicker(bfShield, (0.5)/div, (0.25 * 0.25)/div, false);
		case 'Boyfriend Grid':
			FlxFlicker.flicker(gridRight, (0.5)/1.5, (0.25 * 0.25)/1.5, false, function() {
				bfIsShielded = false;
				ignorePlayerDamage = false;
			});
		case 'Hex Grid':
			FlxFlicker.flicker(gridLeft, (0.5)/1.5, (0.25 * 0.25)/1.5, false);
	}
}
var defaultWhitX;
function onStartSong() {
	defaultWhitX = them.whitty.char.x;
	them.ghost.char.x = them.hex.char.x;
	them.ghost.char.y = them.hex.char.y;
	them.ghost.char.color = 0xffff87cb;
	them.ghost.char.alpha = 0.5;

	them.hex.strumLine.onHit.add((event) -> {
		onHexHitNote(event);
	});
	for(i => name in ['bf', 'gf', 'whitty', 'carol']) { // Thank's to Neo(ne_eo) for the for loop.
		strumLines.members[i+1].onHit.add((event) -> {
			onPlayerHitNoteHold(event, name);
			if (!event.note.isSustainNote) onPlayerHitNote(event, name);
		});
		strumLines.members[i+1].onMiss.add((event) -> {
			onPlayerMissNote(event, name);
		});
	}
	them.robot.strumLine.onHit.add((event) -> {
		if (them.robot.char.animation.name == 'idle-alt') {
			event.animCancelled = true;
		}
		shakeCameraSilly(1, 0.2, FlxAxes.Y);
		if (!event.note.isSustainNote) onPlayerHitNote(event, 'robot');
		for (i in 1...5) {
			if (playerHealths[i-1] + 0.02 <= 1.02) {
				playerHealths[i-1] += (gridLeft.visible && !playersArePossessed) ? 0 : 0.02;
			}
		}
		if (healthBarHex.value - 0.01 >= 0) {
			//healthBarHex.value -= (gridLeft.visible && !playersArePossessed) ? 0 : 0.01;
		}
	});
}
var hitBool:Bool = false;
var triggered:Bool = false;
function onHexHitNote(event) {
	if (!event.note.isSustainNote) {
		if (them.whitty.char.x != defaultWhitX) {
			shakeCameraSilly(2, 0.1, FlxAxes.Y);
			them.whitty.char.x += 1008/4;
			them.whitty.char.playAnim(hitBool ? 'singRIGHT-hit' : 'hit-hurt', true);
			hitBool = !hitBool;
			triggered = true;
			return;
		} else if (them.whitty.char.x > defaultWhitX) {
			them.whitty.char.x = defaultWhitX;
		} else if (triggered) {
			triggered = false;
			whittyHeated = false;
		}
	}
	event.characters = [event.noteType == 'Ghost Note' ? them.ghost.char : them.hex.char];
	if (hexAttackTarget == null || hexAttackTarget == 'NaN') return;
	var dirStrings = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	var indexes = ['Boyfriend', 'Girlfriend', 'Whitty', 'Carol', 'Robot'];
	var hitAnim = ['hurt', 'hit', 'hit', 'block', 'hit'];

	var charIndex = indexes.indexOf(hexAttackTarget);
	if (playerHealths[charIndex] - 0.01 >= 0) {
		playerHealths[charIndex] -= (ignorePlayerDamage && !playersArePossessed) ? 0 : 0.01;
	}
	if (healthBarHex.value + 0.01 < 1.01) {
		//healthBarHex.value += (ignorePlayerDamage && hexAttackTarget != 'All' && !playersArePossessed) ? 0 : 0.01;
	}
	var directionStrings = ['left', 'down', 'up', 'right'];
	var daFunc = function(event, directionStrings, layer, ?who) {
		if (who == null || (who == 'Robot' && (gridRight.visible || playersArePossessed))) return;
		var attackAsset = new FunkinSprite(dad.x, dad.y).copyFrom(hexRef);
		attackAsset.animation.finishCallback = (name) -> {
			attackAsset.kill();
		}
		attackAsset.x = dad.x + 400;
		attackAsset.y = dad.y + 150;
		if (who == 'Robot') {
			attackAsset.skew.set(robotSkewValues[event.direction].x, robotSkewValues[event.direction].y);
		}
		attackAsset.playAnim(directionStrings[event.direction] + '-' + who + (bfIsShielded ? '-Shield' : ''), true);
		insert(layer, attackAsset);
	}
	if (!gridRight.visible && !playersArePossessed && !(bfIsShielded && gridRight.visible)) {
		daFunc(event, directionStrings, members.indexOf(stage.getSprite('attackLayer')), hexAttackTarget);
	}
	if (playersArePossessed) {
		if (hexAttackTarget == 'All') {
			for (i in 1...5) {
				if (playerHealths[i-1] - 0.02 >= 0) {
					playerHealths[i-1] -= 0.02;
				}
				shakeCameraSilly(2, 0.2, FlxAxes.Y);
				strumLines.members[i].characters[0].playAnim(dirStrings[event.direction] + '-hit', true, 'SING');
			}
		} else {
			if (strumLines.members[charIndex + 1].characters[0].animation.name == [ 'Boyfriend' => 'hurt-electric', 'Girlfriend' => 'hit-electrocuted', 'Carol' => 'hit', 'Whitty' => 'hit-hurt' ][hexAttackTarget] && strumLines.members[charIndex + 1].characters[0].animation.curAnim.curFrame < 4) {} else {
				strumLines.members[charIndex + 1].characters[0].playAnim(dirStrings[event.direction] + '-hit', true, 'SING');
			}
		}
	} else {
		if (!ignorePlayerDamage)
			strumLines.members[charIndex + 1].characters[0].playAnim(hitAnim[charIndex], true);
	}
	if (dad.animation.name == 'posses-small') {
		event.animCancelled = true;
	}
}
function onHexTargetChange(who) {
	if (playersArePossessed) {
		shakeCameraSilly(2, 0.2, FlxAxes.Y);
		var attackAsset = new FunkinSprite(dad.x, dad.y).copyFrom(hexRef);
		attackAsset.animation.finishCallback = (name) -> {
			attackAsset.kill();
		}
		attackAsset.x = dad.x + 400;
		attackAsset.y = dad.y + 150;
		var charMap = [ 'Boyfriend' => them.bf.char, 'Girlfriend' => them.gf.char, 'Carol' => them.whitty.char, 'Whitty' => them.carol.char ];
		if (who != 'All') {
			charMap[who].playAnim([
				'Boyfriend' => 'hurt-electric',
				'Girlfriend' => 'hit-electrocuted',
				'Carol' => 'hit',
				'Whitty' => 'hit-hurt'
			][who], true);
			dad.playAnim('posses-small', true);
			attackAsset.playAnim([
				'Boyfriend' => 'possess-bf',
				'Girlfriend' => 'possess-gf',
				'Carol' => 'possess-carol',
				'Whitty' => 'possess-whitty'
			][who], true);
			insert(members.indexOf(charMap[who])+1, attackAsset);
		} else {
			for (si=>strumline in strumLines.members) {
				if (si != 0 && si != 5) {
					strumline.characters[0].playAnim([
						them.bf.char => 'hurt-electric',
						them.gf.char => 'hit-electrocuted',
						them.whitty.char => 'hit',
						them.carol.char => 'hit-hurt'
					][strumline.characters[0]], true);
				}
			}
			attackAsset.playAnim('possess-all', true);
			insert(members.indexOf(them.carol.char)+1, attackAsset);
		}




	}
}
function onPlayerHitNoteHold(event, who:String) {
	if (hexIsShielded) return;
	if (healthBarHex.value - 0.01 >= 0) {
	//	healthBarHex.value -= (gridLeft.visible && !playersArePossessed) ? 0 : 0.01;
	}

	var indexes = ['bf', 'gf', 'whitty', 'carol', 'robot'];
	var charIndex = indexes.indexOf(who);
	if (playerHealths[charIndex] + 0.02 <= 1.02) {
		playerHealths[charIndex] += (gridLeft.visible && !playersArePossessed) ? 0 : 0.02;
	}
}
function onPlayerMissNote(event, who:String) {
	var indexes = ['bf', 'gf', 'whitty', 'carol'];
	var i = indexes.indexOf(who);
	if (i == -1) {
		event.animCancelled = true;
		for (pi=>char in indexes) {
			if (playerHealths[pi] - 0.03 >= 0) {
				playerHealths[pi] -= 0.03;
			} else {
				playerHealths[pi] = 0;
			}
		}
	} else {
		if (playerHealths[i] - 0.03 >= 0) {
			playerHealths[i] -= 0.03;
		} else {
			playerHealths[i] = 0;
		}
	}
}
function onPlayerHitNote(event, who:String) {
	//trace(who + ' note hit');
	if (hexIsShielded) return;
	if (stage.getSprite('finalAttack').alpha == 1) return;

	var directionStrings = ['left', 'down', 'up', 'right'];
	var anims = ['hit-middle', 'hit-bottom', 'hit-top', 'hit-middle'];
	var animsRobo = ['mid-f', 'top-f', 'bottom-f', 'mid-f'];
	if (!gridLeft.visible && them.hex.char.animation.name != 'posses')
		dad.playAnim(anims[event.direction], true);
	var attackRefs = { gf: gfSlashRef, whitty: whittyFireRef, bf: bfRef, carol: carolFireRef, robot: robotRef }
	var daFunc = function(event, directionStrings, layer, ?ref) {
		if (ref == null) return;
		if (gridLeft.visible && !["whitty", "carol", "robot"].contains(who)) return;
		var attackAsset = new FunkinSprite(dad.x, dad.y).copyFrom(ref);
		attackAsset.animation.finishCallback = (name) -> {
			if (gridLeft.visible && ["whitty", "carol"].contains(who)) {
				attackAsset.scale.set(2, 2);
				attackAsset.updateHitbox();
				attackAsset.x = dad.x + 50;
				attackAsset.y = dad.y;
				attackAsset.playAnim(directionStrings[event.direction] + "-smoke", true);
				attackAsset.animation.finishCallback = (name) -> {
					attackAsset.kill();
				}
			} else {
				attackAsset.kill();
			}
		}
		if (who == 'robot') {
 			attackAsset.x = dad.x + 400 + (them.robot.char.animation.name == 'idle-alt' ? 100 : 0);
			attackAsset.y = dad.y + 150 + (them.robot.char.animation.name == 'idle-alt' ? 275 : 0);
			attackAsset.angle = (them.robot.char.animation.name == 'idle-alt' ? 15 : 0);
		}
		attackAsset.playAnim(who != 'robot' ? (directionStrings[event.direction] + (gridLeft.visible ? "-bullet" : ((whittyHeated && who == "whitty") ? "-blast" : ''))) : (!gridLeft.visible ? animsRobo[event.direction] : 'mid-h'), true);
		insert(layer, attackAsset);
	}
	//if (!gridLeft.visible) {
	daFunc(event, directionStrings, members.indexOf(stage.getSprite((who == 'robot') ? 'attackLayerRobot' : 'attackLayer')), Reflect.field(attackRefs, who));
	//} else if (who == ) {
	//	daFunc(event, directionStrings, members.indexOf(stage.getSprite(who == 'robot' ? 'attackLayerRobot' : 'attackLayer')), Reflect.field(attackRefs, who));
	//}
	them.hex.char.flipX = false;
	if (who == 'bf') {
		shockingBf.visible = true;
		shockingBf.playAnim('spawn', true);
		if (hexIsPossessed) {
			var shockingHex = new FunkinSprite(dad.x, dad.y).copyFrom(shockingBf);
			shockingHex.playAnim('spawn', true);
			shockingHex.visible = true;
			shockingHex.updateHitbox();
			shockingHex.x = them.hex.char.x - 200;// - (shockingHex.width);
			shockingHex.y = them.hex.char.y - 100;
			shockingHex.scale.set(shockingHex.scale.x * 1.5, shockingHex.scale.y * 1.5);
			if (event.direction == 3) {
				them.hex.char.flipX = true;
			} else {
				them.hex.char.flipX = false;
			}
			insert(members.indexOf(them.hex.char), shockingHex);
		}
	}
}
function onGamePause(e) {
	endPart.pause();
}
function onGameResume() {
	endPart.resume();
}
var steps = [
	58 => ()-> shakeCameraSilly(2, 0.1, FlxAxes.Y),
	1340 => ()-> {
		playersArePossessed = true;
		shakeCameraSilly(2, 0.1, FlxAxes.XY);
	},
	1664 => ()-> {
		hexIsPossessed = true;
	},
	1728 => ()-> {
		hexIsPossessed = false;
	},
	2348 => ()-> {
		stage.getSprite('finalAttack').alpha = 1;
		stage.getSprite('finalAttack').playAnim('exist', true);
	},
	2367 => ()-> {
		endPart.stop();
		endPart.bitmap.onEndReached.add(function() {
			camGame.visible = false;
			endPart.visible = false;
		});
		endPart.play();
		endPart.visible = true;
	}
];
function stepHit() { (steps[curStep] ?? ()->{})(); }

var defScroll;
var switchers = [false, false];
function postUpdate(elasped:Float) {

	health = 1;
	healthBar.visible = false;
	healthBarBG.visible = false;
	iconP1.visible = false;
	iconP2.visible = false;

	them.ghost.char.visible = them.ghost.char.lastAnimContext == 'SING';

	var allHealths:Float = 0;
	for (i=>healthBar in playerHealths) {
		allHealths += healthBar;
	}
	if (allHealths <= 0) {
		health = 0;
	}
	healthBarHex.value = lerp(healthBarHex.value, 1-(allHealths / 4), 0.2);
	if (healthBarHex.value <= 0.25) {
		playerHealthIcons[0].setHealthSteps([[0, 1], [20, 0]]);
		playerHealthIcons[0].animation.curAnim.curFrame = 1;
		playerHealthIcons[0].setHealthSteps([]);
	}
	for (i=>healthBar in playerHealthBars) {
		healthBar.value = lerp(healthBar.value, playerHealths[i], 0.2);
		if (healthBar.value <= 0.25) {
			playerHealthIcons[i+1].setHealthSteps([[0, 1], [20, 0]]);
			playerHealthIcons[i+1].animation.curAnim.curFrame = 1;
			playerHealthIcons[i+1].setHealthSteps([]);
		}
	}
	for (i=> strumline in strumLines.members) {
		if (strumline.characters[0].icon != 'robot') {
			var icon = playerHealthIcons[i];
			icon.updateHitbox();
			icon.centerOrigin();
			icon.scale.set(lerp(icon.scale.x, 0.3, 0.2), lerp(icon.scale.y, 0.3, 0.2));
			icon.updateHitbox();
			icon.y = 247.5 - (icon.height/2);
			if (i != 0) {
				icon.flipX = true;
				icon.x = (playerHealthBars[i-1].x + (playerHealthBars[i-1].width/2)) - (icon.width/2);
			} else {
				icon.x = (healthBarHex.x + (healthBarHex.width/2)) - (icon.width/2);
			}
		}
	}

	defScroll = defScroll ?? camGame.scroll;
	if (curStep % 2 == 0) {
		switchers[0] = !switchers[0];
		switchers[1] = !switchers[1];
	}

	//_shakeIntensity = 10;
	if (_isShaking) {
		camGame.targetOffset.set(0, FlxG.random.int(0, _shakeIntensity*10)*(switchers[0] ? -1 : 1));
		camGame.snapToTarget();
	} else {
		camGame.targetOffset.set(0, 0);
		camGame.snapToTarget();
	}

	//dad.color = 0xFF000000;
}
function beatHit() {
	for (i=>healthBar in playerHealthBars) {
		if (healthBar.value >= 0.75) {
			playerHealthIcons[i+1].scale.set(0.4, 0.4);
		}
	}
}
function checkFileExists(path:String) {
	return Assets.exists(Paths.getPath(path));
}
var _daPos:Int = -1000;
var _prev:Bool;
function updateLoaded() {
	if (_debugMode) {
		Conductor.songPosition = _daPos;
		FlxG.autoPause = false;
		FlxG.sound?.music?.time = -1000;
		for (sound in FlxG.sound.list.members) {
			sound?.time = -1000;
		}
	} else {
		_daPos = Conductor.songPosition;
	}
	if (_prev != _debugMode) {
		_prev = _debugMode;
		FlxG.sound?.music?.time = _daPos;
		for (sound in FlxG.sound.list.members) {
			sound?.time = _daPos;
		}
	}
}
function postUpdateLoaded() {
	if (checkFileExists('glitcherDebug.json')) {
		var debugData = Json.parse(Assets.getText('glitcherDebug.json'));
		_debugMode = debugData.debugMode;
		if (!debugData.debugMode) {
			for (sprite in stage.stageSprites) {
				sprite?.visible = true;
			}
			camHUD.visible = true;
		}
	}
	if (_debugMode) {
		//Conductor.songPosition = -1;

		if (checkFileExists('glitcherDebug.json')) {
			var debugData = Json.parse(Assets.getText('glitcherDebug.json'));
			_debugRef = ["hexRef" => hexRef, "whittyRef" => whittyFireRef, "carolRef" => carolFireRef, "bfRef" => bfRef, "gfRef" => gfSlashRef, "robotRef" => robotRef ][debugData.debugRef];
			_debugChar = strumLines.members[debugData.debugChar].characters[0];
			_dadDebugAnim = debugData.debugCharAnim;
			_electricityDebugAnim = debugData.attackDebugAnim;
			_debugRef.skew.set(debugData.skew[0], debugData.skew[1]);
			for (i=>strumLine in strumLines.members) {
				if (i != debugData.debugChar) {
					if (i != debugData.debugHitChar) {
						strumLine.characters[0].playAnim('idle', true);
					} else {
						strumLine.characters[0].playAnim(debugData.debugHitCharAnim, true);
					}
				} else {
					if (debugData.debugChar == 1) {
						boyfriend.playAnim(_dadDebugAnim, true);
					} else {
						strumLine.characters[0].playAnim(_dadDebugAnim, true);
					}
				}
				strumLine.characters[0].animation.curAnim.curFrame = 0;
			}
			for (sprite in stage.stageSprites) {
				sprite?.visible = true;
			}
			for (sprite in debugData.stageAssetsToHide) {
				stage.getSprite(sprite).visible = false;
			}
			camHUD.visible = debugData.showHUD;
			_debugRef.playAnim(_electricityDebugAnim, true);
			_debugRef.animation.curAnim.curFrame = debugData.attackDebugFrame;
			if (debugData.debugRef == "hexRef" || debugData.debugRef == "robotRef") {
				_debugRef.x = dad.x + 400;
				_debugRef.y = dad.y + 150;
			} else {
				_debugRef.x = dad.x;
				_debugRef.y = dad.y;
			}
			gridLeft.visible = debugData.gridVisibilityForce.left;
			gridRight.visible = debugData.gridVisibilityForce.right;
		} else {

			_debugRef = hexRef;
		}
		if (members.indexOf(_debugRef) == -1) {
			add(_debugRef);
		}

		camGame.zoom = _debugZoom;

		//hexRef.addOffset(_electricityDebugAnim, 145, 150);



		_debugRef.visible = true;


		_debugZoom += (FlxG.keys.pressed.Q ? -0.05 : (FlxG.keys.pressed.E ? 0.05 : 0));

		if (FlxG.keys.pressed.V) {
			_debugRef.addOffset(_electricityDebugAnim, _debugRef.getAnimOffset(_electricityDebugAnim).x + 1, _debugRef.getAnimOffset(_electricityDebugAnim).y);
			trace(_debugRef.getAnimOffset(_electricityDebugAnim));
		}
		if (FlxG.keys.pressed.B) {
			_debugRef.addOffset(_electricityDebugAnim, _debugRef.getAnimOffset(_electricityDebugAnim).x, _debugRef.getAnimOffset(_electricityDebugAnim).y - 1);
			trace(_debugRef.getAnimOffset(_electricityDebugAnim));
		}
		if (FlxG.keys.pressed.N) {
			_debugRef.addOffset(_electricityDebugAnim, _debugRef.getAnimOffset(_electricityDebugAnim).x, _debugRef.getAnimOffset(_electricityDebugAnim).y + 1);
			trace(_debugRef.getAnimOffset(_electricityDebugAnim));
		}
		if (FlxG.keys.pressed.M) {
			_debugRef.addOffset(_electricityDebugAnim, _debugRef.getAnimOffset(_electricityDebugAnim).x - 1, _debugRef.getAnimOffset(_electricityDebugAnim).y);
			trace(_debugRef.getAnimOffset(_electricityDebugAnim));
		}
	}
}