#import "Utils.h"

@implementation Utils

+ (BOOL)boxInBox:(int)x1 :(int)w1 :(int)y1 :(int)h1 :(int)x2 :(int)w2 :(int)y2 :(int)h2
{
	return !((x1 >= x2 + w2) || (x2 >= x1 + w1) || (y1 >= y2 + h2) || (y2 >= y1 + h1));
}

+ (BOOL)pointInBox:(int)xPoint :(int)yPoint :(int)xBox :(int)width :(int)yBox :(int)height
{
	return (xPoint >= xBox && xPoint <= (xBox + width) && yPoint >= yBox && yPoint <= (yBox + height));
}

+ (BOOL)pointInBoxf:(float)xPoint :(float)yPoint :(float)xBox :(float)width :(float)yBox :(float)height
{
	return (xPoint >= xBox && xPoint <= (xBox + width) && yPoint >= yBox && yPoint <= (yBox + height));
}

+ (BOOL)AABBCollision:(Vector2D *)sepVec :(int)x1 :(int)w1 :(int)y1 :(int)h1 :(int)x2 :(int)w2 :(int)y2 :(int)h2
{
	int distX = (x2 + w2) - (x1 + w1);
	int distY = (y2 + h2) - (y1 + h1);
	int overlapX = w1 + w2 - abs(distX);
	int overlapY = h1 + h2 - abs(distY);

	if (overlapX > 0)
	{
		if (overlapY > 0) //we collide! Now find minimum overlap
		{
			if (overlapX < overlapY)
			{
				if (distX < 0) // collision on right side
				{
					sepVec.x = overlapX;
					sepVec.y = 0;
					return true;
				}
				else //collision on left side
				{
					sepVec.x = -overlapX;
					sepVec.y = 0;
					return true;
				}
			}
			else
			{
				if (distY < 0) //collision from below
				{
					sepVec.x = 0;
					sepVec.y = overlapY;
					return true;
				}
				else
				{
					sepVec.x = 0;
					sepVec.y = -overlapY;
					return true;
				}
			}
		}
	}

	return false;
}

@end
