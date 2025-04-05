import hxvlc.flixel.FlxVideoSprite;

var breaking = new FlxVideoSprite();

var currentStage = "static";

function postCreate() {
    addPreloadItem(()->{
        breaking.autoPause = true;
        breaking.load(Assets.getPath(StringTools.replace(Paths.image('stages/Vs Chara/999/bg/break'), ".png", ".mp4")), [':no-audio']);
        breaking.bitmap.onEndReached.add(()->{
            if (breaking.visible) {
                breaking.bitmap.stop();
                breaking.bitmap.play();
            }
        });
        breaking.play();
        breaking.scrollFactor.set(0, 0);
        breaking.x = stage.getSprite("shaking").x;
        breaking.y = stage.getSprite("shaking").y;
        insert(members.indexOf(stage.getSprite("shaking"))+1, breaking);
    }, "Breaking BG Sprite");
    boyfriend.scale.set(1.1, 1.1);
}
function postUpdate() {
    stage.getSprite("static").visible = currentStage == "static";
    stage.getSprite("shaking").visible = currentStage == "shaking";
    breaking.visible = currentStage == "breaking";

    stage.getSprite("shaking").x = stage.getSprite("static").x;
    stage.getSprite("shaking").y = stage.getSprite("static").y;
    breaking.x = stage.getSprite("static").x;
    breaking.y = stage.getSprite("static").y;
}

function changeStage(stageName:String) {
    currentStage = stageName.toLowerCase();
    if (stageName.toLowerCase() == "breaking") {
        breaking.bitmap.stop();
        breaking.bitmap.play();
    }
}