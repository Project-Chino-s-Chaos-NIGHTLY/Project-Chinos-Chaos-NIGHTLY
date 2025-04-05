import DropShadowShader;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxSave;
import funkin.editors.EditorPicker;
import funkin.menus.ModSwitchMenu;

class RoundedBox {
    public var height:Int;
	public var cornerSize:Int;

	public var box:FlxSpriteGroup = new FlxSpriteGroup();
	public function new (color:FlxColor, x:Float, y:Float, width:Int, height:Int, cornerSize:Int) {
		this.height = height;
		this.cornerSize = cornerSize;
		var innerbox = new FlxSprite(cornerSize, 0).makeGraphic(width-(cornerSize*2), height, color);
		box.add(innerbox);

		var innerbox = new FlxSprite(0, cornerSize).makeGraphic(cornerSize, height-(cornerSize*2), color);
		box.add(innerbox);

		var innerbox = new FlxSprite(width-cornerSize, cornerSize).makeGraphic(cornerSize, height-(cornerSize*2), color);
		box.add(innerbox);

		var topLeftCorner = new FlxSprite(0, 0).loadGraphic(Paths.image("cui/corner"));
		topLeftCorner.setGraphicSize(cornerSize, cornerSize);
		topLeftCorner.updateHitbox();
		topLeftCorner.x = 0;
		topLeftCorner.y = 0;
		topLeftCorner.antialiasing = true;
		topLeftCorner.flipX = true;
		topLeftCorner.flipY = true;
		box.add(topLeftCorner);

		var topRightCorner = new FlxSprite(width, 0).loadGraphic(Paths.image("cui/corner"));
		topRightCorner.setGraphicSize(cornerSize, cornerSize);
		topRightCorner.updateHitbox();
		topRightCorner.x = width-cornerSize;
		topRightCorner.y = 0;
		topRightCorner.antialiasing = true;
		//topRightCorner.flipX = true;
		topRightCorner.flipY = true;
		box.add(topRightCorner);

		var bottomRightCorner = new FlxSprite(width, 0).loadGraphic(Paths.image("cui/corner"));
		bottomRightCorner.setGraphicSize(cornerSize, cornerSize);
		bottomRightCorner.updateHitbox();
		bottomRightCorner.x = width-cornerSize;
		bottomRightCorner.y = height-cornerSize;
		bottomRightCorner.antialiasing = true;
		//bottomRightCorner.flipX = true;
		//bottomRightCorner.flipY = true;
		box.add(bottomRightCorner);

		var bottomLeftCorner = new FlxSprite(width, 0).loadGraphic(Paths.image("cui/corner"));
		bottomLeftCorner.setGraphicSize(cornerSize, cornerSize);
		bottomLeftCorner.updateHitbox();
		bottomLeftCorner.x = 0;
		bottomLeftCorner.y = height-cornerSize;
		bottomLeftCorner.antialiasing = true;
		bottomLeftCorner.flipX = true;
		//bottomRightCorner.flipY = true;
		box.add(bottomLeftCorner);

	}
}

var dropShadowShader:DropShadowShader = new DropShadowShader();

var hitDaGriddy:FlxBackdrop;
var backPanel:FunkinSprite;
var chino:FunkinSprite;
var splashText:FlxText;
var selected:Bool = false;
var randomVol:FlxPoint = new FlxPoint(100, 100);
var menuItemsDefaultOffsets:Array<FlxPoint> = [];
var chinoTweenToggle:Bool = false;

var albumBox:RoundedBox;
var albumArt:FlxSprite;
var albumNowPlaying:FlxText;
var albumTitle:FlxText;
var albumAuthor:FlxText;

function tweenChino() {
	FlxTween.tween(chino, {y: chinoTweenToggle ? 25 - 100 : -25 - 100}, 2, {
		ease: FlxEase.sineInOut,
		onComplete: tweenChino
	});
	chinoTweenToggle = !chinoTweenToggle;
}

function screenCenterSprGroup(daGroup:FlxSpriteGroup, axis:FlxAxes) {
	var menuItemWidth:Float = daGroup.findMaxX() - daGroup.findMinX();
	var menuItemHeight:Float = daGroup.findMaxY() - daGroup.findMinY();
	var centerX:Float = (FlxG.width / 2) - (menuItemWidth / 2);
	var centerY:Float = (FlxG.height / 2) - (menuItemHeight / 2);
	switch (axis) {
		case FlxAxes.X:
			daGroup.x = centerX;
		case FlxAxes.Y:
			daGroup.y = centerY;
		case FlxAxes.XY:
			daGroup.x = centerX;
			daGroup.y = centerY;
	}
}

