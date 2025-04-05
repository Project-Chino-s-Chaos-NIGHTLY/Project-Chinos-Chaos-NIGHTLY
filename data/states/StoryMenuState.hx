import DropShadowShader;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;

var dropShadowShader:DropShadowShader = new DropShadowShader();

var backdrop:FlxBackdrop;
var gradient:FlxSprite;
var panel:FunkinSprite;
var charGroup:FlxGroup;
var assetY:Int = 570;
function create() {
    backdrop = new FlxBackdrop(Paths.image("menus/general/mainChecker"), FlxAxes.XY);
    backdrop.velocity.set(100, 100);
    backdrop.alpha = 0.8;
    backdrop.scale.set(50, 50);
    add(backdrop);
    gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.RED, FlxColor.BLUE], 1, 45);
    gradient.blend = 0;
    gradient.alpha = 0.5;
    add(gradient);

    panel = new FunkinSprite(0, 0, Paths.image("menus/storymenu/panel"));
    panel.screenCenter();
    add(panel);

    charGroup = new FlxGroup();
    add(charGroup);
}
function postCreate() {
    loadChars();

    dropShadowShader.set('divisions', 50);
    dropShadowShader.set('size', 10);
    dropShadowShader.set('strength', 3);

    tracklist.setFormat("Cambria", tracklist.size);
    tracklist.systemFont = "Cambria";
    tracklist.shader = dropShadowShader.get();


    weekTitle.setFormat("Cambria", weekTitle.size + 20, FlxColor.WHITE, 'center');
    weekTitle.systemFont = "Cambria";
    weekTitle.bold = true;
    weekTitle.alpha = 1;
    weekTitle.shader = dropShadowShader.get();
}
function loadChars() {
    for(i=>weekData in weeks) {
        if (weekData.chars != null) {
            var charName = weekData?.chars[0];
            var character = Json.parse(Assets.getText(Paths.json('weekchars/' + charName)));
            var daChar = new FunkinSprite(0, 0, Paths.image("weekchars/" + character.sprite));
            daChar.animation.addByPrefix("idle", character.animation, character.framerate, true);
            daChar.antialiasing = true;
            daChar.addOffset('idle', -character.offsets.x, -character.offsets.y);
            daChar.screenCenter(FlxAxes.X);
            daChar.scale.set(character.scale.x, character.scale.y);
            daChar.playAnim('idle', true);
            charGroup.add(daChar);
            trace(character);
        } else {
            charGroup.add(new FunkinSprite());
        }
        trace(weekData);
    }
}
function update() {
    changeWeek(controls.LEFT_P ? -1 : (controls.RIGHT_P ? 1 : 0));
}
function postUpdate() {
    scoreText.visible = false;
    weekTitle.screenCenter(FlxAxes.X);
    tracklist.screenCenter(FlxAxes.X);
    tracklist.y = weekTitle.y + weekTitle.height + 5;
    weekBG.visible = false;
    blackBar.visible = false;
    characterSprites.visible = false;
    for(e in difficultySprites) e.visible = false;

    for (i => weekSprite in weekSprites.members) {
        weekSprite.updateHitbox();
        weekSprite.y = assetY - (weekSprite.height/2);
        weekSprite.visible = i == curWeek;
        weekSprite.screenCenter(FlxAxes.X);
        //rightArrow.updateHitbox();
        rightArrow.centerOffsets();
        rightArrow.centerOrigin();
        //rightArrow.centerOrigin();
        rightArrow.y = assetY-(rightArrow.height/2);

        leftArrow.centerOffsets();
        leftArrow.centerOrigin();
        leftArrow.y = assetY-(leftArrow.height/2);
        charGroup.members[i].visible = i == curWeek;
    }
    rightArrow.x = panel.x + panel.width - rightArrow.width - 100;
    leftArrow.x = panel.x + 100;

    tracklist.text = "" + {[for(e in weeks[curWeek].songs) if (!e.hide) e.name.toUpperCase()].join('\n');}
}

function onChangeDifficulty(e) e.cancelled = true;

function onChangeWeek(e) {
    e.cancelled = controls.UP || controls.DOWN;
}