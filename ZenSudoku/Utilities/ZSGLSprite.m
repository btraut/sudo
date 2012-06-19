//
//  ZSGLSprite.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSGLSprite.h"

@interface ZSGLSprite()

@property (strong) GLKBaseEffect *effect;
@property (assign) TexturedQuad quad;
@property (strong) GLKTextureInfo *textureInfo;

@end

@implementation ZSGLSprite

@synthesize transform, contentSize, contentSizeNormalized;

@synthesize effect = _effect;
@synthesize quad = _quad;
@synthesize textureInfo = _textureInfo;

- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect {
	self = [super init];
	
    if (self) {  
        self.effect = effect;
		
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft,
                                  nil];
		
		// Fetch the file contents.
        NSError *error;    
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        
		self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
		
		if (self.textureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
            return nil;
        }
		
		// Save the size of the texture.
		self.contentSize = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
		
		if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && [UIScreen mainScreen].scale == 2.0) {
			self.contentSizeNormalized = CGSizeMake(self.textureInfo.width / 2, self.textureInfo.height / 2);
		} else {
			self.contentSizeNormalized = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
		}
		
		// Set up the textured quad.
        TexturedQuad newQuad;
		
		newQuad.bl.geometryVertex = CGPointMake(0, 0);
		newQuad.br.geometryVertex = CGPointMake(self.textureInfo.width, 0);
		newQuad.tl.geometryVertex = CGPointMake(0, self.textureInfo.height);
		newQuad.tr.geometryVertex = CGPointMake(self.textureInfo.width, self.textureInfo.height);
		
		newQuad.bl.textureVertex = CGPointMake(0, 0);
		newQuad.br.textureVertex = CGPointMake(1, 0);
		newQuad.tl.textureVertex = CGPointMake(0, 1);
		newQuad.tr.textureVertex = CGPointMake(1, 1);
		
		self.quad = newQuad;
    }
	
	return self;
}

- (void)render {
	self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
	self.effect.texture2d0.name = self.textureInfo.name;
	self.effect.texture2d0.enabled = YES;
	
	self.effect.transform.modelviewMatrix = self.transform;
	
	[self.effect prepareToDraw];
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	
	long offset = (long)&_quad;        
	glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisableVertexAttribArray(GLKVertexAttribPosition);
	glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
	
	self.effect.texture2d0.enabled = NO;
}

- (void)renderTriangleStrip:(TexturedVertex *)coordinates ofSize:(NSInteger)size {
	self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
	self.effect.texture2d0.name = self.textureInfo.name;
	self.effect.texture2d0.enabled = YES;
	
	self.effect.transform.modelviewMatrix = self.transform;
	
	[self.effect prepareToDraw];
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	
	long offset = (long)coordinates;        
	glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, size);
	
	glDisableVertexAttribArray(GLKVertexAttribPosition);
	glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
	
	self.effect.texture2d0.enabled = NO;
}

@end