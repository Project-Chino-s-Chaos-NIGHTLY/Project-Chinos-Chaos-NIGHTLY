public var lockedCam:Bool = (stage?.stageXML?.get('lockCamPos') ?? 'false') == 'true';
public var lockPos:FlxPoint = FlxPoint.get(stage?.stageXML?.get('startCamPosX'), stage?.stageXML?.get('startCamPosY'));
public var lockZoom = true;

function postCreate() {
	if (lockedCam) {
		camFollow.setPosition(lockPos.x, lockPos.y);
		FlxG.camera.snapToTarget();
		if (lockZoom)
			camGame.zoom = stage?.stageXML?.get('zoom') ?? defaultCamZoom;
	}
}

public function updateLock() {
	if (lockedCam) {
		camFollow.setPosition(lockPos.x, lockPos.y);
		FlxG.camera.snapToTarget();
		if (lockZoom)
			camGame.zoom = (stage?.stageXML?.get('zoom') ?? defaultCamZoom);
	}
}

// For "HScript Call" event.
function setCamLock(value:String)
	lockedCam = value == 'true';

// For "HScript Call" event.
public function setCamLockH(value:String)
	lockedCam = value == 'true';

function onCameraMove(event)
	if (lockedCam)
		event.position.set(lockPos.x, lockPos.y);