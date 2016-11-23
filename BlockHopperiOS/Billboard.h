#import "AssetManager.h"
#import "Vector2D.h"

enum
{
	BILLBOARD_TYPE_EXPLOSION,
	BILLBOARD_TYPE_POOF,
	BILLBOARD_TYPE_PLAYER_DEATH,
	BILLBOARD_TYPE_INTRO_POOF,
	BILLBOARD_TYPE_BODY_PART,
	BILLBOARD_TYPE_FIREWORK,
	BILLBOARD_TYPE_FIREWORK2,
	BILLBOARD_TYPE_CONGRATS,
};

@interface Billboard : NSObject
{
	int startFrame;
	int endFrame;
	int currentFrame;
	int loopType;
	int type;
	BOOL isAlive;
	float velocity;
	float rotVel;
	float rotation;
	AssetManager *am;
	Vector2D *heading;
}

@property(nonatomic)float x;
@property(nonatomic)float y;
@property(nonatomic)int type;
@property(nonatomic)int currentFrame;
@property(nonatomic)BOOL isAlive;
@property(nonatomic)BOOL animFinished;
@property(nonatomic)float rotation;

- (id)initBillboard:(AssetManager *)assetMan;
- (void)setupBillboard :(float)xPos :(float)yPos :(int)billboardType :(int)anim :(float)linearVelocity :(float)rotationalVelocity :(float)theta;
- (void)nextFrame;

@end
