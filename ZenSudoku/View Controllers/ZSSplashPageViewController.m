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
	
	NSString *splashImageName;
	CGRect splashImageViewFrame;
	
	switch (resolution) {
		case UIDevice_iPadStandardRes:
		case UIDevice_iPadHiRes:
			splashImageName = @"Default-Portrait.png";
			splashImageViewFrame = CGRectMake(0, 0, 768, 1004);
			break;
			
		case UIDevice_iPhoneTallerHiRes:
			splashImageName = @"SplashPage-Tall@2x.png";
			splashImageViewFrame = CGRectMake(self.innerView.frame.origin.x, self.innerView.frame.origin.y, 320, 568);
			break;
			
		default:
			splashImageName = @"SplashPage.png";
			splashImageViewFrame = CGRectMake(self.innerView.frame.origin.x, self.innerView.frame.origin.y, 320, 460);
			break;
	}
	
	UIImageView *splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:splashImageName]];
	splashImageView.frame = splashImageViewFrame;
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
