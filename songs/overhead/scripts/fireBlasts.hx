/*  --------- Imports --------- */
import flixel.addons.util.FlxAsyncLoop;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxBarFillDirection;
import flixel.util.FlxGradient;
/*  --------- Classes --------- */

class ShrapnelIcon {
	public  var x:Float;
	public  var y:Float;
	public  var eX:Float;
	public  var eY:Float;
	public  var tweenTime:Float;
	public  var step:Int;
	public  var coloredIcon:FunkinSprite;
	public  var shrapnelIcon:FunkinSprite;
	private var shrapnelPopup:FlxSprite;
	public  var hasText:Bool = false;
	public  var isDark:Bool = true;
	public  var completeCallback;

	public function new(start, end, path, prefix, triggerStep, duration, ?hasPopup, ?dark) {
		x = start.x;
		y = start.y;
		eX = end.x;
		eY = end.y;

		hasText = hasPopup ?? false;
		isDark = dark ?? true;

		coloredIcon = new FunkinSprite();
		coloredIcon.frames = Paths.getSparrowAtlas(path);
		coloredIcon.animation.addByPrefix('bop', prefix + ' bop', 24, true);
		coloredIcon.animation.play('bop');
		coloredIcon.x = x;
		coloredIcon.y = y;
		coloredIcon.antialiasing = true;

		shrapnelIcon = new FunkinSprite();
		shrapnelIcon.frames = Paths.getSparrowAtlas(path);
		shrapnelIcon.animation.addByPrefix('bop', prefix + ' dark', 24, true);
		shrapnelIcon.animation.play('bop');
		shrapnelIcon.x = x;
		shrapnelIcon.y = y;
		shrapnelIcon.antialiasing = true;

		shrapnelPopup = new FlxSprite().loadGraphic(Paths.image('game/popups/Shrapnel'));
		shrapnelPopup.x = x - shrapnelPopup.width / 2;
		shrapnelPopup.y = y + 50;

		shrapnelIcon.visible = false;
		coloredIcon.visible = false;

		var scaleFactor = 1.5;
		coloredIcon.scale.set(scaleFactor, scaleFactor);
		shrapnelIcon.scale.set(scaleFactor, scaleFactor);

		step = triggerStep;
		tweenTime = duration;
	}

	public function updateShrapnel() {
		if (shrapnelIcon == null || coloredIcon == null)
			return;
		// shrapnelIcon.x = x;
		// shrapnelIcon.y = y;
		shrapnelIcon.alpha = 1 - coloredIcon.alpha;
		shrapnelPopup.visible = hasText ? shrapnelIcon.visible : false;
		shrapnelPopup.x = shrapnelIcon.x + (shrapnelIcon.width / 1.5) - (shrapnelPopup.width / 2);
		shrapnelPopup.y = shrapnelIcon.y + 50 + shrapnelIcon.height;
	}

	public function doTween() {
		shrapnelIcon.visible = true;
		coloredIcon.visible = true;
		FlxTween.tween(this.shrapnelIcon, {x: this.eX, y: this.eY}, tweenTime);
		FlxTween.tween(this.coloredIcon, {x: this.eX, y: this.eY}, tweenTime);
		new FlxTimer().start(tweenTime, function(timer) {
			this.coloredIcon.visible = false;
			this.shrapnelIcon.visible = false;
			if (completeCallback != null)
				completeCallback();
		});
		if (isDark)
			FlxTween.tween(this.coloredIcon, {alpha: 0}, tweenTime / 2);
	}
}

class Part {
	public var text;
	public var dash;
	public var reset;

	public function new(Text:String, ?useDash:Bool = false, ?Reset:Bool = false) {
		this.text = Text;
		this.dash = useDash ?? false;
		this.reset = Reset ?? false;
	}
}

/*  ---- Global Variables ----- */
/* ---- FlxSprite ---- */
var shieldDAD:        FlxSprite;
var screamBlast:      FlxSprite;
var screamBlastBF:    FlxSprite;
var shieldBF:         FlxSprite;
var heatedGradientDad:FlxSprite;
var heatedGradientBF: FlxSprite;
var burst:            FlxSprite;
var vignette:         FlxSprite;
/* ----- Boolean ----- */
var loadedAssets:     Bool = false;
var doubleMode:       Bool = false;
var isShaking:        Bool = false;
var customLockEnabled:Bool = false;
var dadLockPose:      Bool = false;
/* ----- Integer ----- */
var dadCurDir:    Int =        4;
var bfCurDir:     Int =        4;
var shakeInterval:Int =        2;
var curPart:      Int =        0;
var DEFAULTCOLOR: Int = 16777215;
var timerStart:   Int =        0;
var timerEnd:     Int =        0;
/* - Floating Point -- */
var timerBar:      Float = 50.0;
var shakeIntensity:Float = 0.05;
var defaultLockX:  Float =    0;
var defaultLockY:  Float =    0;
/* ---- FlxGroups ---- */
var preloaders:FlxTypedGroup = new FlxTypedGroup();
/* --- FlxCameras ---- */
var dialogueCamera:FlxCamera;
var vignetteCamera:FlxCamera;
/* -- FunkinSprite --- */
var dialogueBox:     FunkinSprite;
var dialogueBoxBurn: FunkinSprite;
var fallingWhittyDia:FunkinSprite;
var customBFIcon:    FunkinSprite;
var customDadIcon:   FunkinSprite;
/* ----- FlxText ----- */
var dialogueText:    FlxText = new FlxText(0, 320, 800, 'Baller', 302);
var dialogueTextBack:FlxText = new FlxText(0, 320, 800, 'Baller', 302);
/* ------ FlxBar ----- */
var dialogueTimerBar:FlxBar;
/* ---- Structure ---- */
var vignetteProfiles = {HEATED: 0xCCFF0000, SHRAPNEL: 0x99000000}
var customLock       = {x: 0, y: 0, zoom: 0.7}
/* ------ Array ------ */
var shrapnels:Array;
var parts:    Array = [
	new Part('Why', false, true),
	new Part(' the'),
	new Part(' hell'),
	new Part(' won\'t'),
	new Part(' you'),
	new Part(' leave'),
	new Part(' me'),
	new Part(' a', true),
	new Part('lone?'),
	new Part('Just', false, true),
	new Part(' give'),
	new Part(' up.'),
	new Part(' The'),
	new Part(' fi', true),
	new Part('re'),
	new Part(' won\'t'),
	new Part(' do'),
	new Part(' an', true),
	new Part('y', true),
	new Part('thing.'),
];

