#import "AssetManager.h"

enum
{
	PLAYER_IDLE = 0,
	PLAYER_JUMP = 1 << 0,
	PLAYER_LEFT = 1 << 1,
	PLAYER_RIGHT = 1 << 2,
	PLAYER_ACTION  = 1 << 3,
	PLAYER_FALL = 1 << 4,
	PLAYER_HIT = 1 << 5,
	PLAYER_SPRING = 1 << 6,
	PLAYER_DANCE = 1 << 7,
};

@interface Player : NSObject
{
	AssetManager *am;
	int startFrame;
	int endFrame;
	int loopType;
}

@property(nonatomic)int x;
@property(nonatomic)int y;
@property(nonatomic)int width;
@property(nonatomic)int height;
@property(nonatomic)int state;
@property(nonatomic)int speed;
@property(nonatomic)int boost;
@property(nonatomic)int jump;
@property(nonatomic)int slide;
@property(nonatomic)BOOL isAlive;
@property(nonatomic)BOOL flip;
@property(nonatomic)int currentFrame;
@property(nonatomic)int animState;

- (id)initPlayer:(AssetManager *)assetMan;
- (void)setAnim:(int)anim;
- (void)nextFrame;

@end
