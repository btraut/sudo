//
//  ZSGameViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ZSGameViewController.h"
#import "ZSBoardViewController.h"
#import "ZSGame.h"
#import "ZSBoard.h"
#import "ZSAppDelegate.h"
#import "ZSHistoryEntry.h"
#import "ZSGameController.h"
#import "ZSHintGenerator.h"
#import "ZSHintCard.h"
#import "ZSTile.h"
#import "UIColor+ColorWithHex.h"
#import "ZSHintButtonViewController.h"
#import "UIDevice+Resolutions.h"

#import "Flurry.h"

typedef struct {
	NSInteger row;
	NSInteger col;
	NSInteger pencilNumber;
	BOOL isSet;
} ZSGameViewControllerPencilChangeDescription;

@interface ZSGameViewController() {
	UILabel *title;
	UIButton *_difficultyButton;
	
	UIImageView *_tapToChangeDifficultyNotice;
	NSTimer *_tapToChangeDifficultyNoticeTimer;
	
	CGPoint _foldStartPoint;
	BOOL _foldedCornerTouchCrossedTapThreshold;
	
	NSArray *_hintDeck;
	
	dispatch_queue_t _hintGenerationDispatchQueue;
	dispatch_group_t _hintGenerationDispatchGroup;
	
	NSTimer *_hintButtonEvalutePulsingTimer;
	
	BOOL _guessInSameTileWasJustMade;
	ZSTileViewController *_lastTileToReceiveGuess;
	NSInteger _totalPencilChangesSinceLastGuess;
	ZSGameViewControllerPencilChangeDescription *_pencilChangesSinceLastGuess;
	
	NSTimer *_backgroundProcessTimer;
	NSInteger _backgroundProcessTimerCount;
	
	ZSTileViewController *_lastModifiedTileViewController;
}

@property (strong) ZSFoldedCornerPlusButtonViewController *foldedCornerPlusButtonViewController;

@property (assign) BOOL needsScreenshotUpdate;

@property (assign) BOOL needsHintDeckUpdate;
@property (strong) NSArray *hintDeck;

// Button Handlers
- (void)pencilButtonWasTouched;
- (void)autoPencilButtonWasTouched;
- (void)undoButtonWasTouched;
- (void)redoButtonWasTouched;

- (void)hintButtonWasTouched;
- (void)closeHintButtonWasTouched;

@end

@implementation ZSGameViewController

@synthesize game;
@synthesize active;
@synthesize boardViewController, gameAnswerOptionsViewController;
@synthesize penciling;
@synthesize allowsInput;
@synthesize solved;
@synthesize hintDelegate;
@dynamic animationDelegate;
@synthesize difficultyButtonDelegate;
@synthesize actionWasMadeOnPuzzle = _actionWasMadeOnPuzzle;

@synthesize foldedCornerPlusButtonViewController = _foldedCornerPlusButtonViewController;
@synthesize needsScreenshotUpdate = _needsScreenshotUpdate;
@synthesize hintDeck = _hintDeck;
@synthesize needsHintDeckUpdate = _needsHintDeckUpdate;

#pragma mark - Construction / Deconstruction

- (id)initWithGame:(ZSGame *)newGame {
	self = [self init];
	
	if (self) {
		game = newGame;
		game.stateChangeDelegate = self;
		
		hintGenerator = [[ZSHintGenerator alloc] initWithSize:game.board.size];
		[hintGenerator copyClueMaskFromGameBoard:self.game.board];
		
		penciling = NO;
		
		allowsInput = YES;
		solved = NO;
		
		_foldedCornerTouchCrossedTapThreshold = NO;
		
		_hintGenerationDispatchQueue = dispatch_queue_create("com.tenfoursoftware.hintGenerationQueue", NULL);
		_hintGenerationDispatchGroup = dispatch_group_create();
		
		_guessInSameTileWasJustMade = NO;
		_lastTileToReceiveGuess = nil;
		_totalPencilChangesSinceLastGuess = 0;
		_pencilChangesSinceLastGuess = malloc(sizeof(ZSGameViewControllerPencilChangeDescription) * 81 * 9 * 3);
		
		_actionWasMadeOnPuzzle = NO;
	}
	
	return self;
}

- (void)resetWithGame:(ZSGame *)newGame {
	self.game = newGame;
	newGame.stateChangeDelegate = self;
	
	[hintGenerator clearClueMask];
	[hintGenerator copyClueMaskFromGameBoard:self.game.board];
	
	self.allowsInput = YES;
	self.solved = NO;
	
	pencilButton.enabled = YES;
	
	undoButton.enabled = YES;
	autoPencilButton.enabled = YES;
	hintButtonViewController.button.enabled = YES;
	
	penciling = NO;
	pencilButton.selected = NO;
	
	_guessInSameTileWasJustMade = NO;
	_lastTileToReceiveGuess = nil;
	_totalPencilChangesSinceLastGuess = 0;
	
	_actionWasMadeOnPuzzle = NO;
	
	[self setTitle];
	
	[self.boardViewController resetWithGame:newGame];
	[self.gameAnswerOptionsViewController reloadView];
	
	[self _setErrors];
	[boardViewController reloadView];
	
	[self.foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateHidden animated:NO];
		
	self.needsScreenshotUpdate = YES;
	[self setScreenshotVisible:NO];
}

- (void)dealloc {
	free(_pencilChangesSinceLastGuess);
}

#pragma mark - View Lifecycle

