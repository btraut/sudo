//
//  ZSHintButtonViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSHintButtonViewController.h"

@interface ZSHintButtonViewController () {
	UIImageView *_background;
}

@end

@implementation ZSHintButtonViewController

@synthesize button;
@synthesize pulsing = _pulsing;

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(205, 412, 36, 37)];
}

- (void)viewDidLoad {
	UIImage *hintsImage = [UIImage imageNamed:@"Hints"];
	
	self.button = [UIButton buttonWithType:UIButtonTypeCustom];
	self.button.frame = CGRectMake(0, 0, hintsImage.size.width, hintsImage.size.height);
	[self.button setBackgroundImage:hintsImage forState:UIControlStateNormal];
	[self.button setBackgroundImage:[UIImage imageNamed:@"HintsHighlighted"] forState:UIControlStateHighlighted];
	[self.view addSubview:self.button];
	
	_background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HintsBackground"]];
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
