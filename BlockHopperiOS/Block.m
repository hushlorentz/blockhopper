#import "AssetManager.h"
#import "Animation.h"
#import "AnimObject.h"
#import "Block.h"

@implementation Block

@synthesize x;
@synthesize y;
@synthesize isAlive;
@synthesize isVisible;
@synthesize animFinished;
@synthesize currentFrame;
@synthesize startFrame;
@synthesize type;
@synthesize heading;
@synthesize counter;
@synthesize health;
@synthesize damageZones;
@synthesize drawBlock;
@synthesize leftExtent;
@synthesize rightExtent;
@synthesize upExtent;
@synthesize downExtent;
@synthesize numLasers;
@synthesize timerMax;
@synthesize timer;
@synthesize stateIndex;
@synthesize animState;
@synthesize loopType;
@synthesize endFrame;

- (id)initBlock:(int)blockType WithAssetManager:(AssetManager *)assetMan
{
	self = [super init];

	am = assetMan;
	type = blockType;
	timer = 0;
	timerMax = 0;
	counter = 0;
	numLasers = 0;
	leftExtent = 0;
	rightExtent = 0;
	upExtent = 0;
	downExtent = 0;
	isAlive = true;
	isVisible = true;
	drawBlock = true;
	animState = -1;
	stateIndex = 0;
	heading = [[Vector2D alloc] initVector2D:0 :0];
	damageZones = [[NSMutableArray alloc] init];

	switch (type)
	{
		case BLOCK_TYPE_GOAL:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_GOAL], nil];
			break;
		case BLOCK_TYPE_DEFAULT:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_METAL], nil];
			break;
		case BLOCK_TYPE_INVISIBLE:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_INVISIBLE], [NSNumber numberWithInt:ANIM_INVISIBLE_ACTION], nil];
			break;
		case BLOCK_TYPE_LEFTRIGHT:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_RIGHT_PLATFORM], [NSNumber numberWithInt:ANIM_LEFT_PLATFORM], nil];
			heading.x = 2;
			break;
		case BLOCK_TYPE_UPDOWN:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_UP_PLATFORM], [NSNumber numberWithInt:ANIM_DOWN_PLATFORM], nil];
			heading.y = 2;
			break;
		case BLOCK_TYPE_RIGHTCONVEYOR:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_RIGHT_CONVEYOR], nil];
			heading.x = 2;
			break;
		case BLOCK_TYPE_LEFTCONVEYOR:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_LEFT_CONVEYOR], nil];
			heading.x = -2;
			break;
		case BLOCK_TYPE_REDPORTAL:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_RED_PORTAL], [NSNumber numberWithInt:ANIM_RED_PORTAL_ACTION], nil];
			break;
		case BLOCK_TYPE_GREENPORTAL:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_GREEN_PORTAL], [NSNumber numberWithInt:ANIM_GREEN_PORTAL_ACTION], nil];
			break;
		case BLOCK_TYPE_BLUEPORTAL:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_BLUE_PORTAL], [NSNumber numberWithInt:ANIM_BLUE_PORTAL_ACTION], nil];
			break;
		case BLOCK_TYPE_SPRINGBOARD:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_SPRINGBOARD], [NSNumber numberWithInt:ANIM_SPRINGBOARD_ACTION], nil];
			break;
		case BLOCK_TYPE_BLADE:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_BLADE_BLOCK], nil];
			timerMax = 128;
			break;
		case BLOCK_TYPE_SPIKES_UP:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_SPIKE_BLOCK_UP], nil];
			[damageZones addObject:[NSValue valueWithCGRect:CGRectMake(0, -24, 32, 32)]];
			break;
		case BLOCK_TYPE_SPIKES_RIGHT:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_SPIKE_BLOCK_RIGHT], nil];
			[damageZones addObject:[NSValue valueWithCGRect:CGRectMake(24, 0, 32, 32)]];
			break;
		case BLOCK_TYPE_SPIKES_DOWN:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_SPIKE_BLOCK_DOWN], nil];
			[damageZones addObject:[NSValue valueWithCGRect:CGRectMake(0, 24, 32, 32)]];
			break;
		case BLOCK_TYPE_SPIKES_LEFT:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_SPIKE_BLOCK_LEFT], nil];
			[damageZones addObject:[NSValue valueWithCGRect:CGRectMake(-24, 0, 32, 32)]];
			break;
		case BLOCK_TYPE_LAVA:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_LAVA], nil];
			[damageZones addObject:[NSValue valueWithCGRect:CGRectMake(0, -16, 32, 32)]];
			break;
		case BLOCK_TYPE_FIRE:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_FIRE], [NSNumber numberWithInt:ANIM_FIRE_ACTION], nil];
			break;
		case BLOCK_TYPE_BOMB:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_BOMB], [NSNumber numberWithInt:ANIM_BOMB_ACTION], nil];
			break;
		case BLOCK_TYPE_GUN:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_GUN_IDLE], [NSNumber numberWithInt:ANIM_GUN_SHOOT_UP], [NSNumber numberWithInt:ANIM_GUN_IDLE], [NSNumber numberWithInt:ANIM_GUN_SHOOT_RIGHT], [NSNumber numberWithInt:ANIM_GUN_IDLE], [NSNumber numberWithInt:ANIM_GUN_SHOOT_DOWN], [NSNumber numberWithInt:ANIM_GUN_IDLE], [NSNumber numberWithInt:ANIM_GUN_SHOOT_LEFT], [NSNumber numberWithInt:ANIM_GUN_IDLE], [NSNumber numberWithInt:ANIM_GUN_SHOOT_ALL], nil];
			break;
		case BLOCK_TYPE_MOVINGSPIKES:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_SPIKES_IDLE], [NSNumber numberWithInt:ANIM_SPIKES_EXTEND_UP], [NSNumber numberWithInt:ANIM_SPIKES_UP], [NSNumber numberWithInt:ANIM_SPIKES_RETRACT_UP], [NSNumber numberWithInt:ANIM_SPIKES_EXTEND_RIGHT], [NSNumber numberWithInt:ANIM_SPIKES_RIGHT], [NSNumber numberWithInt:ANIM_SPIKES_RETRACT_RIGHT], [NSNumber numberWithInt:ANIM_SPIKES_EXTEND_DOWN], [NSNumber numberWithInt:ANIM_SPIKES_DOWN], [NSNumber numberWithInt:ANIM_SPIKES_RETRACT_DOWN], [NSNumber numberWithInt:ANIM_SPIKES_EXTEND_LEFT], [NSNumber numberWithInt:ANIM_SPIKES_LEFT], [NSNumber numberWithInt:ANIM_SPIKES_RETRACT_LEFT], [NSNumber numberWithInt:ANIM_SPIKES_EXTEND_ALL], [NSNumber numberWithInt:ANIM_SPIKES_ALL], [NSNumber numberWithInt:ANIM_SPIKES_RETRACT_ALL], nil];
			break;
		case BLOCK_TYPE_LASER:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_LASER_BLOCK], nil];
			break;
		case BLOCK_TYPE_REDSWITCH:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_REDSWITCH_OFF], [NSNumber numberWithInt:ANIM_REDSWITCH_ON], nil];
			timerMax = 64;
			break;
		case BLOCK_TYPE_REDBLOCK:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_REDBLOCK_VISIBLE], [NSNumber numberWithInt:ANIM_REDBLOCK_INVISIBLE], nil];
			break;
		case BLOCK_TYPE_GREENSWITCH:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_GREENSWITCH_OFF], [NSNumber numberWithInt:ANIM_GREENSWITCH_ON], nil];
			timerMax = 64;
			break;
		case BLOCK_TYPE_GREENBLOCK:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_GREENBLOCK_INVISIBLE], [NSNumber numberWithInt:ANIM_GREENBLOCK_VISIBLE], nil];
			isVisible = false;
			break;
		case BLOCK_TYPE_BLUESWITCH:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_BLUESWITCH_OFF], [NSNumber numberWithInt:ANIM_BLUESWITCH_ON], nil];
			timerMax = 64;
			break;
		case BLOCK_TYPE_BLUEBLOCK:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_BLUEBLOCK_VISIBLE], [NSNumber numberWithInt:ANIM_BLUEBLOCK_INVISIBLE], nil];
			break;
		case BLOCK_TYPE_CHECKPOINT:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_CHECKPOINT], [NSNumber numberWithInt:ANIM_CHECKPOINT_ACTION], nil];
			isVisible = false;
			break;
		case BLOCK_TYPE_BUBBLE:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_BUBBLE], [NSNumber numberWithInt:ANIM_BUBBLE_POP], nil];
			break;
		case BLOCK_TYPE_ICE:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_ICE], [NSNumber numberWithInt:ANIM_ICE_MELT], nil];
			break;
		case BLOCK_TYPE_CRYSTAL:
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_CRYSTAL], [NSNumber numberWithInt:ANIM_CRYSTAL_BREAK], nil];
			health = BLOCK_HEALTH;
			break;
		case BLOCK_TYPE_CAKE:	
			animStates = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:ANIM_CAKE], nil];
			break;
	}

	[self setBlockAnim:[[animStates objectAtIndex:0] intValue]];

	return self;
}

