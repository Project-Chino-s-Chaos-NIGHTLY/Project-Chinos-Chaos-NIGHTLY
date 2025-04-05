// Fun file to do shit in :D
import Type;
// import NovaAnimSystem.Animation;
// import NovaAnimSystem.Keyframe;
import flixel.addons.effects.FlxTrail;
import flixel.effects.FlxFlicker;

// import songs.Frame;
// import songs.Keyframe;

var thefunnyeffect:FlxSprite;
var preloadedSlash:FlxSprite;
var orginIndicator:FlxSprite;
var bigShrapnel:FlxSprite;
var crazyScreamWhit:FlxSprite;
var oilBlast:FlxSprite;
var snowFall:FlxSprite;

var bombs:Array = [];
var iceShields:Array = [];

var bfIceExplode:FunkinSprite;
var preloadedBlast_FIRE:FunkinSprite;
var preloadedBlast_ICE:FunkinSprite;
var preloadedBlast_GF:FunkinSprite;
var preloadedBullets_GF:FunkinSprite;
var bfIceShieldCrazy:FunkinSprite;
var dadClone:FunkinSprite;

var biggerBomb1:FunkinSprite;
var biggerBomb2:FunkinSprite;

var FIRE:String = "fire";
var ICE:String = "ice";
var GF:String = "gf";

var shrapnelThrowAnimation;

var curStage:Int = 1;
var curShieldStage:Int = 1;

var functionFrameTimer = 28/24;

var bombDestinations = [
	{ x: 100, y: 100, angle: 0, scale: 0.8, alpha: 0 },
	{ x: 200, y: 200, angle: 0, scale: 0.8, alpha: 0 },
	{ x: 300, y: 300, angle: 0, scale: 0.8, alpha: 0 }
];

var bombSideToggle:Bool = true; // False = dad side, True = bf side;
var biggerBombShaking:Bool = false;

var bigBombProperties = {
	x: 0,
	y: 0,
	scaleX: 1,
	scaleY: 1,
	offsetX: 0,
	offsetY: 0,
	flipX: false,
	flipY: false,
	angle: -50,
	phase: 0,
	visible: false
}

var dadTrail:FlxTrail;
var bfTrail:FlxTrail;
var blankSprite:FunkinSprite = new FunkinSprite(-10000, -100000);

function onChangeCharacter(oldChar:Character, newChar:Character, strumIndex:Int, memberIndex:Int) {
    //if (strumIndex == 0) dadTrail.target = newChar;
    if (strumIndex == 1) bfTrail.target = newChar;
}

function shakeBigBomb(duration:Float) {
	biggerBombShaking = true;
	new FlxTimer().start(duration, (timer) -> {
		biggerBombShaking = false;
	});
}
var dadSidePos = { x: 400, y: 350}
var bfSidePos  = { x: 900, y: 450}
function switchBombSide() {
	bombSideToggle = !bombSideToggle;
	if (bombSideToggle) {
		bigBombProperties.x = bigBombProperties.x+100;
		bigBombProperties.angle = 0;
		bigBombProperties.scaleX = 1.3;
		bigBombProperties.scaleY = 0.7;
		new FlxTimer().start(1/24, (timer) -> {
			bigBombProperties.flipX = false;
			bigBombProperties.scaleX = 1;
			bigBombProperties.scaleY = 1;
			bigBombProperties.x = bfSidePos.x;
			bigBombProperties.y = bfSidePos.y;
			bigBombProperties.flipY = false;
			bigBombProperties.angle = -50;
		});
	} else {
		bigBombProperties.x = bigBombProperties.x-100;
		bigBombProperties.angle = 0;
		bigBombProperties.scaleX = 1.3;
		bigBombProperties.scaleY = 0.7;
		new FlxTimer().start(1/24, (timer) -> {
			if (bigBombProperties.phase == 1) {
				bigBombProperties.flipX = true;
			}
			//bigBombProperties.flipY = bigBombProperties.phase == 0;
			bigBombProperties.scaleX = 1;
			bigBombProperties.scaleY = 1;
			bigBombProperties.x = dadSidePos.x;
			bigBombProperties.y = dadSidePos.y;
			//bigBombProperties.flipY = bigBombProperties.phase == 0;
			if (bigBombProperties.phase == 0) {
				bigBombProperties.angle = 120;
			} else {
				bigBombProperties.angle = 0;
				//trace("Uh Yeh, this one?");
			}
		});
	}
}

