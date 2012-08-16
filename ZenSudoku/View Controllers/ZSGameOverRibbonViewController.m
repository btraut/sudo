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
		self.ribbonImage = [UIImage imageNamed:@"RibbonShort.png"];
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Finish building the title.
	titleLabel.text = @"Congrats!";
	
	// Initialize the colors.
	UIFont *whiteFont = [UIFont fontWithName:@"ReklameScript-Regular" size:35.0f];
	UIColor *whiteTextColor = [UIColor whiteColor];
	UIColor *whiteTextShadowColor = [UIColor colorWithHexString:@"#7d1c0c"];
	
	UIFont *redFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
	UIColor *redTextColor = [UIColor colorWithHexString:@"#7d1c0c"];
	
	// "you just solved a"
	_youJustSolvedALabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 64, 178, 20)];
	_youJustSolvedALabel.backgroundColor = [UIColor clearColor];
	_youJustSolvedALabel.font = redFont;
	_youJustSolvedALabel.textColor = redTextColor;
	_youJustSolvedALabel.textAlignment = UITextAlignmentCenter;
	_youJustSolvedALabel.text = @"you just solved a";
	[ribbonView addSubview:_youJustSolvedALabel];
	
	// "<difficulty>"
	_difficultyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 79, 178, 44)];
	_difficultyLabel.backgroundColor = [UIColor clearColor];
	_difficultyLabel.font = whiteFont;
	_difficultyLabel.textColor = whiteTextColor;
	_difficultyLabel.textAlignment = UITextAlignmentCenter;
	_difficultyLabel.shadowColor = whiteTextShadowColor;
	_difficultyLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[ribbonView addSubview:_difficultyLabel];
	
	// "puzzle in"
	UILabel *puzzleInLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 121, 178, 20)];
	puzzleInLabel.backgroundColor = [UIColor clearColor];
	puzzleInLabel.font = redFont;
	puzzleInLabel.textColor = redTextColor;
	puzzleInLabel.textAlignment = UITextAlignmentCenter;
	puzzleInLabel.text = @"puzzle in";
	[ribbonView addSubview:puzzleInLabel];
	
	// "<completion time>"
	_completionTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 136, 178, 44)];
	_completionTimeLabel.backgroundColor = [UIColor clearColor];
	_completionTimeLabel.font = whiteFont;
	_completionTimeLabel.textColor = whiteTextColor;
	_completionTimeLabel.textAlignment = UITextAlignmentCenter;
	_completionTimeLabel.shadowColor = whiteTextShadowColor;
	_completionTimeLabel.shadowOffset = CGSizeMake(0, -0.5f);
	[ribbonView addSubview:_completionTimeLabel];
	
	// Create "New Record" arrow.
	_newRecordArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PersonalBestRight.png"]];
	_newRecordArrow.frame = CGRectMake(164, 136, _newRecordArrow.frame.size.width, _newRecordArrow.frame.size.height);
	
	// "without using hints"
	_totalHintsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 174, 178, 20)];
	_totalHintsLabel.backgroundColor = [UIColor clearColor];
	_totalHintsLabel.font = redFont;
	_totalHintsLabel.textColor = redTextColor;
	_totalHintsLabel.textAlignment = UITextAlignmentCenter;
	[ribbonView addSubview:_totalHintsLabel];
	
	// Create bottom stitching.
	UIImageView *bottomStitching = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Stitching.png"]];
	bottomStitching.frame = CGRectMake(20, 199.5f, bottomStitching.frame.size.width, bottomStitching.frame.size.height);
	[ribbonView addSubview:bottomStitching];
	
	// "in this difficulty,"
	UILabel *inThisDifficultyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 206, 178, 20)];
	inThisDifficultyLabel.backgroundColor = [UIColor clearColor];
	inThisDifficultyLabel.font = redFont;
	inThisDifficultyLabel.textColor = redTextColor;
	inThisDifficultyLabel.textAlignment = UITextAlignmentCenter;
	inThisDifficultyLabel.text = @"in this difficulty,";
	[ribbonView addSubview:inThisDifficultyLabel];
	
	// "you've solved"
	UILabel *youveSolvedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 219, 178, 20)];
	youveSolvedLabel.backgroundColor = [UIColor clearColor];
	youveSolvedLabel.font = redFont;
	youveSolvedLabel.textColor = redTextColor;
	youveSolvedLabel.textAlignment = UITextAlignmentCenter;
	youveSolvedLabel.text = @"you've solved";
	[ribbonView addSubview:youveSolvedLabel];
	
	// "<total puzzles> puzzles!"
	_totalPuzzlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 236, 178, 44)];
	_totalPuzzlesLabel.backgroundColor = [UIColor clearColor];
	_totalPuzzlesLabel.font = whiteFont;
	_totalPuzzlesLabel.textColor = whiteTextColor;
	_totalPuzzlesLabel.textAlignment = UITextAlignmentCenter;
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
