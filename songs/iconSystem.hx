import CharIcon;

public var oppoIcon:CharIcon;
public var playIcon:CharIcon;

function postCreate() {
	oppoIcon = new CharIcon(iconP2.curCharacter, iconP2);
	playIcon = new CharIcon(iconP1.curCharacter, iconP1, true);
}

function onChangeCharacter(oldChar:Character, newChar:Character, strumIndex:Int, memberIndex:Int, barUpdated:Bool) {
	if (barUpdated && memberIndex == 0) {
		if (strumIndex == 0) {
			oppoIcon.setIcon();
		} else if (strumIndex == 1) {
			playIcon.setIcon();
		}
	}
}

function postUpdate(elasped:Float) {
	if (health <= 0.2 && playIcon.curAnim != "1") {
		playIcon.playAnim(1, true);
		playIcon.curAnim = "1";
	}
	if (health >= 1.8 && playIcon.curAnim != "2") {
		playIcon.playAnim(2, true);
		playIcon.curAnim = "2";
	}
	if ((health < 1.8 && health > 0.2) && playIcon.curAnim != "0") {
		playIcon.playAnim(0, true);
		playIcon.curAnim = "0";
	}
}