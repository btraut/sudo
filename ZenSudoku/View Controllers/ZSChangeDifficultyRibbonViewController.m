//
//  ZSChangeDifficultyRibbonViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 8/4/12.
//
//

#import "ZSChangeDifficultyRibbonViewController.h"

#import "UIColor+colorWithHex.h"

@interface ZSChangeDifficultyRibbonViewController ()

@end

@interface ZSChangeDifficultyRibbonViewController () {
	UIButton *_easyButton;
	UIButton *_moderateButton;
	UIButton *_challengingButton;
	UIButton *_diabolicalButton;
	UIButton *_insaneButton;
}

@end

@implementation ZSChangeDifficultyRibbonViewController

@synthesize delegate;
@synthesize highlightedDifficulty;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Finish building the title.
	titleLabel.text = @"New Game";
	
	// Initialize the colors.
	UIColor *shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	UIColor *textColor = [UIColor whiteColor];
	UIColor *textColorHighlighted = [UIColor colorWithHexString:@"#7d1c0c"];
	
	// Build the difficulty buttons. The spaces in the titles are significant because the font gets clipped otherwise.
	_easyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_easyButton.tag = ZSGameDifficultyEasy;
	_easyButton.frame = CGRectMake(0, 75, 198, 44);
	_easyButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	_easyButton.titleLabel.textAlignment = UITextAlignmentCenter;
	_easyButton.titleLabel.shadowColor = shadowColor;
	_easyButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[_easyButton setTitleColor:textColorHighlighted forState:UIControlStateNormal];
	[_easyButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_easyButton setTitle:@" Easy " forState:UIControlStateNormal];
	[_easyButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_easyButton];
	
	_moderateButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_moderateButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_moderateButton.tag = ZSGameDifficultyModerate;
	_moderateButton.frame = CGRectMake(0, 121, 198, 44);
	_moderateButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	_moderateButton.titleLabel.textAlignment = UITextAlignmentCenter;
	_moderateButton.titleLabel.shadowColor = shadowColor;
	_moderateButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[_moderateButton setTitleColor:textColor forState:UIControlStateNormal];
	[_moderateButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_moderateButton setTitle:@" Moderate " forState:UIControlStateNormal];
	[_moderateButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_moderateButton];
	
#ifdef FREEVERSION
	
#else
	_challengingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_challengingButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_challengingButton.tag = ZSGameDifficultyChallenging;
	_challengingButton.frame = CGRectMake(0, 167, 198, 44);
	_challengingButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	_challengingButton.titleLabel.textAlignment = UITextAlignmentCenter;
	_challengingButton.titleLabel.shadowColor = shadowColor;
	_challengingButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[_challengingButton setTitleColor:textColor forState:UIControlStateNormal];
	[_challengingButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_challengingButton setTitle:@" Challenging " forState:UIControlStateNormal];
	[_challengingButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_challengingButton];
	
	_diabolicalButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_diabolicalButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_diabolicalButton.tag = ZSGameDifficultyDiabolical;
	_diabolicalButton.frame = CGRectMake(0, 213, 198, 44);
	_diabolicalButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	_diabolicalButton.titleLabel.textAlignment = UITextAlignmentCenter;
	_diabolicalButton.titleLabel.shadowColor = shadowColor;
	_diabolicalButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[_diabolicalButton setTitleColor:textColor forState:UIControlStateNormal];
	[_diabolicalButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_diabolicalButton setTitle:@" Diabolical " forState:UIControlStateNormal];
	[_diabolicalButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_diabolicalButton];
	
	_insaneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_insaneButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_insaneButton.tag = ZSGameDifficultyInsane;
	_insaneButton.frame = CGRectMake(0, 259, 198, 44);
	_insaneButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	_insaneButton.titleLabel.textAlignment = UITextAlignmentCenter;
	_insaneButton.titleLabel.shadowColor = shadowColor;
	_insaneButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[_insaneButton setTitleColor:textColor forState:UIControlStateNormal];
	[_insaneButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_insaneButton setTitle:@" Insane " forState:UIControlStateNormal];
	[_insaneButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_insaneButton];
#endif
}

- (void)_difficultyButtonWasPressed:(UIButton *)sender {
	[self.delegate difficultyWasSelected:(ZSGameDifficulty)sender.tag];
	[self hideRibbon];
}

- (void)setHighlightedDifficulty:(ZSGameDifficulty)newHighlightedDifficulty {
	if (newHighlightedDifficulty != highlightedDifficulty) {
		UIColor *textColor = [UIColor whiteColor];
		UIColor *textColorHighlighted = [UIColor colorWithHexString:@"#7d1c0c"];
		
		UIButton *previousDifficultyButton;
		UIButton *newDifficultyButton;
		
		switch (highlightedDifficulty) {
			case ZSGameDifficultyEasy: previousDifficultyButton = _easyButton; break;
			case ZSGameDifficultyModerate: previousDifficultyButton = _moderateButton; break;
			case ZSGameDifficultyChallenging: previousDifficultyButton = _challengingButton; break;
			case ZSGameDifficultyDiabolical: previousDifficultyButton = _diabolicalButton; break;
			case ZSGameDifficultyInsane: previousDifficultyButton = _insaneButton; break;
		}
		
		switch (newHighlightedDifficulty) {
			case ZSGameDifficultyEasy: newDifficultyButton = _easyButton; break;
			case ZSGameDifficultyModerate: newDifficultyButton = _moderateButton; break;
			case ZSGameDifficultyChallenging: newDifficultyButton = _challengingButton; break;
			case ZSGameDifficultyDiabolical: newDifficultyButton = _diabolicalButton; break;
			case ZSGameDifficultyInsane: newDifficultyButton = _insaneButton; break;
		}
		
		[previousDifficultyButton setTitleColor:textColor forState:UIControlStateNormal];
		[newDifficultyButton setTitleColor:textColorHighlighted forState:UIControlStateNormal];
		
		highlightedDifficulty = newHighlightedDifficulty;
	}
}

@end
