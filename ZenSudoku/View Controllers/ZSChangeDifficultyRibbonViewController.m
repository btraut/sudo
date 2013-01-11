//
//  ZSChangeDifficultyRibbonViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 8/4/12.
//
//

#import "ZSChangeDifficultyRibbonViewController.h"

#import "ZSAppDelegate.h"
#import "UIColor+colorWithHex.h"
#import "UIDevice+Resolutions.h"

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

- (id)init {
	self = [super init];
	
	if (self) {
#ifdef FREEVERSION
		// The free version needs a little extra ribbon for the up-sell ad.
		self.ribbonImage = [UIImage imageNamed:@"RibbonLong.png"];
#endif
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIDeviceResolution resolution = [UIDevice currentResolution];
	bool isiPad = (resolution == UIDevice_iPadStandardRes || resolution == UIDevice_iPadHiRes);
	
	CGFloat labelFontSize;
	CGFloat labelShadowOffset;
	CGSize labelSize;
	
	if (isiPad) {
		labelFontSize = 60;
		labelShadowOffset = -1;
		labelSize = CGSizeMake(375, 68);
	} else {
		labelFontSize = 35;
		labelShadowOffset = -0.5f;
		labelSize = CGSizeMake(198, 44);
	}
	
	// Finish building the title.
	titleLabel.text = @"New Game";
	
	// Initialize the colors.
	UIColor *shadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	UIColor *textColor = [UIColor whiteColor];
	UIColor *textColorHighlighted = [UIColor colorWithHexString:@"#7d1c0c"];
	
#ifdef FREEVERSION
	// Build the difficulty buttons. The spaces in the titles are significant because the font gets clipped otherwise.
	_easyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_easyButton.tag = ZSGameDifficultyEasy;
	_easyButton.frame = CGRectMake(0, 66, labelSize.width, labelSize.height);
	_easyButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	_easyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_easyButton.titleLabel.shadowColor = shadowColor;
	_easyButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[_easyButton setTitleColor:textColorHighlighted forState:UIControlStateNormal];
	[_easyButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_easyButton setTitle:@" Easy " forState:UIControlStateNormal];
	[_easyButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_easyButton];
	
	_diabolicalButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_diabolicalButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_diabolicalButton.tag = ZSGameDifficultyDiabolical;
	_diabolicalButton.frame = CGRectMake(0, 110, labelSize.width, labelSize.height);
	_diabolicalButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	_diabolicalButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_diabolicalButton.titleLabel.shadowColor = shadowColor;
	_diabolicalButton.titleLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[_diabolicalButton setTitleColor:textColor forState:UIControlStateNormal];
	[_diabolicalButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_diabolicalButton setTitle:@" Diabolical " forState:UIControlStateNormal];
	[_diabolicalButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_diabolicalButton];
	
	// Create bottom stitching.
	UIImageView *bottomStitching = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Stitching.png"]];
	bottomStitching.frame = CGRectMake(20, 160, bottomStitching.frame.size.width, bottomStitching.frame.size.height);
	[ribbonView addSubview:bottomStitching];
	
	// Create full version ad container.
	UIView *adContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 164, 198, 176)];
	[ribbonView addSubview:adContainer];
	
	UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(_adContainerWasTapped)];
	singleTapRecognizer.numberOfTapsRequired = 1;
	[adContainer addGestureRecognizer:singleTapRecognizer];
	
	UIFont *redFont = [UIFont fontWithName:@"ReklameScript-Medium" size:15.0f];
	UIColor *redTextColor = [UIColor colorWithHexString:@"#7d1c0c"];
	
	// Create the top label.
	UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 6, 140, 20)];
	topLabel.backgroundColor = [UIColor clearColor];
	topLabel.font = redFont;
	topLabel.textColor = redTextColor;
	topLabel.textAlignment = UITextAlignmentLeft;
	topLabel.text = @"✓ More difficulties";
	[adContainer addSubview:topLabel];
	
	UILabel *topLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(28, 24, 140, 20)];
	topLabel2.backgroundColor = [UIColor clearColor];
	topLabel2.font = redFont;
	topLabel2.textColor = redTextColor;
	topLabel2.textAlignment = UITextAlignmentLeft;
	topLabel2.text = @"✓ Thousands of puzzles";
	[adContainer addSubview:topLabel2];
	
	UILabel *topLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(28, 42, 140, 20)];
	topLabel3.backgroundColor = [UIColor clearColor];
	topLabel3.font = redFont;
	topLabel3.textColor = redTextColor;
	topLabel3.textAlignment = UITextAlignmentLeft;
	topLabel3.text = @"✓ No ads";
	[adContainer addSubview:topLabel3];
	
	// Create the icon.
	UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconWithShadow.png"]];
	icon.center = CGPointMake(99, 100);
	[adContainer addSubview:icon];
	
	// Create the bottom label.
	UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 132, 162, 20)];
	bottomLabel.backgroundColor = [UIColor clearColor];
	bottomLabel.font = [UIFont fontWithName:@"ReklameScript-Medium" size:17.0f];
	bottomLabel.textColor = [UIColor whiteColor];
	bottomLabel.textAlignment = NSTextAlignmentCenter;
	bottomLabel.text = @"Sudo";
	[adContainer addSubview:bottomLabel];
	
	// Create the bottom label.
	UILabel *bottomLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(18, 148, 162, 20)];
	bottomLabel2.backgroundColor = [UIColor clearColor];
	bottomLabel2.font = [UIFont fontWithName:@"ReklameScript-Regular" size:14.0f];
	bottomLabel2.textColor = redTextColor;
	bottomLabel2.textAlignment = NSTextAlignmentCenter;
	bottomLabel2.text = @"tap to visit app store";
	[adContainer addSubview:bottomLabel2];
