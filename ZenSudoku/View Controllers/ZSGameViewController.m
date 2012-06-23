//
//  ZSGameViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 Ten Four Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ZSGameViewController.h"
#import "ZSGameBoardViewController.h"
#import "ZSGameAnswerOptionsViewController.h"
#import "ZSGame.h"
#import "ZSGameBoard.h"
#import "ZSAppDelegate.h"
#import "ZSGameHistoryEntry.h"
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
}

@end

@implementation ZSGameViewController

@synthesize game;
@synthesize gameBoardViewController, gameAnswerOptionsViewController;
@synthesize foldedCornerVisibleOnLoad, foldedCornerViewController;
@synthesize foldedPageViewController;
@synthesize pencilButton, penciling;
@synthesize allowsInput;
@synthesize hintDelegate, majorGameStateDelegate;

- (id)initWithGame:(ZSGame *)newGame {
	self = [self init];
	
	if (self) {
		game = newGame;
		game.delegate = self;
		
		hintGenerator = [[ZSHintGenerator alloc] initWithSize:game.gameBoard.size];
		
		penciling = NO;
		
		allowsInput = YES;
		
		foldedCornerVisibleOnLoad = NO;
		_foldedCornerTouchCrossedTapThreshold = NO;
	}
	
	return self;
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
	gameBoardViewController = [ZSGameBoardViewController gameBoardViewControllerForGame:game];
	gameBoardViewController.view.frame = CGRectMake(8, 54, gameBoardViewController.view.frame.size.width, gameBoardViewController.view.frame.size.height);
	gameBoardViewController.delegate = self;
	[_innerView addSubview:gameBoardViewController.view];
	
	// Build the answer options.
	gameAnswerOptionsViewController = [[ZSGameAnswerOptionsViewController alloc] initWithGameViewController:self];
	gameAnswerOptionsViewController.view.frame = CGRectMake(6, 371, gameAnswerOptionsViewController.view.frame.size.width, gameAnswerOptionsViewController.view.frame.size.height);
	gameAnswerOptionsViewController.delegate = self;
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
	
	// Build the autopencil button.
	autoPencilButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[autoPencilButton addTarget:self action:@selector(autoPencilButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	autoPencilButton.frame = CGRectMake(115, 412, 35, 35);
	
	UIImage *autoPencilImage = [UIImage imageNamed:@"AutoPencil"];
	UIImage *autoPencilHighlightedImage = [UIImage imageNamed:@"AutoPencilHighlighted"];
	[autoPencilButton setBackgroundImage:autoPencilImage forState:UIControlStateNormal];
	[autoPencilButton setBackgroundImage:autoPencilHighlightedImage forState:UIControlStateHighlighted];
	
	[_innerView addSubview:autoPencilButton];
	
	// Build the hints button.
	hintButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[hintButton addTarget:self action:@selector(hintButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	hintButton.frame = CGRectMake(170.5f, 412, 35, 35);
	
	UIImage *hintsImage = [UIImage imageNamed:@"Hints"];
	UIImage *hintsHighlightedImage = [UIImage imageNamed:@"HintsHighlighted"];
	[hintButton setBackgroundImage:hintsImage forState:UIControlStateNormal];
	[hintButton setBackgroundImage:hintsHighlightedImage forState:UIControlStateHighlighted];
	
	[_innerView addSubview:hintButton];
	
	// Build the toolbar buttons.
	// undoButton = [[UIBarButtonItem alloc] initWithTitle:@"Undo" style:UIBarButtonItemStyleBordered target:self action:@selector(undoButtonWasTouched)];
	// redoButton = [[UIBarButtonItem alloc] initWithTitle:@"Redo" style:UIBarButtonItemStyleBordered target:self action:@selector(redoButtonWasTouched)];
}

- (void)solveMostOfThePuzzle {
	NSInteger totalUnsolved = game.gameBoard.size * game.gameBoard.size;
	
	for (NSInteger row = 0; row < game.gameBoard.size; ++row) {
		for (NSInteger col = 0; col < game.gameBoard.size; ++col) {
			ZSGameTile *tile = [game getTileAtRow:row col:col];
			
			if (tile.guess) {
				--totalUnsolved;
			}
		}
	}
	
	for (NSInteger row = 0; row < game.gameBoard.size && totalUnsolved > 2; ++row) {
		for (NSInteger col = 0; col < game.gameBoard.size && totalUnsolved > 2; ++col) {
			ZSGameTile *tile = [game getTileAtRow:row col:col];
			
			if (!tile.guess) {
				[game setGuess:tile.answer forTileAtRow:row col:col];
				--totalUnsolved;
			}
		}
	}
}

- (void)viewDidUnload {
	// Call parent.
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[foldedCornerViewController pushUpdate];
	[self.view setNeedsDisplay];
}

- (void)viewWasPromotedToFrontAnimated:(BOOL)animated {
	if (animated) {
		[self.foldedCornerViewController resetToStartPosition];
		[foldedCornerViewController animateStartFold];
		
		// Plus button will be animated when animateStartFold finishes.
	} else {
		[self.foldedCornerViewController resetToDefaultPosition];
		
		[_foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateNormal animated:NO];
	}
	
	[self startPuzzle];
}

- (void)startPuzzle {
	// Reload errors.
	[self setErrors];
	[gameBoardViewController reloadView];
	
	// If the game is already solved, shut off input.
	if ([game isSolved]) {
		allowsInput = NO;
		
		autoPencilButton.enabled = NO;
		hintButton.enabled = NO;
	}
	
	// Start the game timer.
	[game startGameTimer];
	
	// Debug
	if (game.difficulty == ZSGameDifficultyEasy) {
		[self solveMostOfThePuzzle];
	}
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

- (void)resetWithGame:(ZSGame *)newGame {
	self.game = newGame;
	newGame.delegate = self;
	
	allowsInput = YES;
	autoPencilButton.enabled = YES;
	hintButton.enabled = YES;
	
	[self setTitle];
	
	[self.gameBoardViewController resetWithGame:newGame];
	[self.gameAnswerOptionsViewController reloadView];
	
	[self foldedCornerRestoredToStartPoint];
	
	[_foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateHidden animated:NO];
}

- (UIImage *)getScreenshotImage {
    UIGraphicsBeginImageContextWithOptions(_innerView.bounds.size, NO, 0.0f);
	
	[_innerView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return screenshot;
}

#pragma mark - Touch Handling

- (void)foldedCornerTouchStartedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions {
	_foldStartPoint = foldPoint;
	_foldedCornerTouchCrossedTapThreshold = NO;
	
	[foldedCornerViewController setPageImage:[self getScreenshotImage]];
	
	foldedCornerViewController.drawPage = YES;
	[foldedCornerViewController pushUpdate];
	
	_innerView.hidden = YES;
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

- (void)foldedCornerRestoredToStartPoint {
	_innerView.hidden = NO;
	
	foldedCornerViewController.drawPage = NO;
	[foldedCornerViewController pushUpdate];
}

- (void)pageWasTurned {
	[self.majorGameStateDelegate startNewGame];
}

- (void)foldedCornerWasStarted {
	[self foldedCornerRestoredToStartPoint];
}

- (void)foldedCornerStartAnimationFinished {
	[self foldedCornerRestoredToStartPoint];
	
	[_foldedCornerPlusButtonViewController setState:ZSFoldedCornerPlusButtonStateNormal animated:YES];
}

- (void)foldedCornerPlusButtonStartAnimationFinished {
	[self.majorGameStateDelegate frontViewControllerFinishedDisplaying];
}

#pragma mark - User Interaction

- (void)gameBoardTileWasTouchedInRow:(NSInteger)row col:(NSInteger)col {
	// Fetch the touched game tile view controller.
	ZSGameBoardTileViewController *tileView = [[gameBoardViewController.tileViews objectAtIndex:row] objectAtIndex:col];
	
	// If we aren't allowing input, end here.
	if (!allowsInput) {
		return;
	}
	
	// Clear hints.
	if ([hintDelegate getHintsShown]) {
		[hintDelegate endHintDeck];
	}
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSGameBoardTileViewController *selectedTileView = gameBoardViewController.selectedTileView;
	
	// If there was a previously selected tile, deselect it. Otherwise, select the new one.
	if (selectedTileView == tileView) {
		[gameBoardViewController deselectTileView];
	} else {
		[gameBoardViewController selectTileView:tileView];
	}
}

- (void)selectedTileChanged {
	[gameAnswerOptionsViewController reloadView];
}

- (void)gameAnswerOptionTouchEnteredWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption {
	// If we aren't allowing input, end here.
	if (!allowsInput) {
		return;
	}
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSGameBoardTileViewController *selectedTileView = gameBoardViewController.selectedTileView;
	
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

- (void)gameAnswerOptionTouchExitedWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption {
	// If we aren't allowing input, end here.
	if (!allowsInput) {
		return;
	}
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSGameBoardTileViewController *selectedTileView = gameBoardViewController.selectedTileView;
	
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

- (void)gameAnswerOptionTappedWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption {
	// Fetch the touched game answer option view controller.
	ZSGameAnswerOptionViewController *gameAnswerOptionView = [gameAnswerOptionsViewController.gameAnswerOptionViewControllers objectAtIndex:gameAnswerOption];
	
	// If we aren't allowing input, end here.
	if (!allowsInput) {
		return;
	}
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSGameBoardTileViewController *selectedTileView = gameBoardViewController.selectedTileView;
	
	// Is there a tile selected?
	if (selectedTileView) {
		// Only allow the modification if the tile is user-entered.
		if (selectedTileView.tile.locked) {
			return;
		}
		
		// Is the user penciling a guess?
		if (penciling) {
			// Match the selected tile and answer.
			[self setPencilForGameBoardTile:selectedTileView withAnswerOption:gameAnswerOptionView];
			
			// Based on settings, either deselect the tile or reselect it to update highlights.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearTileSelectionAfterPickingAnswerOptionForPencilKey]) {
				[gameBoardViewController deselectTileView];
			} else {
				[gameBoardViewController reselectTile];
			}
		} else {
			// Match the selected tile and answer.
			[self setAnswerForGameBoardTile:selectedTileView withAnswerOption:gameAnswerOptionView];
			
			// Based on settings, either deselect the tile or reselect it to update highlights.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearTileSelectionAfterPickingAnswerOptionForAnswerKey]) {
				[gameBoardViewController deselectTileView];
			} else {
				[gameBoardViewController reselectTile];
			}
		}
	}
}

- (void)setPencilForGameBoardTile:(ZSGameBoardTileViewController *)tileView withAnswerOption:(ZSGameAnswerOptionViewController *)answerOptionView {
	// Only honor the pencil mark if there is no guess in the tile.
	if (tileView.tile.guess) {
		return;
	}
	
	// Set the new pencil to the selected answer option value.
	[game togglePencilForPencilNumber:((NSInteger)answerOptionView.gameAnswerOption + 1) forTileAtRow:tileView.tile.row col:tileView.tile.col];
}

- (void)setAnswerForGameBoardTile:(ZSGameBoardTileViewController *)tileView withAnswerOption:(ZSGameAnswerOptionViewController *)answerOptionView {
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

- (void)setErrors {
	// If the guess is wrong, depending on the error display settings, mark it incorrect.
	ZSShowErrorsOption showErrorsOption = [[NSUserDefaults standardUserDefaults] integerForKey:kShowErrorsOptionKey];
	
	// Loop over all tiles and check errors on the users' guesses.
	for (NSInteger row = 0; row < game.gameBoard.size; row++) {
		for (NSInteger col = 0; col < game.gameBoard.size; col++) {
			ZSGameBoardTileViewController *tileView = [gameBoardViewController getGameBoardTileViewControllerAtRow:row col:col];
			
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
					for (ZSGameTile *influencedTile in influencedTiles) {
						if (tileView.tile.guess == influencedTile.guess) {
							[gameBoardViewController getGameBoardTileViewControllerAtRow:row col:col].error = YES;
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

#pragma mark - Button Handler Methods

- (void)pencilButtonWasTouched {
	// if (penciling) {
	// 	[gameBoardViewController deselectTileView];
	// }
	
	penciling = !penciling;
	pencilButton.selected = penciling;
	
	[gameAnswerOptionsViewController reloadView];
}

- (void)autoPencilButtonWasTouched {
	[self setAutoPencils];
}

- (void)hintButtonWasTouched {
	[hintGenerator copyGameStateFromGameBoard:game.gameBoard];
	NSArray *hintDeck = [hintGenerator generateHint];
	
	[hintDelegate beginHintDeck:hintDeck forGameViewController:self];
}

- (void)closeHintButtonWasTouched {
	[hintDelegate endHintDeck];
}

- (void)setAutoPencils {
	// Add the pencils.
	[game addAutoPencils];
	
	// Update the highlights.
	if (gameBoardViewController.selectedTileView) {
		[gameBoardViewController reselectTile];
	}
}

- (void)undoButtonWasTouched {
	[gameBoardViewController deselectTileView];
	[game undo];
}

- (void)redoButtonWasTouched {
	[gameBoardViewController deselectTileView];
	[game redo];
}

#pragma mark - ZSGameDelegate Methods

- (void)tileGuessDidChange:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Check for errors.
	[self setErrors];
	
	// Reload the tile.
	[[gameBoardViewController getGameBoardTileViewControllerAtRow:row col:col] reloadView];
	
	// Reload the answer options to reflect the available options.
	[gameAnswerOptionsViewController reloadView];
}

- (void)tilePencilDidChange:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Reload the tile.
	[[gameBoardViewController getGameBoardTileViewControllerAtRow:row col:col] reloadView];
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
	autoPencilButton.enabled = NO;
	hintButton.enabled = NO;
	
	// Deselect stuff.
	[gameBoardViewController deselectTileView];
	
	// Show a congratulatory alert.
	UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Puzzle Complete" message:@"You've successfully completed the puzzle. Great job!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[completionAlert show];
}

@end