function spawnBlast(type:String, direction:Int) {
	switch (type) {
		case GF:
			var bullets = new FunkinSprite().copyFrom(preloadedBullets_GF);
			bullets.animation.finishCallback = function() {
				bullets.kill();
			}
			bullets.animation.callback = function(name, frame, index) {
				if (frame == 2) {
					var blasters = new FunkinSprite().copyFrom(preloadedBlast_GF);
					blasters.animation.finishCallback = function() {
						blasters.kill();
					}
					blasters.x = 200;
					blasters.y = gf.y;
					blasters.playAnim("exist", true);
					add(blasters);
				}
			}
			bullets.playAnim("exist", true);
			bullets.updateHitbox();
			bullets.x = -550;
			bullets.y = -600;
			insert(members.indexOf(gf), bullets);
		case FIRE:
			var blast = new FunkinSprite().copyFrom(preloadedBlast_FIRE);
			blast.animation.finishCallback = function() {
				blast.kill();
			}
			blast.animation.callback = function(name, frame, index) {
				if (frame == 1) {
					boyfriend.playAnim('hit', true);
				}
			}
			blast.x = dad.x + 400;
			blast.y = dad.y + 200;
			blast.playAnim(direction+"", true);
			insert(members.indexOf(stage.getSprite("fireWall"))-3, blast);
		case ICE:
			var blast = new FunkinSprite().copyFrom(preloadedBlast_ICE);
			blast.animation.finishCallback = function() {
				blast.kill();
			}
			blast.x = dad.x + dadClone.width - 700;
			blast.y = dad.y + 100;
			var yOff = FlxG.random.int(100, -200);
			var xOff = FlxG.random.int(0, 10);
			blast.addOffset("blast", xOff, yOff);
			var bullet = new FlxSprite().loadGraphic(Paths.image("stages/Vs Whitty/alley/iceBullet"));
			bullet.x = 700;
			bullet.y = boyfriend.y + 550;
			bullet.updateHitbox();
			var originX = (boyfriend.x + 20) - bullet.x;
			var originY = (boyfriend.y + 550) - bullet.y + (bullet.height/2);
			bullet.origin.set(originX, originY);
			var originMarker = new FlxSprite(bullet.x+originX, bullet.y+originY).makeGraphic(10, 10, 0xFF00FF00);
			//add(originMarker);
			blast.updateHitbox();
			var Xdistance:Float = (bullet.x + originX) - ((blast.x + xOff) + (blast.origin.x));
			var Ydistance:Float = (bullet.y + originY) - ((blast.y + yOff) + (blast.origin.y));
			bullet.angle = 15 + FlxG.random.float(-10, 10);
			//_trace(bullet.angle);
			add(bullet);
			new FlxTimer().start(1/24, function(timer) {
				//bullet.kill();
				bullet.visible = false;
				add(blast);
				blast.playAnim("blast", true);
			});

	}
}
function getStagePath(file:String) {
	return "stages/Vs Whitty/alley/" + file;
}
//fuck.run([0, 0]);
function spawnOilBlast() {
	oilBlast.visible = true;
	oilBlast.animation.play("explode", true);
}
var frameRate = 24;
function postCreate() {
	bfTrail = new FlxTrail(blankSprite, null, 1, 4, 0.5);
	add(bfTrail);
	lossSFX = "Freeze";

	addPreloadItem(function() {
		preloadedSlash = new FlxSprite(0, 0);
		preloadedSlash.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/slash');
		preloadedSlash.animation.addByPrefix('slash', 'slash', 24, false);
		preloadedSlash.antialiasing = true;
		preloadedSlash.origin.set(950, 500);
		preloadedSlash.x = dad.x - 800;
	}, "Whitty Scream Blast");

	//preloadedSlash.animation.play('slash', true);
	//add(preloadedSlash);

	orginIndicator = new FlxSprite(0, 0).makeGraphic(5, 5, FlxColor.WHITE);
	//add(orginIndicator);

	addPreloadItem(function() {
		preloadedBlast_GF = new FunkinSprite(0, 0);
		preloadedBlast_GF.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/gfBlast');
		preloadedBlast_GF.animation.addByPrefix('exist', 'BF Blast',  24, false);
		preloadedBlast_GF.antialiasing = true;
	}, "GF Fire Blast");

	addPreloadItem(function() {
		snowFall = new FunkinSprite(0, 0);
		snowFall.frames = Paths.getSparrowAtlas(getStagePath("snowfall"));
		snowFall.animation.addByPrefix('exist', 'Snow Falling',  frameRate, true);
		snowFall.animation.play('exist');
		snowFall.antialiasing = true;
		var scaleAmt = 0.5;
		snowFall.scale.set(scaleAmt,scaleAmt);
		snowFall.screenCenter(FlxAxes.XY);
		snowFall.cameras = [camHUD];
		snowFall.visible = false;
		add(snowFall);
	}, "Snow Fall Anim");

	addPreloadItem(function() {
		preloadedBullets_GF = new FunkinSprite(0, 0);
		preloadedBullets_GF.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/gfBullets');
		preloadedBullets_GF.animation.addByPrefix('exist', 'GF flame blast',  24, false);
		preloadedBullets_GF.antialiasing = true;
	}, "GF Fire Bullets");

	addPreloadItem(function() {
		preloadedBlast_ICE = new FunkinSprite(0, 0);
		preloadedBlast_ICE.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/iceThowBreak');
		preloadedBlast_ICE.animation.addByPrefix('blast', 'blast',  24, false);
		preloadedBlast_ICE.antialiasing = true;
	}, "BF Ice Throw");

	addPreloadItem(function() {
		preloadedBlast_FIRE = new FunkinSprite(0, 0);
		preloadedBlast_FIRE = new FunkinSprite(0, 0);
		preloadedBlast_FIRE.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/fireBlastsBallistic');
		preloadedBlast_FIRE.animation.addByPrefix('0', 'left',  24, false);
		preloadedBlast_FIRE.animation.addByPrefix('1', 'down',  24, false);
		preloadedBlast_FIRE.animation.addByPrefix('2', 'up',	   24, false);
		preloadedBlast_FIRE.animation.addByPrefix('3', 'right', 24, false);
		preloadedBlast_FIRE.addOffset("0", 17, 0);
		preloadedBlast_FIRE.addOffset("1", -64, -4);
		preloadedBlast_FIRE.addOffset("2", -129, 0);
		preloadedBlast_FIRE.addOffset("3", -71, 1);
		preloadedBlast_FIRE.antialiasing = true;
	}, "Whitty Fire Blasts");



	//insert(members.indexOf(boyfriend)-1, dupeSpritesBFBack);
	add(dupeSpritesBF);
	add(dupeSpritesDad);

	addPreloadItem(function() {
		bigShrapnel = new FlxSprite(0, 0);
		bigShrapnel.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/shrapnelBig');
		bigShrapnel.animation.addByPrefix('exist', 'Ballistic Shrapnel Big Ice', 24, true);
		bigShrapnel.animation.play('exist', true);
		bigShrapnel.antialiasing = true;
	}, "Frozen Shrapnel");

	addPreloadItem(function() {
		oilBlast = new FlxSprite(0, 0);
		oilBlast.frames = Paths.getSparrowAtlas(getStagePath("oilExplosion"));
		oilBlast.animation.addByPrefix('explode', 'Explosion', frameRate, false);
		//oilBlast.animation.play('explode', true);
		oilBlast.antialiasing = true;
		oilBlast.animation.finishCallback = function(name) {
			if (name != 'explode') return;
			oilBlast.visible = false;
			var tempOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFFfdec00);
			tempOverlay.scale.set(10, 10);
			tempOverlay.scrollFactor.set(0, 0);
			add(tempOverlay);
			FlxTween.tween(tempOverlay, { alpha: 0 }, 1);
		}
		oilBlast.visible = false;
		add(oilBlast);
	}, "Oil Explosion");

	addPreloadItem(function() {
		crazyScreamWhit = new FlxSprite(-2900, -1600);
		crazyScreamWhit.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/whittyBusts');
		crazyScreamWhit.animation.addByPrefix('bustEverywhere', 'Whitty Busting', 24, false);
		crazyScreamWhit.animation.play('bustEverywhere', true);
		crazyScreamWhit.animation.finishCallback = function() {
			crazyScreamWhit.visible = false;
		}
		crazyScreamWhit.visible = false;
		crazyScreamWhit.antialiasing = true;
		insert(members.indexOf(dad)-1, crazyScreamWhit);
	}, "Whitty Fire Bursts");

	addPreloadItem(function() {
		bfIceShieldCrazy = new FunkinSprite(850, 400);
		bfIceShieldCrazy.frames = Paths.getSparrowAtlas('stages/Vs Whitty/alley/iceShieldCrazy');
		bfIceShieldCrazy.animation.addByPrefix('stage 1', 'Stage 1', 24, true);
		bfIceShieldCrazy.animation.addByPrefix('stage 2', 'Stage 2', 24, true);
		bfIceShieldCrazy.animation.addByPrefix('stage 3', 'Stage 3', 24, true);
		bfIceShieldCrazy.animation.addByPrefix('break', 'Break', 24, false);
		bfIceShieldCrazy.animation.addByPrefix('spawn', 'Spawn', 24, false);
		bfIceShieldCrazy.addOffset("spawn", 400, 200);
		bfIceShieldCrazy.addOffset("break", -50, 50);
		bfIceShieldCrazy.animation.finishCallback = function(name) {
			switch (name) {
				case 'break':
					bfIceShieldCrazy.visible = false;
				case 'spawn':
					bfIceShieldCrazy.playAnim('stage 1', true);
			}
		}
		bfIceShieldCrazy.animation.callback = function(name, frame, index) {
			switch (name) {
				case 'spawn':
					if (frame == 1) {
						bfIceShieldCrazy.visible = true;
					}
			}
		}
		bfIceShieldCrazy.antialiasing = true;
		//bfIceShieldCrazy.playAnim('break', true);
		bfIceShieldCrazy.visible = false;
		add(bfIceShieldCrazy);
	}, "BF Ice Shield");

	addPreloadItem(function() {
		var tempBomb = new FunkinSprite();
		tempBomb.frames = Paths.getSparrowAtlas(getStagePath("bombDodge"));
		tempBomb.animation.addByPrefix('busting', 'DodgeBombFire', frameRate, true);
		tempBomb.animation.addByPrefix('edging', 'DodgeBombCharge', frameRate, true);
		tempBomb.antialiasing = true;
		tempBomb.addOffset("busting", 190, 0);
		tempBomb.playAnim("edging", true);
		tempBomb.flipX = true;
		tempBomb.alpha = 0;
		insert(members.indexOf(boyfriend)-2, tempBomb);
		bombs.push(tempBomb);
	}, "Dodgable Bomb 1");

	addPreloadItem(function() {
		var tempBomb = new FunkinSprite();
		tempBomb.frames = Paths.getSparrowAtlas(getStagePath("bombDodge"));
		tempBomb.animation.addByPrefix('busting', 'DodgeBombFire', frameRate, true);
		tempBomb.animation.addByPrefix('edging', 'DodgeBombCharge', frameRate, true);
		tempBomb.antialiasing = true;
		tempBomb.alpha = 0;
		//tempBomb.addOffset("busting", 0, 0);
		tempBomb.playAnim("edging", true);
		insert(members.indexOf(stage.getSprite("fireWall"))-1, tempBomb);
		bombs.push(tempBomb);
	}, "Dodgable Bomb 2");

	addPreloadItem(function() {
		var tempBomb = new FunkinSprite();
		tempBomb.frames = Paths.getSparrowAtlas(getStagePath("bombDodge"));
		tempBomb.animation.addByPrefix('busting', 'DodgeBombFire', frameRate, true);
		tempBomb.animation.addByPrefix('edging', 'DodgeBombCharge', frameRate, true);
		tempBomb.antialiasing = true;
		tempBomb.alpha = 0;
		//tempBomb.addOffset("busting", 190, 0);
		tempBomb.playAnim("edging", true);
		insert(members.indexOf(boyfriend)-2, tempBomb);
		bombs.push(tempBomb);
	}, "Dodgable Bomb 3");

	addPreloadItem(function() {
		var tempShield = new FunkinSprite(boyfriend.x + 200, boyfriend.y + 200);
		tempShield.frames = Paths.getSparrowAtlas(getStagePath("iceShields"));
		tempShield.animation.addByPrefix('spawn', 'Ice Shield 1 Idle', frameRate, false);
		tempShield.animation.addByPrefix('destroy', 'Ice Shield 1 Exit', frameRate, false);
		tempShield.antialiasing = true;
		tempShield.visible = false;
		tempShield.animation.finishCallback = function(name) {
			if (name == "destroy") {
				tempShield.visible = false;
			}
		}
		tempShield.playAnim("spawn", true);
		insert(members.indexOf(boyfriend)-2, tempShield);
		iceShields.push(tempShield);
	}, "Dodgable Ice Shield 1");

	addPreloadItem(function() {
		var tempShield = new FunkinSprite(1000, 650);
		tempShield.frames = Paths.getSparrowAtlas(getStagePath("iceShields"));
		tempShield.animation.addByPrefix('spawn', 'Ice Shield 2 Idle', frameRate, false);
		tempShield.animation.addByPrefix('destroy', 'Ice Shield 2 Exit', frameRate, false);
		tempShield.antialiasing = true;
		tempShield.visible = false;
		tempShield.playAnim("spawn", true);
		insert(members.indexOf(stage.getSprite("fireWall"))-2, tempShield);
		iceShields.push(tempShield);
	}, "Dodgable Ice Shield 2");

	addPreloadItem(function() {
		var tempShield = new FunkinSprite(boyfriend.x-50, boyfriend.y + 200);
		tempShield.frames = Paths.getSparrowAtlas(getStagePath("iceShields"));
		tempShield.animation.addByPrefix('spawn', 'Ice Shield 3 Idle', frameRate, false);
		tempShield.animation.addByPrefix('destroy', 'Ice Shield 3 Exit', frameRate, false);
		tempShield.antialiasing = true;
		tempShield.visible = false;
		tempShield.playAnim("spawn", true);
		insert(members.indexOf(boyfriend)-2, tempShield);
		iceShields.push(tempShield);
	}, "Dodgable Ice Shield 3");

	addPreloadItem(function() {
		biggerBomb1 = new FunkinSprite();
		biggerBomb1.frames = Paths.getSparrowAtlas(getStagePath("bombDodge"));
		biggerBomb1.animation.addByPrefix('edging', 'DodgeBombCharge', frameRate, true);
		biggerBomb1.antialiasing = true;
		//biggerBomb1.alpha = 0;
		//tempBomb.addOffset("busting", 190, 0);
		biggerBomb1.visible = false;
		biggerBomb1.playAnim("edging", true);
		add(biggerBomb1);
	}, "Shrapnel Phase 1");

	addPreloadItem(function() {
		biggerBomb2 = new FunkinSprite();
		biggerBomb2.frames = Paths.getSparrowAtlas(getStagePath("whittyGetsHead"));
		biggerBomb2.animation.addByPrefix('edging', 'head', frameRate, true);
		biggerBomb2.antialiasing = true;
		biggerBomb2.visible = false;
		//biggerBomb1.alpha = 0;
		//tempBomb.addOffset("busting", 190, 0);
		biggerBomb2.playAnim("edging", true);
		add(biggerBomb2);
	}, "Shrapnel Phase 2");

	addPreloadItem(function() {
		bfIceExplode = new FunkinSprite(-900, -300);
		bfIceExplode.frames = Paths.getSparrowAtlas(getStagePath("bfIceExplode"));
		bfIceExplode.animation.addByPrefix('explode', 'BF Ice Explode', frameRate, false);
		bfIceExplode.antialiasing = true;
		bfIceExplode.animation.finishCallback = function(n) {
			bfIceExplode.visible = false;
		}
		bfIceExplode.visible = false;
		bfIceExplode.playAnim("explode", true);
		add(bfIceExplode);
	}, "BF Ice Explode");
	//add(bigShrapnel);


	//shrapnelThrowAnimation = new Animation();
	/*shrapnelThrowAnimation.addKeyframe(new Keyframe(bigShrapnel, {
		x: 801.8,
		y: 16.55,
		scale: {
			x: 1.36,
			y: 1.36
		},
		angle: -161
	}));*/
}
function fireBomb(which:Int, duration:Float) {
	iceShields[which].playAnim("spawn", true);
	iceShields[which].animation.callback = function(name, frame, index) {
		if (name == "spawn" && frame == 2) {
			bombs[which].playAnim("busting", true);
		}
	}
	iceShields[which].visible = true;
	new FlxTimer().start(duration, (timer) -> {
		bombs[which].playAnim("edging", true);
		iceShields[which].playAnim("destroy", true);
	});
}
var dupeSpritesBF = new FlxTypedGroup();
var dupeSpritesDad = new FlxTypedGroup();
function makeWhittyCry() {
	crazyScreamWhit.visible = true;
	crazyScreamWhit.animation.play('bustEverywhere', true);
}
function updateBfShield(change:Int) {
	if (bfIceShieldCrazy.animation.name == "break") return;
	if (curShieldStage + change > 0 && curShieldStage + change < 4) {
		curShieldStage += change;
	}
	var prevFrame = bfIceShieldCrazy.animation.curAnim.curFrame;
	bfIceShieldCrazy.playAnim("stage " + curShieldStage, true);
	bfIceShieldCrazy.animation.curAnim.curFrame = prevFrame;
}
function spawnDupe(whatOf) {
	switch (whatOf) {
		case boyfriend:
			bfTrail.target = boyfriend;
			new FlxTimer().start(4/24, (timer)->{ bfTrail.target = blankSprite; });
	}
}
var preShakePos = {x: 0, y: 0}
function updateLoaded(elapsed:Float) {
	thefunnyeffect?.alpha = health / maxHealth;
	preloadedSlash.angle += 0.1;
	preloadedSlash.origin.set(preloadedSlash.x + 1742, preloadedSlash.y + 500);
	orginIndicator.x = preloadedSlash.x + preloadedSlash.origin.x;
	orginIndicator.y = preloadedSlash.y + preloadedSlash.origin.y;


	//camGame.scroll.set(orginIndicator.x - (FlxG.width/2), orginIndicator.y - (FlxG.height/2));
}
var unshaketimer;
public function shakeScroll(amt, duration, axis, ?force) {
	if (unshaketimer != null)
		unshaketimer.cancel();
	switch (axis) {
		case FlxAxes.X | FlxAxes.XY:
			camGame.scroll.x = preShakePos.x + (!force ? FlxG.random.int(-amt, amt) : amt);
		case FlxAxes.Y | FlxAxes.XY:
			camGame.scroll.y = preShakePos.y + (!force ? FlxG.random.int(-amt, amt) : amt);
	}
	unshaketimer = new FlxTimer().start(duration, function(timer) {
		camGame.scroll.x = preShakePos.x;
		camGame.scroll.y = preShakePos.y;
	});
}
function postUpdateLoaded() {
	dadClone = new FunkinSprite().copyFrom(dad);
	dadClone.playAnim(dad.animation.name, true);
	dadClone.animation = dad.animation;
	dadClone.updateHitbox();

	for (sprite in dupeSpritesBF.members) {
		if (sprite != null && sprite.animation.name != boyfriend.animation.name) {
			new FlxTimer().start(1/24, function(timer) {
				sprite.kill();
				sprite = null;
				dupeSpritesBF.remove(sprite);
			});
		}
	}

	for (sprite in dupeSpritesDad.members) {
		if (sprite != null && sprite.animation.name != dad.animation.name) {
			new FlxTimer().start(1/24, function(timer) {
				sprite.kill();
				sprite = null;
				dupeSpritesDad.remove(sprite);
			});
		}
	}
	//trace(dad.animation.name);

	if (dad.animation.name == null) {
		dad.playAnim(dad.curCharacter == "whitty-tantrum" ? "powerup" : "idle", true);
	}
	if (dad.animation.name == "powerup2" && dad.curCharacter == "whitty-tantrum" && dad.animation.finished) {
		bfIceShieldCrazy.playAnim('break', true);
	}
	if (dad.animation.name == "powerup" && dad.curCharacter == "whitty-tantrum" && dad.animation.finished) {
		bfIceShieldCrazy.playAnim('spawn', true);
	}
	if ((dad.animation.name == "powerup" || dad.animation.name == "powerup2") && dad.curCharacter == "whitty-tantrum" && dad.animation.finished) {
		dad.playAnim("screaming", true);
		boyfriend.playAnim('hit', true);
		killShield();
		if (curStage < 3) {
			curStage++;
		}
	}
	dad.animation.callback = function(name, frame, index) {
		if (name == "powerup" && frame == 24) {
			FlxTween.tween(lockPos, {x: stage.stageXML.get('startCamPosX'), y: stage.stageXML.get('startCamPosY')}, 0.1, {
				ease: FlxEase.quadIn,
				onUpdate: function() {
					updateLock();
				}
			});
			FlxTween.tween(camGame, {zoom: 0.6}, 0.1, {
				ease: FlxEase.quadIn
			});
		}
		if (name == "screaming" && frame == 0) {
			makeWhittyCry();
		}
	}
	if (dad.animation.name == "screaming") {
		var bigBeatSteps = [1332, 1344, 1364, 1376, 1398, 1408, 1428, 1434, 1472, 1504, 1536];
		if (bigBeatSteps.contains(curStep)) {
			shakeScroll(50, 0.1, FlxAxes.Y, true);
		} else {
			shakeScroll(10, 0.1, FlxAxes.Y);
		}
	}

	var daSprite = stage.getSprite("wall");
	if (dad.animation.name == "tweak" && dad.curCharacter == "whitty-tweaking" && dad.animation.finished) {
		if (daSprite.animation.name != "stage close")
			daSprite.playAnim("stage close", true);
	} else {
		if (daSprite.animation.name != "stage " + curStage) {
			daSprite.animation.play("stage " + curStage, true);
		}
	}
	if (dad.curCharacter == "whitty-tweaking" && dad.animation.name != "tweak") {
		dad.playAnim("tweak", true);
	}

	for (i in 0...bombs.length) {
		var lerpSpeed = 0.05;
		bombs[i].alpha = lerp(bombs[i].alpha, bombDestinations[i].alpha, lerpSpeed);
		bombs[i].x = lerp(bombs[i].x, bombDestinations[i].x, lerpSpeed);
		bombs[i].y = lerp(bombs[i].y, bombDestinations[i].y, lerpSpeed);
		bombs[i].angle = lerp(bombs[i].angle, bombDestinations[i].angle, lerpSpeed);
		bombs[i].scale.x = lerp(bombs[i].scale.x, bombDestinations[i].scale, lerpSpeed);
		bombs[i].scale.y = lerp(bombs[i].scale.y, bombDestinations[i].scale, lerpSpeed);
	}
	if (boyfriend.curCharacter == "bf-throw") {
		bigBombProperties.visible = false;
	}
	if (biggerBombShaking) {
		bigBombProperties.offsetX = FlxG.random.int(-10, 10);
		bigBombProperties.offsetY = FlxG.random.int(-10, 10);
	} else {
		bigBombProperties.offsetX = 0;
		bigBombProperties.offsetY = 0;
	}
	//trace(biggerBomb1.x);
	biggerBomb1.x =	bigBombProperties.x + bigBombProperties.offsetX;
	biggerBomb1.y = bigBombProperties.y + bigBombProperties.offsetY;
	biggerBomb1.angle = bigBombProperties.angle;
	biggerBomb1.flipX = bigBombProperties.flipX;
	biggerBomb1.flipY = bigBombProperties.flipY;
	biggerBomb1.scale.set(bigBombProperties.scaleX, bigBombProperties.scaleY);
	biggerBomb1.visible = bigBombProperties.phase == 0 && bigBombProperties.visible;

	biggerBomb2.x =	(bigBombProperties.x + bigBombProperties.offsetX) - 100;
	biggerBomb2.y = (bigBombProperties.y + bigBombProperties.offsetY);
	biggerBomb2.angle = bigBombProperties.angle + 50;
	biggerBomb2.flipX = bigBombProperties.flipX;
	biggerBomb2.flipY = bigBombProperties.flipY;
	biggerBomb2.scale.set(bigBombProperties.scaleX, bigBombProperties.scaleY);
	biggerBomb2.visible = bigBombProperties.phase == 1 && bigBombProperties.visible;
	//camGame.bgColor = FlxColor.TRANSPARENT;

	boyfriend.animation.finishCallback = function(name) {
		if (boyfriend.curCharacter == "bf-ice-hammer" && name == "idle") {
			trace("Reset BF Curstep = " + curStep);
		}
	}
	boyfriend.animation.callback = function(name, frame, index) {
		if (boyfriend.curCharacter == "bf-throw" && name == "idle" && frame == 17) {
			bfIceExplode.visible = true;
			bfIceExplode.playAnim("explode", true);
		}
	}

	if (boyfriend.curCharacter == "bf-ice-hammer") {
		stage.getSprite("iceGround").alpha = 0.0001;
	} else {
		stage.getSprite("iceGround").alpha = 1;
	}
}
function killShield() {
	if (stage.getSprite("gfShield").alpha != 0.0001)
		FlxFlicker.flicker(stage.getSprite("gfShield"), 0.5 / 2, 0.25 * 0.25, true, true, function() {
			stage.getSprite("gfShield").alpha = 0.0001;
		});
}

