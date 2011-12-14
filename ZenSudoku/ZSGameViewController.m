//
//  ZSGameViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameViewController.h"
#import "ZSGameBoardViewController.h"
#import "ZSGameAnswerOptionsViewController.h"
#import "ZSGame.h"
#import "ZSGameBoard.h"
#import "ZSAppDelegate.h"
#import "ZSGameHistoryEntry.h"

@implementation ZSGameViewController

@synthesize game;
@synthesize gameBoardViewController, gameAnswerOptionsViewController;
@synthesize pencilButton, penciling;
@synthesize allowsInput;

- (id)initWithGame:(ZSGame *)newGame {
	self = [self init];
	
	if (self) {
		game = newGame;
		game.delegate = self;
		
		penciling = NO;
		
		allowsInput = YES;
	}
	
	return self;
}

#pragma mark - View Lifecycle

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Build the menu button.
	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonWasTouched)];
	self.navigationItem.leftBarButtonItem = menuButton;
	
	// Build the toolbar buttons.
	pencilButton = [[UIBarButtonItem alloc] initWithTitle:@"Pencil" style:UIBarButtonItemStyleBordered target:self action:@selector(pencilButtonWasTouched)];
	autoPencilButton = [[UIBarButtonItem alloc] initWithTitle:@"Auto-Pencil" style:UIBarButtonItemStyleBordered target:self action:@selector(autoPencilButtonWasTouched)];
	
	undoButton = [[UIBarButtonItem alloc] initWithTitle:@"Undo" style:UIBarButtonItemStyleBordered target:self action:@selector(undoButtonWasTouched)];
	redoButton = [[UIBarButtonItem alloc] initWithTitle:@"Redo" style:UIBarButtonItemStyleBordered target:self action:@selector(redoButtonWasTouched)];
	
	self.toolbarItems = [NSArray arrayWithObjects:pencilButton, autoPencilButton, undoButton, redoButton, nil];
	[self.navigationController setToolbarHidden:NO animated:NO];
	
	// Build the game board.
	gameBoardViewController = [ZSGameBoardViewController gameBoardViewControllerForGame:game];
	gameBoardViewController.view.frame = CGRectMake(9, 9, gameBoardViewController.view.frame.size.width, gameBoardViewController.view.frame.size.height);
	gameBoardViewController.delegate = self;
	[self.view addSubview:gameBoardViewController.view];
	
	// Build the answer options.
	gameAnswerOptionsViewController = [ZSGameAnswerOptionsViewController gameAnswerOptionsViewControllerForGame:game];
	gameAnswerOptionsViewController.view.frame = CGRectMake(10, 320, gameAnswerOptionsViewController.view.frame.size.width, gameAnswerOptionsViewController.view.frame.size.height);
	gameAnswerOptionsViewController.delegate = self;
	[self.view addSubview:gameAnswerOptionsViewController.view];
	
	// Debug
	if (game.difficulty == ZSGameDifficultyEasy) {
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
	
	// Disable any answer option buttons that are at quota.
//	for (NSInteger i = 0; i < game.gameBoard.size; ++i) {
//		if (![game allowsGuess:(i + 1)]) {
//			ZSGameAnswerOptionViewController *gameAnswerOptionViewController = [gameAnswerOptionsViewController.gameAnswerOptionViewControllers objectAtIndex:i];
//			gameAnswerOptionViewController.enabled = NO;
//			[gameAnswerOptionViewController reloadView];
//		}
//	}
	
	// If the game is already solved, shut off input.
	if ([game isSolved]) {
		allowsInput = NO;
	}
	
	// Start the game timer.
	[game startGameTimer];
	
	[self setTitle];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setTitle {
	switch (game.difficulty) {
		default:
		case ZSGameDifficultyEasy:
			self.title = @"Easy";
			break;
			
		case ZSGameDifficultyMedium:
			self.title = @"Medium";
			break;
			
		case ZSGameDifficultyHard:
			self.title = @"Hard";
			break;
			
		case ZSGameDifficultyExpert:
			self.title = @"Expert";
			break;
	}
}

#pragma mark - User Interaction

- (void)gameBoardTileWasTouchedInRow:(NSInteger)row col:(NSInteger)col {
	// Fetch the touched game tile view controller.
	ZSGameBoardTileViewController *tileView = [[gameBoardViewController.tileViews objectAtIndex:row] objectAtIndex:col];
	
	// If we aren't allowing input, end here.
	if (!allowsInput) {
		return;
	}
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSGameBoardTileViewController *selectedTileView = gameBoardViewController.selectedTileView;
	ZSGameAnswerOptionViewController *selectedGameAnswerOptionView = gameAnswerOptionsViewController.selectedGameAnswerOptionView;
	
	// Is there an answer option selected?
	if (selectedGameAnswerOptionView) {
		// Only allow the modification if the tile is user-entered.
		if ([game getLockedForTileAtRow:row col:col]) {
			return;
		}
		
		// Is the user penciling a guess?
		if (penciling) {
			// Match the selected tile and answer.
			[self setPencilForGameBoardTile:tileView withAnswerOption:selectedGameAnswerOptionView];
			
			// If settings say so, deselect the answer option.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearAnswerOptionSelectionAfterPickingTileForPencilKey]) {
				[gameAnswerOptionsViewController deselectGameAnswerOptionView];
			}
		} else {
			// Match the selected tile and answer.
			[self setAnswerForGameBoardTile:tileView withAnswerOption:selectedGameAnswerOptionView];
			
			// Deselect the tile. The answer option should remain selected.
			[gameBoardViewController deselectTileView];
			
			// If settings say so, deselect the answer option.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearAnswerOptionSelectionAfterPickingTileForAnswerKey]) {
				[gameAnswerOptionsViewController deselectGameAnswerOptionView];
			}
		}
	} else {
		// If there was a previously selected tile, deselect it. Otherwise, select the new one.
		if (selectedTileView == tileView) {
			[gameBoardViewController deselectTileView];
		} else {
			ZSGameTileAnswerOrder gameTileAnswerOrder = [[NSUserDefaults standardUserDefaults] integerForKey:kTileAnswerOrderKey];
			
			// Only allow the selection if the tile/guess order settings allow the tile to be selected before the answer option.
			if (gameTileAnswerOrder == ZSGameTileAnswerOrderHybrid || gameTileAnswerOrder == ZSGameTileAnswerOrderTileFirst) {
				[gameBoardViewController selectTileView:tileView];
			}
		}
	}
}

- (void)gameAnswerOptionWasTouchedWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption {
	// Fetch the touched game answer option view controller.
	ZSGameAnswerOptionViewController *gameAnswerOptionView = [gameAnswerOptionsViewController.gameAnswerOptionViewControllers objectAtIndex:gameAnswerOption];
	
	// If we aren't allowing input, end here.
	if (!allowsInput) {
		return;
	}
	
	// Save the selected tile and answer option. One or both may be nil.
	ZSGameBoardTileViewController *selectedTileView = gameBoardViewController.selectedTileView;
	ZSGameAnswerOptionViewController *selectedGameAnswerOptionView = gameAnswerOptionsViewController.selectedGameAnswerOptionView;
	
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
			
			// If settings say so, deselect the tile.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearTileSelectionAfterPickingAnswerOptionForPencilKey]) {
				[gameBoardViewController deselectTileView];
			}
		} else {
			// Match the selected tile and answer.
			[self setAnswerForGameBoardTile:selectedTileView withAnswerOption:gameAnswerOptionView];
			
			// Deselect the answer option.
			[gameAnswerOptionsViewController deselectGameAnswerOptionView];
			
			// If settings specify, deselect the tile. Otherwise, make sure the highlights are reset.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearTileSelectionAfterPickingAnswerOptionForAnswerKey]) {
				[gameBoardViewController deselectTileView];
			} else {
				[gameBoardViewController resetHighlightsForSelectedTile];
			}
		}
	} else {
		// If there was a previously selected answer option, deselect it. Otherwise, select the new one.
		if (selectedGameAnswerOptionView == gameAnswerOptionView) {
			[gameAnswerOptionsViewController deselectGameAnswerOptionView];
		} else {
			ZSGameTileAnswerOrder gameTileAnswerOrder = [[NSUserDefaults standardUserDefaults] integerForKey:kTileAnswerOrderKey];
			
			// Only allow the selection if the tile/guess order settings allow the answer option to be selected before the tile.
			if (gameTileAnswerOrder == ZSGameTileAnswerOrderHybrid || gameTileAnswerOrder == ZSGameTileAnswerOrderAnswerFirst) {
				[gameAnswerOptionsViewController selectGameAnswerOptionView:gameAnswerOptionView];
			}
		}
	}
}

- (void)setPencilForGameBoardTile:(ZSGameBoardTileViewController *)tileView withAnswerOption:(ZSGameAnswerOptionViewController *)answerOptionView {
	// If the answer option is the erase option, ignore it.
	if (answerOptionView.gameAnswerOption == ZSGameAnswerOptionErase) {
		return;
	}
	
	// Only honor the pencil mark if there is no guess in the tile.
	if (tileView.tile.guess) {
		return;
	}
	
	// Set the new pencil to the selected answer option value.
	[game togglePencilForPencilNumber:((NSInteger)answerOptionView.gameAnswerOption + 1) forTileAtRow:tileView.tile.row col:tileView.tile.col];
}

