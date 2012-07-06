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
#import "ZSFoldedCornerViewController.h"

#import "TestFlight.h"

typedef struct {
	NSInteger row;
	NSInteger col;
	NSInteger pencilNumber;
	BOOL isSet;
} ZSGameViewControllerPencilChangeDescription;

@interface ZSGameViewController() {
	CGPoint _foldStartPoint;
	BOOL _foldedCornerTouchCrossedTapThreshold;
	
	UIImageView *_innerView;
	
	ZSFoldedCornerPlusButtonViewController *_foldedCornerPlusButtonViewController;
	
	NSArray *_hintDeck;
	
	dispatch_queue_t _screenshotRenderDispatchQueue;
	dispatch_queue_t _hintGenerationDispatchQueue;
	
	dispatch_group_t _screenshotRenderDispatchGroup;
	dispatch_group_t _hintGenerationDispatchGroup;
	
	BOOL _guessInSameTileWasJustMade;
	ZSTileViewController *_lastTileToReceiveGuess;
	NSInteger _totalPencilChangesSinceLastGuess;
	ZSGameViewControllerPencilChangeDescription *_pencilChangesSinceLastGuess;
	
	NSTimer *_backgroundProcessTimer;
	NSInteger _backgroundProcessTimerCount;
}

@property (assign) BOOL needsScreenshotUpdate;

@property (assign) BOOL needsHintDeckUpdate;
@property (strong) NSArray *hintDeck;

@end

@implementation ZSGameViewController

@synthesize game;
@synthesize boardViewController, gameAnswerOptionsViewController;
@synthesize foldedCornerVisibleOnLoad, foldedCornerViewController;
@synthesize pencilButton, penciling;
@synthesize allowsInput;
@synthesize hintDelegate, majorGameStateDelegate;

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
		
		penciling = NO;
		
		allowsInput = YES;
		
		foldedCornerVisibleOnLoad = NO;
		_foldedCornerTouchCrossedTapThreshold = NO;
		
		_screenshotRenderDispatchQueue = dispatch_queue_create("com.tenfoursoftware.screenshotRenderQueue", NULL);
		_hintGenerationDispatchQueue = dispatch_queue_create("com.tenfoursoftware.hintGenerationQueue", NULL);
		
		_screenshotRenderDispatchGroup = dispatch_group_create();
		_hintGenerationDispatchGroup = dispatch_group_create();
		
		_guessInSameTileWasJustMade = NO;
		_lastTileToReceiveGuess = nil;
		_totalPencilChangesSinceLastGuess = 0;
		_pencilChangesSinceLastGuess = malloc(sizeof(ZSGameViewControllerPencilChangeDescription) * 81 * 9 * 3);
	}
	
	return self;
}

- (void)resetWithGame:(ZSGame *)newGame {
	self.game = newGame;
	newGame.stateChangeDelegate = self;
	
	self.allowsInput = YES;
	
	undoButton.enabled = YES;
	autoPencilButton.enabled = YES;
	hintButton.enabled = YES;
	
	penciling = NO;
	pencilButton.selected = NO;
	
	_guessInSameTileWasJustMade = NO;
	_lastTileToReceiveGuess = nil;
	_totalPencilChangesSinceLastGuess = 0;
	
	[self setTitle];
	
	[self.boardViewController resetWithGame:newGame];
	[self.gameAnswerOptionsViewController reloadView];
	
	[_foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateHidden animated:NO];
		
	self.needsScreenshotUpdate = YES;
	[self _setScreenshotVisible:NO];
}

- (void)dealloc {
	free(_pencilChangesSinceLastGuess);
	
	dispatch_release(_screenshotRenderDispatchGroup);
	dispatch_release(_hintGenerationDispatchGroup);
	
	dispatch_release(_screenshotRenderDispatchQueue);
	dispatch_release(_hintGenerationDispatchQueue);
}

#pragma mark - View Lifecycle