/*  --------- Functions/Callbacks --------- */
function spawnBlast(type:String) {
	switch (type) {
		case 'dad':
			if (screamBlast == null)
				return;
			screamBlast.alpha = 1;
			screamBlast.animation.play('blast', true);
		case 'bf' | 'boyfriend':
			if (screamBlastBF == null)
				return;
			screamBlastBF.alpha = 1;
			screamBlastBF.animation.play('blast', true);
	}
}

function updateBlast() {
	if (screamBlast == null)
		return;
	screamBlast.x = dad.x - 1660;
	screamBlast.y = dad.y - 1750;
	if (screamBlast.animation.finished) {
		screamBlast.alpha = 0.0001;
	}
	if (screamBlastBF == null)
		return;
	screamBlastBF.x = boyfriend.x - 2090;
	screamBlastBF.y = boyfriend.y - 1450;
	if (screamBlastBF.animation.finished) {
		screamBlastBF.alpha = 0.0001;
	}
}

function copyPreload(index:Int) {
	if (index == null)
		return new FunkinSprite(0, 0);
	preloaders.members[index].revive();
	var returner = preloaders.members[index].clone();
	preloaders.members[index].kill();
	return returner;
}

function postCreate() {
	lossSFX = 'Smoke'; // Set death sound :D

	/* ----- Preload Assets ----- */

	addPreloadItem(function(){
		var blaster = new FlxSprite(100, 400); // , Paths.image('stages/Vs Whitty/alley/fireBlasts'));
		blaster.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/fireBlasts');
		blaster.animation.addByPrefix('dad', 'Fire Blast0', 24, false);
		blaster.animation.addByPrefix('bf', 'Fire Blast BF', 24, false);
		blaster.alpha = 0.0001;
		blaster.kill();
		preloaders.add(blaster);
	}, "Fire Blasts");

	addPreloadItem(function(){
		var bullet = new FlxSprite(100, 400);
		bullet.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/fireBullets');
		bullet.animation.addByPrefix('dad', 'Fire Shot instance 1', 24, false);
		bullet.animation.addByPrefix('bf', 'Fire Shot BF instance 1', 24, false);
		bullet.kill();
		preloaders.add(bullet);
	}, "Fire Bullets");

	addPreloadItem(function(){
		burst = new FlxSprite(boyfriend.x - 95, boyfriend.y + 100);
		burst.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/burst');
		burst.animation.addByPrefix('bust', 'Burst', 24, false);
		burst.animation.callback = function(name, frame, animIndex) {
			switch (frame) {
				case 0 | 1:
					burst.visible = true;
			}
		}
		burst.visible = false;
		burst.animation.finishCallback = function(name) {
			burst.visible = false;
		}
		insert(members.indexOf(boyfriend) - 1, burst);
	}, "Fire Explosion");

	addPreloadItem(function(){
		shieldDAD = new FlxSprite(100, 400);
		shieldDAD.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/flameShield');
		shieldDAD.animation.addByPrefix('spawn', 'Flame Shield Generation0', 24, false);
		shieldDAD.animation.addByPrefix('idle', 'Flame Shield0', 24, true);
		shieldDAD.animation.play('spawn');
		shieldDAD.alpha = 0.0001;
		add(shieldDAD);
	}, "Whitty Shield");

	addPreloadItem(function(){
		shieldBF = new FlxSprite(150, 400);
		shieldBF.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/flameShield');
		shieldBF.animation.addByPrefix('spawn', 'Flame Shield Generation BF0', 24, false);
		shieldBF.animation.addByPrefix('idle', 'Flame Shield BF0', 24, true);
		shieldBF.animation.play('spawn');
		shieldBF.scale.set(0.9, 0.70);
		shieldBF.alpha = 0.0001;
		shieldBF.flipX = true;
		add(shieldBF);
	}, "BF Shield");

	addPreloadItem(function(){
		screamBlast = new FlxSprite(100, 400); // , Paths.image('stages/Vs Whitty/alley/screamBlast'));
		screamBlast.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/screamBlast');
		screamBlast.animation.addByPrefix('blast', 'blast', 24, false);
		screamBlast.animation.play('blast');
		screamBlast.alpha = 0.0001;
		add(screamBlast);
	}, "Whitty Scream Fire");

	addPreloadItem(function(){
		screamBlastBF = new FlxSprite(100, 400); // , Paths.image('stages/Vs Whitty/alley/screamBlast'));
		screamBlastBF.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/screamBlast');
		screamBlastBF.animation.addByPrefix('blast', 'blast', 24, false);
		screamBlastBF.animation.play('blast');
		screamBlastBF.alpha = 0.0001;
		screamBlastBF.color = 0xFFFF9900;
		add(screamBlastBF);
	}, "BF Scream Fire");

	addPreloadItem(function(){
		customBFIcon = new FunkinSprite(100, 0);
		customBFIcon.frames = Paths.getSparrowAtlas('icons/Vs Whitty/animated/bf-fire');
		customBFIcon.animation.addByPrefix('losing', 'BF Flame dying icon', 24/2, true);
		customBFIcon.animation.addByPrefix('winning', 'BF Flame winning icon', 24/2, true);
		customBFIcon.animation.addByPrefix('even', 'BF Flame even icon', 24/2, true);
		customBFIcon.playAnim('even', true);
		customBFIcon.antialiasing = true;
		customBFIcon.cameras = [camHUD];
		add(customBFIcon);
	}, "Custom BF Icon");

	addPreloadItem(function(){
		customDadIcon = new FunkinSprite(0, 0);
		customDadIcon.frames = Paths.getSparrowAtlas('icons/Vs Whitty/animated/whitty-angry-labeled');
		customDadIcon.animation.addByPrefix('losing', 'Whitty losing icon', 24/2, true);
		customDadIcon.animation.addByPrefix('winning', 'Whitty winning Icon', 24/2, true);
		customDadIcon.animation.addByPrefix('even', 'Whitty even Icon', 24/2, true);
		customDadIcon.playAnim('even', true);
		customDadIcon.antialiasing = true;
		customDadIcon.cameras = [camHUD];
		add(customDadIcon);
	}, "Custom Opponent Icon");

	addPreloadItem(function(){
		vignetteCamera = new FlxCamera();
		vignetteCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(vignetteCamera, false);
	}, "Vignette Camera");

	addPreloadItem(function(){
		vignette = new FlxSprite(0, 0, Paths.image('stages/Vs Whitty/alley/vignette'));
		vignette.cameras = [vignetteCamera];
		vignette.scale.set(720 / 1080, 720 / 1080);
		vignette.updateHitbox();
		vignette.x = 0;
		vignette.y = 0;
		vignette.color = vignetteProfiles.HEATED;
		vignette.alpha = 0.3;
		vignette.visible = false;
		add(vignette);
	}, "Vignette");

	dialogueCamera = new FlxCamera();
	dialogueCamera.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(dialogueCamera, false);

	dialogueTimerBar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, 262 * (1280 / 1920), 8 * (1280 / 1920), null, 'timerBar', 0, 100, false);
	dialogueTimerBar.createFilledBar(FlxColor.RED, FlxColor.BLACK);
	dialogueTimerBar.cameras = [dialogueCamera];

	dialogueBox = new FunkinSprite(0, 0);
	dialogueBox.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/Dialogue/textBox');
	dialogueBox.animation.addByPrefix('spawn', 'Text Box Opening', 24, false);
	dialogueBox.animation.addByPrefix('normal', 'Text Box Normal', 24, true);
	dialogueBox.animation.addByPrefix('mad', 'Text Box Mad', 24, true);
	dialogueBox.animation.play('normal');
	dialogueBox.scale.set(1280 / 1920, 1280 / 1920);
	dialogueBox.updateHitbox();
	dialogueBox.y = FlxG.height - dialogueBox.height - 50;

	dialogueBoxBurn = new FunkinSprite(0, 0);
	dialogueBoxBurn.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/Dialogue/textBoxBurn');
	dialogueBoxBurn.animation.addByPrefix('exist', 'Death', 24, false);
	// dialogueBoxBurn.animation.play('exist');
	dialogueBoxBurn.visible = false;
	dialogueBoxBurn.scale.set(1280 / 1920, 1280 / 1920);
	dialogueBoxBurn.updateHitbox();
	dialogueBoxBurn.y = dialogueBox.y + 130;
	dialogueBoxBurn.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
		switch (frameNumber) {
			case 8:
				dialogueBox.visible = false;
				dialogueTimerBar.visible = false;
				fallingWhittyDia.visible = true;
				dialogueText.visible = false;
				dialogueTextBack.visible = false;
			case 16:
				dialogueBoxBurn.visible = false;
			case 17:
				fallingWhittyDia.visible = false;
		}
	}
	dialogueBoxBurn.cameras = [dialogueCamera];

	fallingWhittyDia = new FunkinSprite(150, 0);
	fallingWhittyDia.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/Dialogue/whittyFall');
	fallingWhittyDia.animation.addByPrefix('exists', 'Whitty Shake Fall', 24, false);
	fallingWhittyDia.animation.play('exists');
	fallingWhittyDia.y = dialogueBox.y;
	fallingWhittyDia.scale.set(1280 / 1920, 1280 / 1920);
	fallingWhittyDia.updateHitbox();
	fallingWhittyDia.cameras = [dialogueCamera];
	fallingWhittyDia.visible = false;
	// dialogueBox.animation.play('spawn');

	dialogueTimerBar.screenCenter(FlxAxes.X);
	dialogueTimerBar.y = FlxG.height - 100;
	dialogueTimerBar.visible = false;
	dialogueBox.visible = false;
	dialogueBox.animation.finishCallback = function(animName:String) {
		if (animName == 'spawn') {
			dialogueBox.animation.play('normal');
			dialogueTimerBar.visible = true;
			dialogueText.visible = true;
			dialogueTextBack.visible = true;
		}
	}
	dialogueBox.cameras = [dialogueCamera];
	add(fallingWhittyDia);
	add(dialogueBox);

	dialogueTextBack.setFormat(Paths.font('Lucida Sans Typewriter Regular.ttf'), 30, FlxColor.RED, 'center');
	dialogueTextBack.scrollFactor.set();
	dialogueTextBack.alpha = 1;
	dialogueTextBack.cameras = [dialogueCamera];
	dialogueTextBack.antialiasing = true;
	dialogueTextBack.alignment = 'left';
	add(dialogueTextBack);

	dialogueText.setFormat(Paths.font('Lucida Sans Typewriter Regular.ttf'), 30, FlxColor.BLACK, 'center');
	dialogueText.scrollFactor.set();
	dialogueText.alpha = 1;
	dialogueText.cameras = [dialogueCamera];
	dialogueText.antialiasing = true;
	dialogueText.alignment = 'left';
	add(dialogueText);
	dialogueText.text = 'Why the hell won\'t you leave me alone.';
	dialogueText.updateHitbox();
	dialogueText.screenCenter(FlxAxes.X);
	dialogueText.text = '';
	dialogueText.updateHitbox();
	dialogueText.y += 175;

	add(dialogueTimerBar);
	add(dialogueBoxBurn);

	heatedGradientDad = FlxGradient.createGradientFlxSprite(healthBar.width, healthBar.height, [0x00ffff00, 0xFFffff00], 1, 90);
	heatedGradientDad.cameras = [camHUD];
	heatedGradientDad.x = healthBar.x;
	heatedGradientDad.y = healthBar.y;
	heatedGradientDad.visible = false;
	insert(members.indexOf(healthBar) + 1, heatedGradientDad);

	heatedGradientBF = FlxGradient.createGradientFlxSprite(healthBar.width, healthBar.height, [0x00ffff00, 0xFFffff00], 1, 90);
	heatedGradientBF.cameras = [camHUD];
	heatedGradientBF.x = healthBar.x;
	heatedGradientBF.y = healthBar.y;
	heatedGradientBF.visible = false;
	insert(members.indexOf(healthBar) + 1, heatedGradientBF);

	loadedAssets = true;
	camGame.zoom = stage.stageXML.get('zoom');

	var pathsToPreload = ['stages/Vs Whitty/alley/circle', 'stages/Vs Whitty/alley/circleLong'];
	for (path in pathsToPreload)
		var preloadedImage = new FlxSprite().loadGraphic(Paths.image(path));
	function getShrapnelPreset(char:String, step, duration, ?hasText, ?dark) {
		switch (char) {
			case 'dad':
				return new ShrapnelIcon(
					{x: dad.x + 400, y: dad.y + 300},
					{x: boyfriend.x, y: boyfriend.y + 400},
					'stages/Vs Whitty/alley/shrapnelIcons', 'Agro Shrapnel', step, duration, hasText, dark
				);
			case 'bf' | 'boyfriend':
				return new ShrapnelIcon(
					{x: boyfriend.x, y: boyfriend.y + 400},
					{x: dad.x + 200, y: dad.y + 200},
					'stages/Vs Whitty/alley/shrapnelIcons', 'BF flame Shrapnel', step, duration, hasText, dark
				);
		}
	}
	shrapnels = [];
	shrapnels.push(getShrapnelPreset('dad', 960, 1, true));
	shrapnels.push(getShrapnelPreset('dad', 976, 1));
	shrapnels.push(getShrapnelPreset('dad', 992, 57 / 24));
	shrapnels.push(getShrapnelPreset('bf', 1024, 33 / 24));
	shrapnels.push(getShrapnelPreset('bf', 1044, 1));
	shrapnels.push(getShrapnelPreset('bf', 1060, 1));
	shrapnels.push(getShrapnelPreset('bf', 1344, 35 / 24, false, false));
	var nonDarkShraps = [['bf', 1408, 49 / 24], ['dad', 1407, 49 / 24]];
	for (shrap in nonDarkShraps) {
		var shrapnelTemp = getShrapnelPreset(shrap[0], shrap[1], shrap[2], false, false);
		shrapnelTemp.completeCallback = function() {
			shakeCamera(0.02, 2 / 24, 2);
		}
		shrapnels.push(shrapnelTemp);
	}

	for (icon in shrapnels) {
		if (icon.hasText)
			add(icon.shrapnelPopup);
		add(icon.coloredIcon);
		add(icon.shrapnelIcon);
	}

	// add(shrapnels);


}

