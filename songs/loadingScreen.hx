import flixel.addons.util.FlxAsyncLoop;
import flixel.math.FlxMatrix;
import flixel.text.FlxTextBorderStyle;
import flixel.ui.FlxBar;
import flixel.ui.FlxBarFillDirection;
import funkin.backend.system.framerate.Framerate;

class PreloadableItem {
	//public var beginFunction:Void->Void;
	public var daFunction:Void->Void;
	public var ID:String;
	public var isChar:Bool = false;

	public function new(begin:Void->Void, id:String, ?char:Bool = false) {
		daFunction = begin;
		ID = id ?? 'unknown';
		isChar = char ?? false;
	}
	public function beginFunction(grpFinished:Array) {
		daFunction();
		var finishedArray:Array = grpFinished;
		finishedArray.push("item");
		return finishedArray;
	}
}

public var _grpProgress:FlxGroup;
public var _grpFinished:Array = [];
public var _loopOne:FlxAsyncLoop;
public var preloadArray:Array<PreloadableItem> = [];
public var _bar:FlxBar;
public var _barBG:FlxSprite;
public var _barText:FlxText;
public var _barTextRight:FlxText;
public var _curLoadingItem:Int = 0;
public var _loadingCamera:FlxCamera;
public var _loadingCameraTweenActive:FlxTween = false;
public var _loadingTexts:Array<{text:String, link:Null<String>, ifPerson:Null<Dynamic<{text:String, link:Null<String>, addOn:Null<Bool>}>>}>;
public var finishedLoading:Bool = false;
public var _funFactText:FlxText;
public var _theFactText:FlxText;
public var _curFrames:Array<Array<Int>> = [];
public var _isFaded:Bool = false;

public var _curAssetIsChar:Bool = false;

public var _progressBindText:FlxText;
public var _progressBindTweenActive:Bool = false;
public var _currentAsset:String = 'unknown';
var loopPaused:Bool = false;
public var desiredValue:Float = 0.0;

// Loading Menu Assets
public var _loadingBox:FunkinSprite;
public var _loadingBar:FunkinSprite;

public function getMenuSprite(name) {
	return Paths.image("menus/loadingscreen/" + name);
}

public function addPreloadItem(begin:Void->Void, ?id:String, ?char:Bool) {
	preloadArray.push(new PreloadableItem(begin, id ?? 'unknown', char ?? false));
}

public function addItem() {
	if (!loopPaused) {
		desiredValue = (_grpFinished.length / preloadArray.length) * 100;
		_grpFinished = preloadArray[_curLoadingItem]?.beginFunction(_grpFinished) ?? _grpFinished;
		_currentAsset = preloadArray[_curLoadingItem]?.ID ?? _currentAsset;
		_curAssetIsChar = preloadArray[_curLoadingItem]?.isChar ?? false;

		_curLoadingItem++;

		loopPaused = true;
	}
}

introLength = 10;
function onCountdown(event) {
	event.cancel();
}
var canExit:Bool = false;
var allowPause:Bool = false;
var canOpenLink:Bool = false;
function update(elapsed) {
	if (!_loopOne.started) {} else {
		// if the loop has been started, and is finished, then we swich which groups are active
		if (Math.round(desiredValue) == 100 || Math.round(desiredValue) < 0) {
			_grpFinished.active = true;
			_grpProgress.active = false;

			// clean up our loop
			_loopOne.kill();
			_loopOne.destroy();

			_barText.text = 'Done!';
			_barTextRight.text = 'Loaded Successfully.';
			scripts.call('onLoaded', []);
			finishedLoading = true;
			FlxG.autoPause = Options.autoPause;
			if (!canOpenLink) {
				if (!_progressBindTweenActive) {
					FlxTween.tween(_progressBindText, {alpha: 1}, 0.5, {onComplete: (tween:FlxTween) -> _progressBindTweenActive = false});
					_progressBindTweenActive = true;
				}
			}
			if (canExit) {
				_progressBindText.text = 'Enjoy playing ' + SONG.meta.displayName + '!';
				if (!_loadingCameraTweenActive) {
					FlxTween.tween(_loadingCamera, {alpha: 0}, 0.2, {onComplete: (tween:FlxTween) -> _loadingCameraTweenActive = false});
					FlxTween.tween(camHUD, {alpha: 1}, 0.21, {onComplete: (t:FlxTween) -> scripts.call("onLoadedAccept")});
					_loadingCameraTweenActive = true;
					_isFaded = true;
				}
				allowPause = true;
				Framerate.offset.y = 0;
			}
		}
	}
	if (finishedLoading && canExit) scripts.call('updateLoaded', [elapsed]);
	else Conductor.songPosition = -1000;
	if (!canExit) {
		if (controls.BACK) {
			if (finishedLoading) canExit = true; else {
				if (canOpenLink) {
					_progressBindText.text = 'Link prevented, you can press [ACCEPT] to continue when done.';
					canOpenLink = false; // prevent after asked to stop
				}
			}
		}
		if (controls.ACCEPT) {
			if (canOpenLink) {
				CoolUtil.openURL(curLink);
				canOpenLink = false; // only allow once
				_progressBindText.text = 'Link opened, you can press [ACCEPT] to continue when done.';
			} else {
				if (finishedLoading)
					canExit = true;
			}
		}
	}
}

