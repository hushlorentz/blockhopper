#import "AssetManager.h"
#import "Vector2D.h"

@interface Projectile : NSObject
{
	int x;
	int y;
	int width;
	int height;
	int velocity;
	int image;
	Vector2D *heading;
	AssetManager *am;
}

@property(nonatomic)int x;
@property(nonatomic)int y;
@property(nonatomic)int width;
@property(nonatomic)int height;
@property(nonatomic)int image;
@property(nonatomic)BOOL isAlive;
@property(nonatomic, assign)Vector2D *heading;

- (id)initProjectile:(AssetManager *)assetMan;
- (void)setupProjectile:(int)xPos :(int)yPos :(int)anim;
- (void)setHeadingFromAngle:(float)theta;
- (void)dealloc;

@end