- (void)loadView {
	[super loadView];
	
	UIDeviceResolution resolution = [UIDevice currentResolution];
	
	switch (resolution) {
		case UIDevice_iPadStandardRes:
		case UIDevice_iPadHiRes:
			self.view.frame = CGRectMake(0, 0, 753, 1004);
			break;
			
		case UIDevice_iPhoneTallerHiRes:
			self.view.frame = CGRectMake(0, 0, 314, 548);
			break;
			
		default:
			self.view.frame = CGRectMake(0, 0, 314, 460);
			break;
	}
}

- (void)viewDidLoad {
	// Super duper!
	[super viewDidLoad];
	
	// We need the resolution for a bunch of positioning and sizing.
	UIDeviceResolution resolution = [UIDevice currentResolution];
	bool isiPad = (resolution == UIDevice_iPadStandardRes || resolution == UIDevice_iPadHiRes);
	
	CGFloat difficultyButtonFontSize;
	CGRect difficultyButtonFrame;
	CGSize difficultyButtonShadowSize;
	CGPoint boardPosition;
	
	switch (resolution) {
		case UIDevice_iPadStandardRes:
		case UIDevice_iPadHiRes:
			difficultyButtonFontSize = 60.0f;
			difficultyButtonFrame = CGRectMake(226, 32, 300, 68);
			difficultyButtonShadowSize = CGSizeMake(0, 1.0f);
			boardPosition = CGPointMake(72, 132);
			break;
			
		default:
			difficultyButtonFontSize = 30.0f;
			difficultyButtonFrame = CGRectMake(70, 12, 180, 36);
			difficultyButtonShadowSize = CGSizeMake(0, 0.5f);
			boardPosition = CGPointMake(8, 54);
			break;
	}
	
	// Build the plus button.
	self.foldedCornerPlusButtonViewController = [[ZSFoldedCornerPlusButtonViewController alloc] init];
	self.foldedCornerPlusButtonViewController.animationDelegate = self;
	[self.view insertSubview:self.foldedCornerPlusButtonViewController.view aboveSubview:self.innerView];
	[self.foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateHidden animated:NO];
	
	// Set the plus button (delegate) on the folded corner.
	self.foldedCornerViewController.plusButtonViewController = self.foldedCornerPlusButtonViewController;
	
	// Build the reminder for how to change difficulty.
	if (isiPad) {
		_tapToChangeDifficultyNotice = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TapToChangeDifficultyNotice-iPad.png"]];
	} else {
		_tapToChangeDifficultyNotice = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TapToChangeDifficultyNotice.png"]];
	}
	
	[self.innerView addSubview:_tapToChangeDifficultyNotice];
	
	// Build the title.
	_difficultyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_difficultyButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	_difficultyButton.frame = difficultyButtonFrame;
	_difficultyButton.titleLabel.font = [UIFont fontWithName:@"ReklameScript-Medium" size:difficultyButtonFontSize];
	_difficultyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_difficultyButton.titleLabel.shadowOffset = difficultyButtonShadowSize;
	[_difficultyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_difficultyButton setTitleColor:[UIColor colorWithHexString:@"#e2412c"] forState:UIControlStateHighlighted];
	[_difficultyButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_difficultyButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[_difficultyButton addTarget:self action:@selector(_difficultyButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.innerView addSubview:_difficultyButton];
	
	[self setTitle];
	
	UITapGestureRecognizer *titleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_difficultyButtonWasPressed:)];
	[title addGestureRecognizer:titleTapGestureRecognizer];
	
	// Build the game board.
	boardViewController = [[ZSBoardViewController alloc] initWithGame:game];
	boardViewController.view.frame = CGRectMake(boardPosition.x, boardPosition.y, boardViewController.view.frame.size.width, boardViewController.view.frame.size.height);
	boardViewController.touchDelegate = self;
	[self.innerView addSubview:boardViewController.view];
	
	// Different screen sizes call for different sizes/configurations of answer options.
	if (resolution == UIDevice_iPhoneTallerHiRes) {
		UIImageView *horizontalRule = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HorizontalRule.png"]];
		horizontalRule.frame = CGRectMake(36, 481, horizontalRule.frame.size.width, horizontalRule.frame.size.height);
		[self.innerView addSubview:horizontalRule];
		
		// Build the answer options.
		gameAnswerOptionsViewController = [[ZSAnswerOptionsTallViewController alloc] initWithGameViewController:self];
		gameAnswerOptionsViewController.view.frame = CGRectMake(34, 376, gameAnswerOptionsViewController.view.frame.size.width, gameAnswerOptionsViewController.view.frame.size.height);
		gameAnswerOptionsViewController.touchDelegate = self;
		[self.innerView addSubview:gameAnswerOptionsViewController.view];
		[gameAnswerOptionsViewController reloadView];
	} else if (isiPad) {
		// Build the answer options.
		gameAnswerOptionsViewController = [[ZSAnswerOptionsViewController alloc] initWithGameViewController:self];
		gameAnswerOptionsViewController.view.frame = CGRectMake(56, 790, gameAnswerOptionsViewController.view.frame.size.width, gameAnswerOptionsViewController.view.frame.size.height);
		gameAnswerOptionsViewController.touchDelegate = self;
		[self.innerView addSubview:gameAnswerOptionsViewController.view];
		[gameAnswerOptionsViewController reloadView];
	} else {
		// Build the answer options.
		gameAnswerOptionsViewController = [[ZSAnswerOptionsViewController alloc] initWithGameViewController:self];
		gameAnswerOptionsViewController.view.frame = CGRectMake(6, 371, gameAnswerOptionsViewController.view.frame.size.width, gameAnswerOptionsViewController.view.frame.size.height);
		gameAnswerOptionsViewController.touchDelegate = self;
		[self.innerView addSubview:gameAnswerOptionsViewController.view];
		[gameAnswerOptionsViewController reloadView];
	}
	
	// Build pencil button.
	pencilButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[pencilButton addTarget:self action:@selector(pencilButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	
	if (isiPad) {
		pencilButton.frame = CGRectMake(652, 796, 30, 48);
		
		[pencilButton setBackgroundImage:[UIImage imageNamed:@"Pencil-iPad"] forState:UIControlStateNormal];
		[pencilButton setBackgroundImage:[UIImage imageNamed:@"PencilSelected-iPad"] forState:UIControlStateSelected];
	} else {
		pencilButton.frame = resolution == UIDevice_iPhoneTallerHiRes ? CGRectMake(247, 433.5f, 22, 32) : CGRectMake(287, 371, 22, 32);
		
		[pencilButton setBackgroundImage:[UIImage imageNamed:@"Pencil"] forState:UIControlStateNormal];
		[pencilButton setBackgroundImage:[UIImage imageNamed:@"PencilSelected"] forState:UIControlStateSelected];
	}
	
	[self.innerView addSubview:pencilButton];
	
	// Build the undo button.
	undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[undoButton addTarget:self action:@selector(undoButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	
	if (isiPad) {
		UIImage *undoButtonImage = [UIImage imageNamed:@"Undo-iPad"];
		
		undoButton.frame = CGRectMake(228, 894, undoButtonImage.size.width, undoButtonImage.size.height);
		
		[undoButton setBackgroundImage:undoButtonImage forState:UIControlStateNormal];
		[undoButton setBackgroundImage:[UIImage imageNamed:@"UndoHighlighted-iPad"] forState:UIControlStateHighlighted];
	} else {
		UIImage *undoButtonImage = [UIImage imageNamed:@"Undo"];
		
		undoButton.frame = CGRectMake(80, resolution == UIDevice_iPhoneTallerHiRes ? 497 : 409, undoButtonImage.size.width, undoButtonImage.size.height);
		
		[undoButton setBackgroundImage:undoButtonImage forState:UIControlStateNormal];
		[undoButton setBackgroundImage:[UIImage imageNamed:@"UndoHighlighted"] forState:UIControlStateHighlighted];
	}
	
	[self.innerView addSubview:undoButton];
	
	// Build the autopencil button.
	autoPencilButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[autoPencilButton addTarget:self action:@selector(autoPencilButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	
	if (isiPad) {
		UIImage *autoPencilImage = [UIImage imageNamed:@"AutoPencil-iPad"];
		
		autoPencilButton.frame = CGRectMake(347, 894, autoPencilImage.size.width, autoPencilImage.size.height);
		
		[autoPencilButton setBackgroundImage:autoPencilImage forState:UIControlStateNormal];
		[autoPencilButton setBackgroundImage:[UIImage imageNamed:@"AutoPencilHighlighted-iPad"] forState:UIControlStateHighlighted];
	} else {
		UIImage *autoPencilImage = [UIImage imageNamed:@"AutoPencil"];
		
		autoPencilButton.frame = CGRectMake(140, resolution == UIDevice_iPhoneTallerHiRes ? 497 : 409, autoPencilImage.size.width, autoPencilImage.size.height);
		
		[autoPencilButton setBackgroundImage:autoPencilImage forState:UIControlStateNormal];
		[autoPencilButton setBackgroundImage:[UIImage imageNamed:@"AutoPencilHighlighted"] forState:UIControlStateHighlighted];
	}
	
	[self.innerView addSubview:autoPencilButton];
	
	// Build the hints button.
	hintButtonViewController = [[ZSHintButtonViewController alloc] init];
	[self.innerView addSubview:hintButtonViewController.view];

	if (isiPad) {
		hintButtonViewController.view.frame = CGRectMake(464, 894, hintButtonViewController.view.frame.size.width, hintButtonViewController.view.frame.size.height);
	} else {
		hintButtonViewController.view.frame = CGRectMake(200, resolution == UIDevice_iPhoneTallerHiRes ? 497 : 409, hintButtonViewController.view.frame.size.width, hintButtonViewController.view.frame.size.height);
	}
		
	[hintButtonViewController.button addTarget:self action:@selector(hintButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	
	// Reload errors.
	[self _setErrors];
	[boardViewController reloadView];
}

- (void)viewWasPromotedToFront {
	// Analytics Checkpoint
	[Flurry logEvent:kAnalyticsCheckpointStartedNewPuzzle withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.game.difficulty], @"difficulty", nil]];
	
	// Start with calling super.
	[super viewWasPromotedToFront];
	
	// This is now the active game.
	self.active = YES;
	
	// If the game is already solved, shut off input.
	if ([game isSolved]) {
		self.allowsInput = NO;
		self.solved = YES;
		
		pencilButton.selected = NO;
		pencilButton.enabled = NO;
		
		undoButton.enabled = NO;
		autoPencilButton.enabled = NO;
		hintButtonViewController.button.enabled = NO;
	} else {
		// Start the game timer.
		[self.game startGameTimer];
		
		// Update the hint deck.
		self.needsHintDeckUpdate = YES;
		
		// Handle pulsing.
		[self _evaluateHintButtonPulsing];
	}
	
	// Update the folded corner image.
	self.needsScreenshotUpdate = YES;
	
	// Start the background process timer.
	_backgroundProcessTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_backgroundProcessTimerDidAdvance:) userInfo:nil repeats:YES];
	_backgroundProcessTimerCount = 0;
	
	// Animate the "tap difficulty" notice.
	if (!_tapToChangeDifficultyNotice.hidden) {
		_tapToChangeDifficultyNoticeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(_hideTapToChangeDifficultyNoticeIfActive) userInfo:nil repeats:NO];
	}
}

- (void)viewWasPushedToBack {
	[game stopGameTimer];
	[_backgroundProcessTimer invalidate];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[super applicationWillResignActive:application];
	
	[self.foldedCornerPlusButtonViewController pauseAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[super applicationDidBecomeActive:application];
	
	[self.foldedCornerPlusButtonViewController resumeAnimation];
}

- (void)setTitle {
	UIDeviceResolution resolution = [UIDevice currentResolution];
	bool isiPad = (resolution == UIDevice_iPadStandardRes || resolution == UIDevice_iPadHiRes);
	
	CGFloat tapToChangeDifficultyNoticeHeight = isiPad ? 38 : 14;
	CGFloat tapToChangeDifficultyNoticeWidthFactor = isiPad ? 2.6 : 1;
	
	switch (game.difficulty) {
		default:
		case ZSGameDifficultyEasy:
			[_difficultyButton setTitle:@" Easy " forState:UIControlStateNormal];
			_tapToChangeDifficultyNotice.frame = CGRectMake(32 * tapToChangeDifficultyNoticeWidthFactor, tapToChangeDifficultyNoticeHeight, _tapToChangeDifficultyNotice.frame.size.width, _tapToChangeDifficultyNotice.frame.size.height);
			break;
			
		case ZSGameDifficultyModerate:
			[_difficultyButton setTitle:@" Moderate " forState:UIControlStateNormal];
			_tapToChangeDifficultyNotice.frame = CGRectMake(18 * tapToChangeDifficultyNoticeWidthFactor, tapToChangeDifficultyNoticeHeight, _tapToChangeDifficultyNotice.frame.size.width, _tapToChangeDifficultyNotice.frame.size.height);
			break;
			
		case ZSGameDifficultyChallenging:
			[_difficultyButton setTitle:@" Challenging " forState:UIControlStateNormal];
			_tapToChangeDifficultyNotice.frame = CGRectMake(12 * tapToChangeDifficultyNoticeWidthFactor, tapToChangeDifficultyNoticeHeight, _tapToChangeDifficultyNotice.frame.size.width, _tapToChangeDifficultyNotice.frame.size.height);
			break;
			
		case ZSGameDifficultyDiabolical:
			[_difficultyButton setTitle:@" Diabolical " forState:UIControlStateNormal];
			_tapToChangeDifficultyNotice.frame = CGRectMake(14 * tapToChangeDifficultyNoticeWidthFactor, tapToChangeDifficultyNoticeHeight, _tapToChangeDifficultyNotice.frame.size.width, _tapToChangeDifficultyNotice.frame.size.height);
			break;
		
		case ZSGameDifficultyInsane:
			[_difficultyButton setTitle:@" Insane " forState:UIControlStateNormal];
			_tapToChangeDifficultyNotice.frame = CGRectMake(28 * tapToChangeDifficultyNoticeWidthFactor, tapToChangeDifficultyNoticeHeight, _tapToChangeDifficultyNotice.frame.size.width, _tapToChangeDifficultyNotice.frame.size.height);
			break;
	}
}

- (void)_difficultyButtonWasPressed:(UIGestureRecognizer *)gestureRecognizer {
	// Analytics Checkpoint
	[Flurry logEvent:kAnalyticsCheckpointOpenedRibbon];
	
	[self.difficultyButtonDelegate difficultyButtonWasPressedWithViewController:self];
}

- (void)showTapToChangeDifficultyNoticeAnimated:(BOOL)animated {
	if (_tapToChangeDifficultyNoticeTimer) {
		[_tapToChangeDifficultyNoticeTimer invalidate];
		_tapToChangeDifficultyNoticeTimer = nil;
	}
	
	if (animated) {
		[UIView
		 animateWithDuration:0.4f
		 delay:0
		 options:UIViewAnimationOptionCurveEaseOut
		 animations:^{
			 _tapToChangeDifficultyNotice.alpha = 1;
		 }
		 completion:^(BOOL finished){
			 _tapToChangeDifficultyNotice.hidden = NO;
			 
			 self.needsScreenshotUpdate = YES;
		 }];
	} else {
		_tapToChangeDifficultyNotice.alpha = 1;
		_tapToChangeDifficultyNotice.hidden = NO;
		
		self.needsScreenshotUpdate = YES;
	}
}

- (void)_hideTapToChangeDifficultyNoticeIfActive {
	if (self.active) {
		[self hideTapToChangeDifficultyNoticeAnimated:YES];
	}
}

- (void)hideTapToChangeDifficultyNoticeAnimated:(BOOL)animated {
	if (_tapToChangeDifficultyNoticeTimer) {
		[_tapToChangeDifficultyNoticeTimer invalidate];
		_tapToChangeDifficultyNoticeTimer = nil;
	}
	
	if (animated) {
		[UIView
		 animateWithDuration:0.4f
		 delay:0
		 options:UIViewAnimationOptionCurveEaseOut
		 animations:^{
			 _tapToChangeDifficultyNotice.alpha = 0;
		 }
		 completion:^(BOOL finished){
			 _tapToChangeDifficultyNotice.hidden = YES;
			 
			 self.needsScreenshotUpdate = YES;
		 }];
	} else {
		_tapToChangeDifficultyNotice.hidden = YES;
		_tapToChangeDifficultyNotice.alpha = 0;
		
		self.needsScreenshotUpdate = YES;
	}
}

- (void)_evaluateHintButtonPulsing {
	// If the button is already pulsing, check to see if the errors have been removed and stop pulsing immediately. If not,
	// then we'll delay checking for errors until the timer is up.
	if (hintButtonViewController.pulsing) {
		if (!self.game.board.containsErrors) {
			[hintButtonViewController stopPulsing];
			self.forceScreenshotUpdateOnDrag = NO;
		}
	} else {
		if (!_hintButtonEvalutePulsingTimer) {
			_hintButtonEvalutePulsingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(_evaluateHintButtonPulsingImmediately) userInfo:nil repeats:NO];
		}
	}
}

- (void)_evaluateHintButtonPulsingImmediately {
	if (_hintButtonEvalutePulsingTimer) {
		[_hintButtonEvalutePulsingTimer invalidate];
		_hintButtonEvalutePulsingTimer = nil;
	}
	
	if (self.game.board.containsErrors) {
		[hintButtonViewController startPulsing];
		self.forceScreenshotUpdateOnDrag = YES;
	} else {
		[hintButtonViewController stopPulsing];
		self.forceScreenshotUpdateOnDrag = NO;
	}
}

- (void)_backgroundProcessTimerDidAdvance:(NSTimer *)timer {
	++_backgroundProcessTimerCount;
	
	if (_backgroundProcessTimerCount % 1 == 0) {
		// NSLog(@"Updating screenshot.");
		[self updateScreenshotSynchronous:NO];
	}
	
	if (_backgroundProcessTimerCount % 10 == 0) {
		// NSLog(@"Updating hint deck.");
		[self _updateHintDeck];
	}
	
	if (_backgroundProcessTimerCount % 60 == 0) {
		// NSLog(@"Saving game.");
		[[ZSGameController sharedInstance] saveGame:self.game];
	}
}

#pragma mark - Game Functions

- (void)setAutoPencils {
	// Reset pencil changes.
	_totalPencilChangesSinceLastGuess = 0;
	
	// Add the pencils.
	[game addAutoPencils];
	
	// Update the highlights.
	if (boardViewController.selectedTileView) {
		[boardViewController reselectTileView];
	}
	
	// Reload views.
	[self.boardViewController reloadView];
	[self.gameAnswerOptionsViewController reloadView];
	
	// Update screenshot.
	self.needsScreenshotUpdate = YES;

	// Update hint deck.
	self.needsHintDeckUpdate = YES;
	
	// Note the action.
	_actionWasMadeOnPuzzle = YES;
}

- (void)solveMostOfThePuzzle {
	[self.boardViewController deselectTileView];
	
	NSInteger totalUnsolved = game.board.size * game.board.size;
	
	for (NSInteger row = 0; row < game.board.size; ++row) {
		for (NSInteger col = 0; col < game.board.size; ++col) {
			ZSTile *tile = [game.board getTileAtRow:row col:col];
			
			if (tile.guess) {
				--totalUnsolved;
			}
		}
	}
	
	[game startGenericUndoStop];
	
	for (NSInteger row = 0; row < game.board.size && totalUnsolved > 2; ++row) {
		for (NSInteger col = 0; col < game.board.size && totalUnsolved > 2; ++col) {
			ZSTile *tile = [game.board getTileAtRow:row col:col];
			
			if (!tile.guess) {
				[game setGuess:tile.answer forTileAtRow:row col:col];
				--totalUnsolved;
			}
		}
	}
	
	[game stopGenericUndoStop];
	
	_guessInSameTileWasJustMade = NO;
	
	// Reload views.
	[self.boardViewController reloadView];
	[self.gameAnswerOptionsViewController reloadView];
	
	// Update the screenshot.
	self.needsScreenshotUpdate = YES;
	
	// Update hint deck.
	self.needsHintDeckUpdate = YES;
	
	// These actions don't count as real actions.
	_actionWasMadeOnPuzzle = NO;
}

- (void)completeCoreGameOperation {
	_guessInSameTileWasJustMade = NO;
	
	[self.boardViewController reselectTileView];
	
	[self.boardViewController reloadView];
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
	
	self.needsHintDeckUpdate = YES;
	
	// Handle pulsing.
	[self _evaluateHintButtonPulsing];
}

#pragma mark - Button Handlers

- (void)pencilButtonWasTouched {
	penciling = !penciling;
	pencilButton.selected = penciling;
	
	[gameAnswerOptionsViewController reloadView];
}

- (void)autoPencilButtonWasTouched {
	// Analytics Checkpoint
	[Flurry logEvent:kAnalyticsCheckpointUsedAutoPencil];
	
	[self setAutoPencils];
	
	_guessInSameTileWasJustMade = NO;
}

- (void)undoButtonWasTouched {
	// Analytics Checkpoint
	[Flurry logEvent:kAnalyticsCheckpointUsedUndo];
	
	// Reset pencil changes.
	_totalPencilChangesSinceLastGuess = 0;
	
	_lastModifiedTileViewController = nil;
	
	[self.game undo];
	
	[self.boardViewController deselectTileView];
	
	if (_lastModifiedTileViewController) {
		[self.boardViewController selectTileView:_lastModifiedTileViewController];
	}
	
	// Here, we could reload just the changed tiles, but it's easier to reload all.
	[self.boardViewController reloadView];
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
	
	self.needsHintDeckUpdate = YES;
	
	_guessInSameTileWasJustMade = NO;
	
	// Handle pulsing.
	[self _evaluateHintButtonPulsing];
}

- (void)redoButtonWasTouched {
	// Reset pencil changes.
	_totalPencilChangesSinceLastGuess = 0;
	
	_lastModifiedTileViewController = nil;
	
	[self.game redo];
	
	[self.boardViewController deselectTileView];
	
	if (_lastModifiedTileViewController) {
		[self.boardViewController selectTileView:_lastModifiedTileViewController];
	}
	
	// Here, we could reload just the changed tiles, but it's easier to reload all.
	[self.boardViewController reloadView];
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
	
	self.needsHintDeckUpdate = YES;
	
	_guessInSameTileWasJustMade = NO;
}

- (void)hintButtonWasTouched {
	// Analytics Checkpoint
	[Flurry logEvent:kAnalyticsCheckpointUsedAHint];
	
	// Force an update immediately if one is needed.
	[self _updateHintDeck];
	dispatch_group_wait(_hintGenerationDispatchGroup, DISPATCH_TIME_FOREVER);
	
	[hintDelegate beginHintDeck:self.hintDeck forGameViewController:self];
	
	_guessInSameTileWasJustMade = NO;
}

- (void)closeHintButtonWasTouched {
	[hintDelegate endHintDeck];
	
	_guessInSameTileWasJustMade = NO;
}

- (void)_updateHintDeck {
	dispatch_group_async(_hintGenerationDispatchGroup, _hintGenerationDispatchQueue, ^{
		if (self.needsHintDeckUpdate) {
			if (!self.solved) {
				self.needsHintDeckUpdate = NO;
				
				[hintGenerator copyGameStateFromGameBoard:game.board];
				self.hintDeck = [hintGenerator generateHint];
			}
		}
	});
}

#pragma mark - ZSGameStateChangeDelegate Implementation

- (void)tileGuessDidChange:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Check for errors.
	[self _setErrors];
	
	// Reload the tile.
	ZSTileViewController *tileVC = [self.boardViewController getTileViewControllerAtRow:row col:col];
	tileVC.needsReload = YES;
	
	// Keep track of the tile we just modified.
	_lastModifiedTileViewController = tileVC;
	
	// Reselect the tile to update other error highlighting.
	[self.boardViewController reselectTileView];
	
	// Reload the answer options to reflect the available options.
	[self.gameAnswerOptionsViewController reloadView];
	
	// Update the folded corner image.
	self.needsScreenshotUpdate = YES;
	
	// Update hint deck.
	self.needsHintDeckUpdate = YES;
}

- (void)tilePencilDidChange:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// The tile needs a reload.
	[self.boardViewController getTileViewControllerAtRow:row col:col].needsReload = YES;
	
	// Keep track of all the pencil changes made.
	ZSGameViewControllerPencilChangeDescription *pencilChange = &_pencilChangesSinceLastGuess[_totalPencilChangesSinceLastGuess];
	
	pencilChange->row = row;
	pencilChange->col = col;
	pencilChange->pencilNumber = pencilNumber;
	pencilChange->isSet = isSet;
	
	++_totalPencilChangesSinceLastGuess;
}

- (void)guess:(NSInteger)guess isErrorForTileAtRow:(NSInteger)row col:(NSInteger)col {
	
}

- (void)timerDidAdvance {
	//	if (timerCount % 2) {
	//		NSLog(@"tick");
	//	} else {
	//		NSLog(@"tock");
	//	}
}

- (void)gameWasSolved {
	// Analytics Checkpoint
	[Flurry logEvent:kAnalyticsCheckpointSolvedPuzzle withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.game.difficulty], @"difficulty", nil]];
	
	// Stop the game timer.
	[game stopGameTimer];
	
	// Prevent future input.
	self.allowsInput = NO;
	self.solved = YES;
	
	pencilButton.selected = NO;
	pencilButton.enabled = NO;
	
	undoButton.enabled = NO;
	autoPencilButton.enabled = NO;
	hintButtonViewController.button.enabled = NO;
	
	// Deselect stuff.
	[self.boardViewController deselectTileView];
	self.boardViewController.allowsSelection = NO;
	
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
	
	if ([self.majorGameStateChangeDelegate respondsToSelector: @selector(gameWasSolvedWithViewController:)]) {
		[self.majorGameStateChangeDelegate gameWasSolvedWithViewController:self];
	}
}