- (void)resetAnim
{
	currentFrame = startFrame;
	animFinished = false;
}

- (void)setBlockAnim:(int)anim
{
	if (animState == anim)
	{
		return;
	}

	animState = anim;
	animFinished = false;

	Animation *animation = [am.anims objectAtIndex:1];
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
		if (loopType == ANIM_ONESHOT)
		{
			animFinished = true;
		}
		else
		{
			currentFrame = startFrame;
		}
	}
	else
	{
		currentFrame++;
	}

	timer = ((timer + 1) < timerMax) ? timer + 1 : 0;
}

- (int)getAnim
{
	return [[animStates objectAtIndex:stateIndex] intValue];
}

- (void)nextState
{
	if (type != BLOCK_TYPE_CHECKPOINT)
	{
		isVisible = true;
	}

	stateIndex = (stateIndex + 1) < [animStates count] ? stateIndex + 1 : 0;
	animFinished = false;
	timer = 0;

	[self setBlockAnim:[[animStates objectAtIndex:stateIndex] intValue]];

	switch ([[animStates objectAtIndex:stateIndex] intValue])
	{
		case ANIM_INVISIBLE_ACTION:
		case ANIM_REDBLOCK_INVISIBLE:
		case ANIM_GREENBLOCK_INVISIBLE:
		case ANIM_BLUEBLOCK_INVISIBLE:
			isVisible = false;
			break;
	}
}

- (float)getAngle
{
	float theta = (timerMax - timer) / (float)timerMax;
	theta *= 2 * M_PI;
	return theta;
}

- (void)dealloc
{
	[heading release];
	[animStates release];
	[damageZones release];

	[super dealloc];
}

@end;
