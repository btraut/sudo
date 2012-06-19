//
//  ZSGLShape.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSGLShape.h"

@interface ZSGLShape() {
	GLuint _vertexBuffer;
	GLuint _indexBuffer;
}

@property (strong) GLKBaseEffect *effect;

@end

@implementation ZSGLShape

@synthesize transform, overlay;

@synthesize effect = _effect;

- (id)initWithEffect:(GLKBaseEffect *)effect {
	self = [super init];
	
    if (self) {  
        _effect = effect;
		overlay = NO;
    }
	
	return self;
}

- (void)renderVertices:(ColoredVertex *)vertices ofSize:(NSInteger)size {
	self.effect.transform.modelviewMatrix = self.transform;
	
	[self.effect prepareToDraw];
	
	if (overlay) {
		glBlendFunc(GL_ZERO, GL_SRC_COLOR);
	} else {
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribColor);

	long offset = (long)vertices;
	glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(ColoredVertex), (void *) (offset + offsetof(ColoredVertex, position)));
	glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(ColoredVertex), (void *) (offset + offsetof(ColoredVertex, color)));

	glDrawArrays(GL_TRIANGLE_FAN, 0, size);

	glDisableVertexAttribArray(GLKVertexAttribPosition);
	glDisableVertexAttribArray(GLKVertexAttribColor);
}

@end