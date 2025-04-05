import funkin.backend.CoolUtil; // Sound won't play without it for some reason.
import funkin.backend.chart.Chart;
import funkin.menus.FreeplayState.FreeplaySonglist;
import funkin.menus.FreeplayState;

class Remix {
	var title:String;
	var color:FlxColor;

    public function new(Title:String, Color:FlxColor) {
        this.title = Title;
        this.color = Color;
	}
}

function create() {
    songList = new FreeplaySonglist();
    songList.songs = [];
	for (daSong in _daSongList) {
		songList.songs.push(Chart.loadChartMeta(daSong, "normal", false));
	}
    songs = songList.songs;
}

var partTexts:FlxTypedGroup<Alphabet>;
var gateTexts:FlxTypedGroup<Alphabet>;
var comingSoonGrp:FlxGroup = new FlxGroup();
var tabText:FlxText;
var textCamera:FlxCamera;
var picoTextCamera:FlxCamera; // Used to rotate text, don't you fucking delete it.
// picoText.angle rotates each char seperatley
var picoText:FlxSprite;
function getRemix(title:String, color:FlxColor) return {title: title, color: color}
var remixes:Array = [getRemix("normal", 0xFF00FFFF), getRemix("pico", 0xFF00FF00), getRemix("spooky", FlxColor.ORANGE), getRemix("neo", 0xFFFF03D9), getRemix("b2", 0xFFFF03D9)];
static var curRemix:Int = 0;
var curChar:String = "boyfriend";
var swappedChar:Bool = false;
var leftButton:FunkinSprite;
var rightButton:FunkinSprite;
var randomButton:FunkinSprite;
var backupValues = {x: 0, y: 0}
var isShaking = false;
var prefix:String = "Current Remix:";

var nextDecoration:FlxSprite;
var curDecoration:FlxSprite = new FlxSprite();

function capitalizeFirstChar(str:String) {
	var array = str.split();
	var firstChar = array[0].toUpperCase();
	array.remove(array[0]);
	return (firstChar + array.join());
}

function shakeCamera(duration) {
	comingSoonGrp.visible = true;
	backupValues.x = textCamera.scroll.x;
	backupValues.y = textCamera.scroll.y;
	isShaking = true;
	new FlxTimer().start(duration, () -> {
		isShaking = false;
		textCamera.scroll.x = backupValues.x;
		textCamera.scroll.y = backupValues.y;
		comingSoonGrp.visible = false;
	});
}

override function changeCoopMode(?a, ?e) {}

function swapChar(?set) {
	//swappedChar = set ?? !swappedChar;
	if (curRemix + 1 < remixes.length) {
		curRemix++;
	} else {
		curRemix = 0;
	}
	for (i in 0...remixes.length) {
		if (!checkForPico()) {
			if (curRemix + 1 < remixes.length) {
				curRemix++;
			} else {
				curRemix = 0;
			}
		}
	}
	curRemix = set ?? curRemix;
	coopText.text = prefix + " " + capitalizeFirstChar(remixes[curRemix].title);
	coopText.color = remixes[curRemix].color;
	//picoText.text = remixes[curRemix].title + " mix";
	if (curRemix != 0) {
		picoText.loadGraphic(Paths.image("menus/freeplaymenu/remixes/" + remixes[curRemix].title));
		picoText.antialiasing = true;
		picoText.angle = 10;
		picoText.updateHitbox();
		picoText.setGraphicSize(390.6, 106.4);
		picoText.updateHitbox();
		picoText.screenCenter();
		trace(picoText.width, picoText.height);
	}
	FlxTween.color(coopText, 0.2, coopText.color, 0xffffffff);

	if (songInstPlaying) {
		var songTime = FlxG.sound.music.time;
		if (curPlayingInst != (curPlayingInst = Paths.inst(songs[curSelected].name + (curRemix != 0 ? "-" + remixes[curRemix].title : ""), songs[curSelected].difficulties[curDifficulty]))) {
			var huh:Void->Void = function() {
				FlxG.sound.playMusic(curPlayingInst, 1);
				FlxG.sound.music.time = songTime;
			}
			if (!disableAsyncLoading)
				Main.execAsync(huh);
			else
				huh();
		}
	}
}

