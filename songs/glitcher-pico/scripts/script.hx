import RTXLighting;

var interval:Int = 12;
var doBeat:Bool = false;

function postCreate() {
    var rtxShader:RTXLighting = new RTXLighting();
    rtxShader.setProfile('Hex Fight Stage');
    boyfriend.shader = rtxShader.shader;
    gf.shader = rtxShader.shader;
    camGame.visible = false;

	addPreloadItem(function() {
		var preloadSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image("stages/Vs Hex/detected/hexBackAU"));
	}, 'AU Stage Back');

	addPreloadItem(function() {
		var preloadSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image("stages/Vs Hex/detected/hexFrontAU"));
	}, 'AU Stage Front');

    stage.getSprite("speakerBop").visible = false;

}
function update() {
    camGame.zoom = lerp(camGame.zoom, 0.6, 0.1);
}
function onStartSong() {
    camGame.visible = true;
    camGame.flash(FlxColor.BLACK, 5.35, null, true);
}

var steps = [
	64 => ()-> {
		camGame.flash(null, 0.5, null, true);
	}
    320 => ()-> {
        interval = 8;
        doBeat = true;
    }
    448 => ()-> { interval = 4; }
    512 => ()-> { interval = 2; }
    544 => ()-> { interval = 1; }
    560 => ()-> { doBeat = false; }
    576 => ()-> {
        toggleStage();
        interval = 4;
        doBeat = true;
    }
    832 => ()-> { toggleStage(); }
];
function stepHit() {
    (steps[curStep] ?? ()->{})();
    if (doBeat) {
        if (curStep % interval == 0)
            camGame.zoom += 0.05;
    }
}


var isToggled:Bool = false;
function toggleStage() {
	isToggled = !isToggled;
	camGame.flash(null, null, null, true);
	stage.getSprite("wall").loadGraphic(Paths.image("stages/Vs Hex/detected/hexBack" + (isToggled ? "AU" : "")));
	stage.getSprite("ground").loadGraphic(Paths.image("stages/Vs Hex/detected/hexFront" + (isToggled ? "AU" : "")));
	stage.getSprite("walkway").visible = !isToggled;
	stage.getSprite("caLogo").visible = !isToggled;
	stage.getSprite("crowd").visible = !isToggled;
	stage.getSprite("speakerBopBehind").visible = !isToggled;
	gf.visible = !isToggled;
}