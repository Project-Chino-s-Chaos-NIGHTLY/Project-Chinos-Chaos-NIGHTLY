var dadDefIndex:Int;
var bofDefIndex:Int;

var defX = {dad: 0, bf: 0}

var noDodgeWhitelist = {dad: ['matt-glowin'], bf: ['bf-glowin']}

var dodgeSprite:FunkinSprite;

var mattCooking:FunkinSprite;
var bfCooking:FunkinSprite;

var curMatt:String = "matt-boxin";
var curBf:String = "bf-boxin";

var mattBlast:FunkinSprite;

var debugMode:Bool = false;

function getStagePath(file:String) {
	return "stages/Vs Matt/boxin/" + file;
}
function whack(whoToWhack:String, hit:Bool) {
    switch (whoToWhack) {
        case 'matt':
            // Will code
        case 'boyfriend':
            mattCooking.playAnim('fistYourMOM', true);
            changeCharacter(0, 'matt-glowin', 0, false);
            new FlxTimer().start(13/24, function() {
                var particle = new FunkinSprite().copyFrom(mattBlast);
                particle.playAnim(hit ? 'hit' : 'miss');
                add(particle);
                particle.animation.finishCallback = function() {
                    remove(particle);
                }
                if (hit) new FlxTimer().start(1/24, function() {
                    boyfriend.playAnim('bfBackshots', true);
                });
            });
    }
}
function postCreate() {
    dadDefIndex = members.indexOf(dad);
    bofDefIndex = members.indexOf(boyfriend);
    defX.dad = dad.x;
    defX.bf = boyfriend.x;

    addPreloadItem(()->{
        dodgeSprite = new FunkinSprite();
        dodgeSprite.frames = Paths.getSparrowAtlas(getStagePath("dodge"));
        dodgeSprite.animation.addByPrefix('dodge', 'dodge', 24, false);
        dodgeSprite.playAnim('dodge');
        dodgeSprite.antialiasing = true;
        dodgeSprite.x = boyfriend.x + 50;
        dodgeSprite.y = boyfriend.y - 200;
        dodgeSprite.scale.set(1.5, 1.5);
    }, "Dodge Popup");

    addPreloadItem(()->{
        mattBlast = new FunkinSprite();
        mattBlast.frames = Paths.getSparrowAtlas(getStagePath("blast"));
        mattBlast.animation.addByPrefix('hit', 'Hit', 24, false);
        mattBlast.animation.addByPrefix('miss', 'Miss', 24, false);
        mattBlast.x = boyfriend.x-450;
        mattBlast.y = boyfriend.y-50;
        //add(mattBlast);
    }, "Matt Glove Throw");

    addPreloadItem(()->{
        mattCooking = new FunkinSprite();
        mattCooking.frames = Paths.getSparrowAtlas("characters/matt/boxin");
        mattCooking.animation.addByPrefix('yourMOM', 'Matt GlowEyes Dance', 24, true);
        mattCooking.animation.addByPrefix('fistYourMOM', 'Matt Attack FistThrow', 24, false);
        mattCooking.animation.callback = function (name, frame, id) {
            if (name == "fistYourMOM" && frame == 0) {
                mattCooking.visible = true;
                new FlxTween().tween(mattCooking, { x: dad.x - 600 }, 11/24, { ease: FlxEase.sineOut, onComplete: function() {
                    new FlxTween().tween(mattCooking, { x: dad.x - 280 }, 10/24, { ease: FlxEase.sineIn, onComplete: function() {
                        changeCharacter(0, 'matt-boxin', 0, false);
                        mattCooking.visible = false;
                        mattCooking.x = dad.x - 230;
                    }});
                }});
            }
        }
        mattCooking.addOffset('fistYourMOM', -170, -257);
        mattCooking.playAnim('yourMOM');
        mattCooking.antialiasing = true;
        mattCooking.scale.set(1.1, 1.1);
        mattCooking.x = dad.x - 230;
        mattCooking.y = dad.y - 300;
        mattCooking.visible = false;
        add(mattCooking);
    }, "Matt Dancing");

    addPreloadItem(()->{
        bfCooking = new FunkinSprite();
        bfCooking.frames = Paths.getSparrowAtlas("characters/boyfriend/boxin");
        bfCooking.animation.addByPrefix('yourMOM', 'BF GlowEyes Dance', 24, true);
        bfCooking.playAnim('yourMOM');
        bfCooking.antialiasing = true;
        bfCooking.scale.set(1.1, 1.1);
        bfCooking.x = boyfriend.x - 180;
        bfCooking.y = boyfriend.y - 330;
        bfCooking.visible = false;
        add(bfCooking);
    }, "Boyfriend Dancing");
    //add(dodgeSprite);
}
function onOpponentHit(event) {
    if (event.noteType == "dodge note") {
        event.animCancelled = true;
        //var particle = new FunkinSprite().copyFrom(dodgeSprite);
        //particle.playAnim('dodge');
        //add(particle);
        if (event.direction == 0 || event.direction == 3) {
            dad.playAnim("parryDOWN", true);
        } else {
            dad.playAnim("parryUP", true);
        }
    }
    remove(dad);
    remove(boyfriend);
    insert(bofDefIndex, dad);
    insert(dadDefIndex, boyfriend);
    if (noDodgeWhitelist.dad.indexOf(dad.curCharacter) != -1) return;
    boyfriend.playAnim("block" + ["LEFT", "DOWN", "UP", "RIGHT"][event.direction], true);

    if (debugMode) return;
    var healthDrain = 0.02;
    if (health - healthDrain > 0) {
        health -= healthDrain;// Screw health drain
    } else {
        health = 0.01;
    }
}

