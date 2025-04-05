import sys.FileSystem;
import sys.io.FileSeek;
import DropShadowShader;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;
import funkin.backend.utils.CoolUtil.CoolSfx;

var dropShadowShader:DropShadowShader = new DropShadowShader();
	dropShadowShader.set('divisions', 100);
	dropShadowShader.set('size', 30);
	dropShadowShader.set('strength', 1);

static var _freeplaySection:String;
static var _daSongList:Array<String>;
static var _curSelected:Int = 0;
static var _globalComingSoon:Bool = false;

var cards:FlxGroup;
var sectors:Array<String> = [];
var daWidth:Float = 0;
var daHeight:Float = 0;
var boxGroup:FlxGroup;

var camGame:FlxCamera;
var camSelected:FlxCamera;
var camHUD:FlxCamera;

var comingSoonGrp:FlxGroup = new FlxGroup();

var arrows:FlxGroup = new FlxGroup();

var newContentGroup:FlxGroup = new FlxGroup();


function create() {
	camGame = new FlxCamera();
	//camGame.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(camGame, true);
	camGame.zoom = 0.9;
	camSelected = new FlxCamera();
    camSelected.bgColor = FlxColor.TRANSPARENT;
	camSelected.addShader(dropShadowShader.get());
    FlxG.cameras.add(camSelected, false);
	camHUD = new FlxCamera();
    camHUD.bgColor = FlxColor.TRANSPARENT;
	camHUD.addShader(dropShadowShader.get());
    FlxG.cameras.add(camHUD, false);
	cards = new FlxGroup();

	var backdrop = new FlxBackdrop(Paths.image("menus/general/mainChecker"), FlxAxes.XY);
    backdrop.velocity.set(100, 100);
    backdrop.alpha = 0.8;
    backdrop.scale.set(50, 50);
	backdrop.scrollFactor.set();
    add(backdrop);
	//backDrop.cameras = [backDropCamera];
	//backDrop.origin.set(FlxG.width / 2, FlxG.height / 2);
	//add(backDrop);
	var gradient = FlxGradient.createGradientFlxSprite(FlxG.width/camGame.zoom, FlxG.height/camGame.zoom, [FlxColor.RED, FlxColor.BLUE], 1, 45);
    gradient.blend = 0;
    gradient.alpha = 0.5;
	gradient.scrollFactor.set();
	gradient.screenCenter();
    add(gradient);

	sectors = Json.parse(Assets.getText(Paths.json('config/freeplaySectors')));
	//trace(sectors);
	var daFolder = Paths.getFolderContent("images/menus/freeplayselection/");
	for (file in daFolder) {
		daFolder[daFolder.indexOf(file)] = StringTools.replace(file, ".png", "");
	}
	//trace(daFolder);
	var i = 0;
	var padding = 10;
	for (sector in sectors) {
		var cardName = sector.iCard; // cards.members[i-1] == null ? 0 : (cards.members[i-1].width*i)
		var card = new FunkinSprite((daWidth+(padding))*i, (padding/1.5), Paths.image("menus/freeplayselection/" + (daFolder.contains(cardName) ? cardName : "unknown")));
		if (!daFolder.contains(cardName)) trace("Could not find \"" + cardName + ".png\" in \"images\\menus\\freeplayselection\\\"");
		card.scale.set((card.height-(padding*2))/FlxG.width, (card.height-(padding*2))/FlxG.width);
		card.antialiasing = true;
		card.updateHitbox();
		if (daWidth == 0) {
			daWidth = card.width;
		}
		if (daHeight == 0) {
			daHeight = card.height;
		}
		cards.add(card);

		var newContent = new FunkinSprite(card.x + (card.width/2), card.y).loadGraphic(Paths.image('menus/freeplayselection/NEW_CONTENT'));
		newContent.cameras = [camGame];
		newContent.scale.set(0.3, 0.3);
		newContent.updateHitbox();
		newContent.x -= newContent.width/2;
		newContentGroup.add(newContent);
		//trace(cardName);
		i++;
	}
	var selectionBox = new FlxGroup();

	var line = new FlxSprite(0, 0).makeGraphic(daWidth+(padding*2), (padding*2), FlxColor.WHITE);
	line.scrollFactor.set(0, 0);
	line.screenCenter(FlxAxes.X);
	selectionBox.add(line);


	var line = new FlxSprite(line.x, 0).makeGraphic((padding*2), daHeight+padding, FlxColor.WHITE);
	line.scrollFactor.set(0, 0);
	var daStart:Int = line.x;
	//line.screenCenter(FlxAxes.X);
	selectionBox.add(line);

	var line = new FlxSprite(0, FlxG.height - (padding*2)).makeGraphic(daWidth+(padding*2), (padding*2), FlxColor.WHITE);
	line.scrollFactor.set(0, 0);
	line.screenCenter(FlxAxes.X);
	selectionBox.add(line);

	var line = new FlxSprite(line.x + daWidth, 0).makeGraphic((padding*2), daHeight+padding, FlxColor.WHITE);
	line.scrollFactor.set(0, 0);
	//line.screenCenter(FlxAxes.X);
	selectionBox.add(line);

	var arrow = new FunkinSprite(0, 0, Paths.image("menus/general/whiteArrow"));
	arrow.animation.addByPrefix("press", "Press", 24, false);
	arrow.animation.addByPrefix("idle", "Static", 24, false);
	arrow.scale.set(0.5, 0.5);
	arrow.playAnim('idle', true);
	arrow.flipX = true;
	arrow.antialiasing = true;
	arrow.scrollFactor.set(0, 0);
	arrow.updateHitbox();
	arrow.x = daStart - (padding*2) - arrow.width;
	arrow.screenCenter(FlxAxes.Y);
	arrow.centerOrigin();
	arrow.centerOffsets();
	arrows.add(arrow);

	var arrow = new FunkinSprite(0, 0, Paths.image("menus/general/whiteArrow"));
	arrow.animation.addByPrefix("press", "Press", 24, false);
	arrow.animation.addByPrefix("idle", "Static", 24, false);
	arrow.scale.set(0.5, 0.5);
	arrow.playAnim('idle', true);
	arrow.antialiasing = true;
	arrow.scrollFactor.set(0, 0);
	arrow.updateHitbox();
	arrow.x = line.x + (padding*4);
	arrow.screenCenter(FlxAxes.Y);
	arrow.centerOrigin();
	arrow.centerOffsets();
	arrows.add(arrow);

	add(cards);
	add(newContentGroup);
	add(arrows);
	add(selectionBox);
	changeSelection(0);

	for (member in selectionBox.members) {
		member.cameras = [camHUD];
	}
	for (member in arrows.members) {
		member.cameras = [camHUD];
	}
	selectionBox.visible = false;

	var tint = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	tint.alpha = 0.5;
	tint.screenCenter();
	tint.scrollFactor.set(0, 0);
	tint.cameras = [camSelected];
	comingSoonGrp.add(tint);

	var comingSoonText:FlxText = new FlxText(0, 0, FlxG.width);
	comingSoonText.setFormat(Paths.font('ErasBoldITC.ttf'), 100, FlxColor.WHITE, 'center');
	comingSoonText.updateHitbox();
	comingSoonText.screenCenter();
	comingSoonText.text = "Coming Soon!";
	comingSoonText.scrollFactor.set(0, 0);
	comingSoonText.cameras = [camSelected];
	comingSoonGrp.add(comingSoonText);

	// comingSoonGrp.scrollFactor.set(0, 0);

	comingSoonGrp.visible = false;
	add(comingSoonGrp);
	//cards.screenCenter(FlxAxes.Y);
}
var dontUpdateArrows = false;
function onPress() {
	if (FlxG.mouse.overlaps(arrows.members[0])) {
		dontUpdateArrows = true;
		arrows.members[0].playAnim("press");
		changeSelection(-1);
	}
	if (FlxG.mouse.overlaps(arrows.members[1])) {
		dontUpdateArrows = true;
		arrows.members[1].playAnim("press");
		changeSelection(1);
	}
	//remove(hitBox1);
}