function postCreate() {
	canSelect = false;
	FlxG.cameras.add(textCamera = new FlxCamera(), false);
	textCamera.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(picoTextCamera = new FlxCamera(), false);
	picoTextCamera.bgColor = FlxColor.TRANSPARENT;

	partTexts = new FlxTypedGroup();
	gateTexts = new FlxTypedGroup();

	swappedChar = ModOptions.freeplayLastCharacter ?? false;
	curChar = (swappedChar ? "pico" : "boyfriend");

	swapChar(0);
	// coopText.text = "Current Character: " + (swappedChar ? "Pico" : "Boyfriend");
	i = 0;
	for (text in grpSongs) {
		text.isMenuItem = false;
		text.screenCenter();

		var part:Alphabet = new Alphabet(0, 0, songs[i].customValues.partText ?? '', false, false);
		part.screenCenter();
		part.y = text.y + 40;
		partTexts.add(part);
		var isGated:Bool = (songs[i].customValues.gateKept ?? 'false') == 'true';
		var gate:Alphabet = new Alphabet(0, 0, isGated ? '(Gate Kept by Sock.Clip)' : '', false, false);
		gate.scale.set(0.5, 0.5);
		gate.updateHitbox();
		var wheresThatDamn4thChaosEmerald:Int = 0;
		for (l in gate) {
			var diff:Float = (wheresThatDamn4thChaosEmerald - (gate.length / 2));
			l.x = (diff * 20);
			if (gate.text.charAt(wheresThatDamn4thChaosEmerald) == 'l')
				l.x += 5;
			l.y = gate.y + ((gate.members[0].height - l.height) * gate.scale.y) + 30;
			wheresThatDamn4thChaosEmerald++;
		}
		gate.updateHitbox();
		gate.screenCenter();
		if (isGated)
			for (l in [text, part])
				l.y -= 15;
		gate.y = part.y + 70;
		gateTexts.add(gate);
		i++;
	}
	add(gateTexts);
	add(partTexts);

	tabText = new FlxText(0, 0);
	tabText.text = "Press [ TAB ] to change remixes";
	tabText.setFormat(null, 20);
	tabText.updateHitbox();
	tabText.screenCenter(FlxAxes.X);
	tabText.alpha = 0.5;
	tabText.y = 10;
	add(tabText);

	for (l in [grpSongs, partTexts, gateTexts]) {
		l.cameras = [textCamera];
		i = 0;
		for (a in l) {
			if (i != 0)
				a.x += FlxG.width * i;
			i++;
		}
	}
	for (l in iconArray) {
		l.screenCenter(FlxAxes.X);
		if (i != 0)
			l.x += FlxG.width * i;
		l.cameras = [textCamera];
		l.scrollFactor.set(1, 1);
	}
	checkForPico();

	FlxG.mouse.visible = true;

	leftButton = new FunkinSprite();
	leftButton.frames = Paths.getSparrowAtlas('menus/storymenu/assets');
	leftButton.animation.addByPrefix('idle', 'arrow left', 24, false);
	leftButton.animation.addByPrefix('left-push', 'arrow push left', 24, false);
	leftButton.cameras = [textCamera];
	leftButton.scrollFactor.set(0, 0);
	leftButton.antialiasing = true;
	add(leftButton);

	rightButton = new FunkinSprite();
	rightButton.frames = Paths.getSparrowAtlas('menus/storymenu/assets');
	rightButton.animation.addByPrefix('idle', 'arrow right', 24, false);
	rightButton.animation.addByPrefix('left-push', 'arrow push right', 24, false);
	rightButton.cameras = [textCamera];
	rightButton.scrollFactor.set(0, 0);
	rightButton.antialiasing = true;
	add(rightButton);

	randomButton = new FunkinSprite();
	randomButton.frames = Paths.getSparrowAtlas('menus/freeplaymenu/randomButton');
	randomButton.animation.addByPrefix('idle', 'Idle', 24, false);
	randomButton.animation.addByPrefix('press', 'Press', 24, false);
	randomButton.scale.set(0.5, 0.5);
	randomButton.cameras = [textCamera];
	randomButton.scrollFactor.set(0, 0);
	randomButton.antialiasing = true;
	add(randomButton);

	randomButton.updateHitbox();
	randomButton.y = FlxG.height - randomButton.height - 10;
	randomButton.screenCenter(FlxAxes.X);

	picoText = new FlxSprite();
	picoText.screenCenter();
	picoText.cameras = [picoTextCamera];
	//picoTextCamera.angle = 10;
	picoTextCamera.zoom = 0.8;
	add(picoText);
	FlxG.sound.music.volume = 0;

	var tint = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	tint.alpha = 0.5;
	tint.screenCenter();
	tint.scrollFactor.set(0, 0);
	comingSoonGrp.add(tint);

	var comingSoonText:FlxText = new FlxText(0, 0, FlxG.width);
	comingSoonText.setFormat(Paths.font('ErasBoldITC.ttf'), 100, FlxColor.WHITE, 'center');
	comingSoonText.updateHitbox();
	comingSoonText.screenCenter();
	comingSoonText.scrollFactor.set(0, 0);
	// comingSoonText.cameras = [textCamera];
	comingSoonGrp.add(comingSoonText);

	comingSoonGrp.cameras = [textCamera];
	// comingSoonGrp.scrollFactor.set(0, 0);
	add(comingSoonGrp);
	comingSoonGrp.visible = false;

	FlxTween.color(coopText, 0.2, coopText.color, 0xffffffff);

	currentTrack = "freeplayMenu"; // Does nothing until menu is closed.
	// picoText.y = text.y + 40;
}

