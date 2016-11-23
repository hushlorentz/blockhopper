#import "AnimObject.h"

@implementation AnimObject

@synthesize type;
@synthesize loopType;
@synthesize totalFrames;
@synthesize startFrame;

- (id)initAnimObject:(int)animType loop:(int)animLoopType totalFrames:(int)animTotalFrames startFrame:(int)animStartFrame
{
	self = [super init];

	type = animType;
	loopType = animLoopType;
	totalFrames = animTotalFrames;
	startFrame = animStartFrame;

	return self;
}

@end