#else
	// Build the difficulty buttons. The spaces in the titles are significant because the font gets clipped otherwise.
	_easyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_easyButton.tag = ZSGameDifficultyEasy;
	_easyButton.frame = CGRectMake(0, (isiPad ? 132 : 75), labelSize.width, labelSize.height);
	_easyButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:labelFontSize];
	_easyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_easyButton.titleLabel.shadowColor = shadowColor;
	_easyButton.titleLabel.shadowOffset = CGSizeMake(0, labelShadowOffset);
	[_easyButton setTitleColor:textColorHighlighted forState:UIControlStateNormal];
	[_easyButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_easyButton setTitle:@" Easy " forState:UIControlStateNormal];
	[_easyButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_easyButton];
	
	_moderateButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_moderateButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_moderateButton.tag = ZSGameDifficultyModerate;
	_moderateButton.frame = CGRectMake(0, (isiPad ? 220 : 121), labelSize.width, labelSize.height);
	_moderateButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:labelFontSize];
	_moderateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_moderateButton.titleLabel.shadowColor = shadowColor;
	_moderateButton.titleLabel.shadowOffset = CGSizeMake(0, labelShadowOffset);
	[_moderateButton setTitleColor:textColor forState:UIControlStateNormal];
	[_moderateButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_moderateButton setTitle:@" Moderate " forState:UIControlStateNormal];
	[_moderateButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_moderateButton];
	
	_challengingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_challengingButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_challengingButton.tag = ZSGameDifficultyChallenging;
	_challengingButton.frame = CGRectMake(0, (isiPad ? 308 : 167), labelSize.width, labelSize.height);
	_challengingButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:labelFontSize];
	_challengingButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_challengingButton.titleLabel.shadowColor = shadowColor;
	_challengingButton.titleLabel.shadowOffset = CGSizeMake(0, labelShadowOffset);
	[_challengingButton setTitleColor:textColor forState:UIControlStateNormal];
	[_challengingButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_challengingButton setTitle:@" Challenging " forState:UIControlStateNormal];
	[_challengingButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_challengingButton];
	
	_diabolicalButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_diabolicalButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_diabolicalButton.tag = ZSGameDifficultyDiabolical;
	_diabolicalButton.frame = CGRectMake(0, (isiPad ? 396 : 213), labelSize.width, labelSize.height);
	_diabolicalButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:labelFontSize];
	_diabolicalButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_diabolicalButton.titleLabel.shadowColor = shadowColor;
	_diabolicalButton.titleLabel.shadowOffset = CGSizeMake(0, labelShadowOffset);
	[_diabolicalButton setTitleColor:textColor forState:UIControlStateNormal];
	[_diabolicalButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_diabolicalButton setTitle:@" Diabolical " forState:UIControlStateNormal];
	[_diabolicalButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_diabolicalButton];
	
	_insaneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_insaneButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_insaneButton.tag = ZSGameDifficultyInsane;
	_insaneButton.frame = CGRectMake(0, (isiPad ? 484 : 259), labelSize.width, labelSize.height);
	_insaneButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Regular" size:labelFontSize];
	_insaneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_insaneButton.titleLabel.shadowColor = shadowColor;
	_insaneButton.titleLabel.shadowOffset = CGSizeMake(0, labelShadowOffset);
	[_insaneButton setTitleColor:textColor forState:UIControlStateNormal];
	[_insaneButton setTitleColor:textColorHighlighted forState:UIControlStateHighlighted];
	[_insaneButton setTitle:@" Insane " forState:UIControlStateNormal];
	[_insaneButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[ribbonView addSubview:_insaneButton];
#endif
}

- (void)_adContainerWasTapped {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[UIApplication sharedApplication] openURL:appDelegate.iTunesURL];
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