- (void)loadView {
	[super loadView];
	
	self.view.frame = CGRectMake(0, 0, 314, 460);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// TestFlight Checkpoint
	[TestFlight passCheckpoint:kTestFlightCheckPointStartedNewPuzzle];
	
	// Hide the menu bar.
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	self.navigationController.navigationBarHidden = YES;
	
	// Add the inner view.
	_innerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ForwardsPage.png"]];
	_innerView.userInteractionEnabled = YES;
	_innerView.frame = self.view.frame;
	[self.view addSubview:_innerView];
	
	// Build the plus button.
	_foldedCornerPlusButtonViewController = [[ZSFoldedCornerPlusButtonViewController alloc] init];
	_foldedCornerPlusButtonViewController.animationDelegate = self;
	[self.view addSubview:_foldedCornerPlusButtonViewController.view];
	[_foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateHidden animated:NO];
	
	// Build the folded corner.
	foldedCornerViewController = [[ZSFoldedCornerViewController alloc] init];
	foldedCornerViewController.view.hidden = !self.foldedCornerVisibleOnLoad;
	foldedCornerViewController.touchDelegate = self;
	foldedCornerViewController.plusButtonViewController = _foldedCornerPlusButtonViewController;
	[self.view addSubview:foldedCornerViewController.view];
	
	// Build the title.
	title = [[UILabel alloc] initWithFrame:CGRectMake(70, 12, 180, 32)];
	title.font = [UIFont fontWithName:@"ReklameScript-Medium" size:30.0f];
	title.textAlignment = UITextAlignmentCenter;
	title.backgroundColor = [UIColor clearColor];
	[_innerView addSubview:title];
	[self setTitle];
	
	// Build the game board.
	boardViewController = [[ZSBoardViewController alloc] initWithGame:game];
	boardViewController.view.frame = CGRectMake(8, 54, boardViewController.view.frame.size.width, boardViewController.view.frame.size.height);
	boardViewController.touchDelegate = self;
	[_innerView addSubview:boardViewController.view];
	
	// Build the answer options.
	gameAnswerOptionsViewController = [[ZSAnswerOptionsViewController alloc] initWithGameViewController:self];
	gameAnswerOptionsViewController.view.frame = CGRectMake(6, 371, gameAnswerOptionsViewController.view.frame.size.width, gameAnswerOptionsViewController.view.frame.size.height);
	gameAnswerOptionsViewController.touchDelegate = self;
	[_innerView addSubview:gameAnswerOptionsViewController.view];
	[gameAnswerOptionsViewController reloadView];
	
	// Build pencil button.
	pencilButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[pencilButton addTarget:self action:@selector(pencilButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	pencilButton.frame = CGRectMake(288, 371, 21.5f, 32.0f);
	
	UIImage *pencilImage = [UIImage imageNamed:@"Pencil"];
	UIImage *pencilSelectedImage = [UIImage imageNamed:@"PencilSelected"];
	[pencilButton setBackgroundImage:pencilImage forState:UIControlStateNormal];
	[pencilButton setBackgroundImage:pencilSelectedImage forState:UIControlStateSelected];
	
	[_innerView addSubview:pencilButton];
	
	// Build the hints button.
	undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[undoButton addTarget:self action:@selector(undoButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	undoButton.frame = CGRectMake(79, 412, 35, 35);
	
	UIImage *undoImage = [UIImage imageNamed:@"Undo"];
	UIImage *undoHighlightedImage = [UIImage imageNamed:@"UndoHighlighted"];
	[undoButton setBackgroundImage:undoImage forState:UIControlStateNormal];
	[undoButton setBackgroundImage:undoHighlightedImage forState:UIControlStateHighlighted];
	
	[_innerView addSubview:undoButton];
	
	// Build the autopencil button.
	autoPencilButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[autoPencilButton addTarget:self action:@selector(autoPencilButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	autoPencilButton.frame = CGRectMake(142, 412, 35, 35);
	
	UIImage *autoPencilImage = [UIImage imageNamed:@"AutoPencil"];
	UIImage *autoPencilHighlightedImage = [UIImage imageNamed:@"AutoPencilHighlighted"];
	[autoPencilButton setBackgroundImage:autoPencilImage forState:UIControlStateNormal];
	[autoPencilButton setBackgroundImage:autoPencilHighlightedImage forState:UIControlStateHighlighted];
	
	[_innerView addSubview:autoPencilButton];
	
	// Build the hints button.
	hintButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[hintButton addTarget:self action:@selector(hintButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	hintButton.frame = CGRectMake(205, 412, 35, 35);
	
	UIImage *hintsImage = [UIImage imageNamed:@"Hints"];
	UIImage *hintsHighlightedImage = [UIImage imageNamed:@"HintsHighlighted"];
	[hintButton setBackgroundImage:hintsImage forState:UIControlStateNormal];
	[hintButton setBackgroundImage:hintsHighlightedImage forState:UIControlStateHighlighted];
	
	[_innerView addSubview:hintButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[foldedCornerViewController pushUpdate];
	[self.view setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.needsScreenshotUpdate = YES;
}

- (void)viewWasPromotedToFrontAnimated:(BOOL)animated {
	// Debug
	if (game.difficulty == ZSGameDifficultyEasy) {
		[self solveMostOfThePuzzle];
	}
	
	// Reload errors.
	[self _setErrors];
	[boardViewController reloadView];
	
	// If the game is already solved, shut off input.
	if ([game isSolved]) {
		allowsInput = NO;
		
		undoButton.enabled = NO;
		autoPencilButton.enabled = NO;
		hintButton.enabled = NO;
	}
	
	// Update the folded corner image.
	self.needsScreenshotUpdate = YES;
	
	if (animated) {
		[self.foldedCornerViewController resetToStartPosition];
		[foldedCornerViewController animateStartFold];
		
		// Plus button will be animated when animateStartFold finishes.
	} else {
		[self.foldedCornerViewController resetToDefaultPosition];
		
		[_foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateNormal animated:NO];
	}
	
	// Update the hint deck.
	self.needsHintDeckUpdate = YES;
	
	// Start the game timer.
	[game startGameTimer];
	
	// Start the background process timer.
	_backgroundProcessTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_backgroundProcessTimerDidAdvance:) userInfo:nil repeats:YES];
	_backgroundProcessTimerCount = 0;
}

- (void)viewWasPushedToBack {
	[_backgroundProcessTimer invalidate];
}

- (void)setTitle {
	switch (game.difficulty) {
		default:
		case ZSGameDifficultyEasy:
			title.text = @"Easy";
			break;
			
		case ZSGameDifficultyModerate:
			title.text = @"Moderate";
			break;
			
		case ZSGameDifficultyChallenging:
			title.text = @"Challenging";
			break;
			
		case ZSGameDifficultyDiabolical:
			title.text = @"Diabolical";
			break;
		
		case ZSGameDifficultyInsane:
			title.text = @"Insane";
			break;
	}
}

- (UIImage *)getScreenshotImage {
    UIGraphicsBeginImageContextWithOptions(_innerView.bounds.size, NO, 0.0f);
	
	[_innerView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return screenshot;
}

- (void)_updateScreenshot {
	dispatch_group_async(_screenshotRenderDispatchGroup, _screenshotRenderDispatchQueue, ^{
		if (self.needsScreenshotUpdate) {
			self.needsScreenshotUpdate = NO;
			
			[self.foldedCornerViewController setPageImage:[self getScreenshotImage]];
		}
	});
}

- (void)_backgroundProcessTimerDidAdvance:(NSTimer *)timer {
	++_backgroundProcessTimerCount;
	
	if (_backgroundProcessTimerCount % 1 == 0) {
//		NSLog(@"Updating screenshot.");
		[self _updateScreenshot];
	}
	
	if (_backgroundProcessTimerCount % 10 == 0) {
//		NSLog(@"Updating hint deck.");
		[self _updateHintDeck];
	}
	
	if (_backgroundProcessTimerCount % 60 == 0) {
//		NSLog(@"Saving game.");
		[[ZSGameController sharedInstance] saveGame:self.game];
	}
}

#pragma mark - Game Functions

- (void)deselectTileView {
	[self.boardViewController deselectTileView];
	
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
}

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
}

- (void)solveMostOfThePuzzle {
	NSInteger totalUnsolved = game.board.size * game.board.size;
	
	for (NSInteger row = 0; row < game.board.size; ++row) {
		for (NSInteger col = 0; col < game.board.size; ++col) {
			ZSTile *tile = [game getTileAtRow:row col:col];
			
			if (tile.guess) {
				--totalUnsolved;
			}
		}
	}
	
	[game startGenericUndoStop];
	
	for (NSInteger row = 0; row < game.board.size && totalUnsolved > 2; ++row) {
		for (NSInteger col = 0; col < game.board.size && totalUnsolved > 2; ++col) {
			ZSTile *tile = [game getTileAtRow:row col:col];
			
			if (!tile.guess) {
				[game setGuess:tile.answer forTileAtRow:row col:col];
				--totalUnsolved;
			}
		}
	}
	
	[game stopGenericUndoStop];
	
	_guessInSameTileWasJustMade = NO;
}

- (void)completeCoreGameOperation {
	_guessInSameTileWasJustMade = NO;
	
	[self.boardViewController reselectTileView];
	
	[self.boardViewController reloadView];
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
	
	self.needsHintDeckUpdate = YES;
}

#pragma mark - Button Handlers

- (void)pencilButtonWasTouched {
	penciling = !penciling;
	pencilButton.selected = penciling;
	
	[gameAnswerOptionsViewController reloadView];
}

- (void)autoPencilButtonWasTouched {
	[self setAutoPencils];
	
	_guessInSameTileWasJustMade = NO;
}

- (void)undoButtonWasTouched {
	// Reset pencil changes.
	_totalPencilChangesSinceLastGuess = 0;
	
	[self.game undo];
	
	// Here, we could reload just the changed tiles, but it's easier to reload all.
	[self.boardViewController reloadView];
	
	[self.boardViewController deselectTileView];
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
	
	self.needsHintDeckUpdate = YES;
	
	_guessInSameTileWasJustMade = NO;
}

- (void)redoButtonWasTouched {
	// Reset pencil changes.
	_totalPencilChangesSinceLastGuess = 0;
	
	[self.game redo];
	
	// Here, we could reload just the changed tiles, but it's easier to reload all.
	[self.boardViewController reloadView];
	
	[self.boardViewController deselectTileView];
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
	
	self.needsHintDeckUpdate = YES;
	
	_guessInSameTileWasJustMade = NO;
}

- (void)hintButtonWasTouched {
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
			self.needsHintDeckUpdate = NO;
			
			[hintGenerator copyGameStateFromGameBoard:game.board];
			self.hintDeck = [hintGenerator generateHint];
		}
	});
}

#pragma mark - ZSGameStateChangeDelegate Implementation

- (void)tileGuessDidChange:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Check for errors.
	[self _setErrors];
	
	// Reload the tile.
	[self.boardViewController getTileViewControllerAtRow:row col:col].needsReload = YES;
	
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
	// TestFlight Checkpoint
	[TestFlight passCheckpoint:kTestFlightCheckPointSolvedPuzzle];
	
	// Stop the game timer.
	[game stopGameTimer];
	
	// Prevent future input.
	allowsInput = NO;
	
	undoButton.enabled = NO;
	autoPencilButton.enabled = NO;
	hintButton.enabled = NO;
	
	// Deselect stuff.
	[boardViewController deselectTileView];
	[self.gameAnswerOptionsViewController reloadView];
	
	self.needsScreenshotUpdate = YES;
	
	// Show a congratulatory alert.
	NSInteger totalMinutes = game.timerCount / 60;
	NSInteger remainingSeconds = game.timerCount - (totalMinutes * 60);
	
	NSString *minutes = totalMinutes == 1 ? @"" : @"s";
	NSString *seconds = remainingSeconds == 1 ? @"" : @"s";
	
	NSString *dialogText = [NSString stringWithFormat:@"You solved the puzzle in %i minute%@ %i second%@. Great job!", totalMinutes, minutes, remainingSeconds, seconds];
	
	UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Puzzle Complete" message:dialogText delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[completionAlert show];
}

#pragma mark - ZSFoldedCornerViewControllerTouchDelegate Implementation

- (void)foldedCornerTouchStartedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions {
	_foldStartPoint = foldPoint;
	_foldedCornerTouchCrossedTapThreshold = NO;
	
	// Force a screenshot update if one is needed.
	[self _updateScreenshot];
	dispatch_group_wait(_screenshotRenderDispatchGroup, DISPATCH_TIME_FOREVER);
	
	[self _setScreenshotVisible:YES];
}

- (void)foldedCornerTouchMovedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions {
	if (_foldedCornerTouchCrossedTapThreshold || (foldPoint.x - _foldStartPoint.x) * (foldPoint.x - _foldStartPoint.x) + (foldPoint.y - _foldStartPoint.y) * (foldPoint.y - _foldStartPoint.y) > 16) {
		_foldedCornerTouchCrossedTapThreshold = YES;
	}
}

- (void)foldedCornerTouchEndedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions {
	if (_foldedCornerTouchCrossedTapThreshold) {
		if (foldPoint.x > foldedCornerViewController.view.frame.size.width / 2) {
			[foldedCornerViewController animatePageTurn];
		} else {
			[foldedCornerViewController animateSendFoldBackToCorner];
		}
	} else {
		[foldedCornerViewController animateCornerTug];
	}
}

- (void)foldedCornerRestoredToDefaultPoint {
	[self _setScreenshotVisible:NO];
}

- (void)pageTurnAnimationDidFinish {
	[self.majorGameStateDelegate startNewGame];
	
	[self viewWasPushedToBack];
}

- (void)startFoldAnimationDidFinish {
	[self foldedCornerRestoredToDefaultPoint];
	
	[_foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateNormal animated:YES];
}

- (void)_setScreenshotVisible:(BOOL)visible {
	if (visible) {
		foldedCornerViewController.drawPage = YES;
		[foldedCornerViewController pushUpdate];
		
		_innerView.hidden = YES;
	} else {
		_innerView.hidden = NO;
		
		foldedCornerViewController.drawPage = NO;
		[foldedCornerViewController pushUpdate];
	}
}

#pragma mark - ZSFoldedCornerPlusButtonViewControllerAnimationDelegate Implementation

- (void)foldedCornerPlusButtonStartAnimationFinished {
	[self.majorGameStateDelegate frontViewControllerFinishedDisplaying];
	
	// Force an immediate update of the screenshot.
	self.needsScreenshotUpdate = YES;
	[self _updateScreenshot];
}

#pragma mark - ZSAnswerOptionsViewControllerTouchDelegate Implementation

- (void)gameAnswerOptionTouchEnteredWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption {
	// If we aren't allowing input, end here.
	if (!allowsInput) {
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
			selectedTileView.ghosted = YES;
			selectedTileView.ghostedValue = (NSInteger)gameAnswerOption + 1;
			[selectedTileView reloadView];
		}
	}
}

- (void)gameAnswerOptionTouchExitedWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption {
	// If we aren't allowing input, end here.
	if (!allowsInput) {
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
			selectedTileView.ghosted = NO;
			selectedTileView.ghostedValue = 0;
			[selectedTileView reloadView];
		}
	}
}

- (void)gameAnswerOptionTappedWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption {
	// Fetch the touched game answer option view controller.
	ZSAnswerOptionViewController *gameAnswerOptionView = [gameAnswerOptionsViewController.gameAnswerOptionViewControllers objectAtIndex:gameAnswerOption];
	
	// If we aren't allowing input, end here.
	if (!allowsInput) {
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

- (void)tileWasTouchedInRow:(NSInteger)row col:(NSInteger)col {
	// If we aren't allowing input, end here.
	if (!allowsInput) {
		return;
	}
	
	// Clear hints.
	if ([hintDelegate getHintsShown]) {
		[hintDelegate endHintDeck];
	}
	
	// Fetch the touched game tile view controller.
	ZSTileViewController *tileView = [[boardViewController.tileViews objectAtIndex:row] objectAtIndex:col];
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSTileViewController *selectedTileView = boardViewController.selectedTileView;
	
	// If there was a previously selected tile, deselect it. Otherwise, select the new one.
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

#pragma mark - State Changes

- (void)_setPencilForTile:(ZSTileViewController *)tileView withAnswerOption:(ZSAnswerOptionViewController *)answerOptionView {
	// Only honor the pencil mark if there is no guess in the tile.
	if (tileView.tile.guess) {
		return;
	}
	
	// Set the new pencil to the selected answer option value.
	[game togglePencilForPencilNumber:((NSInteger)answerOptionView.gameAnswerOption + 1) forTileAtRow:tileView.tile.row col:tileView.tile.col];
}

- (void)_setGuessForTile:(ZSTileViewController *)tileView withAnswerOption:(ZSAnswerOptionViewController *)answerOptionView {
	NSInteger guess = ((NSInteger)answerOptionView.gameAnswerOption + 1);
	
	tileView.ghosted = NO;
	tileView.ghostedValue = 0;
	
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
	
	// If the guess we're setting isn't empty (0), set the new value for it. 
	if (guess) {
		// Set the new guess to the selected guess option value.
		[game setGuess:guess forTileAtRow:tileView.tile.row col:tileView.tile.col];
	}
	
	// We're done tying actions together. End the undo stop.
	[game stopGenericUndoStop];
}

- (void)_setErrors {
	// If the guess is wrong, depending on the error display settings, mark it incorrect.
	ZSShowErrorsOption showErrorsOption = [[NSUserDefaults standardUserDefaults] integerForKey:kShowErrorsOptionKey];
	
	// Loop over all tiles and check errors on the users' guesses.
	for (NSInteger row = 0; row < game.board.size; row++) {
		for (NSInteger col = 0; col < game.board.size; col++) {
			ZSTileViewController *tileView = [boardViewController getTileViewControllerAtRow:row col:col];
			
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
					NSArray *influencedTiles = [game getAllInfluencedTilesForTileAtRow:row col:col includeSelf:NO];
					
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
		}
	}
}


@end
