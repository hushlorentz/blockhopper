#import "AssetManager.h"

enum
{
	BUTTON_TYPE_LEFT,
	BUTTON_TYPE_RIGHT,
	BUTTON_TYPE_UP,
	BUTTON_TYPE_DOWN,
	BUTTON_TYPE_BLOCK,
	BUTTON_TYPE_OK,
	BUTTON_TYPE_RESET,
	BUTTON_TYPE_PREV_BLOCK,
	BUTTON_TYPE_NEXT_BLOCK,
	BUTTON_TYPE_DESTRUCT,
	BUTTON_TYPE_NEXT_MAP,
};

enum
{
	BUTTON_PADDING = 32
};

enum
{
	BUTTON_STATE_UP,
	BUTTON_STATE_DOWN,
};

enum
{
	BUTTON_GROUP_NONE,
	BUTTON_GROUP_PLAY,
	BUTTON_GROUP_BLOCKS,
	BUTTON_GROUP_BLOCKS_INTRO,
	BUTTON_GROUP_CONFIG,
};

@interface GameButton : NSObject
{
	AssetManager *am;
	int animState;
	int startFrame;
	int endFrame;
	int loopType;
}

@property(nonatomic)CGRect bounds;
@property(nonatomic)int buttonState;
@property(nonatomic)int currentFrame;
@property(nonatomic)int type;
@property(nonatomic)BOOL isActive;

- (id)initButtonWithBounds:(CGRect)frame AndType:(int)buttonType AndAssetManager:(AssetManager *)assetMan;
- (void)nextFrame;
- (void)setAnim:(int)anim;
- (void)setState:(int)state;
- (BOOL)pressHitTest:(CGPoint)point;
- (BOOL)releaseHitTest:(CGPoint)point;

@end