var offsetTimer:Array<Int> = [];
var backDropCamera:FlxCamera;
var camGame:FlxCamera;
var buttonCamera:FlxCamera;
var charSets:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var sets:Array;
var blacklistedUsers = ['8owser', 'chinosanimated', 'sock.wav'];

function postCreate() {
	FlxG.mouse.visible = true;
	sets = Json.parse(Assets.getText(Paths.json('config/menuchars')));

	backDropCamera = new FlxCamera();
	backDropCamera.width = FlxG.width * 2;
	backDropCamera.height = FlxG.width * 2;
	backDropCamera.x -= FlxG.width / 2;
	backDropCamera.y -= backDropCamera.height / 2;
	backDropCamera.bgColor = FlxColor.TRANSPARENT;
	camGame = new FlxCamera();
	camGame.bgColor = FlxColor.TRANSPARENT;
	buttonCamera = new FlxCamera();
	buttonCamera.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(backDropCamera, false);
	FlxG.cameras.add(camGame, false);
	FlxG.cameras.add(buttonCamera, false);

	hitDaGriddy = new FlxBackdrop(Paths.image('menus/mainmenu/tiles'), FlxAxes.XY);
	hitDaGriddy.velocity.set(100, 100);
	hitDaGriddy.antialiasing = true;
	hitDaGriddy.scale.set(0.5, 0.5);
	hitDaGriddy.scrollFactor.set();
	hitDaGriddy.cameras = [backDropCamera];
	hitDaGriddy.origin.set(FlxG.width / 2, FlxG.height / 2);
	insert(members.indexOf(menuItems), hitDaGriddy);

	backPanel = new FunkinSprite();
	backPanel.frames = Paths.getSparrowAtlas('menus/mainmenu/sidePanel');
	backPanel.animation.addByPrefix('shine', 'Menu Shine', 24, false);
	backPanel.animation.addByIndices('idle', 'Menu Shine', [0], '', 24, false);
	backPanel.playAnim('idle');
	backPanel.scrollFactor.set();
	backPanel.scale.set(FlxG.width / 1920, FlxG.width / 1920);
	backPanel.updateHitbox();
	backPanel.screenCenter(FlxAxes.Y);
	backPanel.x = FlxG.width;
	backPanel.cameras = [camGame];
	backPanel.antialiasing = true;
	insert(members.indexOf(menuItems), backPanel);

	var randomInt:Int = 0;
	for (i in 0...100)
		randomInt = FlxG.random.int(0, sets.length - 1);

	for (index in 0...sets.length) {
		var array = sets[index];
		var set = new FlxTypedGroup();
		if (index != randomInt)
			set.visible = false;
		set.ID = index;
		for (index2 in 0...array.length) {
			var obj = array[index2];
			var sprite = new FunkinSprite(obj.x, obj.y);
			if (index == randomInt) {
				if (obj.animPrefix == null)
					sprite.loadGraphic(Paths.image('menus/mainmenu/' + obj.path));
				else {
					sprite.frames = Paths.getSparrowAtlas('menus/mainmenu/' + obj.path);
					sprite.animation.addByPrefix('idle', obj.animPrefix, obj.frameRate, obj.loop);
				}
				sprite.flipX = obj.flipX ?? false;
				sprite.scale.set(obj.scale * (FlxG.width / 1920), obj.scale * (FlxG.width / 1920));
				sprite.playAnim('idle');
				sprite.ID = 0;
				sprite.antialiasing = true;
				// sprite.updateHitbox();
			}
			set.add(sprite);
		}
		charSets.add(set);
	}

	// charSets.members[randomInt].visible = true;
	charSets.cameras = [camGame];
	add(charSets);

	chino = new FunkinSprite(0, 25 - 100).loadGraphic(Paths.image('menus/mainmenu/chino'));
	chino.scrollFactor.set();
	chino.scale.set(0.77 * (FlxG.width / 1920), 0.77 * (FlxG.width / 1920));
	chino.cameras = [camGame];
	chino.antialiasing = true;
	add(chino);
	tweenChino();

	dropShadowShader.set('divisions', 50);
    dropShadowShader.set('size', 15);
    dropShadowShader.set('strength', 0.5);
	buttonCamera.addShader(dropShadowShader.get());

	var lilGuy = new FunkinSprite(-100, 0);
	lilGuy.frames = Paths.getSparrowAtlas('menus/mainmenu/jusALilGuy');
	lilGuy.animation.addByPrefix('dance', 'dance', 24, true);
	lilGuy.playAnim('dance');
	lilGuy.scale.set(0.5, 0.5);
	lilGuy.updateHitbox();
	lilGuy.screenCenter(FlxAxes.Y);
	lilGuy.cameras = [camGame];
	lilGuy.antialiasing = true;
	lilGuy.visible = false;
	add(lilGuy);

	var rando:Int = FlxG.random.int(0, 100);
	if (rando == 50) {
		lilGuy.visible = true;
		charSets.members[randomInt].visible = false;
		chino.visible = false;
	}

	for (item in menuItems) {
		var i:Int = menuItems.members.indexOf(item);
		item.x = 825 - ((item.width / 10) * i);
		item.y = 60 + (i * (160 / (menuItems.length / 4)));

		offsetTimer.push(offsetTimer[item.ID - 1] != null ? offsetTimer[item.ID - 1] - 300 : 0);

		// item.y = 150 + ((item.height * 1.2) * i);
		item.scale.set(0.7, 0.7);
		item.updateHitbox();

		item.scrollFactor.x = 0;
		menuItemsDefaultOffsets.push(item.offset);
		item.cameras = [buttonCamera];
	}

	try {
		if (forceCenterX || !forceCenterX) {
			forceCenterX = false;
			versionText.text = 'Project: Chino\'s Chaos v' + modVersion;
			versionText.antialiasing = true;
			versionText.y = FlxG.height - 2 - versionText.height;
			versionText.cameras = [camGame];
		}
	} catch (error:Dynamic) {
		var warnCam = new FlxCamera();
		warnCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(warnCam, false);

		var errorThing = new FlxSprite();
		errorThing.loadGraphic(Paths.image('editors/ui/grayscale-popup'));
		errorThing.screenCenter();
		errorThing.color = 0xFFFF0000;
		errorThing.cameras = [warnCam];
		add(errorThing);

		var titleSpr = new FlxText(errorThing.x + 5, errorThing.y, errorThing.bWidth - 50, 'New Update!', 15, -1);
		titleSpr.y = errorThing.y + ((30 - titleSpr.height) / 2) + 2;
		titleSpr.cameras = [warnCam];
		add(titleSpr);

		var desc = new FlxText(errorThing.x + 5, errorThing.y, errorThing.width - 5, 'Please update Codename Engine.', 10, -1);
		desc.y = errorThing.y + ((30 - titleSpr.height) * 2) + 17;
		desc.cameras = [warnCam];
		add(desc);

		new FlxTimer().start(0.2, function(timer) {
			FlxTween.tween(warnCam, {zoom: 2}, 0.66, {ease: FlxEase.elasticOut});
			CoolUtil.playMenuSFX(WARNING);
		});
	}
	randomBackdropAngle();

	splashText = new FlxText(2, 2);
	splashText.cameras = [camGame];
	splashText.text = 'Sample';
	splashText.visible = false; // Will add later ig.
	add(splashText);
	new FlxTimer().start(1, function(timer) {
		if (blacklistedUsers.contains(getDiscordName()) && !ModOptions.banLifted) {
			FlxG.switchState(new ModState('LolState')); // KYS hscript
		}
	});
	playMenuSong(ModOptions.menuTrack);

	var albumData = getSongData();

	albumNowPlaying = new FlxText(0, 0, null, 'Now Playing:', 10);
	albumNowPlaying.cameras = [camGame];

	albumTitle = new FlxText(0, 0, '', null, 15);
	albumTitle.cameras = [camGame];
	albumTitle.text = albumData.name;


	albumAuthor = new FlxText(0, 0, '', null, 12);
	albumAuthor.cameras = [camGame];
	albumAuthor.text = "By: " + albumData.by;


	albumBox = new RoundedBox(0xFF000000, 20, 20, 130 + (albumTitle.width > albumAuthor.width ? albumTitle.width : albumAuthor.width), 115, 20);
	albumBox.box.cameras = [camGame];
	albumBox.box.alpha = 0.5;

	albumBox.box.x = -albumBox.box.width;

	albumArt = new FlxSprite().loadGraphic(getCoverArt());
	albumArt.cameras = [camGame];
	albumArt.setGraphicSize(albumBox.height-(albumBox.cornerSize), albumBox.height-(albumBox.cornerSize));
	albumArt.updateHitbox();
	albumArt.antialiasing = true;

	updateAlbum();

	FlxTween.tween(albumBox.box, {x: 20, y: 20}, 1, {ease: FlxEase.backOut});
	add(albumBox.box);
	add(albumArt);
	add(albumTitle);
	add(albumAuthor);
	add(albumNowPlaying);
}
function updateAlbum() {
	new FlxTimer().start(0.1, ()->{
		var albumData = getSongData();
		//albumTitle = new FlxText(albumTitle.x, 0, null, albumData.name, 15);
		//albumTitle.cameras = [camGame];
		albumTitle.text = albumData.name;
		albumAuthor.text = "By: " + albumData.by;
		albumArt.loadGraphic(getCoverArt());
	});
}
var currentSong:String = "";
function getCoverArt() {
	return StringTools.replace(Paths.music(FlxG.sound.music.name), ".ogg", ".png");
}
function getSongData() {
	var path = StringTools.replace(Paths.music(FlxG.sound.music.name), ".ogg", ".json");
	var jsonText:String = Assets.getText(StringTools.replace(path, "assets/", ""));
	var jsonData:Dynamic = Json.parse(jsonText);
	return jsonData;
	//var skinData:Dynamic = Json.parse(jsonData);
}
function randomBackdropAngle() {
	var duration:Float = FlxG.random.float(2, 7);
	FlxTween.tween(backDropCamera, {zoom: FlxG.random.float(0.5, 3)}, duration, {
		ease: FlxEase.sineInOut,
		onComplete: function() {
			new FlxTimer().start(duration, function(timer) {
				randomBackdropAngle();
			});
		}
	});
}

