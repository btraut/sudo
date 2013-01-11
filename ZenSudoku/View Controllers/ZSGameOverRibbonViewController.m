//
//  ZSGameOverRibbonViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 8/4/12.
//
//

#import "ZSGameOverRibbonViewController.h"

#import "MTLabel.h"
#import "UIColor+colorWithHex.h"
#import "UIDevice+Resolutions.h"

@interface ZSGameOverRibbonViewController ()

@end

@interface ZSGameOverRibbonViewController () {
	UIButton *_easyButton;
	UIButton *_moderateButton;
	UIButton *_challengingButton;
	UIButton *_diabolicalButton;
	UIButton *_insaneButton;
	
	UILabel *_youJustSolvedALabel;
	UILabel *_difficultyLabel;
	UILabel *_completionTimeLabel;
	UILabel *_totalHintsLabel;
	UILabel *_totalPuzzlesLabel;
	
	UIImageView *_newRecordArrow;
}

@end

@implementation ZSGameOverRibbonViewController

@synthesize difficulty;
@synthesize completionTime;
@synthesize newRecord;
@synthesize hintsUsed;
@synthesize puzzlesSolved;

- (id)init {
	self = [super init];
	
	if (self) {
		UIDeviceResolution resolution = [UIDevice currentResolution];
		bool isiPad = (resolution == UIDevice_iPadStandardRes || resolution == UIDevice_iPadHiRes);
		
		if (isiPad) {
			self.ribbonImage = [UIImage imageNamed:@"RibbonShort-iPad.png"];
		} else {
			self.ribbonImage = [UIImage imageNamed:@"RibbonShort.png"];
		}
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIDeviceResolution resolution = [UIDevice currentResolution];
	bool isiPad = (resolution == UIDevice_iPadStandardRes || resolution == UIDevice_iPadHiRes);
	
	CGFloat labelShadowOffset;
	CGSize labelSize;
	CGSize labelSizeSmall;
	
	if (isiPad) {
		labelShadowOffset = -1;
		labelSize = CGSizeMake(375, 68);
		labelSizeSmall = CGSizeMake(375, 32);
	} else {
		labelShadowOffset = -0.5f;
		labelSize = CGSizeMake(198, 44);
		labelSizeSmall = CGSizeMake(178, 20);
	}
	
	// Finish building the title.
	titleLabel.text = @"Congrats!";
	
	// Initialize the colors.
	UIFont *whiteFont = [UIFont fontWithName:@"ReklameScript-Regular" size:(isiPad ? 60 : 35)];
	UIColor *whiteTextColor = [UIColor whiteColor];
	UIColor *whiteTextShadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	
	UIFont *redFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:(isiPad ? 24 : 12)];
	UIColor *redTextColor = [UIColor colorWithHexString:@"#7d1c0c"];
	
	// "you just solved a"
	_youJustSolvedALabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (isiPad ? 126 : 64), labelSizeSmall.width, labelSizeSmall.height)];
	_youJustSolvedALabel.backgroundColor = [UIColor clearColor];
	_youJustSolvedALabel.font = redFont;
	_youJustSolvedALabel.textColor = redTextColor;
	_youJustSolvedALabel.textAlignment = NSTextAlignmentCenter;
	_youJustSolvedALabel.text = @"you just solved a";
	[ribbonView addSubview:_youJustSolvedALabel];
	
	// "<difficulty>"
	_difficultyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (isiPad ? 162 : 79), labelSize.width, labelSize.height)];
	_difficultyLabel.backgroundColor = [UIColor clearColor];
	_difficultyLabel.font = whiteFont;
	_difficultyLabel.textColor = whiteTextColor;
	_difficultyLabel.textAlignment = NSTextAlignmentCenter;
	_difficultyLabel.shadowColor = whiteTextShadowColor;
	_difficultyLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[ribbonView addSubview:_difficultyLabel];
	
	// "puzzle in"
	UILabel *puzzleInLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (isiPad ? 238 : 121), labelSizeSmall.width, labelSizeSmall.height)];
	puzzleInLabel.backgroundColor = [UIColor clearColor];
	puzzleInLabel.font = redFont;
	puzzleInLabel.textColor = redTextColor;
	puzzleInLabel.textAlignment = NSTextAlignmentCenter;
	puzzleInLabel.text = @"puzzle in";
	[ribbonView addSubview:puzzleInLabel];
	
	// "<completion time>"
	_completionTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (isiPad ? 272 : 136), labelSize.width, labelSize.height)];
	_completionTimeLabel.backgroundColor = [UIColor clearColor];
	_completionTimeLabel.font = whiteFont;
	_completionTimeLabel.textColor = whiteTextColor;
	_completionTimeLabel.textAlignment = NSTextAlignmentCenter;
	_completionTimeLabel.shadowColor = whiteTextShadowColor;
	_completionTimeLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[ribbonView addSubview:_completionTimeLabel];
	
	// Create "New Record" arrow.
	_newRecordArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isiPad ? @"PersonalBestRight-iPad.png" : @"PersonalBestRight.png")]];
	_newRecordArrow.frame = CGRectMake((isiPad ? 310 : 164), (isiPad ? 256 : 136), _newRecordArrow.frame.size.width, _newRecordArrow.frame.size.height);
	
	// "without using hints"
	_totalHintsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (isiPad ? 341 : 174), labelSizeSmall.width, labelSizeSmall.height)];
	_totalHintsLabel.backgroundColor = [UIColor clearColor];
	_totalHintsLabel.font = redFont;
	_totalHintsLabel.textColor = redTextColor;
	_totalHintsLabel.textAlignment = NSTextAlignmentCenter;
	[ribbonView addSubview:_totalHintsLabel];
	
	// Create bottom stitching.
	if (isiPad) {
		UIImageView *bottomStitching = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Stitching-iPad.png"]];
		bottomStitching.frame = CGRectMake(31, 391, bottomStitching.frame.size.width, bottomStitching.frame.size.height);
		[ribbonView addSubview:bottomStitching];
	} else {
		UIImageView *bottomStitching = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Stitching.png"]];
		bottomStitching.frame = CGRectMake(20, 199.5f, bottomStitching.frame.size.width, bottomStitching.frame.size.height);
		[ribbonView addSubview:bottomStitching];
	}
	
	// "in this difficulty,"
	UILabel *inThisDifficultyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (isiPad ? 406 : 206), labelSizeSmall.width, labelSizeSmall.height)];
	inThisDifficultyLabel.backgroundColor = [UIColor clearColor];
	inThisDifficultyLabel.font = redFont;
	inThisDifficultyLabel.textColor = redTextColor;
	inThisDifficultyLabel.textAlignment = NSTextAlignmentCenter;
	inThisDifficultyLabel.text = @"in this difficulty,";
	[ribbonView addSubview:inThisDifficultyLabel];
	
	// "you've solved"
	UILabel *youveSolvedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (isiPad ? 432 : 219), labelSizeSmall.width, labelSizeSmall.height)];
	youveSolvedLabel.backgroundColor = [UIColor clearColor];
	youveSolvedLabel.font = redFont;
	youveSolvedLabel.textColor = redTextColor;
	youveSolvedLabel.textAlignment = NSTextAlignmentCenter;
	youveSolvedLabel.text = @"you've solved";
	[ribbonView addSubview:youveSolvedLabel];
	
	// "<total puzzles> puzzles!"
	_totalPuzzlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (isiPad ? 470 : 236), labelSize.width, labelSize.height)];
	_totalPuzzlesLabel.backgroundColor = [UIColor clearColor];
	_totalPuzzlesLabel.font = whiteFont;
	_totalPuzzlesLabel.textColor = whiteTextColor;
	_totalPuzzlesLabel.textAlignment = NSTextAlignmentCenter;
	_totalPuzzlesLabel.shadowColor = whiteTextShadowColor;
	_totalPuzzlesLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[ribbonView addSubview:_totalPuzzlesLabel];
}

