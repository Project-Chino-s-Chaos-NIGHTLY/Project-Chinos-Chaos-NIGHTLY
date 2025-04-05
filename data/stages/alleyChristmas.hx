import SnowShader;

var snowShader:SnowShader = new SnowShader();
var prevX:Float;
var prevY:Float;
function postCreate() {
    prevX = camGame.scroll.x;
    prevY = camGame.scroll.y;
    stage.getSprite("lightsTop").cameras = [camHUD];
    stage.getSprite("lightsTop").scale.set(0.65, 0.65);
    stage.getSprite("lightsTop").updateHitbox();
    stage.getSprite("lightsTop").screenCenter(FlxAxes.X);
    stage.getSprite("lightsTop").y -= 20;

    var lightsBottom = stage.getSprite("lightsTop").clone();
    lightsBottom.flipY = true;
    lightsBottom.cameras = [camHUD];
    lightsBottom.scale.set(0.65, 0.65);
    lightsBottom.updateHitbox();
    lightsBottom.screenCenter(FlxAxes.X);
    lightsBottom.y = FlxG.height-lightsBottom.height+20;
    insert(members.indexOf(stage.getSprite("lightsTop")), lightsBottom);

    camGame.addShader(snowShader.get());
}
var time:Float = 0.0;
var shaderSpeed:Float = 0.03;
var camSpeed:Array = [0, 0];
function update(elapsed) {
    time -= shaderSpeed;
    //trace(snowShader.get("time"));
    if (prevX != camGame.scroll.x) {
        camSpeed[0] = camGame.scroll.x - prevX;
    } else {
        camSpeed[0] = 0;
    }
    if (prevY != camGame.scroll.y) {
        camSpeed[1] = camGame.scroll.y - prevY;
    } else {
        camSpeed[1] = 0;
    }

    snowShader.set("time", time);
    snowShader.set("wind", camSpeed[0] * 0.00003);
    //snowShader.shader.MAX_DEPTH = 10;
}