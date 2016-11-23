#import "Animation.h"
#import "AnimObject.h"
#import "Projectile.h"

@implementation Projectile

@synthesize x;
@synthesize y;
@synthesize width;
@synthesize height;
@synthesize image;
@synthesize isAlive;
@synthesize heading;

- (id)initProjectile:(AssetManager *)assetMan
{
	self = [super init];

	am = assetMan;
	heading = [Vector2D alloc];
	velocity = 4;
	width = height = 6;
	isAlive = true;

	return self;
}

- (void)setupProjectile:(int)xPos :(int)yPos :(int)anim
{
	x = xPos;
	y = yPos;

	Animation *animation = [am.anims objectAtIndex:3];
	AnimObject *ao = [animation.framePairs objectAtIndex:anim];
	image = ao.startFrame;
	isAlive = true;
}

- (void)setHeadingFromAngle:(float)theta
{
	heading.x = velocity * cos(theta);
	heading.y = velocity * sin(theta);
}

- (void)dealloc
{
	[heading release];
	[super dealloc];
}

@end
