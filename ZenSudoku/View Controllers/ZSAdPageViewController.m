//
//  ZSAdPageViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 8/5/12.
//
//

#import "ZSAdPageViewController.h"

#import "FlurryAds.h"

@interface ZSAdPageViewController ()

@end

@implementation ZSAdPageViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWasPromotedToFront {
	[super viewWasPromotedToFront];
	
	BOOL adWasAvailable = [FlurryAds showAdForSpace:@"Full Page Ad" view:self.innerView size:FULLSCREEN timeout:3.0f];
	NSLog(@"%i", adWasAvailable);
}

@end
