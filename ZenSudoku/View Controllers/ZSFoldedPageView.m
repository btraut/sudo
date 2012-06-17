//
//  ZSFoldedPageView.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSFoldedPageView.h"
#import "ZSGameViewController.h"

#import <QuartzCore/CALayer.h>

@interface ZSFoldedPageView () {
	UIImage *_forwardsPageImage;
	UIImage *_screenshotImage;
}

@end

@implementation ZSFoldedPageView

@synthesize foldDimensions = _foldDimensions;

- (id)init {
	return [self initWithFrame:CGRectMake(0, 0, 314, 460)];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self != nil) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.clearsContextBeforeDrawing = YES;
		self.clipsToBounds = YES;
		self.contentMode = UIViewContentModeBottomLeft;
		
		_forwardsPageImage = [UIImage imageNamed:@"ForwardsPage.png"];
		_screenshotImage = [UIImage imageNamed:@"ForwardsPage.png"];
	}
	
	return self;
}

- (void)createScreenshotFromView {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	_screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

- (void)setAllSubViewsHidden:(BOOL)hidden except:(UIView *)excludeView {
	for (UIView *view in self.subviews) {
		if (view != excludeView) {
			view.hidden = hidden;
		}
	}
}

- (void)restoreScreenshotFromOriginal {
	_screenshotImage = [UIImage imageNamed:@"ForwardsPage.png"];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Cut the corner off the page.
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, 0, self.frame.size.height);
	CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
	CGContextAddLineToPoint(context, self.frame.size.width, _foldDimensions.height);
	CGContextAddLineToPoint(context, self.frame.size.width - _foldDimensions.width, 0);
	CGContextAddLineToPoint(context, 0, 0);
	CGContextClosePath(context);
	CGContextClip(context);
	
	[_screenshotImage drawInRect:[self bounds]];
}

@end
