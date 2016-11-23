@interface Vector2D : NSObject
{
}

@property(nonatomic)float x;
@property(nonatomic)float y;

- (id)initVector2D:(float)xCoord :(float)yCoord;
- (float)squaredDistance;
- (void)normalize;

@end
