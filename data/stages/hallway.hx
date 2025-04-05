import hxvlc.flixel.FlxVideoSprite;

var hallway = new FlxVideoSprite();

function postCreate() {
    addPreloadItem(()->{
        hallway.autoPause = true;
        hallway.load(Assets.getPath(StringTools.replace(Paths.image('stages/Vs Whitty/hallway/bg'), ".png", ".mp4")), [':no-audio']);
        hallway.bitmap.onEndReached.add(()->{
            hallway.bitmap.stop();
            hallway.bitmap.play();
        });
        hallway.play();
        hallway.scale.set(1920/1280, 1920/1280);
        hallway.updateHitbox();
        hallway.x = stage.getSprite("sample").x;
        hallway.y = stage.getSprite("sample").y;
        insert(members.indexOf(stage.getSprite("sample")), hallway);
        stage.getSprite("sample").visible = false;
    }, "Hallway Animated Background");
}

function postUpdate() {
    camGame.zoom = 1280/1920;
    if (curStep < 1) {
        boyfriend.playAnim("enter", true);
    }
}