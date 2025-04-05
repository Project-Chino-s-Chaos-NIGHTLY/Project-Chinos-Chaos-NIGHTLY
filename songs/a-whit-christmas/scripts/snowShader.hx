import SnowShader;

var snowShader:SnowShader = new SnowShader();
var prevX:Float;
var prevY:Float;
function postCreate() {
    prevX = camGame.scroll.x;
    prevY = camGame.scroll.y;

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