var nothingToLoad:FlxTween;
function postUpdate(elapsed:Float) {
	// prevent % being -289398749%
	var output:Int = Math.round(_bar.value) <= 0 ? 0 : Math.round(_bar.value);
	if (!finishedLoading) _barText.text = output + '%';
	if (preloadArray.length == 0 && !nothingToLoad?.active) _bar.value = 100;
	else if (Math.round(_bar.value) != Math.round(desiredValue))
		_bar.value = lerp(_bar.value, desiredValue, 0.1);
	else loopPaused = false;
	//_barText.y = _bar.y - 60;
	if (finishedLoading && canExit)
		scripts.call('postUpdateLoaded', [elapsed]);

	if (!finishedLoading) _barTextRight.text = _currentAsset == 'unknown' ? 'Getting Assets...' : ((_curAssetIsChar ? 'Character: ' : 'Asset: ') + _currentAsset);
	_barTextRight.y = _bar.y - 55;
	_barTextRight.updateHitbox();
	_barTextRight.x = _bar.x + _bar.width - _barTextRight.width;

	_progressBindText.x = FlxG.width - _progressBindText.width - 50;

	if (!finishedLoading && !canExit)
		for (strumLine in strumLines.members) {
			for (char in strumLine.characters) {
				char?.animation?.curAnim?.curFrame = 0;
			}
		}
}

function onGamePause(event) {
	if (!allowPause)
		event.cancelled = true;
}

function destroy() {
	FlxG.autoPause = Options.autoPause;
	Framerate.offset.y = 0;
}

public var _chosenText:{text:String, link:Null<String>, ifPerson:Null<Dynamic<{text:String, link:Null<String>, addOn:Null<Bool>}>>} = {
	text: '{UserName}',
	link: null,
	ifPerson: {
		"rodney528@nebulastellanova": {
			text: '\n{DisplayName} format to, {PersonName}!',
			link: 'link',
			addOn: true
		}
	}
}
public var _subChosenText:{text:String, link:Null<String>, addOn:Null<Bool>} = {
	text: '\n{DisplayName} format to, {PersonName}!',
	link: 'link',
	addOn: true
}
public var _chosenIndex:Int;
public var _awaitingInput:Bool = true;

var curLink:String = 'nolink';

