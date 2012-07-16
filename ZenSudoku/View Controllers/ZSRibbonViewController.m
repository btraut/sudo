//
//  ZSRibbonViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 7/16/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSRibbonViewController.h"

#import "UIColor+ColorWithHex.h"

@interface ZSRibbonViewController ()

@end

@implementation ZSRibbonViewController

@synthesize delegate;

- (void)loadView {
	UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ribbon.png"]];
	view.frame = CGRectMake(53, -329, 213, 329);
	view.userInteractionEnabled = YES;
	self.view = view;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Build the title.
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 213, 40)];
	title.font = [UIFont fontWithName:@"ReklameScript-Medium" size:36.0f];
	title.textAlignment = UITextAlignmentCenter;
	title.backgroundColor = [UIColor clearColor];
	title.textColor = [UIColor whiteColor];
	title.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	title.shadowOffset = CGSizeMake(0, -0.5f);
	title.text = @"Difficulties";
	[self.view addSubview:title];
	
	// Build the difficulty buttons.
	UIButton *easyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[easyButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	easyButton.tag = ZSGameDifficultyEasy;
	easyButton.frame = CGRectMake(0, 75, 213, 30);
	easyButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	easyButton.titleLabel.textAlignment = UITextAlignmentCenter;
	easyButton.titleLabel.textColor = [UIColor whiteColor];
	easyButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	easyButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[easyButton setTitle:@"Easy" forState:UIControlStateNormal];
	[self.view addSubview:easyButton];
	
	UIButton *moderateButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[moderateButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	easyButton.tag = ZSGameDifficultyModerate;
	moderateButton.frame = CGRectMake(0, 121, 213, 30);
	moderateButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	moderateButton.titleLabel.textAlignment = UITextAlignmentCenter;
	moderateButton.titleLabel.textColor = [UIColor whiteColor];
	moderateButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	moderateButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[moderateButton setTitle:@"Moderate" forState:UIControlStateNormal];
	[self.view addSubview:moderateButton];
	
	UIButton *challengingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[challengingButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	easyButton.tag = ZSGameDifficultyChallenging;
	challengingButton.frame = CGRectMake(0, 167, 213, 30);
	challengingButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	challengingButton.titleLabel.textAlignment = UITextAlignmentCenter;
	challengingButton.titleLabel.textColor = [UIColor whiteColor];
	challengingButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	challengingButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[challengingButton setTitle:@"Challenging" forState:UIControlStateNormal];
	[self.view addSubview:challengingButton];
	
	UIButton *diabolicalButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[diabolicalButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	easyButton.tag = ZSGameDifficultyDiabolical;
	diabolicalButton.frame = CGRectMake(0, 213, 213, 30);
	diabolicalButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	diabolicalButton.titleLabel.textAlignment = UITextAlignmentCenter;
	diabolicalButton.titleLabel.textColor = [UIColor whiteColor];
	diabolicalButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	diabolicalButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[diabolicalButton setTitle:@"Diabolical" forState:UIControlStateNormal];
	[self.view addSubview:diabolicalButton];
	
	UIButton *insaneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[insaneButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	easyButton.tag = ZSGameDifficultyInsane;
	insaneButton.frame = CGRectMake(0, 259, 213, 30);
	insaneButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	insaneButton.titleLabel.textAlignment = UITextAlignmentCenter;
	insaneButton.titleLabel.textColor = [UIColor whiteColor];
	insaneButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	insaneButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[insaneButton setTitle:@"Insane" forState:UIControlStateNormal];
	[self.view addSubview:insaneButton];
}

- (void)_difficultyButtonWasPressed:(id)sender {
	
}

@end
