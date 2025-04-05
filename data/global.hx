import FunkinMouse;
import funkin.backend.scripting.Script;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.WindowUtils;
import funkin.editors.charter.Charter;

static var ModOptions:Dynamic = FlxG.save.data;
static var isDev:Bool = false;
static var stateChangeCount:Int = 0;
static var dontCheckMusic:Bool = false;

//static var mouseCursor:FunkinMouse;

static var currentCursorSkin:String = "base";

static function loadCursor(?fileName:String) {
	FlxG.mouse.useSystemCursor = false;
	FlxG.mouse.load(Paths.image("cui/" + (fileName ?? "base")));
	currentCursorSkin = fileName;
}

function new() {
	loadCursor(currentCursorSkin);
	getModVersion();
	/* Main */
		ModOptions.hideComboGroup = ModOptions.hideComboGroup ?? false;
		ModOptions.disableMechanics = ModOptions.disableMechanics ?? false;
		ModOptions.menuTrack = ModOptions.menuTrack ?? 'chaosMenu';
	/* Main */

	/* Extra */
		/* Lane Underlay */
			ModOptions.underlayOpacity = ModOptions.underlayOpacity ?? 0;
			ModOptions.laneTint = ModOptions.laneTint ?? false;
			ModOptions.responsiveLanes = ModOptions.responsiveLanes ?? false;
		/* Lane Underlay */
		ModOptions.noteSquish = ModOptions.noteSquish ?? false;
		ModOptions.comboNotes = ModOptions.comboNotes ?? false;
		ModOptions.glitcherModchart = ModOptions.glitcherModchart ?? false;
	/* Extra */

	/* Potato */
		ModOptions.basicGameplay = ModOptions.basicGameplay ?? false;
		ModOptions.ghostingDisabled = ModOptions.ghostingDisabled ?? false;
		ModOptions.playOgAnim = ModOptions.playOgAnim ?? false;
	/* Potato */

	/* Joke */
		ModOptions.wallOfHeads = ModOptions.wallOfHeads ?? false;
	/* Joke */

	var githubAccessors:Array<String> = [
		'nebulastellanova',
		'rodney528', 'rodneythesilly',
		'tsaku'
	];
	for (member in githubAccessors) {
		if (getDiscordName() == member) {
			isDev = true;
			break;
		}
	}
	if (!isDev)
		Framerate.debugMode = 0;

	//mouseCursor = new FunkinMouse();
}

function postStateSwitch() {
	WindowUtils.winTitle = 'Project: Chino\'s Chaos | v' + modVersion;
	if (stateChangeCount > 1 && !dontCheckMusic)
		playMenuSong(ModOptions.menuTrack);
	stateChangeCount++;
	DiscordUtil.changePresence('', 'Version: ' + modVersion);

	loadCursor(FlxG.sound.music.name == 'wiiSportsTheme' ? 'wii' : 'base');
	//mouseCursor.skin = FlxG.sound.music.name == 'wiiSportsTheme' ? 'wii' : 'base';
	//mouseCursor.reload();
	//if (!FlxG.state.members.contains(mouseCursor.sprite))
	//	FlxG.state.add(mouseCursor.sprite);
}

static function importClass(file:String, ?script:Script = null, ?fileAs:String):CustomClassHandler {
	file = 'data.scripts.classes.' + file;
	var hscript:Script = importScript(StringTools.replace(file, '.', '/'));
	if (hscript == null)
		return null;

	var split:Array<String> = file.split('.');
	var className:String = split[split.length - 1];

	var _class = hscript.interp.customClasses.get(className);

	if (script != null)
		script.interp.variables.set(fileAs ?? className, _class);

	return _class;
}

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.F12)
		playMenuSong('random', true, true);
	if (FlxG.keys.justPressed.F1)
		FlxG.switchState(new MainMenuState());

	//if (mouseCursor.sprite != null)
	//	mouseCursor.sprite.cameras = FlxG.cameras.list;
}

static var currentTrack:String = null; // Don't delete this again, you broke it last time.
var songList:Array<String> = [
	'chaosMenu',
	'galleryMenu',
	'starsInTheSky',
	'shyGuyFalls',
	'wiiSportsTheme',
	'stayFunky',
	'loFight',
	'freakyMenu',
	'thickOfIt',
	'festiveShowdown',
	'badPiggies',
	'shootingStars',
	'lastChristmas',
	'greenHillZone'
];
static function playMenuSong(file:String, ?fadeIn:Bool, ?passthrough:Bool) {
	if (PlayState.instance != null || Charter.instance != null)
		return;

	if (file == 'random')
		if (songList.indexOf(currentTrack) == -1 || passthrough)
			for (i in 0...1000)
				file = songList[FlxG.random.int(0, songList.length)];
		else
			file = currentTrack;

	if (FlxG.sound.music == null || currentTrack != file || FlxG.sound.music.name == null) {
		currentTrack = file ?? 'chaosMenu';
		CoolUtil.playMusic(Paths.music(currentTrack), true, (fadeIn ?? false) ? 0 : 1, true, 102);
		FlxG.sound.music.persist = true;
		if ((fadeIn ?? false))
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		FlxG.sound.music.name = file ?? 'chaosMenu';
	}
}

static function getDiscordName(?type:String) {
	return switch (type ?? 'user') {
		case 'user': DiscordUtil.user.username;
		case 'display': DiscordUtil.user.globalName;
		case 'formatted': switch (DiscordUtil.user.username) {
			case 'sock.wav': 'Sock.Clip';
			case '8owser16': '8owser';
			case 'uniquegeese': 'Geese';
			case 'shadow_mario': 'Shadow Mario';
			case 'rodney528' | 'rodneythesilly': 'Rodney';
			case 'atlasgamer27' | 'invisiblegrape16': 'Atlas';
			case 'nebulastellanova': 'Nebula';
			case 'vcherrykai16': 'Kacey';
			case 'chinosanimated': 'Chino';
			case 'spamtongspamton2137': 'Vegito';
			case 'jamvip': 'Jam';
			case 'higg399': 'Higg';
			case 'novikond': 'Novi';
			case 'theconcealedcow': 'Cow';
			case 'unholywanderer04': 'Unholy';
			case 'functionsilly' | 'sox1605': 'Sox';
			case 'thedogdousky_' | 'dexdousky2': 'Dede';
			case 'zyflixel': 'Zyflx';
			case 'shamrockdeveloper': 'Brayden';
			case '_gen.zu': '_gen.zu';
			case 'pixel_cloud15': 'Pixel';
			case 'wt12': 'Bob';
			case 'dopudioflp': 'Doppio';
			case 'SSF2008': 'Super';
			case 'astro_galaxy': 'Astro';
			case 'kittysleeper': 'Brandon';
			case '_novathefurry': 'Nova';
			case 'zerrvyx': 'Zerr';
			case 'okobo26': 'Seth';
			case 'sn0wenx': 'Snow';
			case 'catedmon': 'Cat';
			default: DiscordUtil.user.globalName;
		}
	}
}

static var modVersion = '';
static function getModVersion() {
	modVersion = Assets.getText('version.txt');
	modVersion = StringTools.replace(modVersion, '<br>', '\n');
	return modVersion;
}

static function getModFolder(suffix:String, hasPrefix:Bool = true)
	return StringTools.replace(Paths.getAssetsRoot(), './', (hasPrefix ?? true) ? './' : '') + '/' + suffix;



function destroy() {
	FlxG.mouse.useSystemCursor = true;
	FlxG.mouse.unload();
}