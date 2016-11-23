#import "AssetManager.h"
#import "Vector2D.h"

enum
{
	BLOCK_TYPE_DEFAULT,
	BLOCK_TYPE_INVISIBLE,
	BLOCK_TYPE_LEFTRIGHT,
	BLOCK_TYPE_UPDOWN,
	BLOCK_TYPE_RIGHTCONVEYOR,
	BLOCK_TYPE_LEFTCONVEYOR,
	BLOCK_TYPE_REDPORTAL,
	BLOCK_TYPE_GREENPORTAL,
	BLOCK_TYPE_BLUEPORTAL,
	BLOCK_TYPE_SPRINGBOARD,
	BLOCK_TYPE_CRYSTAL,
	BLOCK_TYPE_BLADE,
	BLOCK_TYPE_FIRE,
	BLOCK_TYPE_BOMB,
	BLOCK_TYPE_GUN,
	BLOCK_TYPE_MOVINGSPIKES,
	BLOCK_TYPE_LAVA,
	BLOCK_TYPE_GOAL,
	BLOCK_TYPE_LASER,
	BLOCK_TYPE_SPIKES_UP,
	BLOCK_TYPE_SPIKES_RIGHT,
	BLOCK_TYPE_SPIKES_DOWN,
	BLOCK_TYPE_SPIKES_LEFT,
	BLOCK_TYPE_REDSWITCH,
	BLOCK_TYPE_REDBLOCK,
	BLOCK_TYPE_GREENSWITCH,
	BLOCK_TYPE_GREENBLOCK,
	BLOCK_TYPE_BLUESWITCH,
	BLOCK_TYPE_BLUEBLOCK,
	BLOCK_TYPE_BUBBLE,
	BLOCK_TYPE_ICE,
	BLOCK_TYPE_CHECKPOINT,
	BLOCK_TYPE_CAKE,
	NUM_BLOCK_TYPES,
};

enum
{
	BLOCK_STATE_IDLE,
	BLOCK_STATE_PREACTION,
	BLOCK_STATE_ACTION,
	BLOCK_STATE_SHOOTUP,
	BLOCK_STATE_SHOOTDOWN,
	BLOCK_STATE_SHOOTLEFT,
	BLOCK_STATE_SHOOTRIGHT,
	BLOCK_STATE_SHOOTALL
};

enum
{
	BLOCK_HEALTH = 96,
	BLOCK_BUBBLE_IDLE_TIME = 8,
};

@interface Block : NSObject
{
	NSArray *animStates;
	AssetManager *am;
}

@property(nonatomic)int x;
@property(nonatomic)int y;
@property(nonatomic)int type;
@property(nonatomic)int currentFrame;
@property(nonatomic)int startFrame;
@property(nonatomic)int counter;
@property(nonatomic)int health;
@property(nonatomic)int stateIndex;
@property(nonatomic)int animState;
@property(nonatomic)int loopType;
@property(nonatomic)int endFrame;
@property(nonatomic)BOOL isAlive;
@property(nonatomic)BOOL isVisible;
@property(nonatomic)BOOL animFinished;
@property(nonatomic)BOOL drawBlock;
@property(nonatomic, assign)Vector2D *heading;
@property(nonatomic, assign)NSMutableArray *damageZones;
@property(nonatomic)int leftExtent;
@property(nonatomic)int rightExtent;
@property(nonatomic)int upExtent;
@property(nonatomic)int downExtent;
@property(nonatomic)int numLasers;
@property(nonatomic)int timerMax;
@property(nonatomic)int timer;

- (id)initBlock:(int)blockType WithAssetManager:(AssetManager *)assetMan;
- (void)resetAnim;
- (void)setBlockAnim:(int)anim;
- (void)nextFrame;
- (int)getAnim;
- (void)nextState;
- (float)getAngle;

@end
