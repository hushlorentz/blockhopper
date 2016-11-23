#import "Tile.h"

@implementation Tile

+ (BOOL)hasFlag:(int)tile :(int)flag
{
	return (tile & flag) == flag;
}	

+ (int)getImageX:(int)tile
{
	return (tile >> TILE_XPOS_SHIFT) & 0xFF;
}

+ (int)getImageY:(int)tile
{
	return (tile >> TILE_YPOS_SHIFT) & 0xFF;
}

+ (int)getType:(int)tile
{
	return (tile >> TILE_TYPE_SHIFT) & 0x1F;
}	

@end
