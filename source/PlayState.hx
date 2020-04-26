package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
    static inline var SHIP_SIZE:Int = 16;
    static inline var SHIP_Y_POS:Float = 0.90;
    static inline var SHIP_X_SPEED:Int = 500;
    static inline var SHIP_COLOR:FlxColor = FlxColor.WHITE;
    
    static inline var HOLE_MIN_WIDTH:Int = SHIP_SIZE * 3;
    static inline var HOLE_MAX_WIDTH:Int = SHIP_SIZE * 5;
    static inline var BARRIER_HEIGHT:Int = SHIP_SIZE;
    static inline var BARRIER_MIN_GAP:Int = SHIP_SIZE * 6;
    static inline var BARRIER_MAX_GAP:Int = SHIP_SIZE * 10;
    static inline var BARRIER_Y_SPEED:Int = 200;
    static inline var BARRIER_COLOR:FlxColor = FlxColor.GRAY;
    
    private var barrierEmit:FlxSignal;
    private var barrierEmitPosition:Int;
    private var scoreUI:FlxText;
    
    private var ship:FlxSprite;
    private var barriers:FlxTypedGroup<FlxTypedSpriteGroup<FlxSprite>>;
    private var score:Int = -1;
    
    override public function create() {
        super.create();
        
        // create ship
        ship = new FlxSprite(FlxG.width / 2, FlxG.height * SHIP_Y_POS);
        ship.makeGraphic(SHIP_SIZE, SHIP_SIZE, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawTriangle(ship, 0, 0, SHIP_SIZE, SHIP_COLOR);
        add(ship);
        
        // create barriers
        barriers = new FlxTypedGroup<FlxTypedSpriteGroup<FlxSprite>>();
        barrierEmit = new FlxSignal(); // create barrier emitter to create a new barrier row
        barrierEmit.add(emitBarrier); // set up callback
        emitBarrier(); // create the first row that descends
        add(barriers);
        
        // create UI
        scoreUI = new FlxText(0, SHIP_SIZE, -1, "", SHIP_SIZE);
        scoreUI.alignment = CENTER;
        add(scoreUI);
        updateScore();
    }
    
    override public function update(elapsed:Float) {
        super.update(elapsed); // game tick
        
        handleShipMovement(); // move the ship
        checkBarrierAlive(); // kill barriers that fall off the screen and increment score
        checkEmitBarrier(); // should we emit a barrier?
        
        FlxG.overlap(ship, barriers, gameOver);
    }
    
    private function gameOver(ship:FlxSprite, barrier:FlxTypedSpriteGroup<FlxSprite>) {
        FlxG.camera.fade(FlxColor.BLACK, 1, false, function() {
            FlxG.switchState(new GameOverState(score));
        });
    }
    
    private function updateScore() {
        score++; // increment the score
        scoreUI.text = Std.string(score); // update the text on screen
        scoreUI.screenCenter(FlxAxes.X); // center the text
    }
    
    private function handleShipMovement() {
        // control ship
        if (FlxG.keys.pressed.LEFT)
            ship.velocity.x = -SHIP_X_SPEED;
        else if (FlxG.keys.pressed.RIGHT)
            ship.velocity.x = SHIP_X_SPEED;
        else
            ship.velocity.x = 0;
        // wrap the x position on the screen edge
        FlxSpriteUtil.screenWrap(ship, true, true, false, false);
    }
    
    private function checkBarrierAlive() {
        // kill barriers that fall off the screen
        barriers.forEachAlive(function(barrier) {
            if (barrier.y >= FlxG.height) {
                updateScore(); // increment score
                barrier.destroy(); // destroy this barrier
            }
        });
    }
    
    private function checkEmitBarrier() {
        // should we emit a barrier?
        var newest = FlxG.height * 1.0;
        
        barriers.forEachAlive(function(barrier) {
            newest = Math.min(newest, barrier.y);
        });
        
        if (newest >= barrierEmitPosition)
            barrierEmit.dispatch();
    }
    
    private function createBarrierRow():FlxTypedSpriteGroup<FlxSprite> {
        var barrierRow = new FlxTypedSpriteGroup<FlxSprite>(2); // hold the whole row
        var holeWidth = FlxG.random.int(HOLE_MIN_WIDTH, HOLE_MAX_WIDTH); // width of the hole
        var holePosition:Int = FlxG.random.int(0, FlxG.width - holeWidth); // x position of the hole
        var barrierY:Float = -BARRIER_HEIGHT; // barrier should start above the screen
        barrierRow.y = barrierY; // set the entire row's position
        
        // left barrier
        var barrierLeft = new FlxSprite(0, barrierY);
        barrierLeft.makeGraphic(holePosition, BARRIER_HEIGHT, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawRect(barrierLeft, 0, 0, barrierLeft.width, BARRIER_HEIGHT, BARRIER_COLOR);
        
        // right barrier
        var barrierRight = new FlxSprite(barrierLeft.width + holeWidth, barrierY);
        barrierRight.makeGraphic(Std.int(FlxG.width - barrierRight.width), BARRIER_HEIGHT, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawRect(barrierRight, 0, 0, barrierRight.width, BARRIER_HEIGHT, BARRIER_COLOR);
        
        // add the two barriers to the row
        barrierRow.add(barrierLeft);
        barrierRow.add(barrierRight);
        
        // set up barrier movement
        barrierRow.velocity.y = BARRIER_Y_SPEED;
        
        return barrierRow;
    }
    
    private function emitBarrier() {
        // if (barriers.getFirstDead() !=)
        // emit a new barrier
        barriers.add(createBarrierRow());
        
        // set the position for this barrier when the next barrier will be emitted
        barrierEmitPosition = FlxG.random.int(BARRIER_MIN_GAP, BARRIER_MAX_GAP);
    }
}