function onStartCountdown() {
	customLock.x = stage.stageXML.get('startCamPosX');
	customLock.y = stage.stageXML.get('startCamPosY');
	customLock.zoom = camGame.zoom;
	customLockEnabled = true;
}

function spawnShield(type) {
	switch (type.toLowerCase()) {
		case 'dad':
			shieldDAD.alpha = 1;
			shieldDAD.animation.play('spawn');
		case 'bf':
			shieldBF.alpha = 1;
			shieldBF.animation.play('spawn');
	}
}

function createCircleWow(?type:String) {
	var circle = new FunkinSprite(boyfriend.x - 370, boyfriend.y - 40);
	switch (type) {
		case 'long':
			circle.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/circleLong');
			circle.animation.addByPrefix('tween', 'Circle Tweener Long', 24, false);
		default:
			circle.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/circle');
			circle.animation.addByPrefix('tween', 'Circle Tweener', 24, false);
	}
	circle.animation.play('tween');
	circle.animation.finishCallback = function(name:String) {
		remove(circle);
	}
	insert(members.indexOf(boyfriend) - 1, circle);
}

function killShield(type) {
	switch (type.toLowerCase()) {
		case 'dad':
			FlxFlicker.flicker(shieldDAD, 0.5 / 2, 0.25 * 0.25, true, true, function() {
				shieldDAD.alpha = 0.0001;
			});
		case 'bf':
			FlxFlicker.flicker(shieldBF, 0.5 / 2, 0.25 * 0.25, true, true, function() {
				shieldBF.alpha = 0.0001;
			});
	}
}

