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
#import "ZSGameController.h"
#import "ZSHintGenerator.h"
#import "ZSHintCard.h"

#import "TestFlight.h"

@implementation ZSGameViewController

@synthesize game;
@synthesize gameBoardViewController, gameAnswerOptionsViewController;
@synthesize pencilButton, penciling;
@synthesize allowsInput;
@synthesize hintDelegate;

- (id)initWithGame:(ZSGame *)newGame {
	self = [self init];
	
	if (self) {
		game = newGame;
		game.delegate = self;
		
		hintGenerator = [[ZSHintGenerator alloc] initWithSize:game.gameBoard.size];
		
		penciling = NO;
		
		allowsInput = YES;
	}
	
	return self;
}

#pragma mark - View Lifecycle

- (void)loadView {
	self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaperBackgroundCurled.png"]];
	self.view.frame = CGRectMake(0, 0, 320, 460);
	self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// TestFlight Checkpoint
	[TestFlight passCheckpoint:kTestFlightCheckPointStartedNewPuzzle];
	
	// Hide the menu bar.
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	self.navigationController.navigationBarHidden = YES;
	
	// Build the title.
	title = [[UILabel alloc] initWithFrame:CGRectMake(70, 12, 180, 32)];
	title.font = [UIFont fontWithName:@"ReklameScript-Medium" size:30.0f];
	title.textAlignment = UITextAlignmentCenter;
	title.backgroundColor = [UIColor clearColor];
	[self.view addSubview:title];
	[self setTitle];
	
	// Build the toolbar buttons.
//	undoButton = [[UIBarButtonItem alloc] initWithTitle:@"Undo" style:UIBarButtonItemStyleBordered target:self action:@selector(undoButtonWasTouched)];
//	redoButton = [[UIBarButtonItem alloc] initWithTitle:@"Redo" style:UIBarButtonItemStyleBordered target:self action:@selector(redoButtonWasTouched)];
	
//	self.toolbarItems = [NSArray arrayWithObjects:autoPencilButton, undoButton, redoButton, nil];
//	[self.navigationController setToolbarHidden:NO animated:NO];
	
	// Build the game board.
	gameBoardViewController = [ZSGameBoardViewController gameBoardViewControllerForGame:game];
	gameBoardViewController.view.frame = CGRectMake(8, 54, gameBoardViewController.view.frame.size.width, gameBoardViewController.view.frame.size.height);
	gameBoardViewController.delegate = self;
	[self.view addSubview:gameBoardViewController.view];
	
	// Build the answer options.
	gameAnswerOptionsViewController = [[ZSGameAnswerOptionsViewController alloc] initWithGameViewController:self];
	gameAnswerOptionsViewController.view.frame = CGRectMake(6, 371, gameAnswerOptionsViewController.view.frame.size.width, gameAnswerOptionsViewController.view.frame.size.height);
	gameAnswerOptionsViewController.delegate = self;
	[self.view addSubview:gameAnswerOptionsViewController.view];
	[gameAnswerOptionsViewController reloadView];
	
	// Build pencil button.
	pencilButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[pencilButton addTarget:self action:@selector(pencilButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	pencilButton.frame = CGRectMake(288, 371, 21.5f, 32.0f);
	
	UIImage *pencilImage = [UIImage imageNamed:@"Pencil"];
	UIImage *pencilSelectedImage = [UIImage imageNamed:@"PencilSelected"];
	[pencilButton setBackgroundImage:pencilImage forState:UIControlStateNormal];
	[pencilButton setBackgroundImage:pencilSelectedImage forState:UIControlStateSelected];
	
	[self.view addSubview:pencilButton];
	
	// Build the autopencil button.
	autoPencilButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[autoPencilButton addTarget:self action:@selector(autoPencilButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	autoPencilButton.frame = CGRectMake(115, 412, 34.5f, 34.5f);
	
	UIImage *autoPencilImage = [UIImage imageNamed:@"AutoPencil"];
	UIImage *autoPencilHighlightedImage = [UIImage imageNamed:@"AutoPencilHighlighted"];
	[autoPencilButton setBackgroundImage:autoPencilImage forState:UIControlStateNormal];
	[autoPencilButton setBackgroundImage:autoPencilHighlightedImage forState:UIControlStateHighlighted];
	
	[self.view addSubview:autoPencilButton];
	
	// Build the hints button.
	hintButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[hintButton addTarget:self action:@selector(hintButtonWasTouched) forControlEvents:UIControlEventTouchUpInside];
	hintButton.frame = CGRectMake(170.5f, 412, 34.5f, 34.5f);
	
	UIImage *hintsImage = [UIImage imageNamed:@"Hints"];
	UIImage *hintsHighlightedImage = [UIImage imageNamed:@"HintsHighlighted"];
	[hintButton setBackgroundImage:hintsImage forState:UIControlStateNormal];
	[hintButton setBackgroundImage:hintsHighlightedImage forState:UIControlStateHighlighted];
	
	[self.view addSubview:hintButton];
	
	// Reload errors.
	[self setErrors];
	[gameBoardViewController reloadView];
	
	// Debug
	if (game.difficulty == ZSGameDifficultyInsane) {
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
	
	// If the game is already solved, shut off input.
	if ([game isSolved]) {
		allowsInput = NO;
		
		autoPencilButton.enabled = NO;
		hintButton.enabled = NO;
	}
	
	// Start the game timer.
	[game startGameTimer];
}

- (void)viewDidUnload {
	// Call parent.
	[super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
	// Start the game timer.
	[game stopGameTimer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
		
		[gameAnswerOptionsViewController reloadView];
	} else {
		// If there was a previously selected tile, deselect it. Otherwise, select the new one.
		if (selectedTileView == tileView) {
			[gameBoardViewController deselectTileView];
		} else {
			ZSGameTileAnswerOrder gameTileAnswerOrder = [[NSUserDefaults standardUserDefaults] integerForKey:kTileAnswerOrderKey];
			
			// Only allow the selection if the tile/guess order settings allow the tile to be selected before the answer option.
			if (gameTileAnswerOrder == ZSGameTileAnswerOrderHybrid || gameTileAnswerOrder == ZSGameTileAnswerOrderTileFirst) {
				[gameBoardViewController selectTileView:tileView];
				[gameAnswerOptionsViewController reloadView];
			}
		}
	}
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
				[gameBoardViewController resetSimilarHighlights];
				[gameBoardViewController resetErrorHighlights];
			}
		}
		
		[gameAnswerOptionsViewController reloadView];
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

- (void)closeButtonWasTouched {
	// If the game was finished, delete it.
	if ([game isSolved]) {
		[[ZSGameController sharedInstance] clearCurrentGame];
	}
	
	// Navigate back to the main menu.
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
		[gameBoardViewController resetSimilarHighlights];
	}
	
	[gameAnswerOptionsViewController reloadView];
}

- (void)undoButtonWasTouched {
	[gameBoardViewController deselectTileView];
	[game undo];
	[gameAnswerOptionsViewController reloadView];
}

- (void)redoButtonWasTouched {
	[gameBoardViewController deselectTileView];
	[game redo];
	[gameAnswerOptionsViewController reloadView];
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
	[gameAnswerOptionsViewController deselectGameAnswerOptionView];
	
	// Show a congratulatory alert.
	UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Puzzle Complete" message:@"You've successfully completed the puzzle. Great job!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[completionAlert show];
}

@end
