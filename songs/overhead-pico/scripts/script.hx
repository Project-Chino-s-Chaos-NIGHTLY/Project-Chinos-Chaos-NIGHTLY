import BlurShader;
import BlurShaderWhite;
import GaussianBlur;
import RTXLighting;

var skipTime:Bool = false;
var time:Float = Conductor.crochet * 16 - (Conductor.stepCrochet / 2);
var blurShader:BlurShader = new BlurShader();
var blurShader2:BlurShaderWhite = new BlurShaderWhite();
var rtxShader:RTXLighting = new RTXLighting();
var gfShader:RTXLighting = new RTXLighting(); // for dark parts
var gfShadow:FunkinSprite;
var gaussianBlurShader:GaussianBlur = new GaussianBlur();

var innerGlowShaders = {
	bf: new RTXLighting(),
	gf: new RTXLighting(),
	dad: new RTXLighting(),
	notes: {
		dad: new RTXLighting(),
		bf: new RTXLighting()
	}
}

function postCreate() {
	lockedCam = false;

	// for (daShader in 0...4) {
	// var a = new RTXLighting();

	// boyfriend.shader = a.shader;
	// dad.shader = a.shader;

	gfShadow = gf.clone();
	gfShadow.visible = false;
	var gfIndex = members.indexOf(gf);
	insert(gfIndex, gfShadow);
}

function onChangeCharacter(oldChar:Character, newChar:Character, strumIndex:Int, memberIndex:Int, barUpdated:Bool) {
	if (Options.gameplayShaders) newChar.shader = oldChar.shader;
}

function onStartSong() {
	if (PlayState.isStoryMode) {
		skipTime = true;
	}
}

function postUpdate(elasped:Float) {
	// camHUD.bgColor = FlxColor.BLACK;
	if (skipTime && Conductor.songPosition <= time) {
		Conductor.songPosition = FlxG?.sound?.music?.time = time;
		vocals?.time = Conductor.songPosition + Conductor.songOffset;
		for (strumLine in strumLines.members)
			strumLine?.vocals?.time = vocals?.time;
	}

	gfShadow.x = gf.x + gf.getAnimOffset(gf.getAnimName()).x + gf.globalOffset.x + (gf.idleSuffix == '-left' ? 30 : -30);
	gfShadow.y = gf.y + gf.getAnimOffset(gf.getAnimName()).y + gf.globalOffset.y;
	gfShadow.frame = gf.frame;

	blurShader.setShaderVar("blur", "amount", 1.5);
	if (Options.gameplayShaders) gfShadow.shader = blurShader.shaderBlur;
	gfShadow.color = FlxColor.BLACK;
	gfShadow.alpha = 0.5;

	//trace(innerGlowShaders.dad.shader.innerShadowDistance);
	//trace(innerGlowShaders.bf.shader.innerShadowDistance);
}

