package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class GameOverState extends FlxState {
    private var score:Int;
    
    public function new(s:Int) {
        super();
        score = s;
    }
    
    override public function create() {
        var scoreText = new FlxText(0, 0, -1, "Score: " + score, 32);
        scoreText.alignment = CENTER;
        scoreText.screenCenter();
        add(scoreText);
        
        super.create();
    }
    
    override public function update(elapsed:Float) {
        if (FlxG.keys.pressed.ANY) {
            FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() {
                FlxG.switchState(new PlayState());
            });
        }
    }
}
