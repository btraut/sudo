//
//  ZSFoldedCornerGLView.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/4/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import "ZSFoldedCornerGLView.h"

@interface ZSFoldedCornerGLView ()

@end

@implementation ZSFoldedCornerGLView

@synthesize hitTestDelegate;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return [hitTestDelegate pointInside:point withEvent:event];
}

@end