var textAlphaThing = 1;
var newSongCheck = false;

function update(elasped:Float) {
	newSongCheck = songInstPlaying;
	diffText.text = StringTools.replace(diffText.text, "<", "↓ Charter:");
	diffText.text = StringTools.replace(diffText.text, " >", " ↑");
}

function onPress() {
	if (FlxG.mouse.overlaps(randomButton)) {
		randomButton.playAnim("press");
		changeSelection(FlxG.random.int(1, songs.length - 1));
	}
}

function onRelease() {
	if (randomButton.animation.name == "press") {
		randomButton.playAnim("idle");
	}
}
var tweenOut;
var tweenIn;
function onSwitch() {
	trace(songs[curSelected].customValues.decoration);
	if (tweenOut != null) tweenOut.cancel();
	tweenOut = FlxTween.tween(curDecoration, {alpha: 0}, 0.49, { onComplete: ()->{remove(curDecoration);}});
	if (songs[curSelected].customValues.decoration != null) {
		var decorData = songs[curSelected].customValues.decoration;
		nextDecoration = new FlxSprite();
		if (decorData.animation != null) {
			nextDecoration.frames = Paths.getSparrowAtlas("menus/freeplaymenu/decorations/" + decorData.file);
			nextDecoration.animation.addByPrefix('idle', decorData.animation, 24, true);
			nextDecoration.animation.play('idle', true);
		} else {
			nextDecoration.loadGraphic(Path.image("menus/freeplaymenu/decorations/" + decorData.file));
		}
		nextDecoration.alpha = 0;
		nextDecoration.scale.set(decorData.scale, decorData.scale);
		nextDecoration.updateHitbox();
		nextDecoration.cameras = [textCamera];
		nextDecoration.scrollFactor.set();
		if (decorData.position.x != "center") {
			nextDecoration.x = Std.parseInt(decorData.position.x);
		} else {
			nextDecoration.screenCenter(FlxAxes.X);
		}
		if (decorData.position.y != "center") {
			nextDecoration.y = Std.parseInt(decorData.position.y);
		} else {
			nextDecoration.screenCenter(FlxAxes.Y);
		}
		add(nextDecoration);
		if (tweenIn != null) tweenIn.cancel();
		tweenIn = FlxTween.tween(nextDecoration, { alpha: 1 }, 0.5, { onComplete: ()->{
			curDecoration = nextDecoration.clone();
			curDecoration.scale.set(decorData.scale, decorData.scale);
			curDecoration.cameras = [textCamera];
			curDecoration.scrollFactor.set();
			curDecoration.animation.curAnim.curFrame = nextDecoration.animation.curAnim.curFrame;
			if (decorData.position.x != "center") {
				curDecoration.x = Std.parseInt(decorData.position.x);
			} else {
				curDecoration.screenCenter(FlxAxes.X);
			}
			if (decorData.position.y != "center") {
				curDecoration.y = Std.parseInt(decorData.position.y);
			} else {
				curDecoration.screenCenter(FlxAxes.Y);
			}
			curDecoration.alpha = 1;

			add(curDecoration);
			remove(nextDecoration);
		}});
	}
}
function postUpdate(elapsed:Float) {
	picoText.angle = 10;
	picoText.setGraphicSize(390.6, 106.4);
	picoText.updateHitbox();
	picoText.screenCenter();
	FlxG.camera.zoom = lerp(FlxG.camera.zoom, 1, 0.1);
	if (isShaking) {
		var distanceX = FlxG.random.int(-10, 10);
		var distanceY = FlxG.random.int(-10, 10);
		textCamera.scroll.x = backupValues.x + distanceX;
		textCamera.scroll.y = backupValues.y + distanceY;
	}
	if (controls.BACK) {
		FlxG.switchState(new ModState('FreeplaySelectionState'));
	}
	if (FlxG.keys.justPressed.TAB) {
		swapChar();
	}
	diffText.visible = !(songs[curSelected].difficulties.length <= 1);
	// coopText.visible = false;
	if (songs[curSelected].difficulties.length <= 1) {
		scoreBG.scale.set(Math.max(Math.max(diffText.width, scoreText.width), coopText.width) + 8, (coopText.visible ? 66 + 5 : 66 - coopText.height + 5));
		scoreBG.updateHitbox();
	}
	coopText.y = diffText.y + (diffText.height * (diffText.visible ? 1 : 0));
	//trace(diffText.text);

	leftButton.playAnim((controls.LEFT || (FlxG.mouse.pressed && FlxG.mouse.overlaps(leftButton))) ? "left-push" : "idle", true);
	leftButton.x = 10;
	leftButton.updateHitbox();
	leftButton.screenCenter(FlxAxes.Y);

	rightButton.playAnim((controls.RIGHT || (FlxG.mouse.pressed && FlxG.mouse.overlaps(rightButton))) ? "left-push" : "idle", true);
	rightButton.updateHitbox();
	rightButton.x = FlxG.width - rightButton.width - 10;
	rightButton.screenCenter(FlxAxes.Y);

	// randomButton.playAnim((FlxG.mouse.pressed && FlxG.mouse.overlaps(rightButton)) ? "press" : "idle", false);
	// randomButton.playAnim("press");
	FlxG.mouse.justPressed ? onPress() : 0;
	FlxG.mouse.justReleased ? onRelease() : 0;

	randomButton.centerOrigin();
	randomButton.centerOffsets();

	if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(leftButton)) {
		if (curSelected - 1 < 0)
			textCamera.scroll.x += 1280 * grpSongs.members.length;
		changeSelection(-1);
		checkForPico() ? 0 : swapChar(0);
		onSwitch();
	}
	if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(rightButton)) {
		if (curSelected + 1 > grpSongs.members.length - 1)
			textCamera.scroll.x -= 1280 * grpSongs.members.length;
		changeSelection(1);
		checkForPico() ? 0 : swapChar(0);
		onSwitch();
	}

	if (controls.LEFT_P) {
		if (curSelected - 1 < 0)
			textCamera.scroll.x += 1280 * grpSongs.members.length;
		changeSelection(-1);
		checkForPico() ? 0 : swapChar(0);
		onSwitch();
	} else if (controls.RIGHT_P) {
		if (curSelected + 1 > grpSongs.members.length - 1)
			textCamera.scroll.x -= 1280 * grpSongs.members.length;
		changeSelection(1);
		checkForPico() ? 0 : swapChar(0);
		onSwitch();
	}
	changeDiff((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));
	changeCoopMode((FlxG.keys.justPressed.TAB ? 1 : 0));
	// putting it before so that its actually smooth
	updateOptionsAlpha();

	FreeplayState.select = function() {}

	tabText.alpha = coopText.visible ? 0.5 : 0;
	if (curRemix == 0) {
		picoText.visible = false;
	} else {
		picoText.visible = coopText.visible;
	}
	picoText.screenCenter(FlxAxes.Y);
	picoText.scrollFactor.set(1, 0);
	picoTextCamera.x = -textCamera.scroll.x + (FlxG.width * curSelected);
	if (!checkForPico())
		return;
	if (!disableAutoPlay && !newSongCheck && (autoplayElapsed > timeUntilAutoplay || FlxG.keys.justPressed.SPACE)) {
		if (curPlayingInst != (curPlayingInst = Paths.inst(songs[curSelected].name + (swappedChar ? "-pico" : ""),
			songs[curSelected].difficulties[curDifficulty]))) {
			var huh:Void->Void = function() FlxG.sound.playMusic(curPlayingInst, 0);
			if (!disableAsyncLoading)
				Main.execAsync(huh);
			else
				huh();
		}
		// songInstPlaying = true;
		if (disableAsyncLoading)
			dontPlaySongThisFrame = true;
	}
}
//lerp(FlxG.camera.zoom, 1, 0.1);
function beatHit() {
	FlxG.camera.zoom = 1.05;
}
function checkForPico() {
	var daSong = songs[curSelected].name;
	if (curRemix != 0) {
		daSong = songs[curSelected].name + "-" + remixes[curRemix].title;
	}
	var data = [];
	data = data.concat(Paths.getFolderContent("songs/" + daSong + "/", true));
	data = data.concat(Paths.getFolderContent("songs/" + daSong + "/"));

	/*if (data.length == 0) {
		coopText.visible = false;
	} else {
		coopText.visible = true;
	}*/
	return data.length != 0;
}