- (void)setAnswerForGameBoardTile:(ZSGameBoardTileViewController *)tileView withAnswerOption:(ZSGameAnswerOptionViewController *)answerOptionView {
	// Is the selected option the erase option, or did the user select the same guess as what already exists in the tile?
	if (answerOptionView.gameAnswerOption == ZSGameAnswerOptionErase) {
		// Erase the guess.
		[game clearGuessForTileAtRow:tileView.tile.row col:tileView.tile.col];
	} else {
		// Set the new guess to the selected guess option value.
		[game setGuess:((NSInteger)answerOptionView.gameAnswerOption + 1) forTileAtRow:tileView.tile.row col:tileView.tile.col];
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
			tileView.incorrect = NO;
			
			if (tileView.tile.guess && !tileView.tile.locked) {
				// If we're showing all errors and this is an error, mark it incorrect.
				if (showErrorsOption == ZSShowErrorsOptionAlways) {
					if (tileView.tile.guess != tileView.tile.answer) {
						tileView.incorrect = YES;
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
							[gameBoardViewController getGameBoardTileViewControllerAtRow:row col:col].incorrect = YES;
							foundError = YES;
						}
					}
					
					// If we found another tile that errs with this one, mark this one as an error.
					if (foundError) {
						tileView.incorrect = YES;
					}
				}
			}
		}
	}
}

#pragma mark - Button Handler Methods

- (void)closeButtonWasTouched {
	UINavigationController *gameNavController = self.navigationController;
	UINavigationController *mainNavController;
	
	if ([gameNavController respondsToSelector:@selector(presentingViewController)]) {
        mainNavController = (UINavigationController *)gameNavController.presentingViewController;
    } else {
        mainNavController = (UINavigationController *)gameNavController.parentViewController;
    }
	
	[mainNavController popToRootViewControllerAnimated:NO];
	
	[gameNavController dismissModalViewControllerAnimated:YES];
}

- (void)pencilButtonWasTouched {
	penciling = !penciling;
	
	if (penciling) {
		pencilButton.style = UIBarButtonItemStyleDone;
	} else {
		pencilButton.style = UIBarButtonItemStyleBordered;
	}
	
	ZSGameAnswerOptionViewController *eraseGameAnswerOptionViewController = [[gameAnswerOptionsViewController gameAnswerOptionViewControllers] objectAtIndex:ZSGameAnswerOptionErase];
	eraseGameAnswerOptionViewController.enabled = !penciling;
	[eraseGameAnswerOptionViewController reloadView];
}

- (void)autoPencilButtonWasTouched {
	// Add the pencils.
	[game addAutoPencils];
	
	// Update the highlights.
	if (gameBoardViewController.selectedTileView) {
		[gameBoardViewController resetHighlightsForSelectedTile];
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
	// [gameAnswerOptionsViewController reloadView];
	
//	// If there was previously a guess and it's being replaced or erased, and its answer option was disabled due to quota, re-enable it.
//	if (tileView.tile.guess && ![game allowsGuess:tileView.tile.guess]) {
//		ZSGameAnswerOptionViewController *disabledGameAnswerOptionViewController = [[gameAnswerOptionsViewController gameAnswerOptionViewControllers] objectAtIndex:(tileView.tile.guess - 1)];
//		disabledGameAnswerOptionViewController.enabled = YES;
//		[disabledGameAnswerOptionViewController reloadView];
//	}
//	
//	// If the new guess is at quota, disable the answer option for it.
//	if (![game allowsGuess:tileView.tile.guess]) {
//		answerOptionView.enabled = NO;
//		[gameAnswerOptionsViewController deselectGameAnswerOptionView];
//		[gameAnswerOptionsViewController reloadView];
//	}
}

- (void)tilePencilDidChange:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Reload the tile.
	[[gameBoardViewController getGameBoardTileViewControllerAtRow:row col:col] reloadView];
}

- (void)timerDidAdvance {
//	if (timerCount % 2) {
//		NSLog(@"tick");
//	} else {
//		NSLog(@"tock");
//	}
}

- (void)gameWasSolved {
	// Stop the game timer.
	[game stopGameTimer];
	
	// Prevent future input.
	allowsInput = NO;
	
	// Deselect stuff.
	[gameBoardViewController deselectTileView];
	[gameAnswerOptionsViewController deselectGameAnswerOptionView];
	
	// Show a congratulatory alert.
	UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Puzzle Complete" message:@"You've successfully completed the puzzle. Great job!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[completionAlert show];
}

@end