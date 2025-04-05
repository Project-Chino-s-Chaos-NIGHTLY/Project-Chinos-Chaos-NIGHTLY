function getVisualsPath(file:String) { return "stages/Vs Chara/999/visuals/" + file; }          // Return the stage's "visuals" folder path with file name.
function getBGPath(file:String) { return "stages/Vs Chara/999/bg/" + file; }                    // Return the stage's "bg" folder path with file name.

/* -- Integers -- */
var currentDialogue:Int = 0;                                                                    // Index of current dialogue.

/* -- FlxSprites -- */
var startFrame:FlxSprite;                                                                       // Image with the heart that fades out.
var dialogue:FlxSprite;                                                                         // Dialogue animated sprite.

function postCreate() {
    /* -- Create, Process, and add Start Frame -- */
    startFrame = new FlxSprite(0, 0).loadGraphic(Paths.image(getVisualsPath("startFrame")));    // Initialize image for start frame.
    startFrame.cameras = [camHUD];                                                              // Set start frame camera to the HUD/UI camera.
    startFrame.setGraphicSize(FlxG.width, FlxG.height);                                         // Set start frame width and height to the camera width and height.
    add(startFrame);                                                                            // Add start frame to scene/state.
    
    /* -- Create, Process, and add Dialogue -- */
    addPreloadItem(function() {
        dialogue = new FlxSprite();
        dialogue.frames = Paths.getSparrowAtlas(getVisualsPath('dialogue'));
        for (i in 1...13) {
		    dialogue.animation.addByPrefix(i + "", 'Dialogue ' + i + " FIX", 24, false);
        }
        dialogue.animation.finishCallback = function(anim) {
            dialogue.visible = false;
        }
        dialogue.cameras = [camHUD];
        //dialogue.scale.set(FlxG.width/1920, FlxG.width/1920);
        dialogue.visible = false;
        dialogue.y = 40;
        dialogue.screenCenter(FlxAxes.X);
        add(dialogue);
    }, "Dialogues");
}

var dialogueTimings = [4, 32, 72, 168, 216, 400, 478, 1023, 1232, 1316, 1947, 2244];

var steps = [
    -1 => ()-> {
        FlxTween.tween(startFrame, {alpha: 0}, 0.5);                                            // Fade out start frame.
    }
];
function stepHit() { 
    (steps[curStep] ?? ()->{})();                                                               // Run functions on respective steps.
    for (step in dialogueTimings) {
        if (curStep == step) {
            advanceDialogue(step);
        }
    }
}

function advanceDialogue(step:Int) {                                                            // Trigger next dialogue.
    currentDialogue = dialogueTimings.indexOf(step)+1;
    dialogue.animation.play(currentDialogue + "", true);
    dialogue.visible = true;
}