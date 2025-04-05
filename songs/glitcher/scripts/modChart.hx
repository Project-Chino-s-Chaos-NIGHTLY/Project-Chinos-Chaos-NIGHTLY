import openfl.geom.Rectangle;
function stepHit() {
    return;
	if(curStep != 2) return;
	var image = new FlxSprite().loadGraphic(Paths.image("gallery/itsPicover"));
        // add(image);
    windowd = Application.current.createWindow({
        title:"live camera",
        width:307,
        height:278,
        borderless:true,
        alwaysOnTop:true,
        opacity:1
    });

    windowd.onClose.add(()->{ trace("Window Closed"); }, true);
    //var rect = new Rectangle(image.x, image.y, image.width, image.height);
    windowd.stage.color = FlxColor.TRANSPARENT;
    //image.scrollRect = rect;
    //image.x = 0;
    //image.y = 0;
    //reload();
    //windowd.stage.addChild(rect);

}