var slashTints = [ 0x91b500ff, 0x8f12deff, 0x7000ff00, 0x8fff0000 ];
var slashDatas = [ { x: -500, y: -400, angle: -20 }, { x: -500, y: -400, angle: -10 }, { x: -500, y: -400, angle: -20 }, { x: -500, y: -400, angle: -30 }];
function spawnSlash(direction:Int) {
	//return;
	var slash = preloadedSlash.clone();
	slash.x = dad.x + slashDatas[direction].x;
	slash.y = dad.y + slashDatas[direction].y;
	slash.origin.set(slash.x + 1742, slash.y + 500);
	slash.angle = slashDatas[direction].angle;
	slash.color = slashTints[direction];
	slash.alpha = 1;
	slash.animation.finishCallback = function(name) {
		slash.visible = false;
	}
	slash.animation.play('slash', true);
	slash.animation.callback = function(name, frame, index) {
		if (frame == 1) {
			boyfriend.playAnim('block', true);
		}
	}
	add(slash);

}

var activeLast:Bool = false;
//var toggler:Bool = false;
var cycle:Int = 0;
function advanceCycle() {
	if (cycle+1 <= 2) {
		cycle++;
	} else {
		cycle = 0;
	}
}
function onStartSong() {
	preShakePos.x = camGame.scroll.x;
	preShakePos.y = camGame.scroll.y;
	strumLines.members[0].onHit.add((event) -> {
		if (dad.curCharacter == "whitty-tantrum" || dad.curCharacter == "whitty-freeze-pop") {
			event.animCancelled = true;
			return;
		}
		var poses = ["singLEFT-alt", "singUP-alt", "singDOWN-alt", "singRIGHT-alt"];
		var chance = 3;
		var daRandomCheck = FlxG.random.int(0, chance);
		if (daRandomCheck == Math.floor(chance/2)) {
			activeLast = true;
			event.animCancelled = true;
			dad.playAnim(poses[event.direction], true, "SING");
		} else {
			if (!event.isSustainNote) {
				activeLast = false;
			} else if (activeLast) {
				event.animCancelled = true;
				dad.playAnim(poses[event.direction], "SING");
			}

		}
		if (dad.curCharacter == "whitty-crazy-weak") {
			event.animCancelled = true;
			var things = ["singSIDE", "singUP", "singDOWN"];
			if (!event.isSustainNote) {
				dad.playAnim(things[cycle], true);
				//toggler = !toggler;
				advanceCycle();
				boyfriend.playAnim(cycle == 1 ? "hit" : "bonk", true);
				dad.x = boyfriend.x - 400;
			}
		}
		//if (!StringTools.endsWith(dad.animation.name, "-alt")) {
			//dad.playAnim(poses[event.direction], true);
		//}
		//spawnDupe(dad);
		if (dad.curCharacter != "whitty-crazy-weak") {
			if (!activeLast) {
				spawnSlash(event.direction);
			} else {
				spawnBlast(FIRE, event.direction);
			}
		}
	});
	strumLines.members[1].onHit.add((event) -> {
		if (boyfriend.animation.curAnim.curFrame < 2 && !event.isSustainNote && curStep < 1311) {
			if (!ModOptions.ghostingDisabled) {
				spawnDupe(boyfriend);
			} else {
				bfTrail.target = blankSprite;
			}
		}
		if (boyfriend.curCharacter == "bf-ice-hammer") {
			event.animCancelled = true;
		}
		if (dad.curCharacter == "whitty-crazy-weak") {
			if ((dad.animation.name != "singSIDE" && dad.animation.name != "singUP" && dad.animation.name != "singDOWN") || dad.animation.curAnim.curFrame >= 4) {
				dad.x = dad.x - ((-50 + dad.x)/4);
				dad.playAnim("hit");
			}
		}
		if (dad.curCharacter == "whitty-tweaking") {
			dad.playAnim("tweak", true);
		}
		if (boyfriend.animation.name == "bonk") {
			event.animCancelled == true;
		}
		if (dad.curCharacter != "whitty-tantrum" && dad.curCharacter != "whitty-freeze-pop") {
			if (curStep < 2064) {
				spawnBlast(ICE, event.direction);
			}
		}
	});
	strumLines.members[2].onHit.add((event) -> {
		spawnBlast(GF, event.direction);
		health = lerp(health, 1, 0.5);
	});
}