#pragma mark - ZSFoldedCornerViewControllerAnimationDelegate Implementation

- (void)pageTurnAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController {
	self.active = NO;
	
	if (_tapToChangeDifficultyNoticeTimer) {
		[_tapToChangeDifficultyNoticeTimer invalidate];
		_tapToChangeDifficultyNoticeTimer = nil;
	}
	
	[super pageTurnAnimationDidFinishWithViewController:viewController];
	
	[self viewWasPushedToBack];
}

- (void)startFoldAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController {
	[super startFoldAnimationDidFinishWithViewController:viewController];
	
	[self.foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateNormal animated:YES];
}

#pragma mark - ZSFoldedCornerPlusButtonViewControllerAnimationDelegate Implementation

- (void)foldedCornerPlusButtonStartAnimationFinishedWithViewController:(ZSFoldedCornerPlusButtonViewController *)viewController {
	if ([self.animationDelegate respondsToSelector: @selector(plusButtonStartAnimationDidFinishWithViewController:)]) {
		[self.animationDelegate plusButtonStartAnimationDidFinishWithViewController:self];
	}
}

- (void)foldedCornerViewController:(ZSFoldedCornerViewController *)viewController touchStartedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions {
	[super foldedCornerViewController:viewController touchStartedWithFoldPoint:foldPoint foldDimensions:foldDimensions];
	
	if ([self.animationDelegate respondsToSelector:@selector(userBeganDraggingFoldedCornerWithViewController:)]) {
		[self.animationDelegate userBeganDraggingFoldedCornerWithViewController:self];
	}
}

