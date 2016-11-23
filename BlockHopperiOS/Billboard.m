#import "Animation.h"
#import "AnimObject.h"
#import "Billboard.h"

@implementation Billboard

@synthesize x;
@synthesize y;
@synthesize type;
@synthesize currentFrame;
@synthesize isAlive;
@synthesize animFinished;
@synthesize rotation;

- (id)initBillboard:(AssetManager *)assetMan
{
	self = [super init];

	am = assetMan;
	heading = [Vector2D alloc];

	return self;
}

- (void)setupBillboard :(float)xPos :(float)yPos :(int)billboardType :(int)anim :(float)linearVelocity :(float)rotationalVelocity :(float)theta
{
	x = xPos;
	y = yPos;
	type = billboardType;
	rotation = 0;
	velocity = linearVelocity;
	rotVel = rotationalVelocity;
	heading.x = velocity * cos(theta);
	heading.y = velocity * sin(theta);

	Animation *animation;

	if (type == BILLBOARD_TYPE_EXPLOSION || type == BILLBOARD_TYPE_PLAYER_DEATH)
	{
		animation = [am.anims objectAtIndex:1];
	}
	else if (type == BILLBOARD_TYPE_FIREWORK)
	{
		animation = [am.anims objectAtIndex:5];
	}
	else if (type == BILLBOARD_TYPE_FIREWORK2)
	{
		animation = [am.anims objectAtIndex:6];
	}
	else if (type == BILLBOARD_TYPE_CONGRATS)
	{
		animation = [am.anims objectAtIndex:7];
	}
	else
	{
		animation = [am.anims objectAtIndex:4];
	}

	AnimObject *ao = [animation.framePairs objectAtIndex:anim];

	startFrame = ao.startFrame;
	endFrame = startFrame + ao.totalFrames;
	loopType = ao.loopType;
	currentFrame = startFrame;

	animFinished = false;
	isAlive = true;
}

- (void)nextFrame
{
	if (currentFrame >= (endFrame - 1))
	{
		if (loopType == ANIM_LOOPING)
		{
			currentFrame = startFrame;
		}
		else
		{
			isAlive = false;
			animFinished = true;
		}
	}
	else
	{
		currentFrame++;
	}

	x += heading.x;
	y += heading.y;
	rotation += rotVel;
}

- (void)dealloc
{
	[heading release];
	[super dealloc];
}

@end
