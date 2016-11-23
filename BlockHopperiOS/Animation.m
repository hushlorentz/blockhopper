#import "Animation.h"
#import "AnimObject.h"

@implementation Animation

@synthesize framePairs;
@synthesize animBounds;
@synthesize frameList;
@synthesize type;
@synthesize loopType;

- (id)initWithData:(int *)data OfLength:(int)length
{
	self = [super init];

	int i;
	int boundsSize = 0;
	int dataIndex = 0;

	type = 0;
	loopType = 0;

	framePairs = [[NSMutableArray alloc] init];
	animBounds = [[NSMutableArray alloc] init];
	frameList = [[NSMutableArray alloc] init];

	boundsSize = data[dataIndex++];

	for (i = 0; i < boundsSize; i++)
	{
		int x = data[dataIndex++];
		int y = data[dataIndex++];
		int w = data[dataIndex++];
		int h = data[dataIndex++];

		CGRect rect = CGRectMake(x, y, w, h);
		[animBounds addObject:[NSValue valueWithCGRect:rect]];
	}

	int pairSize = data[dataIndex++];

	for (i = 0; i < pairSize; i++)
	{
		int t = data[dataIndex++];
		int lType = data[dataIndex++];
		int tFrames = data[dataIndex++];
		int sFrame = data[dataIndex++];

		AnimObject *ao = [[AnimObject alloc] initAnimObject:t loop:lType totalFrames:tFrames startFrame:sFrame];

		[framePairs addObject:ao];
		[ao release];
	}

	while (dataIndex < length)
	{
		int frame = data[dataIndex++];
		[frameList addObject:[NSNumber numberWithInteger:frame]];
	}

	return self;
}

- (void)dealloc
{
	[framePairs release];
	[animBounds release];
	[frameList release];

	[super dealloc];
}

@end
