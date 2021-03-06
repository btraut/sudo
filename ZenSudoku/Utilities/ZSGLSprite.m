//
//  ZSGLSprite.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/14/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSGLSprite.h"

@interface ZSGLSprite()

@property (strong) GLKBaseEffect *effect;
@property (strong) GLKTextureInfo *textureInfo;

@end

@implementation ZSGLSprite

@synthesize transform, contentSize, contentSizeNormalized;

@synthesize effect = _effect;
@synthesize textureInfo = _textureInfo;
@synthesize overlay;

- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect {
	self = [super init];
	
	if (self) {  
		self.effect = effect;
		
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft,
								 nil];
		
		// Fetch the file contents.
		NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
		NSError *error;
		self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
		
		glFlush();
		
		if (self.textureInfo == nil) {
			NSLog(@"Error loading file: %@", [error localizedDescription]);
			return nil;
		}
		
		// Save the size of the texture.
		self.contentSize = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
		self.contentSizeNormalized = CGSizeMake(self.textureInfo.width / [UIScreen mainScreen].scale, self.textureInfo.height / [UIScreen mainScreen].scale);
	}
	
	return self;
}

- (id)initWithCGImage:(CGImageRef)imageRef effect:(GLKBaseEffect *)effect {
	self = [super init];
	
	if (self) {  
		self.effect = effect;
		
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft,
								 nil];
		
		NSError *error = nil;
		self.textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:options error:&error];
		
		glFlush();
		
		if (self.textureInfo == nil) {
			NSLog(@"Error loading file: %@", [error localizedDescription]);
			return nil;
		}
		
		// Save the size of the texture.
		self.contentSize = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
		self.contentSizeNormalized = CGSizeMake(self.textureInfo.width / [UIScreen mainScreen].scale, self.textureInfo.height / [UIScreen mainScreen].scale);
	}
	
	return self;
}

- (void)dealloc {
	GLuint textureName = self.textureInfo.name;
	glDeleteTextures(1, &textureName);
}

- (void)render {
	self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
	self.effect.texture2d0.name = self.textureInfo.name;
	self.effect.texture2d0.enabled = YES;
	
	self.effect.transform.modelviewMatrix = self.transform;
	
	[self.effect prepareToDraw];
	
	if (self.overlay) {
		glBlendFunc(GL_ZERO, GL_SRC_COLOR);
	} else {
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	
	// Set up the textured quad.
	TexturedQuad newQuad;
	
	newQuad.bl.geometryVertex = CGPointMake(0, 0);
	newQuad.br.geometryVertex = CGPointMake(self.contentSizeNormalized.width, 0);
	newQuad.tl.geometryVertex = CGPointMake(0, self.contentSizeNormalized.height);
	newQuad.tr.geometryVertex = CGPointMake(self.contentSizeNormalized.width, self.contentSizeNormalized.height);
	
	newQuad.bl.textureVertex = CGPointMake(0, 0);
	newQuad.br.textureVertex = CGPointMake(1, 0);
	newQuad.tl.textureVertex = CGPointMake(0, 1);
	newQuad.tr.textureVertex = CGPointMake(1, 1);
	
	long offset = (long)&newQuad;
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
	
	if (self.overlay) {
		glBlendFunc(GL_ZERO, GL_SRC_COLOR);
	} else {
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	
	long offset = (long)coordinates;
	glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (int)size);
	
	glDisableVertexAttribArray(GLKVertexAttribPosition);
	glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
	
	self.effect.texture2d0.enabled = NO;
}

@end