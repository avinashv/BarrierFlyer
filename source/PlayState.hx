package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
    static inline var SHIP_SIZE:Int = 16;
    static inline var SHIP_Y_POS:Float = 0.90;
    static inline var SHIP_X_SPEED:Int = 400;
    static inline var SHIP_COLOR:FlxColor = FlxColor.WHITE;
    
    static inline var HOLE_WIDTH:Int = SHIP_SIZE * 4;
    static inline var BARRIER_HEIGHT:Int = SHIP_SIZE;
    static inline var BARRIER_MIN_GAP:Int = SHIP_SIZE * 4;
    static inline var BARRIER_MAX_GAP:Int = SHIP_SIZE * 10;
    static inline var BARRIER_Y_SPEED:Int = 100;
    static inline var BARRIER_COLOR:FlxColor = FlxColor.GRAY;
    
    private var ship:FlxSprite;
    private var barriers:FlxTypedGroup<FlxTypedGroup<FlxSprite>>;
    
    private var barrierEmit:FlxSignal;
    private var barrierEmitPosition:Int;
    
    override public function create() {
        super.create();
        
        // create ship
        ship = new FlxSprite(FlxG.width / 2, FlxG.height * SHIP_Y_POS);
        ship.makeGraphic(SHIP_SIZE, SHIP_SIZE, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawTriangle(ship, 0, 0, SHIP_SIZE, SHIP_COLOR);
        add(ship);
        
        // create barriers
        barriers = new FlxTypedGroup<FlxTypedGroup<FlxSprite>>();
        barrierEmit = new FlxSignal(); // create barrier emitter to create a new barrier row
        barrierEmit.add(emitBarrier); // set up callback
        emitBarrier(); // create the first row that descends
        add(barriers);
    }
    
    override public function update(elapsed:Float) {
        super.update(elapsed);
        
        // control ship
        if (FlxG.keys.pressed.LEFT)
            ship.velocity.x = -SHIP_X_SPEED;
        else if (FlxG.keys.pressed.RIGHT)
            ship.velocity.x = SHIP_X_SPEED;
        else
            ship.velocity.x = 0;
            
        var newest = 2000.0;
        barriers.forEachAlive(function(barrier) {
            newest = Math.min(newest, barrier.members[0].y);
        });
        
        if (newest >= barrierEmitPosition)
            barrierEmit.dispatch();
    }
    
    private function createBarrierRow():FlxTypedGroup<FlxSprite> {
        var barrierRow = new FlxTypedGroup<FlxSprite>(2); // hold the whole row
        var holePosition:Int = FlxG.random.int(0, FlxG.width - HOLE_WIDTH); // x position of the hole
        var barrierY:Float = -BARRIER_HEIGHT; // barrier should start above the screen
        
        // left barrier
        var barrierLeft = new FlxSprite(0, barrierY);
        barrierLeft.makeGraphic(holePosition, BARRIER_HEIGHT, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawRect(barrierLeft, 0, 0, barrierLeft.width, BARRIER_HEIGHT, BARRIER_COLOR);
        
        // right barrier
        var barrierRight = new FlxSprite(barrierLeft.width + HOLE_WIDTH, barrierY);
        barrierRight.makeGraphic(Std.int(FlxG.width - barrierRight.width), BARRIER_HEIGHT, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawRect(barrierRight, 0, 0, barrierRight.width, BARRIER_HEIGHT, BARRIER_COLOR);
        
        // add the two barriers to the row
        barrierRow.add(barrierLeft);
        barrierRow.add(barrierRight);
        
        // set up barrier movement
        barrierLeft.velocity.y = BARRIER_Y_SPEED;
        barrierRight.velocity.y = BARRIER_Y_SPEED;
        
        return barrierRow;
    }
    
    private function emitBarrier() {
        // emit a new barrier
        barriers.add(createBarrierRow());
        
        // set the position for this barrier when the next barrier will be emitted
        barrierEmitPosition = FlxG.random.int(BARRIER_MIN_GAP, BARRIER_MAX_GAP);
    }
}
