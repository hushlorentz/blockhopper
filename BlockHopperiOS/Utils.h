#import "Vector2D.h"

@interface Utils : NSObject

+ (BOOL)boxInBox:(int)x1 :(int)w1 :(int)y1 :(int)h1 :(int)x2 :(int)w2 :(int)y2 :(int)h2;
+ (BOOL)pointInBox:(int)xPoint :(int)yPoint :(int)xBox :(int)width :(int)yBox :(int)height;
+ (BOOL)pointInBoxf:(float)xPoint :(float)yPoint :(float)xBox :(float)width :(float)yBox :(float)height;
+ (BOOL)AABBCollision:(Vector2D *)sepVec :(int)x1 :(int)w1 :(int)y1 :(int)h1 :(int)x2 :(int)w2 :(int)y2 :(int)h2;

@end
