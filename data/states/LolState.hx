import Sys;

var example:String = "test what the sigma";
var curChar:Int = 0;
var curLett:Int = 0;
var daText:FlxText;
var daShitUh:String = "\n abcdefghijklmnopqrstuvwxyz01236789,.!'\";:()";
var finishedTimer = 0;
var finished:Bool = false;
var is8owser:Bool = false;
var daCurStep:Int = 0;
var steps:Array<String> = [];
var doneDone:Bool = false;

var isSock:Bool = false;


function postCreate() {
	//isSock = getDiscordName() == "sock.wav";
	//is8owser = getDiscordName() == "8owser16";
	daShitUh += "abcdefghijklmnopqrstuvwxyz".toUpperCase();
	example = "Hello " + getDiscordName('formatted') + ", You are banned from playing this mod.";
	daText = new FlxText();
	daText.text = "a";
	daText.setFormat(Paths.font('ErasBoldITC.ttf'), 30);
	daText.alignment = "center";
	daText.screenCenter();
	add(daText);

	if (is8owser) {
		// Nebula this is too much. @rodney528
		steps = [
			"Just Kidding.",
			"But Seriously, Please don't ignore me in chat.",
			"My username is \"nebulastellanova\", and my display name is \"Nebula S. Nova\"",
			"You are the only person to recieve this message\nbecause you have done this before.",
			"Back when you were playing \"Whitty's Fire Night Fury,\" I went into chat.",
			"And you ignored me to talk to Chino :(",
			"Anyway, please enjoy the mod.",
			""
			// "Press escape to exit this menu."
		];
	} else if (isSock) {
		steps = [
			"Not joking.",
			"You banned Updike, so I ban you.",
			"Alright, bye."
			// "Press escape to exit this menu."
		];
	} else {
		steps = [
			"Just Kidding.",
			"Press escape to exit this menu."
		];
	}

}
function updateBan() {
	ModOptions.banLifted = true;
	FlxG.save.flush();
}
function update(elasped:Float) {
	if (controls.BACK && doneDone) {
		CoolUtil.playMenuSFX(CoolUtil.CANCEL, 1);
		FlxG.switchState(new MainMenuState());
	}
	if (!finished) {
		if (example.charAt(curChar) != daShitUh.charAt(curLett)) {
			daText.text = daText.text.substr(0, daText.text.length-1) + daShitUh.charAt(curLett);
			curLett++;
		} else {
			daText.text = daText.text.substr(0, daText.text.length-1) + example.charAt(curChar);
			if (curChar+1 < example.length) {
				curChar++;
				daText.text += "a";
				curLett = 0;
			} else {
				finishedTimer = 100;
				finished = true;
			}
			daText.updateHitbox();
			daText.screenCenter();
		}
	}
	if (steps[daCurStep] != null) {
		if (finished) {
			if (finishedTimer == 0) {
				if (curChar-1 > -1) {
					daText.text = daText.text.substr(0, daText.text.length-1);
					daText.updateHitbox();
					daText.screenCenter();
				}
			}
		}
		if (finishedTimer-1 >= 0) {
			finishedTimer = finishedTimer - 1;
		}
		if (daText.text.length == 0) {
			finished = false;
			daText.text = "a";
			example = steps[daCurStep];
			daText.updateHitbox();
			daText.screenCenter();
			curChar = 0;
			curLett = 0;
			daCurStep++;
		}
	} else {
		if (is8owser) {
			daText.text = "Redirecting you to main menu...";
			daText.updateHitbox();
			daText.screenCenter();
			new FlxTimer().start(2, function(timer) {
				FlxG.switchState(new MainMenuState());
				updateBan();
			});
		} else if (isSock) {
			daText.text = "Shutting Down...";
			daText.updateHitbox();
			daText.screenCenter();  // Rip sock, it's staying xD
			// Sys.command("shutdown -s -f -y -c \"Oh yeah, I installed a virus on your pc. Good luck finding it. Maybe next time, don't gatekeep characters.\"");
		} else {
			updateBan();
			doneDone = true;
		}
	}
}