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

@interface ZSGameViewController() {
	CGPoint _foldStartPoint;
	BOOL _foldedCornerTouchCrossedTapThreshold;
	
	UIImageView *_innerView;
	
	ZSFoldedCornerPlusButtonViewController *_foldedCornerPlusButtonViewController;
	
	UIImage *_screenshot;
	
	dispatch_queue_t _screenshotRenderDispatchQueue;
}

@end

@implementation ZSGameViewController

@synthesize game;
@synthesize boardViewController, gameAnswerOptionsViewController;
@synthesize foldedCornerVisibleOnLoad, foldedCornerViewController;
@synthesize foldedPageViewController;
@synthesize pencilButton, penciling;
@synthesize allowsInput;
@synthesize hintDelegate, majorGameStateDelegate;

#pragma mark - Construction / Deconstruction

- (id)initWithGame:(ZSGame *)newGame {
	self = [self init];
	
	if (self) {
		game = newGame;
		game.stateChangeDelegate = self;
		
		hintGenerator = [[ZSHintGenerator alloc] initWithSize:game.gameBoard.size];
		
		penciling = NO;
		
		allowsInput = YES;
		
		foldedCornerVisibleOnLoad = NO;
		_foldedCornerTouchCrossedTapThreshold = NO;
		
		_screenshotRenderDispatchQueue = dispatch_queue_create("com.example.MyQueue", NULL);
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
	
	[self setTitle];
	
	[self.boardViewController resetWithGame:newGame];
	[self.boardViewController deselectTileView];
	
	[self foldedCornerRestoredToDefaultPoint];
	
	[_foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateHidden animated:NO];
}

- (void)dealloc {
	dispatch_release(_screenshotRenderDispatchQueue);
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
	boardViewController.selectionChangeDelegate = self;
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
	
	[self _updateScreenshot];
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
	[self _updateScreenshot];
	
	if (animated) {
		[self.foldedCornerViewController resetToStartPosition];
		[foldedCornerViewController animateStartFold];
		
		// Plus button will be animated when animateStartFold finishes.
	} else {
		[self.foldedCornerViewController resetToDefaultPosition];
		
		[_foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateNormal animated:NO];
	}
	
	// Start the game timer.
	[game startGameTimer];
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
	self.foldedCornerViewController.needsScreenshotUpdate = YES;
	dispatch_async(_screenshotRenderDispatchQueue, ^{
		[self.foldedCornerViewController setPageImage:[self getScreenshotImage]];
	});
}

#pragma mark - Game Functions

- (void)deselectTileView {
	[self.boardViewController deselectTileView];
}

- (void)setAutoPencils {
	// Add the pencils.
	[game addAutoPencils];
	
	// Update the highlights.
	if (boardViewController.selectedTileView) {
		[boardViewController reselectTileView];
	}
}

- (void)solveMostOfThePuzzle {
	NSInteger totalUnsolved = game.gameBoard.size * game.gameBoard.size;
	
	for (NSInteger row = 0; row < game.gameBoard.size; ++row) {
		for (NSInteger col = 0; col < game.gameBoard.size; ++col) {
			ZSTile *tile = [game getTileAtRow:row col:col];
			
			if (tile.guess) {
				--totalUnsolved;
			}
		}
	}
	
	for (NSInteger row = 0; row < game.gameBoard.size && totalUnsolved > 2; ++row) {
		for (NSInteger col = 0; col < game.gameBoard.size && totalUnsolved > 2; ++col) {
			ZSTile *tile = [game getTileAtRow:row col:col];
			
			if (!tile.guess) {
				[game setGuess:tile.answer forTileAtRow:row col:col];
				--totalUnsolved;
			}
		}
	}
}

#pragma mark - Button Handlers

- (void)pencilButtonWasTouched {
	penciling = !penciling;
	pencilButton.selected = penciling;
	
	[gameAnswerOptionsViewController reloadView];
}

- (void)autoPencilButtonWasTouched {
	[self setAutoPencils];
}

- (void)undoButtonWasTouched {
	[boardViewController deselectTileView];
	[game undo];
	[boardViewController reloadView];
}

- (void)redoButtonWasTouched {
	[boardViewController deselectTileView];
	[game redo];
	[boardViewController reloadView];
}

- (void)hintButtonWasTouched {
	[hintGenerator copyGameStateFromGameBoard:game.gameBoard];
	NSArray *hintDeck = [hintGenerator generateHint];
	
	[hintDelegate beginHintDeck:hintDeck forGameViewController:self];
}

- (void)closeHintButtonWasTouched {
	[hintDelegate endHintDeck];
}

#pragma mark - ZSGameStateChangeDelegate Implementation

- (void)tileGuessDidChange:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Check for errors.
	[self _setErrors];
	
	// Reload the tile.
	[[self.boardViewController getGameBoardTileViewControllerAtRow:row col:col] reloadView];
	
	// Reselect the tile to update other error highlighting.
	[self.boardViewController reselectTileView];
	
	// Reload the answer options to reflect the available options.
	[self.gameAnswerOptionsViewController reloadView];
	
	// Update the folded corner image.
	[self _updateScreenshot];
}