#pragma mark - ZSAnswerOptionsViewControllerTouchDelegate Implementation

- (void)gameAnswerOptionTouchEnteredWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption {
	// If we aren't allowing input, end here.
	if (!self.allowsInput) {
		return;
	}
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSTileViewController *selectedTileView = boardViewController.selectedTileView;
	
	// Only show a preview if a tile is selected.
	if (selectedTileView) {
		// Only allow the modification if the tile is user-entered.
		if (selectedTileView.tile.locked) {
			return;
		}
		
		// No previews for pencils.
		if (!penciling) {
			selectedTileView.ghostedValue = (NSInteger)gameAnswerOption + 1;
			[selectedTileView reloadView];
		}
	}
}

- (void)gameAnswerOptionTouchExitedWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption {
	// If we aren't allowing input, end here.
	if (!self.allowsInput) {
		return;
	}
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSTileViewController *selectedTileView = boardViewController.selectedTileView;
	
	// Only show a preview if a tile is selected.
	if (selectedTileView) {
		// Only allow the modification if the tile is user-entered.
		if (selectedTileView.tile.locked) {
			return;
		}
		
		// No previews for pencils.
		if (!penciling) {
			selectedTileView.ghostedValue = 0;
			[selectedTileView reloadView];
		}
	}
}

- (void)gameAnswerOptionTappedWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption {
	// Fetch the touched game answer option view controller.
	ZSAnswerOptionViewController *gameAnswerOptionView = [gameAnswerOptionsViewController.gameAnswerOptionViewControllers objectAtIndex:gameAnswerOption];
	
	// If we aren't allowing input, end here.
	if (!self.allowsInput) {
		return;
	}
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSTileViewController *selectedTileView = boardViewController.selectedTileView;
	
	// Is there a tile selected?
	if (selectedTileView) {
		// Only allow the modification if the tile is user-entered.
		if (selectedTileView.tile.locked) {
			return;
		}
		
		// Is the user penciling a guess?
		if (penciling) {
			// Match the selected tile and answer.
			[self _setPencilForTile:selectedTileView withAnswerOption:gameAnswerOptionView];
			
			// Based on settings, either deselect the tile or reselect it to update highlights.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearTileSelectionAfterPickingAnswerOptionForPencilKey]) {
				[boardViewController deselectTileView];
			} else {
				[boardViewController reselectTileView];
			}
			
			[selectedTileView reloadView];
		} else {
			// Match the selected tile and answer.
			[self _setGuessForTile:selectedTileView withAnswerOption:gameAnswerOptionView];
			
			// Based on settings, either deselect the tile or reselect it to update highlights.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearTileSelectionAfterPickingAnswerOptionForAnswerKey]) {
				[boardViewController deselectTileView];
			} else {
				[boardViewController reselectTileView];
			}
			
			[self.boardViewController reloadView];
		}
		
		// Reload views.
		[self.gameAnswerOptionsViewController reloadView];
		
		// Update the screenshot.
		self.needsScreenshotUpdate = YES;
		
		// Update hint deck.
		self.needsHintDeckUpdate = YES;
	}
}