/**
 * Shakes screen on given interval.
 * @param intensity Default is 0.05.
 * @param duration How long it will shake for.
 * @param interval Interval the camera will shake, 2 = every 2 stepHits.
 */
function shakeCamera(intensity:Float, duration:Float, ?interval:Int) {
	shakeIntensity = intensity;
	shakeInterval = interval ?? shakeInterval;
	camera.shake(shakeIntensity, 0.1);
	isShaking = true;
	new FlxTimer().start(duration, function(timer) {
		isShaking = false;
	});
}

function setMode(what:String) {
	setModeScript(what.toLowerCase());
	switch (what.toLowerCase()) {
		case 'shrapnel':
			vignette.visible = true;
			vignette.color = vignetteProfiles.SHRAPNEL;
			vignette.alpha = 0.9;
			healthBar.visible = false;
			healthBarBG.color = FlxColor.BLACK;
			oppoIcon.color = FlxColor.BLACK;
			playIcon.color = FlxColor.BLACK;
			iconP1.color = FlxColor.BLACK;
			iconP2.color = FlxColor.BLACK;
		case 'heated':
			vignette.visible = true;
			vignette.color = vignetteProfiles.HEATED;
			vignette.alpha = 0.3;
		case 'none':
			vignette.visible = false;
			healthBar.visible = true;
			iconP1.color = DEFAULTCOLOR;
			iconP2.color = DEFAULTCOLOR;
			oppoIcon.color = DEFAULTCOLOR;
			playIcon.color = DEFAULTCOLOR;
		case 'none-fade':
			vignette.visible = true;
			FlxTween.tween(vignette, {alpha: 0}, 4 / 24, {
				onComplete: function() {
					vignette.visible = false;
				}
			});
			healthBar.visible = true;
			iconP1.color = DEFAULTCOLOR;
			iconP2.color = DEFAULTCOLOR;
			oppoIcon.color = DEFAULTCOLOR;
			playIcon.color = DEFAULTCOLOR;
	}
}

