//
//  ZSGLSprite.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/14/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;    
} TexturedQuad;

@interface ZSGLSprite : NSObject

- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (id)initWithCGImage:(CGImageRef)imageRef effect:(GLKBaseEffect *)effect;

- (void)render;
- (void)renderTriangleStrip:(TexturedVertex *)texturedTriangle ofSize:(NSInteger)size;

@property (assign) GLKMatrix4 transform;
@property (assign) CGSize contentSize;
@property (assign) CGSize contentSizeNormalized;

@property (assign) BOOL overlay;

@end