function onRelease() {
	if (arrows.members[0].animation.name == "press") {
		dontUpdateArrows = false;
		arrows.members[0].playAnim("idle");
	}
	if (arrows.members[1].animation.name == "press") {
		dontUpdateArrows = false;
		arrows.members[1].playAnim("idle");
	}
}
function postUpdate(elapsed:Float) {
	for (i=>member in newContentGroup.members) {
		member.cameras = cards.members[i].cameras;
		member.visible = sectors[i].hasNewContent;
	}
	//FlxG.switchState(new FreeplayState());
	if (controls.BACK) {
		FlxG.switchState(new MainMenuState());
	}

	if (!dontUpdateArrows) {
		arrows.members[0].playAnim(controls.LEFT_P ? "press" : (!controls.LEFT ? "idle" : ""));
		arrows.members[1].playAnim(controls.RIGHT_P ? "press" : (!controls.RIGHT ? "idle" : ""));
	}
	FlxG.mouse.justPressed ? onPress() : 0;
	FlxG.mouse.justReleased ? onRelease() : 0;

	arrows.members[0].centerOffsets();
	arrows.members[0].centerOrigin();
	arrows.members[1].centerOffsets();
	arrows.members[1].centerOrigin();

	arrows.members[0].visible = !comingSoonGrp.visible;
	arrows.members[1].visible = !comingSoonGrp.visible;
	//arrows.members[0].screenCenter(FlxAxes.Y);
	//arrows.members[1].updateHitbox();
	//arrows.members[1].screenCenter(FlxAxes.Y);


	//}
	if (controls.LEFT_P) {
		//if (_curSelected - 1 < 0)
		//	textCamera.scroll.x += 1280 * grpSongs.members.length;
		changeSelection(-1);
		//checkForPico();
	} else if (controls.RIGHT_P) {
		//if (_curSelected + 1 > grpSongs.members.length - 1)
		//	textCamera.scroll.x -= 1280 * grpSongs.members.length;
		changeSelection(1);
		//checkForPico();
	}
	camGame.scroll.x = lerp(camGame.scroll.x, cards.members[_curSelected].x - (1280/2) + (cards.members[_curSelected].width/2), 0.2);
	if (controls.ACCEPT) {// || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(arrows.members[0]) && !FlxG.mouse.overlaps(arrows.members[1]) )) {
		selectSector();
	}
	camSelected.scroll = camGame.scroll;
	for (index => card in cards.members) {
		card.color = index == _curSelected ? FlxColor.WHITE : 0xFF888888;
		card.cameras = index == _curSelected ? [camSelected] : [camGame];
		if (index == _curSelected) {
			//card.screenCenter();
		}
	}

	camGame.zoom = lerp(camGame.zoom, 0.9, 0.1);
	camSelected.zoom = lerp(camSelected.zoom, 1, 0.2);

}

function selectSector() {
	if (sectors[_curSelected].locked) {
		CoolUtil.playMenuSFX(2, 1);
		comingSoonGrp.members[1].text = sectors[_curSelected].lockMessage;
		comingSoonGrp.visible = true;
		new FlxTimer().start(0.3, (timer)->{
			comingSoonGrp.visible = false;
		});
	} else {
		_daSongList = sectors[_curSelected].songs;
		_globalComingSoon = sectors[_curSelected].comingSoon;
		_freeplaySection = sectors[_curSelected].iCard;
		FlxG.switchState(new FreeplayState());
	}
}

function changeSelection(dir:Int) {
	camSelected.zoom = camGame.zoom;
	if (_curSelected + dir > cards.length -1) {
		_curSelected = 0;
	} else if (_curSelected + dir < 0) {
		_curSelected = cards.length -1;
	} else {
		_curSelected += dir;
	}
	if (dir != 0) {
		CoolUtil.playMenuSFX(CoolSfx.SELECT, 1);
	}
	trace(_curSelected);
}
function beatHit() {
	camGame.zoom = 0.95;
}