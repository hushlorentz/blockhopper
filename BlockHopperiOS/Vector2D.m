#import "Vector2D.h"

@implementation Vector2D

@synthesize x;
@synthesize y;

- (id)initVector2D:(float)xCoord :(float)yCoord
{
	self = [super init];

	x = xCoord;
	y = yCoord;

	return self;
}

- (float)squaredDistance
{
	return x*x + y*y;
}

- (void)normalize
{
	float magnitude = sqrt([self squaredDistance]);

	if (magnitude == 0)
	{
		x = 0;
		y = 0;
	}
	else
	{
		x /= magnitude;
		y /= magnitude;
	}
}

@end