- (void)showRibbon {
	switch (difficulty) {
		case ZSGameDifficultyModerate:
		case ZSGameDifficultyChallenging:
		case ZSGameDifficultyDiabolical:
			_youJustSolvedALabel.text = @"you just solved a";
			break;
			
		case ZSGameDifficultyEasy:
		case ZSGameDifficultyInsane:
			_youJustSolvedALabel.text = @"you just solved an";
			break;
	}
	
	switch (difficulty) {
		case ZSGameDifficultyEasy: _difficultyLabel.text = @"Easy"; break;
		case ZSGameDifficultyModerate: _difficultyLabel.text = @"Moderate"; break;
		case ZSGameDifficultyChallenging: _difficultyLabel.text = @"Challenging"; break;
		case ZSGameDifficultyDiabolical: _difficultyLabel.text = @"Diabolical"; break;
		case ZSGameDifficultyInsane: _difficultyLabel.text = @"Insane"; break;
	}
	
	_completionTimeLabel.text = [self _formatedCompletionTime];
	
	[_newRecordArrow removeFromSuperview];
	
	if (self.hintsUsed == 1) {
		_totalHintsLabel.text = @"with only one hint";
	} else if (self.hintsUsed > 1 && self.hintsUsed <= 3) {
		_totalHintsLabel.text = [NSString stringWithFormat:@"with only %i hints", self.hintsUsed];
	} else if (self.hintsUsed > 3) {
		_totalHintsLabel.text = [NSString stringWithFormat:@"with %i hints", self.hintsUsed];
	} else {
		_totalHintsLabel.text = @"without using any hints";
	}
	
	if (self.puzzlesSolved == 1) {
		_totalPuzzlesLabel.text = @"1 puzzle!";
	} else {
		_totalPuzzlesLabel.text = [NSString stringWithFormat:@"%i puzzles!", self.puzzlesSolved];
	}
	
	[super showRibbon];
}