function create() {
	_loadingCamera = new FlxCamera();
	_loadingCamera.bgColor = 0x55000000;

	_loadingBox = new FunkinSprite(-20, 0, getMenuSprite("loadingArea"));
	_loadingBox.cameras = [_loadingCamera];
	_loadingBox.antialiasing = true;

	_loadingBox.updateHitbox();
	_loadingBox.y = FlxG.height - _loadingBox.height + 40;
	add(_loadingBox);

	var _loadingBarFill = new FunkinSprite(0, 0, getMenuSprite("loadingBarFilled"));

	_loadingBar = new FunkinSprite(0, 0, getMenuSprite("loadingBar"));
	_loadingBar.cameras = [_loadingCamera];
	_loadingBar.antialiasing = true;
	_loadingBar.y = FlxG.height - _loadingBar.height - 50;
	_loadingBar.x = FlxG.width - _loadingBar.width - 50;
	add(_loadingBar);


	_loadingTexts = Json.parse(Assets.getText(Paths.json('config/funfacts')));
	_chosenText = _loadingTexts[_chosenIndex = FlxG.random.int(0, _loadingTexts.length - 1)];

	var resultText:String = _chosenText.text;
	if (Reflect.hasField(_chosenText, 'link')) {
		curLink = _chosenText.link;
		canOpenLink = true;
	} else allowPause = true;
	if (Reflect.hasField(_chosenText, 'ifPerson'))
		for (personTag in Reflect.fields(_chosenText.ifPerson))
			for (person in personTag.split('@'))
				if (StringTools.trim(person) == getDiscordName()) {
					_subChosenText = Reflect.field(_chosenText.ifPerson, personTag);
					var addOn:Bool = Reflect.hasField(_subChosenText, 'addOn') ? _subChosenText.addOn : false;
					resultText = addOn ? (_chosenText.text + _subChosenText.text) : _subChosenText?.text;
					if (Reflect.hasField(_subChosenText, 'link')) {
						curLink = _subChosenText.link;
						canOpenLink = true;
						allowPause = false;
					} else {
						allowPause = true;
						curLink = 'nolink';
					}
				}
	resultText = StringTools.replace(resultText, '{PersonName}', getDiscordName('formatted'));
	resultText = StringTools.replace(resultText, '{DisplayName}', getDiscordName('display'));
	resultText = StringTools.replace(resultText, '{UserName}', getDiscordName());

	_grpProgress = new FlxGroup();
	//_grpFinished = new FlxGroup(preloadArray.length);
	//_grpFinished.visible = false;
	//_grpFinished.active = false;

	_loopOne = new FlxAsyncLoop(1000000, addItem, 1);

	_barBG = new FlxSprite(50, 600).makeGraphic(1010, 30, FlxColor.BLACK);
	_barBG.screenCenter(FlxAxes.X);
	_barBG.cameras = [_loadingCamera];
	_barBG.visible = false;
	_grpProgress.add(_barBG);

	_bar = new FlxBar(_loadingBar.x, _loadingBar.y, FlxBarFillDirection.LEFT_TO_RIGHT, _loadingBar.width, _loadingBar.height, null, '', 0, 100, false);
	//_bar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.WHITE, false);
	_bar.createImageBar(_loadingBar.graphic, _loadingBarFill.graphic, FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);
	_bar.value = 0;
	//_bar.screenCenter(FlxAxes.X);
	_bar.cameras = [_loadingCamera];
	_grpProgress.add(_bar);


	// some text for the bar
	_barText = new FlxText(290, 625, FlxG.width, 'Loading... 0 / ' + preloadArray.length);
	_barText.setFormat(Paths.font('COOLINE.otf'), 80, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE);
	_barText.borderColor = FlxColor.BLACK;
	_barText.borderSize = 2;
	_barText.borderQuality = 10;
	_barText.antialiasing = true;
	_barText.cameras = [_loadingCamera];
	_grpProgress.add(_barText);

	_barTextRight = new FlxText(_bar.x, 540, FlxG.width, 'Current Asset: ');
	_barTextRight.setFormat(Paths.font('ErasBoldITC.ttf'), 40, FlxColor.WHITE, 'right', FlxTextBorderStyle.OUTLINE);
	_barTextRight.borderColor = FlxColor.BLACK;
	_barTextRight.borderSize = 2;
	_barTextRight.borderQuality = 10;
	_barTextRight.antialiasing = true;
	_barTextRight.cameras = [_loadingCamera];
	_grpProgress.add(_barTextRight);

	_funFactText = new FlxText(10, 10, null, 'FUN FACT!');
	_funFactText.setFormat(Paths.font('monofonto rg.otf'), 30, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE);
	_funFactText.borderColor = FlxColor.BLACK;
	_funFactText.borderSize = 2;
	_funFactText.borderQuality = 10;
	_funFactText.antialiasing = true;
	_funFactText.cameras = [_loadingCamera];
	//_funFactText.screenCenter(FlxAxes.X);
	_grpProgress.add(_funFactText);

	_theFactText = new FlxText(10, 45, FlxG.width - 10, resultText);
	_theFactText.setFormat(Paths.font('monofonto rg.otf'), 25, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE);
	_theFactText.borderColor = FlxColor.BLACK;
	_theFactText.borderSize = 2;
	_theFactText.borderQuality = 10;
	_theFactText.antialiasing = true;
	_theFactText.cameras = [_loadingCamera];
	//_theFactText.screenCenter();
	_grpProgress.add(_theFactText);

	_progressBindText = new FlxText(0, 675, null, !canOpenLink ? 'Press [ACCEPT] to continue.' : 'Press [BACK] to back out of opening the link.');
	_progressBindText.setFormat(Paths.font('ErasBoldITC.ttf'), 25, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE);
	_progressBindText.borderColor = FlxColor.BLACK;
	_progressBindText.borderSize = 2;
	_progressBindText.borderQuality = 10;
	_progressBindText.antialiasing = true;
	_progressBindText.alpha = 0;
	_progressBindText.cameras = [_loadingCamera];
	_grpProgress.add(_progressBindText);
	if (canOpenLink) {
		if (!_progressBindTweenActive) {
			FlxTween.tween(_progressBindText, {alpha: 1}, 0.5, {onComplete: (tween:FlxTween) -> _progressBindTweenActive = false});
			_progressBindTweenActive = true;
		}
	}

	// only our progress bar group should be getting draw() and update() called on it until the loop is done...
	_grpFinished.visible = false;
	_grpFinished.active = false;

	add(_grpProgress);
	//add(_grpFinished);

	// add our loop, so that it gets updated
	add(_loopOne);

	FlxG.autoPause = false;
	new FlxTimer().start(1, function(timer) {
		_loopOne.start();
	});
}

function postCreate() {
	camHUD.alpha = 0;
	FlxG.cameras.add(_loadingCamera, false);
	if (preloadArray.length == 0) nothingToLoad = FlxTween.tween(_bar, {value: 100}, 0.3);
	Framerate.offset.y = _theFactText.y + _theFactText.height * 2;
}

function onStrumCreation(event)
	event.__doAnimation = false;