#pragma mark - ZSBoardViewControllerTouchDelegate Implementation

- (void)tileWasTappedInRow:(NSInteger)row col:(NSInteger)col {
	// If we aren't allowing input, end here.
	if (!self.allowsInput) {
		return;
	}
	
	// Clear hints.
	[hintDelegate endHintDeck];
	
	// Fetch the touched game tile view controller.
	ZSTileViewController *tileView = [[boardViewController.tileViews objectAtIndex:row] objectAtIndex:col];
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSTileViewController *selectedTileView = boardViewController.selectedTileView;
	
	// If the tapped tile was previously selected, deselect it. Otherwise, select the new one.
	if (selectedTileView == tileView) {
		[boardViewController deselectTileView];
	} else {
		[boardViewController selectTileView:tileView];
	}
	
	// Reload views.
	[self.boardViewController reloadView];
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
}

- (void)tileWasDoubleTappedInRow:(NSInteger)row col:(NSInteger)col {
	// If we aren't allowing input, end here.
	if (!self.allowsInput) {
		return;
	}
	
	// Clear hints.
	[self.hintDelegate endHintDeck];
	
	// Fetch the touched game tile view controller.
	ZSTileViewController *tileView = [[boardViewController.tileViews objectAtIndex:row] objectAtIndex:col];
	
	// Check the tile for pencil marks;
	NSInteger totalPencilsFound = 0;
	NSInteger lastPencilFound = 0;
	
	for (NSInteger i = 1; i <= self.boardViewController.game.board.size; ++i) {
		if ([tileView.tile getPencilForGuess:i]) {
			++totalPencilsFound;
			lastPencilFound = i;
		}
	}
	
	// If the tile only has one pencil mark, fill it in.
	if (totalPencilsFound == 1) {
		[self _setGuess:lastPencilFound forTile:tileView];
	}
	
	// Select the new tile.
	[self.boardViewController selectTileView:tileView];
	
	// Reload views.
	[self.boardViewController reloadView];
	[self.gameAnswerOptionsViewController reloadView];

	self.needsScreenshotUpdate = YES;
}

