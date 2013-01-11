//
//  ZSHintButtonViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSHintButtonViewController.h"
#import "UIDevice+Resolutions.h"

@interface ZSHintButtonViewController () {
	UIImageView *_background;
}

@end

@implementation ZSHintButtonViewController

@synthesize button;
@synthesize pulsing = _pulsing;

- (void)loadView {
	UIDeviceResolution resolution = [UIDevice currentResolution];
	bool isiPad = (resolution == UIDevice_iPadStandardRes || resolution == UIDevice_iPadHiRes);
	
	if (isiPad) {
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 59, 59)];
	} else {
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, 37)];
	}
}

- (void)viewDidLoad {
	UIDeviceResolution resolution = [UIDevice currentResolution];
	bool isiPad = (resolution == UIDevice_iPadStandardRes || resolution == UIDevice_iPadHiRes);
	
	self.button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	UIImage *hintsImage;
	UIImage *hintsBackgroundImage;
	
	if (isiPad) {
		hintsImage = [UIImage imageNamed:@"Hints-iPad"];
		[self.button setBackgroundImage:[UIImage imageNamed:@"HintsHighlighted-iPad"] forState:UIControlStateHighlighted];
		
		hintsBackgroundImage = [UIImage imageNamed:@"HintsBackground-iPad"];
	} else {
		hintsImage = [UIImage imageNamed:@"Hints"];
		[self.button setBackgroundImage:[UIImage imageNamed:@"HintsHighlighted"] forState:UIControlStateHighlighted];
		
		hintsBackgroundImage = [UIImage imageNamed:@"HintsBackground"];
	}
	
	[self.button setBackgroundImage:hintsImage forState:UIControlStateNormal];
	self.button.frame = CGRectMake(0, 0, hintsImage.size.width, hintsImage.size.height);
	[self.view addSubview:self.button];
	
	_background = [[UIImageView alloc] initWithImage:hintsBackgroundImage];
	_background.alpha = 0;
	[self.view addSubview:_background];
}

- (void)startPulsing {
	if (self.pulsing) {
		return;
	}
	
	_pulsing = YES;
	
	[self _fadeIn];
}

- (void)stopPulsing {
	if (!self.pulsing) {
		return;
	}
	
	_pulsing = NO;
}

- (void)_fadeOut {
	[UIView
	 animateWithDuration:1.5f
	 delay:0
	 options:UIViewAnimationOptionCurveEaseOut
	 animations:^{
		 _background.alpha = 0;
	 }
	 completion:^(BOOL finished){
		 if (self.pulsing) {
			 [self _fadeIn];
		 }
	 }];
}

- (void)_fadeIn {
	[UIView
	 animateWithDuration:1.5f
	 delay:0
	 options:UIViewAnimationOptionCurveEaseOut
	 animations:^{
		 _background.alpha = 1.0f;
	 }
	 completion:^(BOOL finished){
		 [self _fadeOut];
	 }];
}

@end
