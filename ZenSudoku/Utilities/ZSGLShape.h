//
//  ZSGLShape.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/14/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct {
    CGPoint position;
    GLKVector4 color;
} ColoredVertex;

@interface ZSGLShape : NSObject

- (id)initWithEffect:(GLKBaseEffect *)effect;

- (void)renderVertices:(ColoredVertex *)vertices ofSize:(NSInteger)size;

@property (assign) GLKMatrix4 transform;
@property (assign) BOOL overlay;

@end