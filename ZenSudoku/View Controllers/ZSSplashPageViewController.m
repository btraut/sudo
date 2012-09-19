//
//  ZSSplashPageViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 7/9/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSSplashPageViewController.h"
#import "UIDevice+Resolutions.h"

@interface ZSSplashPageViewController ()

@end

@implementation ZSSplashPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIDeviceResolution resolution = [UIDevice currentResolution];
	
	UIImageView *splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(resolution == UIDevice_iPhoneTallerHiRes ? @"SplashPage-Tall@2x.png" : @"SplashPage.png")]];
	splashImageView.frame = CGRectMake(self.innerView.frame.origin.x, self.innerView.frame.origin.y, 320, self.innerView.frame.size.height);
	splashImageView.userInteractionEnabled = YES;
	[self.innerView addSubview:splashImageView];
	
	self.animateCornerWhenPromoted = NO;
}

- (void)viewWasPromotedToFront {
	[super viewWasPromotedToFront];
	
	[self.foldedCornerViewController resetToStartPosition];
}

- (void)dismiss {
	self.needsScreenshotUpdate = YES;
	
	[self turnPage];
}

@end