function spawnDialogue() {
	dialogueBox.visible = true;
	dialogueBox.animation.play('spawn');
}

function killDialogue() {
	dialogueBoxBurn.visible = true;
	dialogueBoxBurn.animation.play('exist');
	fallingWhittyDia.animation.play('exists');
}

public function doGradientEvent(event) {
	switch (event.character) {
		case 'dad':
			heatedGradientDad.visible = event.visible;
		case 'bf' | 'boyfriend':
			heatedGradientBF.visible = event.visible;
		case 'both':
			heatedGradientDad.visible = false;
			heatedGradientBF.visible = false;
	}
}

function stepHit() {
	switch (curStep) {
		case 1:
			customLockEnabled = false;
		// case 10:
		// 	spawnShield('bf');
		// case 1:
		// 	setMode('shrapnel');
		// case 5:
		// 	setMode('none');
		case 32:
			customLockEnabled = true;
			FlxTween.tween(customLock, {x: boyfriend.getCameraPosition().x, y: boyfriend.getCameraPosition().y, zoom: 1.2}, 2.2, {
				ease: FlxEase.cubeOut
			});
		case 64: // GF Suffix Change.
			gf.idleSuffix = '-left';
			defaultLockX = stage.stageXML.get('startCamPosX');
			defaultLockY = stage.stageXML.get('startCamPosY');
			FlxTween.tween(customLock, {x: stage.stageXML.get('startCamPosX'), y: stage.stageXML.get('startCamPosY'), zoom: stage.stageXML.get('zoom')}, 0.7, {
				ease: FlxEase.cubeOut,
				onComplete: function() {
					customLockEnabled = false;
				}
			});
		case 128: // GF Suffix Change.
			gf.idleSuffix = '-right';
		case 184: // Move camera :)
			customLockEnabled = true;
			FlxTween.tween(customLock, {x: camFollow.x + 200, y: camFollow.y + 120, zoom: 0.8}, 0.5, {
				ease: FlxEase.quadOut,
				onComplete: function() {
					// customLockEnabled = false;
				}
			});
		case 192: // GF Suffix Removal.
			gf.idleSuffix = '';
			FlxTween.tween(customLock, {x: camFollow.x - 200, y: camFollow.y - 120, zoom: 0.7}, 0.7, {
				ease: FlxEase.quadOut,
				onComplete: function() {
					customLockEnabled = false;
				}
			});
		case 280:
			customLockEnabled = true;
			FlxTween.tween(customLock, {x: camFollow.x + 300, y: camFollow.y + 40, zoom: camGame.zoom + 0.2}, 5 / 24, {
				ease: FlxEase.quadOut,
				onComplete: function() {
					FlxTween.tween(customLock, {x: stage.stageXML.get('startCamPosX'), y: stage.stageXML.get('startCamPosY'), zoom: camGame.zoom - 0.2},
						3 / 24, {
							ease: FlxEase.quadIn,
							onComplete: function() {
								// customLockEnabled = false;
							}
						});
				}
			});
			FlxTween.tween(dad, {x: stage.characterPoses['dad'].x + 320}, 5 / 24, {
				ease: FlxEase.backOut,
				onComplete: function() {
					dad.x = stage.characterPoses['dad'].x;
				}
			});
		case 368: // Remove dad shield. (Spawned by spin note, will change later)
			killShield('dad');
		case 448:
			killShield('dad');
		case 446 | 574:
			spawnDialogue();
		case 448 | 576:
			timerStart = curStep;
			timerEnd = curStep + 35;
		case 480 | 608:
			killDialogue();
		case 544:
			burst.animation.play('bust');
		case 688: // Heat up dad.
			gf.idleSuffix = '-left';
			setMode('heated-dad');
		case 696: // GF Suffix Change.
			gf.idleSuffix = '-right';
		case 704: // Heat up bf. GF Suffix Removal
			gf.idleSuffix = '';
			setMode('heated-bf');
		case 896 | 900 | 904:
			createCircleWow('long');
		case 948:
			customLockEnabled = false;
			FlxTween.tween(camGame, {zoom: camGame.zoom - 0.05}, 1, {
				ease: FlxEase.quadOut
			});
		case 960: // Remove heat up, replace with shrapnel mode (Dark Part)
			setMode('none');
			setMode('shrapnel');
			gf.idleSuffix = '-left';
			FlxTween.tween(camGame, {zoom: camGame.zoom + 0.1}, 0.3, {
				ease: FlxEase.sineOut
			});
		case 1024: // GF Suffix Change.
			gf.idleSuffix = '-right';
			scripts.call('onEvent', [
				{
					event: {
						name: 'Popups',
						params: [1, 'Echo', 'right', 100, -20]
					}
				}
			]);
		case 1088: // Fade out vignette. And remove inner shadow.
			gf.idleSuffix = '';
			setMode('none-fade');
			FlxTween.tween(camGame, {zoom: camGame.zoom - 0.05}, 0.3, {
				ease: FlxEase.quadOut
			});
		case 1178:
			spawnShield('bf');
			scripts.call('onEvent', [
				{
					event: {
						name: 'Popups',
						params: [1, 'Echo', 'right', 100, -20]
					}
				}
			]);
		case 1184:
			killShield('bf');
		case 1196: // Heat up dad, agro ig.
			setMode('heated-dad-agro');
		case 1210:
			scripts.call('onEvent', [
				{
					event: {
						name: 'Popups',
						params: [1, 'Heated Up', 'up', 0, 0]
					}
				}
			]);
		// makePopup('Heated Up', 'up', 1, new FlxPoint(0, 200));
		case 1196 | 1200 | 1204 | 1208 | 1212:
			camGame.zoom += 0.05;
			FlxTween.tween(camGame, {zoom: camGame.zoom - 0.05}, 0.3, {
				ease: FlxEase.quadOut
			});
			if (curStep == 1204) {
				vignette.alpha = 0;
				vignette.visible = true;
				vignette.color = vignetteProfiles.HEATED;
				FlxTween.tween(vignette, {alpha: 0.3}, 4 / 24);
			}
		case 1216: // Heat up bf, with agro.
			setMode('heated-bf-agro');
		case 1406:
			dadLockPose = true;
			dad.playAnim('spin', true);
			dad.x -= 50;
		case 1408:
			shakeCamera(0.03, 6 / 24, 3);
			customLockEnabled = true;
			FlxTween.tween(customLock, {x: camFollow.x - 50, y: camFollow.y + 50, zoom: camGame.zoom - 0.1}, 0.2, {
				ease: FlxEase.quadOut
			});
			doubleMode = !doubleMode; // Set to true :D
			scripts.call('onEvent', [
				{
					event: {
						name: 'Popups',
						params: [1, 'Echo', 'right', 100, 200]
					}
				}
			]);
		case 1410:
			dadLockPose = false;
		case 1424:
			spawnShield('dad');
			spawnShield('bf');
		case 1432:
			killShield('dad');
			killShield('bf');
		case 1472: // Remove heat and vignette.
			doubleMode = !doubleMode; // Set to false.
			// setMode('none');
			// vignette.alpha = 0.3;
			dad.x += 50;
			setMode('none-fade');
			FlxTween.tween(customLock, {x: stage.stageXML.get('startCamPosX'), y: stage.stageXML.get('startCamPosY'), zoom: camGame.zoom + 0.1}, 0.2, {
				ease: FlxEase.quadOut
			});
		case 1481:
			FlxTween.tween(customLock, {x: customLock.x - 200}, 0.5, {
				ease: FlxEase.quadOut
			});
		case 1495:
			var thingsToTween = [healthBar, healthBarBG, scoreTxt, missesTxt, accuracyTxt];
			for (thing in thingsToTween) {
				var index = thingsToTween.indexOf(thing);
				FlxTween.tween(thing, {y: thing.y + 300}, 0.5, {
					ease: FlxEase.quadIn
				});
			}
			new FlxTimer().start(0.5, function(timer) {
				FlxTween.tween(camHUD, {alpha: 0}, 0.5);
			});
	}
	// Deal With dialogue
	var stepsToPart:Array<Int> = [
		448, 452, 454, 458, 462, 466, 470, 472, 476,          // Section 1
		576, 580, 582, 586, 590, 594, 598, 600, 602, 604, 606 // Section 2
	];

	for (step in stepsToPart)
		if (curStep == step)
			curPart++;

	if (curStep % shakeInterval == 0 && isShaking)
		camera.shake(shakeIntensity, 0.1);

	for (shrapnel in shrapnels)
		if (curStep == shrapnel.step)
			shrapnel.doTween();

	var snapSteps:Array<Int> = [970, 986, 1018];
	for (snap in snapSteps)
		if (curStep == snap)
			dad.playAnim('snap', true);
}

