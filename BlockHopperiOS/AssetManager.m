#import "Image.h"
#import "AssetManager.h"

@implementation AssetManager

@synthesize anims;
@synthesize images;
@synthesize assets;

- (id)init
{
	self = [super init];

	anims = [[NSMutableArray alloc] init];
	images = [[NSMutableArray alloc] init];
	assets = [[NSMutableArray alloc] init];

	return self;
}

- (void)dealloc
{
	[anims release];
	[images release];
	[assets release];

	[super dealloc];
}

@end