var canSelect:Bool = true;
var didScroll:Bool = false;
var prevMouseScroll:Int = 0;
var cursorMoving:Bool = false;
var prevpos = {x: 0, y: 0}
var desiredZoom = 1;

function inRange(rangeStart:Int, rangeEnd:Int, number:Int) {
	return number >= rangeStart && number <= rangeEnd;
}

function update(elapsed:Float) {
	if (!inRange(prevpos.x - 30, prevpos.x + 30, FlxG.mouse.screenX) || !inRange(prevpos.y - 30, prevpos.y + 30, FlxG.mouse.screenY)) {
		cursorMoving = true;
		prevpos.x = FlxG.mouse.screenX;
		prevpos.y = FlxG.mouse.screenY;
	} else
		cursorMoving = false;

	if (hitDaGriddy.velocity.x == randomVol.x) {
		var randoInt:Int = FlxG.random.float(-200, 200);
		randomVol.x = randoInt;
		FlxTween.tween(hitDaGriddy.velocity, {x: randoInt}, FlxG.random.float(5, 10), {ease: FlxEase.quartInOut});
	}

	if (hitDaGriddy.velocity.y == randomVol.y) {
		var randoInt:Int = FlxG.random.float(-200, 200);
		randomVol.y = randoInt;
		FlxTween.tween(hitDaGriddy.velocity, {y: randoInt}, FlxG.random.float(5, 10), {ease: FlxEase.quartInOut});
	}

	if (FlxG.mouse.wheel != 0)
		setItem(-1 * FlxG.mouse.wheel);
	for (item in menuItems) {
		if (item.animation.name == 'selected') {
			item.scale.set(0.55, 0.55);
			item.updateHitbox();
		} else {
			item.scale.set(0.7, 0.7);
			item.updateHitbox();
		}
		if (FlxG.mouse.justMoved && curSelected != item.ID && FlxG.mouse.overlaps(item) && canSelect && cursorMoving)
			setItem(item.ID, true);
	}
	buttonCamera.zoom = lerp(buttonCamera.zoom, desiredZoom, 0.05);
	camGame.zoom = lerp(camGame.zoom, desiredZoom, 0.05);
	if (canSelect && ((FlxG.mouse.overlaps(menuItems.members[curSelected]) && FlxG.mouse.justPressed) || controls.ACCEPT)) {
		if (!controls.ACCEPT) selectItem();
		canSelect = false;
		for (spr in menuItems) {
			if (spr.ID != curSelected) {
				FlxTween.tween(spr, {x: spr.x + 600}, 0.7, {ease: FlxEase.cubeIn});
				FlxTween.tween(backPanel, { alpha: 0 }, 0.7, {ease: FlxEase.cubeIn});
				FlxTween.tween(chino, { alpha: 0 }, 0.7, {ease: FlxEase.cubeIn});
				FlxTween.tween(versionText, { alpha: 0 }, 0.7, {ease: FlxEase.cubeIn});
				for (set in charSets.members) {
					for (char in set.members) {
						FlxTween.tween(char, { alpha: 0 }, 0.7, {ease: FlxEase.cubeIn});
					}
				}
			} else {
				var startPos = {x: spr.x, y: spr.y}
				//spr.scale.set(2, 2);
				spr.screenCenter();
				//spr.updateHitbox();
				var endPos = {x: spr.x, y: spr.y}
				spr.x = startPos.x;
				spr.y = startPos.y;
				FlxTween.tween(spr, {x: endPos.x, y: endPos.y }, 0.7, {ease: FlxEase.cubeOut});
				desiredZoom = 2;
				//FlxTween.tween(spr, {"scale.x": 2, "scale.y": 2 }, 0.7, {ease: FlxEase.cubeOut});
				//FlxTween.tween(spr.scale, {x: 2, y: 2}, 0.7, {ease: FlxEase.cubeOut});
				//spr.scale.x = 2;
			}
		}
	}
}