function beatHit() {
	// createCircleWow();
	customBFIcon.scale.set(1.2, 1.2);
	customDadIcon.scale.set(1.2, 1.2);
}

function postUpdateLoaded() {
	for (icon in shrapnels)
		icon.updateShrapnel();
	dialogueText.text = '';
	for (i in 0...curPart) {
		if (parts[i].reset)
			dialogueText.text = '';

		dialogueText.text += parts[i].text;

		if (i == curPart - 1)
			if (parts[i].dash)
				dialogueText.text += '-';
	}
	dialogueTextBack.text = dialogueText.text;
	dialogueTextBack.x = dialogueText.x + 3;
	dialogueTextBack.y = dialogueText.y + 3;

	dialogueBox.updateHitbox();
	dialogueBox.screenCenter(FlxAxes.X);
	dialogueBoxBurn.updateHitbox();
	dialogueBoxBurn.screenCenter(FlxAxes.X);
	if (customLockEnabled) {
		camFollow.setPosition(customLock.x, customLock.y);
		camGame.scroll.x = customLock.x + (FlxG.width / 2);
		camGame.scroll.y = customLock.y + (FlxG.height / 2);
		FlxG.camera.snapToTarget();
		camGame.zoom = customLock.zoom;
	} else {
		customLock.x = camFollow.x;
		customLock.y = camFollow.y;
		customLock.zoom = camGame.zoom;
	}
	if (boyfriend.curCharacter == 'bf-shake')
		if (boyfriend.animation.name == 'shake') {
			if (boyfriend.animation.finished)
				changeCharacter(1, 'bf', 0, false);
		} else
			boyfriend.playAnim('shake', true);
	// camHUD.alpha = 1;
	// trace(timerStart);
	// trace(timerEnd);
	// trace(curStep);
	dialogueTimerBar.percent = ((curStep - timerStart >= 0 ? curStep - timerStart : 0) / (timerEnd - timerStart)) * 100;

	if (healthBar.percent < 20 && customBFIcon.animation.name != 'losing') {
		customBFIcon.playAnim('losing', true);
		customDadIcon.playAnim('winning', true);
	}
	if (healthBar.percent > 80 && customBFIcon.animation.name != 'winning') {
		customBFIcon.playAnim('winning', true);
		customDadIcon.playAnim('losing', true);
	}
	if ((healthBar.percent <= 80 && healthBar.percent >= 20) && customBFIcon.animation.name != 'even') {
		customBFIcon.playAnim('even', true);
		customDadIcon.playAnim('even', true);
	}

	customBFIcon.updateHitbox();
	// customDadIcon.updateHitbox();
	customBFIcon.y = healthBar.y + (healthBar.height / 2) - (customBFIcon.height / 2) - 15 * (downscroll ? -1 : 1);
	customDadIcon.y = healthBar.y + (healthBar.height / 2) - (customDadIcon.height / 2) - 20 * (downscroll ? -1 : 1);

	customBFIcon.color = iconP1.color;
	customDadIcon.color = iconP2.color;

	customBFIcon.x = iconP1.x - 5;
	customDadIcon.x = iconP2.x + 5;
	customDadIcon.centerOrigin();
	customBFIcon.scale.set(lerp(customBFIcon.scale.x, 1, 0.33), lerp(customBFIcon.scale.y, 1, 0.33));
	customDadIcon.scale.set(lerp(customDadIcon.scale.x, 1, 0.33), lerp(customDadIcon.scale.y, 1, 0.33));

	playIcon.alpha = 0.001;
	oppoIcon.alpha = 0.001;
	customBFIcon.visible = playIcon.visible;
	customDadIcon.visible = oppoIcon.visible;

	heatedGradientDad.scale.x = 1 - (healthBar.percent / 100);
	heatedGradientDad.updateHitbox();
	heatedGradientDad.x = healthBar.x;

	heatedGradientBF.scale.x = healthBar.percent / 100;
	heatedGradientBF.updateHitbox();
	heatedGradientBF.x = healthBar.x + healthBar.width - heatedGradientBF.width;
	// heatedGradientDad.width = healthBar.width * (1-(healthBar.percent/100));

	boyfriend.animation.callback = function(name:String, frame:Int, frameIndex:Int) {
		// trace(name);
		if (name == 'heatup' || name == 'powerup') {
			switch (frame) {
				case 1:
					createCircleWow();
					createCircleWow();
				case 9:
					if (name == 'heatup') {
						doGradientEvent({
							character: 'boyfriend',
							visible: true
						});
					}
					health = 2;
					shakeCamera(0.02, 2 / 24, 2);
			}
		}
	}
	for (icon in shrapnels) {
		if (icon.hasText) {
			remove(icon.shrapnelPopup);
			add(icon.shrapnelPopup);
		}
		remove(icon.coloredIcon);
		add(icon.coloredIcon);
		remove(icon.shrapnelIcon);
		add(icon.shrapnelIcon);
	}
}

