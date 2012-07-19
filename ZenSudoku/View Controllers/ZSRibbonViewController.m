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
	UIImageView *_ribbonView;
	
	UISwipeGestureRecognizer *_upSwipeGestureRecognizer;
	UITapGestureRecognizer *_ribbonTapGestureRecognizer;
}

@end

@implementation ZSRibbonViewController

@synthesize delegate;
@synthesize shown = _shown;

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Build the overlay.
	UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	[self.view addSubview:overlay];
	
	_upSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideRibbon)];
	_upSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
	
	_ribbonTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideRibbon)];
	
	[overlay addGestureRecognizer:_upSwipeGestureRecognizer];
	[overlay addGestureRecognizer:_ribbonTapGestureRecognizer];
	
	// Build the ribbon.
	_ribbonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ribbon.png"]];
	_ribbonView.frame = CGRectMake(61, -329, 198, 329);
	_ribbonView.userInteractionEnabled = YES;
	[self.view addSubview:_ribbonView];
	
	// Build the title.
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, 198, 40)];
	title.font = [UIFont fontWithName:@"ReklameScript-Medium" size:36.0f];
	title.textAlignment = UITextAlignmentCenter;
	title.backgroundColor = [UIColor clearColor];
	title.textColor = [UIColor whiteColor];
	title.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	title.shadowOffset = CGSizeMake(0, -0.5f);
	title.text = @"New Game";
	[_ribbonView addSubview:title];
	
	// Build the difficulty buttons. The spaces in the titles are significant because the font gets clipped otherwise.
	UIButton *easyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	easyButton.tag = ZSGameDifficultyEasy;
	easyButton.frame = CGRectMake(0, 75, 198, 30);
	easyButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	easyButton.titleLabel.textAlignment = UITextAlignmentCenter;
	easyButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	easyButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[easyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[easyButton setTitleColor:[UIColor colorWithHexString:@"#F7FF00"] forState:UIControlStateHighlighted];
	[easyButton setTitle:@" Easy " forState:UIControlStateNormal];
	[easyButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[_ribbonView addSubview:easyButton];
	
	UIButton *moderateButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[moderateButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	moderateButton.tag = ZSGameDifficultyModerate;
	moderateButton.frame = CGRectMake(0, 121, 198, 30);
	moderateButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	moderateButton.titleLabel.textAlignment = UITextAlignmentCenter;
	moderateButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	moderateButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[moderateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[moderateButton setTitleColor:[UIColor colorWithHexString:@"#F7FF00"] forState:UIControlStateHighlighted];
	[moderateButton setTitle:@" Moderate " forState:UIControlStateNormal];
	[moderateButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[_ribbonView addSubview:moderateButton];
	
	UIButton *challengingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[challengingButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	challengingButton.tag = ZSGameDifficultyChallenging;
	challengingButton.frame = CGRectMake(0, 167, 198, 30);
	challengingButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	challengingButton.titleLabel.textAlignment = UITextAlignmentCenter;
	challengingButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	challengingButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[challengingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[challengingButton setTitleColor:[UIColor colorWithHexString:@"#F7FF00"] forState:UIControlStateHighlighted];
	[challengingButton setTitle:@" Challenging " forState:UIControlStateNormal];
	[challengingButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[_ribbonView addSubview:challengingButton];
	
	UIButton *diabolicalButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[diabolicalButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	diabolicalButton.tag = ZSGameDifficultyDiabolical;
	diabolicalButton.frame = CGRectMake(0, 213, 198, 30);
	diabolicalButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	diabolicalButton.titleLabel.textAlignment = UITextAlignmentCenter;
	diabolicalButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	diabolicalButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[diabolicalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[diabolicalButton setTitleColor:[UIColor colorWithHexString:@"#F7FF00"] forState:UIControlStateHighlighted];
	[diabolicalButton setTitle:@" Diabolical " forState:UIControlStateNormal];
	[diabolicalButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[_ribbonView addSubview:diabolicalButton];
	
	UIButton *insaneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[insaneButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	insaneButton.tag = ZSGameDifficultyInsane;
	insaneButton.frame = CGRectMake(0, 259, 198, 30);
	insaneButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	insaneButton.titleLabel.textAlignment = UITextAlignmentCenter;
	insaneButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	insaneButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[insaneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[insaneButton setTitleColor:[UIColor colorWithHexString:@"#F7FF00"] forState:UIControlStateHighlighted];
	[insaneButton setTitle:@" Insane " forState:UIControlStateNormal];
	[insaneButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[_ribbonView addSubview:insaneButton];
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
		 _ribbonView.frame = CGRectMake(53, -3, _ribbonView.frame.size.width, _ribbonView.frame.size.height);
	 }
	 completion:NULL];
}

- (void)hideRibbon {
	if (!_shown) {
		return;
	}
	
	_shown = NO;
	
	[UIView
	 animateWithDuration:0.4f
	 delay:0
	 options:UIViewAnimationOptionCurveEaseOut
	 animations:^{
		 _ribbonView.frame = CGRectMake(53, -329, _ribbonView.frame.size.width, _ribbonView.frame.size.height);
	 }
	 completion:^(BOOL finished){
		 [self.delegate hideRibbonAnimationDidFinish];
	 }];
}

- (void)_difficultyButtonWasPressed:(UIButton *)sender {
	[self.delegate difficultyWasSelected:(ZSGameDifficulty)sender.tag];
	[self hideRibbon];
}

@end
