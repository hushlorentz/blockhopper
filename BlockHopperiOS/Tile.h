enum
{
	TILE_TYPE_SHIFT = 24,
	TILE_XPOS_SHIFT = 16,
	TILE_YPOS_SHIFT = 8,
	WALL = 1 << 2,
};

enum
{
	SPECIAL_GOAL = 1,
	SPECIAL_PLAYER = 2,
	SPECIAL_SPIKES_UP = 3,
	SPECIAL_SPIKES_RIGHT = 4,
	SPECIAL_SPIKES_DOWN = 5,
	SPECIAL_SPIKES_LEFT = 6,
	SPECIAL_LAVA = 7,
	SPECIAL_LASER = 8,
	SPECIAL_REDSWITCH = 9,
	SPECIAL_REDBLOCK = 10,
	SPECIAL_GREENSWITCH = 11,
	SPECIAL_GREENBLOCK = 12,
	SPECIAL_BLUESWITCH = 13,
	SPECIAL_BLUEBLOCK = 14,
	SPECIAL_BUBBLE = 15,
	SPECIAL_ICE = 16,
	SPECIAL_LEFTRIGHT = 17,
	SPECIAL_UPDOWN = 18,
	SPECIAL_CHECKPOINT = 19,
};

@interface Tile : NSObject

+ (BOOL)hasFlag:(int)tile :(int)flag;
+ (int)getImageX:(int)tile;
+ (int)getImageY:(int)tile;
+ (int)getType:(int)tile;

@end