var didTheShit:Bool = false;

function postUpdate(elapsed:Float) {

	for (i in 0...offsetTimer.length)
		offsetTimer[i] = lerp(offsetTimer[i], 0, 0.1, true);
	for (item in menuItems) {
		var difference = ((FlxG.width - backPanel.width + 50) - backPanel.x);
		var perc = difference / -763.333333333333;
		item.offset.x = (difference) + menuItemsDefaultOffsets[item.ID].x + (offsetTimer[item.ID]) - (20 * item.ID);
	}
	backPanel.x = lerp(backPanel.x, FlxG.width - backPanel.width + 50, 0.1, true);
	if (backPanel.x < FlxG.width - backPanel.width + 51 && !didTheShit) {
		didTheShit = true;
		backPanel.playAnim('shine', true);
	}

	if (FlxG.keys.justPressed.F12) {
		trace("RAN THE SHIT");
		updateAlbum();
	}
	albumArt.setGraphicSize(albumBox.height-(albumBox.cornerSize)-15, albumBox.height-(albumBox.cornerSize)-15);
	albumArt.updateHitbox();

	albumArt.x = albumBox.box.x + (albumBox.cornerSize);
	albumArt.y = albumBox.box.y + (albumBox.cornerSize/2) + 15;

	albumNowPlaying.x = albumArt.x;
	albumNowPlaying.y = albumArt.y - 20;

	albumTitle.x = albumArt.x + 10 + albumArt.width;
	albumTitle.y = albumArt.y + 10;

	albumAuthor.x = albumArt.x + 10 + albumArt.width;
	albumAuthor.y = albumTitle.y + 20;


}

function setItem(move:Int, ?pureSelect:Bool) {
	curSelected = FlxMath.wrap((pureSelect ?? false) ? move : (curSelected + move), 0, menuItems.length - 1);

	CoolUtil.playMenuSFX(Paths.sound('scroll'), 0.7);

	for (spr in menuItems) {
		spr.animation.play('idle');

		if (spr.ID == curSelected) {
			spr.animation.play('selected');
			var mid:FlxPoint = spr.getGraphicMidpoint();
			camFollow.setPosition(mid.x, mid.y);
			mid.put();
		}

		spr.updateHitbox();
		spr.centerOffsets();
	}
}

function onSelectItem(event) {
	switch (event.name) {
		case 'gallery':
			FlxG.switchState(new ModState('GalleryMenuState'));
		case 'freeplay':
			event.cancelled = true;
			FlxG.switchState(new ModState('FreeplaySelectionState'));
	}
}