- (NSString *)_formatedCompletionTime {
	NSTimeInterval remainingInterval = self.completionTime;
	NSMutableString *timeString = [NSMutableString string];
	
	// Days
	if (remainingInterval >= 24 * 60 * 60) {
		NSInteger totalDays = remainingInterval / (24 * 60 * 60);
		remainingInterval -= totalDays * (24 * 60 * 60);
		
		[timeString appendString:[NSString stringWithFormat:@"%id", totalDays]];
	}
	
	// Hours
	if (remainingInterval >= 60 * 60) {
		NSInteger totalHours = remainingInterval / (60 * 60);
		remainingInterval -= totalHours * (60 * 60);
		
		if (timeString.length) {
			[timeString appendString:@" "];
		}
		
		[timeString appendString:[NSString stringWithFormat:@"%ih", totalHours]];
	}
	
	// Minutes
	if (remainingInterval >= 60) {
		NSInteger totalMinutes = remainingInterval / (60);
		remainingInterval -= totalMinutes * (60);
		
		if (timeString.length) {
			[timeString appendString:@" "];
		}
		
		[timeString appendString:[NSString stringWithFormat:@"%im", totalMinutes]];
	}
	
	// Seconds
	{
		NSInteger totalSeconds = remainingInterval;
		
		if (timeString.length) {
			[timeString appendString:@" "];
		}
		
		[timeString appendString:[NSString stringWithFormat:@"%is", totalSeconds]];
	}
	
	return timeString;
}

- (void)ribbonFinishedShowing {
	[super ribbonFinishedShowing];
	
	// Debug
	if (self.newRecord) {
		CGRect originalFrame = _newRecordArrow.frame;
		
		_newRecordArrow.alpha = 0;
		_newRecordArrow.frame = CGRectMake(originalFrame.origin.x - originalFrame.size.width, originalFrame.origin.y - originalFrame.size.height, originalFrame.size.width * 3, originalFrame.size.height * 3);
		
		[ribbonView addSubview:_newRecordArrow];
		
		[UIView
		 animateWithDuration:0.4f
		 delay:0
		 options:UIViewAnimationOptionCurveEaseOut
		 animations:^{
			 _newRecordArrow.frame = originalFrame;
			 _newRecordArrow.alpha = 1;
		 }
		 completion:NULL];
	}
}

@end
