//
//  ShadowedFontLabel.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShadowedFontLabel.h"

@implementation ShadowedFontLabel

- (void) drawTextInRect:(CGRect)rect {
    CGSize myShadowOffset = CGSizeMake(0, 1);
    float myColorValues[] = {1, 1, 1, 0.4};
    
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(myContext);
    
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
    CGContextSetShadowWithColor(myContext, myShadowOffset, 0, myColor);
    
    [super drawTextInRect:rect];
    
    CGColorRelease(myColor);
    CGColorSpaceRelease(myColorSpace); 
    
    CGContextRestoreGState(myContext);
}

@end