function onPlayerHit(event) {
    if (event.noteType == "dodge note") {
        event.animCancelled = true;
        var particle = new FunkinSprite().copyFrom(dodgeSprite);
        particle.playAnim('dodge');
        add(particle);
        if (event.direction == 0 || event.direction == 3) {
            boyfriend.playAnim("dodgeDOWN", true);
        } else {
            boyfriend.playAnim("dodgeUP", true);
        }
    }
    remove(dad);
    remove(boyfriend);
    insert(dadDefIndex, dad);
    insert(bofDefIndex, boyfriend);
    if (noDodgeWhitelist.bf.indexOf(boyfriend.curCharacter) != -1) return;
    dad.playAnim("block" + ["LEFT", "DOWN", "UP", "RIGHT"][event.direction], true);
}

function postUpdate() {
    if (debugMode) {
        healthBar.visible = false;
        healthBarBG.visible = false;
        iconP1.visible = false;
        iconP2.visible = false;

        health = 1;
    }
    if (curMatt != dad.curCharacter) {
        curMatt = dad.curCharacter;
        if (mattCooking.animation.name != "fistYourMOM") {
            if (curMatt == "matt-glowin") {
                mattCooking.visible = true;
                mattCooking.playAnim('yourMOM', true);
                new FlxTween().tween(mattCooking, { x: dad.x - 600 }, 0.4, {ease: FlxEase.sineOut});
            } else if (curMatt == "matt-boxin") {
                mattCooking.visible = false;
            }
        }
    }
    if (curBf != boyfriend.curCharacter) {
        curBf = boyfriend.curCharacter;
        if (curBf == "bf-glowin") {
            bfCooking.visible = true;
            bfCooking.playAnim('yourMOM', true);
            new FlxTween().tween(bfCooking, { x: boyfriend.x + 210 }, 0.4, {ease: FlxEase.sineOut});
        } else if (curBf == "bf-boxin") {
            bfCooking.visible = false;
        }
    }
}


var steps = [
    890 => ()-> { new FlxTween().tween(mattCooking, { x: dad.x - 230 }, 0.4, {ease: FlxEase.sineIn}); }
    1018 => ()-> { new FlxTween().tween(bfCooking, { x: boyfriend.x - 180 }, 0.4, {ease: FlxEase.sineIn}); }
    1402 => ()-> { new FlxTween().tween(mattCooking, { x: dad.x - 230 }, 0.4, {ease: FlxEase.sineIn}); }
    1530 => ()-> { new FlxTween().tween(bfCooking, { x: boyfriend.x - 180 }, 0.4, {ease: FlxEase.sineIn}); }
    2170 => ()-> { new FlxTween().tween(mattCooking, { x: dad.x - 230 }, 0.4, {ease: FlxEase.sineIn}); }
    2298 => ()-> { new FlxTween().tween(bfCooking, { x: boyfriend.x - 180 }, 0.4, {ease: FlxEase.sineIn}); }

    1712 => ()-> { whack('boyfriend', true); }
    2480 => ()-> { whack('boyfriend', true); }
    2576 => ()-> { whack('boyfriend', true); }
    2608 => ()-> { whack('boyfriend', false); }
    2640 => ()-> { whack('boyfriend', true); }
    2672 => ()-> { whack('boyfriend', false); }
];
function stepHit() {
    (steps[curStep] ?? ()->{})();
}