#pragma mark - State Changes

- (void)_setPencilForTile:(ZSTileViewController *)tileView withAnswerOption:(ZSAnswerOptionViewController *)answerOptionView {
	[self _setPencil:((NSInteger)answerOptionView.gameAnswerOption + 1) forTile:tileView];
}

- (void)_setPencil:(NSInteger)pencilNumber forTile:(ZSTileViewController *)tileView {
	// Only honor the pencil mark if there is no guess in the tile.
	if (tileView.tile.guess) {
		return;
	}
	
	// Set the new pencil to the selected answer option value.
	[game togglePencilForPencilNumber:pencilNumber forTileAtRow:tileView.tile.row col:tileView.tile.col];
	
	// Note the action.
	_actionWasMadeOnPuzzle = YES;
}

- (void)_setGuessForTile:(ZSTileViewController *)tileView withAnswerOption:(ZSAnswerOptionViewController *)answerOptionView {
	[self _setGuess:((NSInteger)answerOptionView.gameAnswerOption + 1) forTile:tileView];
}

- (void)_setGuess:(NSInteger)guess forTile:(ZSTileViewController *)tileView {
	NSInteger previousGuess = tileView.tile.guess;
	
	// Start a generic undo stop. We're going to be tying multiple actions together.
	[game startGenericUndoStop];
	
	// Start by clearing the previous value in the tile. It's possible that it was empty.
	[game clearGuessForTileAtRow:tileView.tile.row col:tileView.tile.col];
	
	// If the user is choosing another guess immediately prior to a previous guess, we should revert all pencil marks removed from the last one.
	if (tileView == _lastTileToReceiveGuess && _guessInSameTileWasJustMade) {
		for (NSInteger i = _totalPencilChangesSinceLastGuess - 1; i >= 0; --i) {
			// Reverse the pencil change.
			ZSGameViewControllerPencilChangeDescription *pencil = &_pencilChangesSinceLastGuess[i];
			[game setPencil:!pencil->isSet forPencilNumber:pencil->pencilNumber forTileAtRow:pencil->row col:pencil->col];
		}
	}
	
	// Reset the pencil changes bookkeeping.
	_lastTileToReceiveGuess = tileView;
	_guessInSameTileWasJustMade = YES;
	_totalPencilChangesSinceLastGuess = 0;
	
	// If the guess we're setting isn't empty (0) and isn't the same value as was previously in the tile, set the new value for it. 
	if (guess != previousGuess) {
		// Set the new guess to the selected guess option value.
		[game setGuess:guess forTileAtRow:tileView.tile.row col:tileView.tile.col];
	}
	
	// We're done tying actions together. End the undo stop.
	[game stopGenericUndoStop];
	
	// Note the action.
	_actionWasMadeOnPuzzle = YES;
	
	// Handle pulsing.
	[self _evaluateHintButtonPulsing];
}

