@interface AnimObject : NSObject

@property(nonatomic)int type;
@property(nonatomic)int loopType;
@property(nonatomic)int totalFrames;
@property(nonatomic)int startFrame;

- (id)initAnimObject:(int)type loop:(int)loopType totalFrames:(int)totalFrames startFrame:(int)startFrame;

@end
