#import "Animation.h"
#import "AnimObject.h"
#import "Player.h"

@implementation Player

@synthesize x;
@synthesize y;
@synthesize width;
@synthesize height;
@synthesize state;
@synthesize speed;
@synthesize isAlive;
@synthesize boost;
@synthesize jump;
@synthesize slide;
@synthesize flip;
@synthesize currentFrame;
@synthesize animState;

- (id)initPlayer:(AssetManager *)assetMan
{
	am = assetMan;
	x = y = boost = jump = slide = 0;
	speed = 5;
	width = height = 32;
	isAlive = true;
	flip = false;
	animState = -1;
	return self;
}

- (void)setAnim:(int)anim
{
	if (animState == anim)
	{
		return;
	}

	animState = anim;

	Animation *animation = [am.anims objectAtIndex:0];
	AnimObject *ao = [animation.framePairs objectAtIndex:anim];

	startFrame = ao.startFrame;
	endFrame = startFrame + ao.totalFrames;
	loopType = ao.loopType;
	currentFrame = startFrame;
}

- (void)nextFrame
{
	if (currentFrame >= (endFrame - 1))
	{
		if (loopType != ANIM_ONESHOT)
		{
			currentFrame = startFrame;
		}
	}
	else
	{
		currentFrame++;
	}
}

@end
