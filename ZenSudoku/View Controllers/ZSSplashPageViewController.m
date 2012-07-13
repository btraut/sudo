//
//  ZSSplashPageViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSSplashPageViewController.h"

@interface ZSSplashPageViewController ()

@end

@implementation ZSSplashPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIImageView *splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPage.png"]];
	splashImageView.frame = self.innerView.frame;
	splashImageView.userInteractionEnabled = YES;
	[self.innerView addSubview:splashImageView];
	
	[self.foldedCornerViewController resetToDefaultPosition];
}

- (void)viewDidAppear:(BOOL)animated {
	self.needsScreenshotUpdate = YES;
	[self updateScreenshotSynchronous:YES];
	
	[self setScreenshotVisible:YES];
	
	[self.foldedCornerViewController animatePageTurnSlower];
	
	self.innerView.hidden = YES;
}

@end