public function setNoteShaders(whos:String, what:CustomShader) {
	switch (whos) {
		case "dad":
			for (strumLine in strumLines.members[0]) {
				if (Options.gameplayShaders) strumLine.shader = what;
			}
		case "boyfriend" | "bf":
			for (strumLine in strumLines.members[1]) {
				if (Options.gameplayShaders) strumLine.shader = what;
			}
		case "both" | "all":
			for (strumLine in strumLines.members[0]) {
				if (Options.gameplayShaders) strumLine.shader = what;
			}
			for (strumLine in strumLines.members[1]) {
				if (Options.gameplayShaders) strumLine.shader = what;
			}
	}
}
function doShit(values) {
	innerGlowShaders.notes.dad.values = values;
	innerGlowShaders.dad.values = values;
	innerGlowShaders.bf.values = values;
	innerGlowShaders.gf.values = values;
	innerGlowShaders.dad.updateShader();
	innerGlowShaders.bf.updateShader();
	innerGlowShaders.gf.updateShader();
}
public function setModeScript(mode:String) {
	switch (mode) {
		case "shrapnel":
			gfShadow.visible = true;
			doShit({
				overlay: {red: 0, green: 0, blue: 0, alpha: 0},
				satin: {red: 0, green: 0, blue: 0, alpha: 0.3},
				inner: {red: -255, green: -255, blue: -255, alpha: 0.1, angle: 90, distance: 15}
			});
			if (Options.gameplayShaders) {
				boyfriend.shader = innerGlowShaders.dad.shader;
				gf.shader = innerGlowShaders.gf.shader;
				dad.shader = innerGlowShaders.dad.shader;
				camHUD.addShader(innerGlowShaders.notes.dad.shader);
			}
			stage.getSprite("wall").alpha = 0.7;
			doGradientEvent({
				character: "both",
				visible: false
			});
			//setNoteShaders("both", innerGlowShaders.bf.shader);
		case "heated-dad" | "heated-dad-agro":
			gfShadow.visible = false;
			gf.shader = null;
			if (Options.gameplayShaders) dad.shader = innerGlowShaders.dad.shader;
			//innerGlowShaders.dad.shader.innerShadowAngle = (90.0) * (Math.PI / 180);
			//innerGlowShaders.dad.shader.innerShadowDistance = 30;
			innerGlowShaders.dad.setProfile("Heated Up");
			var defaultAlpha = innerGlowShaders.dad.values.inner.alpha;
			innerGlowShaders.dad.values.inner.angle = 90;
			innerGlowShaders.dad.values.inner.distance = 20;
			innerGlowShaders.dad.values.inner.alpha = 0;
			innerGlowShaders.dad.updateShader();
			FlxTween.tween(innerGlowShaders.dad.values.inner, { alpha: 0.05 }, 0.2, {
				onUpdate: function() {
					innerGlowShaders.dad.updateShader();
				}
			});
			innerGlowShaders.notes.dad.setProfile("Heated Up");
			innerGlowShaders.notes.dad.values.inner.angle = 90;
			innerGlowShaders.notes.dad.values.inner.distance = 20;
			innerGlowShaders.notes.dad.values.inner.alpha = 0;
			innerGlowShaders.notes.dad.updateShader();
			FlxTween.tween(innerGlowShaders.notes.dad.values.inner, { alpha: 0.05 }, 0.2, {
				onUpdate: function() {
					innerGlowShaders.notes.dad.updateShader();
				}
			});
			stage.getSprite("wall").alpha = 1;
			setNoteShaders("dad", innerGlowShaders.notes.dad.shader);
			doGradientEvent({
				character: "dad",
				visible: true
			});
		case "heated-bf" | "heated-bf-agro":
			gfShadow.visible = false;
			gf.shader = null;
			if (Options.gameplayShaders) boyfriend.shader = innerGlowShaders.bf.shader;
			innerGlowShaders.bf.setProfile("Heated Up");
			//innerGlowShaders.bf.shader.innerShadowAngle = (90.0) * (Math.PI / 180);
			//innerGlowShaders.bf.shader.innerShadowDistance = 30;
			var defaultAlpha = innerGlowShaders.bf.values.inner.alpha;
			innerGlowShaders.bf.values.inner.angle = 90;
			innerGlowShaders.bf.values.inner.distance = 10;
			innerGlowShaders.bf.values.inner.alpha = 0;
			innerGlowShaders.bf.updateShader();
			FlxTween.tween(innerGlowShaders.bf.values.inner, { alpha: 0.05 }, 0.2, {
				onUpdate: function() {
					innerGlowShaders.bf.updateShader();
				}
			});
			stage.getSprite("wall").alpha = 1;
			setNoteShaders("bf", innerGlowShaders.bf.shader);
		case "none":
			gfShadow.visible = false;
			gf.shader = null;
			boyfriend.shader = null;
			dad.shader = null;
			if (Options.gameplayShaders) camHUD.removeShader(innerGlowShaders.notes.dad.shader);
			stage.getSprite("wall").alpha = 1;
			setNoteShaders("both", null);
			doGradientEvent({
				character: "both",
				visible: false
			});
		case "none-fade":
			gfShadow.visible = false;
			gf.shader = null;
			boyfriend.shader = null;
			dad.shader = null;
			if (Options.gameplayShaders) camHUD.removeShader(innerGlowShaders.notes.dad.shader);
			stage.getSprite("wall").alpha = 1;
			setNoteShaders("both", null);
			doGradientEvent({
				character: "both",
				visible: false
			});
	}
}