function onUpdateOptionsAlpha(event) {
	event.cancelled = true;
	event.idleAlpha = 0;
	event.idlePlayingAlpha = 0;
	event.selectedAlpha = 1;
	event.selectedPlayingAlpha = 1;
	event.lerp = 0.20;

	textCamera.scroll.x = lerp(textCamera.scroll.x, FlxG.width * curSelected, event.lerp);
	for (i in 0...iconArray.length) {
		partTexts.members[i].alpha = iconArray[i].alpha = lerp(iconArray[i].alpha, #if PRELOAD_ALL songInstPlaying ? event.idlePlayingAlpha : #end event.idleAlpha, event.lerp);
		var midPoint:FlxPoint = iconArray[i].sprTracker.getMidpoint();
		iconArray[i].setPosition(midPoint.x - (iconArray[i].width / 2), midPoint.y - 180);
		midPoint.put();
	}
	partTexts.members[curSelected].alpha = iconArray[curSelected].alpha = #if PRELOAD_ALL songInstPlaying ? event.selectedPlayingAlpha : #end
	event.selectedAlpha;
	for (i => item in grpSongs.members) {
		item.targetY = i - curSelected;
		item.alpha = lerp(item.alpha, #if PRELOAD_ALL songInstPlaying ? event.idlePlayingAlpha : #end event.idleAlpha, event.lerp);
		if (item.targetY == 0)
			partTexts.members[i].alpha = item.alpha = #if PRELOAD_ALL songInstPlaying ? event.selectedPlayingAlpha : #end
		event.selectedAlpha;
		gateTexts.members[i].alpha = partTexts.members[i].alpha;
	}
}

function onSelect(event) {
	event.cancelled = true;
	customSelect(event);
}

function customSelect(event) {
	if (songs[curSelected].customValues.comingSoon == 'true' || _globalComingSoon) {
		comingSoonGrp.members[1].text = "Coming in v" + songs[curSelected].customValues.comingIn;
		CoolUtil.playMenuSFX(2, 1);
		shakeCamera(0.3);
		if (!isDev) return;
	}
	if (songs[curSelected].difficulties.length <= 0)
		return;
	FlxG.mouse.visible = false;

	ModOptions.freeplayLastCharacter = swappedChar;
	var daSong = event.song + "-" + remixes[curRemix].title;
	var data = [];
	data = data.concat(Paths.getFolderContent("songs/" + daSong + "/", true));
	data = data.concat(Paths.getFolderContent("songs/" + daSong + "/"));
	if (data.length == 0 && swappedChar)
		daSong = event.song;
	PlayState.loadSong(StringTools.replace(daSong, "-normal", ""), event.difficulty, event.opponentMode, event.coopMode);
	FlxG.switchState(new PlayState());
}
