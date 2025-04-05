import NovaAnimSystem.Animation;
import NovaAnimSystem.Frame;
import NovaAnimSystem.Keyframe;

function onEvent(event) {
	switch (event.event.name) {
		case 'Whitty Throws it Back':
			scripts.call('whenWhittyThrowsItBack');
            theShitToDo();
	}
}

function theShitToDo() {
    var slideAnim:Animation = new Animation();
    var char = strumLines.members[3].characters[0];
    var defaultScale = char.scale.x;
    var destinationOffX = 350;
    slideAnim.addKeyframe(new Keyframe(char, { x: char.x - 150, skew: { x: 15 } }));
    //slideAnim.addKeyframe(new Frame());
    //slideAnim.addKeyframe(new Frame());
    slideAnim.addKeyframe(new Keyframe(char, { x: dad.x + (destinationOffX + 50), skew: { x: 0 }, scale: { x: 2 } }));
    //slideAnim.addKeyframe(new Frame());
    //slideAnim.addKeyframe(new Frame());
    slideAnim.addKeyframe(new Keyframe(char, { x: dad.x + destinationOffX, scale: { x: defaultScale }, skew: { y: 5 } }));
    //slideAnim.addKeyframe(new Frame());
    //slideAnim.addKeyframe(new Frame());
    slideAnim.addKeyframe(new Keyframe(char, { x: dad.x + destinationOffX - 50, skew: { y: 0 } }));
    slideAnim.play();
}