import sys.io.FileSeek;
import funkin.backend.utils.CoolUtil.CoolSfx;
class SymbolTypes {
	public var GRAPHIC = 'graphic';
	public var MOVIECLIP = 'movie';
	public var VIDEO = 'video';
}

class Symbol {
	public var type:String;
	public var title:String;
	public var description:String;
	public var image:String;
	public var hitbox:FlxSprite;

	public function new(Type:String, Title:String, Description:String, Image:String) {
		this.type = Type;
		this.title = Title;
		this.image = Image;
		this.description = Description;
		this.hitbox = new FlxSprite(0, 0).makeGraphic(202, 22);
	}
}

var GalleryPaths = {
	rootGalleryImage: function(where:String) {
		return Paths.image('menus/gallerymenu/' + where);
	},
	galleryImage: function(where:String) {
		return Paths.image('gallery/' + where);
	}
}

var bg:FlxSprite;
var symbols:FlxTypedGroup = new FlxTypedGroup();
var scaleFactor:Float = 1280 / 1920;
var imageSlot:FlxSprite;
var curSelected:Int = -1;
var description:FlxText;
var titleBG:FlxSprite;
var title:FlxText;

function create() {
	dontCheckMusic = true;
}
function postCreate() {
	window.borderless = true;

	CoolUtil.playMusic(Paths.music("galleryMenu"), false, 0);
	var data = [];
	//data = data.concat(Paths.getFolderContent("images/gallery/", true));
	data = data.concat(Paths.getFolderContent("images/gallery/"));
	trace(data);
	for (i in 0...data.length) {
		var fileName = data[i];
		if (StringTools.endsWith(fileName, '.png')) {
			fileName = StringTools.replace(fileName, '.png', '');
			var jsonShit = Json.parse(Assets.getText(Paths.getPath("images/gallery/" + fileName + ".json")));
			symbols.add(new Symbol(SymbolTypes.GRAPHIC, jsonShit.title, jsonShit.description, fileName));
			trace(jsonShit);
		}
	}
	//symbols.add(new Symbol(SymbolTypes.GRAPHIC, 'Beta Menu', 'Original main menu from the demo.', 'betaMenu'));
	//symbols.add(new Symbol(SymbolTypes.GRAPHIC, 'Cover Art', 'Official cover art, drawn by Astro Galaxy', 'coverArt'));
	//symbols.add(new Symbol(SymbolTypes.GRAPHIC, '???', 'Secret? You tell me.', 'uhhhh'));
	//symbols.add(new Symbol(SymbolTypes.GRAPHIC, 'It\' Picover.', 'It\'s Picover', 'itsPicover'));
	// symbols.add(new Symbol(SymbolTypes.GRAPHIC, 'Beta Menu2', 'betaMenu'));
	bg = new FlxSprite(0, 0);
	bg.loadGraphic(GalleryPaths.rootGalleryImage('background'));
	bg.scale.set(scaleFactor, scaleFactor);
	bg.screenCenter();
	bg.antialiasing = true;
	add(bg);

	imageSlot = new FlxSprite(300, 300).loadGraphic(GalleryPaths.rootGalleryImage('click'));
	imageSlot.antialiasing = true;
	add(imageSlot);
	description = new FlxText(0, 0, 500, '');
	description.setFormat(Paths.font('ErasBoldITC.ttf'), 30);
	description.alignment = 'center';
	description.antialiasing = true;
	add(description);

	title = new FlxText(115, 42.5, null, '');
	title.setFormat(Paths.font('SourceCodePro-Regular.ttf'), 10);
	title.letterSpacing = 0.8;
	title.alignment = 'center';
	title.antialiasing = true;
	titleBG = new FlxSprite(115, 42).makeGraphic(10, 15, 0xFF292929);
	add(titleBG);
	add(title);

	for (symbol in symbols) {
		var i = symbols.members.indexOf(symbol);
		symbol.hitbox.x = 1050;
		symbol.hitbox.y = 193 + (symbol.hitbox.height * i);
		var graphicSymbol = new FlxSprite(symbol.hitbox.x + 10, symbol.hitbox.y + 2).loadGraphic(GalleryPaths.rootGalleryImage('graphic'));
		graphicSymbol.scale.set(scaleFactor, scaleFactor);
		graphicSymbol.antialiasing = true;
		add(symbol.hitbox);
		add(graphicSymbol);
		var label = new FlxText(graphicSymbol.x + graphicSymbol.width + 2, graphicSymbol.y + 3, null, symbol.title);
		label.setFormat(Paths.font('SourceCodePro-Regular.ttf'), 10);
		label.antialiasing = true;
		add(label);
	}
}

function postUpdate(elapsed:Float) {
	if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.6) {
		FlxG.sound.music.volume += 0.5*elapsed;
	}
	if (controls.BACK) {
		CoolUtil.playMenuSFX(2, 1);
		FlxG.switchState(new MainMenuState());
	}
	for (symbol in symbols) {
		var i = symbols.members.indexOf(symbol);
		if (FlxG.mouse.overlaps(symbol.hitbox)) {
			if (FlxG.mouse.justPressed) {
				curSelected = i;
				CoolUtil.playMenuSFX(CoolSfx.SELECT, 1);
				imageSlot.loadGraphic(GalleryPaths.galleryImage(symbol.image));
				imageSlot.screenCenter();
				imageSlot.antialiasing = true;
				description.text = symbol.description;
				if (imageSlot.width > imageSlot.height)
					imageSlot.scale.set(641 / imageSlot.width, 641 / imageSlot.width);
				else
					imageSlot.scale.set(361 / imageSlot.height, 361 / imageSlot.height);
				imageSlot.x -= 100;
				if (description.text != '') imageSlot.y -= 10 + 40;
			}
			symbol.hitbox.alpha = 0.1;
		} else {
			symbol.hitbox.alpha = 0;
		}
	}
	description.updateHitbox();
	description.screenCenter();
	description.x -= 100;
	description.y = FlxG.height - 150 - 40;

	if (curSelected != -1) {
		title.text = symbols.members[curSelected].title;
		titleBG.makeGraphic(title.width, 16, 0xFF292929);
	}
}

function destroy() {
	window.borderless = false;
	dontCheckMusic = false;
}