function stepHit() {
	switch (curStep) {
		//case 10:
			//shrapnelThrowAnimation.play();
		case 161:
			spawnOilBlast();
			bombDestinations[0].x = 1500;
			bombDestinations[0].y = -60;
			bombDestinations[0].alpha = 1;
		case 224:
			fireBomb(0, 2);
			bombDestinations[1].x = 650;
			bombDestinations[1].y = 750;
			bombDestinations[1].alpha = 1;
			bombDestinations[1].angle = -75;
		case 288:
			fireBomb(0, 2);
			fireBomb(1, 2);
			bombDestinations[2].y = -20;
			bombDestinations[2].x = 820;
			bombDestinations[2].alpha = 1;
		case 352 | 416 | 480 | 544 | 608:
			fireBomb(0, 2);
			fireBomb(1, 2);
			fireBomb(2, 2);
		case 640:
			for (i in 0...bombs.length) {
				bombDestinations[i].x = 500;
				bombDestinations[i].y = 400;
			}
			new FlxTimer().start(0.6, (timer) -> {
				for (i in 0...bombs.length) {
					bombDestinations[i].alpha = 0;
					bombs[i].alpha = 0;
				}
				bigBombProperties.x = 550;
				bigBombProperties.y = 300;
				bigBombProperties.visible = true;
				shakeBigBomb(0.5);
			});
		case 798:
			bigBombProperties.phase = 1;
		case 1056:
			bigBombProperties.visible = false;
			snowFall.visible = true;
		case 1296:
			for (strum in strumLines.members[0].members) {
				strum.alpha = 0;
				for (note in strumLines.members[0].notes.members) {
					note.alpha = 0;
				}
			}
		case 1312:
			snowFall.visible = false;
		case 1326 | 1336:
			updateBfShield(1);
		case 1349 | 1351:
			updateBfShield(-1);
		case 1366:
			updateBfShield(1);
		case 1368:
			updateBfShield(-1);
		case 1441:
			FlxTween.tween(boyfriend, {y: boyfriend.y-190}, 1, {
				ease: FlxEase.quintOut
			});
		case 1566:
			stage.getSprite('icePed').alpha = 1;
			stage.getSprite('icePed').playAnim('spawn', true);
		case 1697:
			FlxTween.tween(boyfriend, {y: boyfriend.y + 120}, 8/24, {
				ease: FlxEase.quadOut,
				onComplete: function() {
					boyfriend.y += 190-120;
				}
			});
			stage.getSprite('icePed').playAnim('destroy', true);
		case 1808:
			curStage = 1;
		case 2094:
			boyfriend.playAnim("idle", true);
	}
	switch (curStep) {
		case 1296 | 1300 | 1304 | 1308:
			setCamLockH('true');
			lockZoom = false;
			camGame.zoom += 0.02;
			lockPos.x -= 30;
			lockPos.y -= 10;
			updateLock();
	}
	switch (curStep) { // handle big bomb switch side
		case 672 | 688 | 704 | 720 | 736 | 752 | 768 | 784 | 800 | 808 | 816 | 824 | 832 | 840 | 848 | 856 | 864 | 872 | 880 | 888 | 896 | 904 | 912 | 920 | 928 | 944 | 960 | 976 | 992 | 1008 | 1024 | 1040:
			switchBombSide();
	}
}

function begAssFireBlast(show:String, blast:String) {
	var showFire:Bool = show == 'true';
	var fireBlast:Bool = (blast ?? 'false') == 'true';
	for (i in 1...6) {
		var object:FunkinSprite = stage.getSprite('smallFire' + i);
		object.alpha = showFire ? 1 : 0.0001;
	}
	stage.getSprite('fireWall').alpha = showFire ? 1 : 0.0001;

	if (fireBlast) {
		//
	}
}