function updateLoaded() {
	// camHUD.alpha = 1;
		// If my loop hasn't started yet, start it
	updateBlast();
	if (!loadedAssets)
		return;

	if (shieldDAD.animation.name == 'spawn')
		if (shieldDAD.animation.curAnim.finished)
			shieldDAD.animation.play('idle');
	if (shieldBF.animation.name == 'spawn')
		if (shieldBF.animation.frameIndex == 6)
			shieldBF.animation.play('idle');

	if (dad.animation.name == 'idle')
		dadCurDir = 4;
	if (boyfriend.animation.name == 'idle')
		bfCurDir = 4;

	var shieldOffsetsDAD = [-100, 50, 0, 100, 0];
	var shieldOffsetsBF = [-50, 0, 0, 0, 0];
	shieldDAD.x = dad.x + 130 + shieldOffsetsDAD[dadCurDir];
	shieldDAD.y = dad.y - 105;
	shieldBF.x = boyfriend.x - 130 + shieldOffsetsBF[bfCurDir]; // + shieldOffsetsDAD[dadCurDir];
	shieldBF.y = boyfriend.y + 50;

}

function onStartSong() {
	strumLines.members[0].onHit.add((event) -> {
		dadCurDir = event.direction;
		if (dadLockPose)
			event.animCancelled = true;
		switch (event.noteType) {
			case 'Attack':
				var blast = copyPreload(0);
				blast.x = boyfriend.x - 100 - (doubleMode ? 800 : 0);
				blast.y = boyfriend.y + 200 - (doubleMode ? 150 : 0);
				blast.flipX = doubleMode;

				var bulletData:Array<{x:Float, y:Float, angle:Float}> = [
					{x: 600, y: 580, angle: 15},
					{x: 620, y: 620, angle: 25},
					{x: 600, y: 580, angle: 15},
					{x: 600, y: 600, angle: 25}
				];

				var bullet = copyPreload(1);
				bullet.setPosition(bulletData[event.direction].x - (doubleMode ? 300 : 0), bulletData[event.direction].y - (doubleMode ? 100 : 0));
				bullet.angle = bulletData[event.direction].angle;
				bullet.animation.play('dad');
				add(bullet);
				new FlxTimer().start(1 / 24, function(timer) {
					remove(bullet);
					bullet.kill();
					blast.animation.play('dad');
					blast.animation.finishCallback = function(name:String) {
						// blast.kill();
					}
					switch (boyfriend.curCharacter) {
						case 'bf':
							boyfriend.playAnim('hit', true);
						case 'bf-fire':
							if (boyfriend.animation.name != 'heatup') {
								if (curStep == 280) {
									boyfriend.playAnim('hit', true);
									new FlxTimer().start(1 / 24, function(timer) {
										boyfriend.x = stage.characterPoses['boyfriend'].x + 40;
										FlxTween.tween(boyfriend, {x: stage.characterPoses['boyfriend'].x}, 4 / 24, {startDelay: 3 / 24});
									});
								} else {
									if (shieldBF.alpha == 1 && shieldBF.animation.name == 'idle')
										blast.x = shieldBF.x - 40;
									else if (!doubleMode)
										boyfriend.playAnim('block', true);
								}
							}
					}

					add(blast);
				});
			case 'Attack Crit':
				var blast = copyPreload(0);
				blast.setPosition(boyfriend.x - 100, boyfriend.y + 200);
				blast.flipX = false;

				var bulletData:Array<{x:Float, y:Float, angle:Float}> = [
					{x: 600, y: 580, angle: 15},
					{x: 620, y: 620, angle: 25},
					{x: 600, y: 580, angle: 15},
					{x: 600, y: 600, angle: 25}
				];

				var bullet = copyPreload(1);
				bullet.setPosition(bulletData[event.direction].x, bulletData[event.direction].y);
				bullet.angle = bulletData[event.direction].angle;
				bullet.animation.play('dad');
				add(bullet);
				new FlxTimer().start(1 / 24, function(timer) {
					remove(bullet);
					bullet.kill();
					blast.animation.play('dad');
					blast.animation.finishCallback = function(name:String) {
						blast.kill();
					}
					if (shieldBF.alpha == 1 && shieldBF.animation.name == 'idle')
						blast.x = shieldBF.x - 40;
					else
						boyfriend.playAnim('hit', true);
					add(blast);
				});
			case 'Click':
				event.animCancelled = true;
				boyfriend.playAnim('hit', true);
				var blast = copyPreload(0);
				blast.x = boyfriend.x - 100;
				blast.y = boyfriend.y + 200;
				blast.animation.play('dad');
				blast.shader = boyfriend.shader;
				add(blast);
				shakeCamera(0.02, 2 / 24, 2);
			case 'Spin':
				event.animCancelled = true;
				dad.playAnim('spin', true);
				spawnShield('dad');
			case 'Scream':
				event.animCancelled = true;
				if (!event.note.isSustainNote) {
					dad.playAnim('scream', true);
					spawnBlast('dad');
					shakeCamera(0.02, 4 / 24, 3);
					new FlxTimer().start(1 / 24, function(timer) {
						boyfriend.playAnim('hit', true);
						gf.playAnim('shock', true);
						new FlxTimer().start(1 / 24, function(timer) {
							boyfriend.x = stage.characterPoses['boyfriend'].x + 40;
							FlxTween.tween(boyfriend, {x: stage.characterPoses['boyfriend'].x}, 4 / 24, {startDelay: 3 / 24});
						});
					});
					gf.idleSuffix = '-leftnerve';
					new FlxTimer().start(2, function(timer) {
						gf.idleSuffix = '';
					});
				}
		}
		if (dad.getAnimName() == 'snap')
			if (!dad.animation.finished)
				event.animCancelled = true;
	});
	strumLines.members[1].onHit.add((event) -> {
		bfCurDir = event.direction;
		switch (event.noteType) {
			case 'Attack':
				var blast = copyPreload(0);
				blast.flipX = !doubleMode;
				var shieldOFFs = [-100, 0, 100, 200,];
				var randomOff = FlxG.random.int(0, shieldOFFs.length);
				var bulletData:Array<{x:Float, y:Float, angle:Float}> = [
					{x: 600, y: 400, angle: 15},
					{x: 600, y: 400, angle: 25},
					{x: 600, y: 400, angle: 15},
					{x: 600, y: 400, angle: 25}
				];
				var bullet = copyPreload(1);
				bullet.x = bulletData[event.direction].x + (shieldDAD.alpha != 0.0001 ? 100 : 0) + (doubleMode ? 450 : 0);
				bullet.y = bulletData[event.direction].y + (shieldDAD.alpha != 0.0001 ? 50 : 0) + (shieldDAD.alpha != 0.0001 ? (shieldOFFs[randomOff] / 1.4) : 0) + (doubleMode ? 200 : 0);
				bullet.angle = bulletData[event.direction].angle + (shieldDAD.alpha != 0.0001 ? (5 * ((randomOff / 2) - 1)) : 0);
				bullet.animation.play('bf');
				add(bullet);
				new FlxTimer().start(1 / 24, function(timer) {
					remove(bullet);
					bullet.kill();
					blast.animation.play('bf');
					if ((shieldDAD.alpha == 0.0001 || !shieldDAD.visible) && dad.animation.name != 'heatup' && dad.animation.name != 'cooleddown' && !doubleMode && !dadLockPose)
						dad.playAnim('hit', true);
					function getBlastOffsets() {
						switch (dad.animation.name) {
							case 'hit':                   return {x: 0,   y: 0}
							case 'heatup' | 'cooleddown': return {x: 120, y: 0}
							case 'singRIGHT':             return {x: 220, y: 0}
							default:                      return {x: 0,   y: 0}
						}
					}

					if (shieldDAD.alpha != 0.0001 && !doubleMode) {
						blast.x = shieldDAD.x - 60;
						blast.y = shieldDAD.y + 100 + (shieldOFFs[randomOff]);
					} else {
						blast.x = dad.x - 200 + (!doubleMode ? getBlastOffsets().x : 0) + (doubleMode ? 850 : 0);
						blast.y = dad.y - 200 + (!doubleMode ? getBlastOffsets().y : 0) + (doubleMode ? 250 : 0);
					}
					add(blast);
				});
			case 'Click':
				event.animCancelled = true;
				boyfriend.playAnim('snap', true);
				var blast = copyPreload(0);
				blast.flipX = true;
				blast.x = dad.x - 200;
				blast.y = dad.y - 200;
				blast.animation.play('bf');
				blast.shader = dad.shader;
				dad.playAnim('hit', true);
				add(blast);
				shakeCamera(0.02, 2 / 24, 2);
			case 'Scream':
				event.animCancelled = true;
				boyfriend.playAnim('singUP-alt', true);
				spawnBlast('bf');
				shakeCamera(0.02, 4 / 24, 3);
		}
		if (boyfriend.getAnimName() == 'heatup')
			if (!boyfriend.animation.finished)
				event.animCancelled = true;
	});
}
