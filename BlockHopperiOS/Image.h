#import <Foundation/Foundation.h>
#import "Texture2D.h"

@interface Image : NSObject 
{
	Texture2D *texture;
	NSUInteger imageWidth;
	NSUInteger imageHeight;
	NSUInteger textureWidth;
	NSUInteger textureHeight;
	float maxTexWidth;
	float maxTexHeight;
	float texWidthRatio;
	float texHeightRatio;
	NSUInteger textureOffsetX;
	NSUInteger textureOffsetY;
	float rotation;
	float scale;
	float colorFilter[4];
}

@property(nonatomic)NSUInteger imageWidth;
@property(nonatomic)NSUInteger imageHeight;
@property(nonatomic, readonly)NSUInteger textureWidth;
@property(nonatomic, readonly)NSUInteger textureHeight;
@property(nonatomic, readonly)float texWidthRatio;
@property(nonatomic, readonly)float texHeightRatio;
@property(nonatomic)NSUInteger textureOffsetX;
@property(nonatomic)NSUInteger textureOffsetY;
@property(nonatomic)float rotation;
@property(nonatomic)float scale;

//initialisers
//- (id)initWithTexture:(Texture2D *)tex;
//- (id)initWithTexture:(Texture2D *)tex scale:(float)imageScale;
- (id)initWithString:(NSString *)imgPath;
//- (id)initWithImage:(UIImage *)image filter:(GLenum)filter;
//- (id)initWithImage:(UIImage *)image scale:(float)imageScale;
//- (id)initWithImage:(UIImage *)image scale:(float)imageScale filter:(GLenum)filter;

//Action methods
- (Image *)getSubImageAtPoint:(CGPoint)point subImageWidth:(GLuint)subImageWidth subImageHeight:(GLuint)subImageHeight subImageScale:(float)subImageScale;
- (void)renderAtPoint:(CGPoint)point centerOfImage:(BOOL)center;
- (void)renderSubImageAtPoint:(CGPoint)point offset:(CGPoint)offsetPoint subImageWidth:(GLfloat)subImageWidth subImageHeight:(GLfloat)subImageHeight centerOfImage:(BOOL)center;
- (void)renderSubImageAtPoint:(CGPoint)point offset:(CGPoint)offsetPoint subImageWidth:(GLfloat)subImageWidth subImageHeight:(GLfloat)subImageHeight centerOfImage:(BOOL)center rotation:(float)rot;
- (void)renderSubImageAsRect:(CGRect)bounds offset:(CGPoint)offsetPoint subImageWidth:(GLfloat)subImageWidth subImageHeight:(GLfloat)subImageHeight centerOfImage:(BOOL)center;

//setter
- (void)setColorFilterRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
- (void)setAlpha:(float)alpha;

@end
