
#import "Animation.h"
#import "AnimObject.h"
#import "GameButton.h"
#import "Utils.h"

@implementation GameButton

@synthesize bounds;
@synthesize buttonState;
@synthesize currentFrame;
@synthesize type;
@synthesize isActive;

- (id)initButtonWithBounds:(CGRect)frame AndType:(int)buttonType AndAssetManager:(AssetManager *)assetMan
{
	self = [super init];

	bounds = frame;
	am = assetMan;
	type = buttonType;
	animState = -1;
	isActive = true;

	return self;
}

- (void)setAnim:(int)anim
{
	if (animState == anim)
	{
		return;
	}

	animState = anim;

	Animation *animation = [am.anims objectAtIndex:2];
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

- (void)setState:(int)state
{
	buttonState = state;
}

- (BOOL)pressHitTest:(CGPoint)point
{
	return [Utils pointInBoxf:point.x :point.y :bounds.origin.x :bounds.size.width :bounds.origin.y :bounds.size.height];
}

- (BOOL)releaseHitTest:(CGPoint)point
{
	return [Utils pointInBoxf:point.x :point.y :bounds.origin.x - BUTTON_PADDING :bounds.size.width + 2 * BUTTON_PADDING :bounds.origin.y - BUTTON_PADDING :bounds.size.height + 2 * BUTTON_PADDING];
}

@end