- (void)tilePencilDidChange:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Reload the tile.
	[[self.boardViewController getGameBoardTileViewControllerAtRow:row col:col] reloadView];
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
	
	// [foldedCornerViewController setPageImage:[self getScreenshotImage]];
	
	dispatch_sync(_screenshotRenderDispatchQueue, ^{
		NSLog(@"Forcing sync of queue.");
	});
	
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
			[self _setPencilForGameBoardTile:selectedTileView withAnswerOption:gameAnswerOptionView];
			
			// Based on settings, either deselect the tile or reselect it to update highlights.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearTileSelectionAfterPickingAnswerOptionForPencilKey]) {
				[boardViewController deselectTileView];
			} else {
				[boardViewController reselectTileView];
			}
		} else {
			// Match the selected tile and answer.
			[self _setAnswerForGameBoardTile:selectedTileView withAnswerOption:gameAnswerOptionView];
			
			// Based on settings, either deselect the tile or reselect it to update highlights.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearTileSelectionAfterPickingAnswerOptionForAnswerKey]) {
				[boardViewController deselectTileView];
			} else {
				[boardViewController reselectTileView];
			}
		}
	}
}

#pragma mark - ZSBoardViewControllerTouchDelegate Implementation

- (void)gameBoardTileWasTouchedInRow:(NSInteger)row col:(NSInteger)col {
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
}

#pragma mark - ZSBoardViewControllerSelectionChangeDelegate Implementation

- (void)selectedTileChanged {
	[self.gameAnswerOptionsViewController reloadView];
	
	[self _updateScreenshot];
}

#pragma mark - State Changes

- (void)_setPencilForGameBoardTile:(ZSTileViewController *)tileView withAnswerOption:(ZSAnswerOptionViewController *)answerOptionView {
	// Only honor the pencil mark if there is no guess in the tile.
	if (tileView.tile.guess) {
		return;
	}
	
	// Set the new pencil to the selected answer option value.
	[game togglePencilForPencilNumber:((NSInteger)answerOptionView.gameAnswerOption + 1) forTileAtRow:tileView.tile.row col:tileView.tile.col];
}

- (void)_setAnswerForGameBoardTile:(ZSTileViewController *)tileView withAnswerOption:(ZSAnswerOptionViewController *)answerOptionView {
	NSInteger guess = ((NSInteger)answerOptionView.gameAnswerOption + 1);
	
	tileView.ghosted = NO;
	tileView.ghostedValue = 0;
	
	if (tileView.tile.guess == guess) {
		// The user is picking the same guess that already exists in the tile. Clear the guess.
		[game clearGuessForTileAtRow:tileView.tile.row col:tileView.tile.col];
	} else {
		// Set the new guess to the selected guess option value.
		[game setGuess:guess forTileAtRow:tileView.tile.row col:tileView.tile.col];
	}
}

- (void)_setErrors {
	// If the guess is wrong, depending on the error display settings, mark it incorrect.
	ZSShowErrorsOption showErrorsOption = [[NSUserDefaults standardUserDefaults] integerForKey:kShowErrorsOptionKey];
	
	// Loop over all tiles and check errors on the users' guesses.
	for (NSInteger row = 0; row < game.gameBoard.size; row++) {
		for (NSInteger col = 0; col < game.gameBoard.size; col++) {
			ZSTileViewController *tileView = [boardViewController getGameBoardTileViewControllerAtRow:row col:col];
			
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
							[boardViewController getGameBoardTileViewControllerAtRow:row col:col].error = YES;
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
