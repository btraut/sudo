//
//  ZSFoldedCornerView.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/4/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSFoldedCornerView.h"

@interface ZSFoldedCornerView ()

@end

@implementation ZSFoldedCornerView

@synthesize hitTestDelegate;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return [hitTestDelegate pointInside:point withEvent:event];
}

@end