- (void)_setErrors {
	// If the guess is wrong, depending on the error display settings, mark it incorrect.
	ZSShowErrorsOption showErrorsOption = (ZSShowErrorsOption)[[NSUserDefaults standardUserDefaults] integerForKey:kShowErrorsOptionKey];
	
	// Loop over all tiles and check errors on the users' guesses.
	for (NSInteger row = 0; row < game.board.size; row++) {
		for (NSInteger col = 0; col < game.board.size; col++) {
			ZSTileViewController *tileView = [boardViewController getTileViewControllerAtRow:row col:col];
			
			// Keep track of the previous error setting.
			BOOL previouslyError = tileView.error;
			
			// Start by assuming no error.
			tileView.error = NO;
			
			if (tileView.tile.guess && !tileView.tile.locked) {
				// If we're showing all errors and this is an error, mark it incorrect.
				if (showErrorsOption == ZSShowErrorsOptionAlways) {
					if (tileView.tile.guess != tileView.tile.answer) {
						tileView.error = YES;
					}
				}
				
				// Are we only showing logical errors?
				if (showErrorsOption == ZSShowErrorsOptionLogical) {
					// Keep track of whether or not we found any errors.
					BOOL foundError = NO;
					
					// Get all influenced tiles.
					NSArray *influencedTiles = [game.board getAllInfluencedTilesForTileAtRow:row col:col includeSelf:NO];
					
					// Loop over all influenced tiles and check if any others have the same guess as this one. If so, mark it as incorrect.
					for (ZSTile *influencedTile in influencedTiles) {
						if (tileView.tile.guess == influencedTile.guess) {
							[boardViewController getTileViewControllerAtRow:row col:col].error = YES;
							foundError = YES;
						}
					}
					
					// If we found another tile that errs with this one, mark this one as an error.
					if (foundError) {
						tileView.error = YES;
					}
				}
			}
			
			// If the error value has changed, the tile needs a reload.
			if (tileView.error != previouslyError) {
				tileView.needsReload = YES;
			}
		}
	}
}

@end
