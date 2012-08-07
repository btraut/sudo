//
//  ZSRibbonViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 7/16/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSRibbonViewController.h"

#import "UIColor+ColorWithHex.h"

@interface ZSRibbonViewController () {
	UISwipeGestureRecognizer *_upSwipeGestureRecognizer;
	UITapGestureRecognizer *_ribbonTapGestureRecognizer;
	
	UIView *_overlay;
}

@end

@implementation ZSRibbonViewController

@synthesize ribbonImage;
@synthesize shown = _shown;
@synthesize delegate;

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Build the overlay.
	_overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	[self.view addSubview:_overlay];
	
	_upSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideRibbon)];
	_upSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
	
	_ribbonTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideRibbon)];
	
	// Build the ribbon.
	if (self.ribbonImage == nil) {
		self.ribbonImage = [UIImage imageNamed:@"Ribbon.png"];
	}
	
	ribbonView = [[UIImageView alloc] initWithImage:self.ribbonImage];
	ribbonView.frame = CGRectMake((320 - ribbonView.frame.size.width) / 2, -ribbonView.frame.size.height, ribbonView.frame.size.width, ribbonView.frame.size.height);
	ribbonView.userInteractionEnabled = YES;
	[self.view addSubview:ribbonView];
	
	// Initialize the colors.
	UIColor *shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	UIColor *textColor = [UIColor whiteColor];
	
	// Build the title.
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, 198, 40)];
	titleLabel.font = [UIFont fontWithName:@"ReklameScript-Medium" size:36.0f];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = textColor;
	titleLabel.shadowColor = shadowColor;
	titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[ribbonView addSubview:titleLabel];
	
	// Create top stitching.
	UIImageView *topStitching = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Stitching.png"]];
	topStitching.frame = CGRectMake(20, 58, topStitching.frame.size.width, topStitching.frame.size.height);
	[ribbonView addSubview:topStitching];
}

- (void)showRibbon {
	if (_shown) {
		return;
	}
	
	_shown = YES;
	
	[UIView
	 animateWithDuration:0.4f
	 delay:0
	 options:UIViewAnimationOptionCurveEaseOut
	 animations:^{
		 ribbonView.frame = CGRectMake(ribbonView.frame.origin.x, -3, ribbonView.frame.size.width, ribbonView.frame.size.height);
	 }
	 completion:^(BOOL finished){
		 [self ribbonFinishedShowing];
	 }];
}

- (void)hideRibbon {
	if (!_shown) {
		return;
	}
	
	_shown = NO;
	
	[self.view removeGestureRecognizer:_upSwipeGestureRecognizer];
	[_overlay removeGestureRecognizer:_ribbonTapGestureRecognizer];
	
	[UIView
	 animateWithDuration:0.4f
	 delay:0
	 options:UIViewAnimationOptionCurveEaseOut
	 animations:^{
		 ribbonView.frame = CGRectMake(ribbonView.frame.origin.x, -ribbonView.frame.size.height, ribbonView.frame.size.width, ribbonView.frame.size.height);
	 }
	 completion:^(BOOL finished){
		 [self ribbonFinishedHiding];
	 }];
}

- (void)ribbonFinishedShowing {
	[self.view addGestureRecognizer:_upSwipeGestureRecognizer];
	[_overlay addGestureRecognizer:_ribbonTapGestureRecognizer];
}

- (void)ribbonFinishedHiding {
	[self.delegate hideRibbonAnimationDidFinish];
}

@end
