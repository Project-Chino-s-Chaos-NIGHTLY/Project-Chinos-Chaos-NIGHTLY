function onStartSong() {
    var tint = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    tint.cameras = [camHUD];
    tint.alpha = 0;
    tint.screenCenter();
    add(tint);
    var unfinishedText = new FlxText(0, 0, null,'Warning:\nThis Song is Unfinished.\nSorry.\n(Finished Version in v1.16 - v2.0)');
    unfinishedText.cameras = [camHUD];
    unfinishedText.alignment = 'center';
    unfinishedText.alpha = 0;
    unfinishedText.size = 40;
    unfinishedText.updateHitbox();
    unfinishedText.screenCenter();
    add(unfinishedText);
    FlxTween.tween(tint, {alpha: 0.75}, 0.5);
    FlxTween.tween(tint, {alpha: 0}, 0.5, {startDelay: 2});
    FlxTween.tween(unfinishedText, {alpha: 1}, 0.5);
    FlxTween.tween(unfinishedText, {alpha: 0}, 0.5, {startDelay: 2});
}