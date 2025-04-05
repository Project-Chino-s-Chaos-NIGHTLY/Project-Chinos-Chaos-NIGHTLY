function create()
	FlxG.cameras.add(camera = cam = new FlxCamera(), false).bgColor = 0;

function destroy()
	if (FlxG.cameras.list.contains(cam))
		FlxG.cameras.remove(cam);