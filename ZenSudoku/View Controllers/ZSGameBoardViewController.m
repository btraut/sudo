//
//  ZSGameBoardViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSGameBoardViewController.h"
#import "ZSGameBoardTileViewController.h"
#import "ZSGameViewController.h"
#import "ZSGame.h"
#import "ZSGameBoard.h"
#import "ZSGameTile.h"
#import "ZSAppDelegate.h"

@implementation ZSGameBoardViewController

@synthesize game, tileViews;
@synthesize touchDelegate, selectionChangeDelegate;
@synthesize selectedTileView, highlightedSimilarTileViews;

#pragma mark - Construction / Deconstruction

- (id)init {
	self = [super init];
	
	if (self) {
		selectedTileView = nil;
		highlightedSimilarTileViews = [NSMutableArray array];
		highlightedErrorTileViews = [NSMutableArray array];
	}
	
	return self;
}

- (id)initWithGame:(ZSGame *)newGame {
	self = [self init];
	
	if (self) {
		game = newGame;
	}
	
	return self;
}

- (void)resetWithGame:(ZSGame *)newGame {
	[self deselectTileView];
	
	self.game = newGame;
	
	for (NSInteger row = 0; row < game.gameBoard.size; row++) {
		for (NSInteger col = 0; col < game.gameBoard.size; col++) {
			ZSGameBoardTileViewController *tileViewController = [[tileViews objectAtIndex:row] objectAtIndex:col];
			tileViewController.tile = [game getTileAtRow:row col:col];
		}
	}
	
	[self reloadView];
}

#pragma mark - View Lifecycle

- (void)loadView {
	self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Board.png"]];
	self.view.frame = CGRectMake(0, 0, 304, 304);
	self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Build the tiles.
	NSMutableArray *rows = [NSMutableArray array];
	NSInteger yOffset = 3;
	
	for (NSInteger row = 0; row < game.gameBoard.size; row++) {
		NSInteger xOffset = 3;
		
		NSMutableArray *rowTiles = [NSMutableArray array];
		
		for (NSInteger col = 0; col < game.gameBoard.size; col++) {
			ZSGameBoardTileViewController *tileViewController = [[ZSGameBoardTileViewController alloc] initWithTile:[game getTileAtRow:row col:col]];
			tileViewController.view.frame = CGRectMake(xOffset, yOffset, tileViewController.view.frame.size.width, tileViewController.view.frame.size.height);
			tileViewController.touchDelegate = self;
			
			[self.view addSubview:tileViewController.view];
			[rowTiles addObject:tileViewController];
			
			xOffset += (col % 3 == 2) ? 34 : 33;
		}
		
		[rows addObject:rowTiles];
		
		yOffset += (row % 3 == 2) ? 34 : 33;
	}
	
	tileViews = rows;
	
	[self reloadView];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)reloadView {
	for (NSInteger row = 0; row < game.gameBoard.size; row++) {
		for (NSInteger col = 0; col < game.gameBoard.size; col++) {
			[[self getGameBoardTileViewControllerAtRow:row col:col] reloadView];
		}
	}
}

#pragma mark - Selection

- (void)selectTileView:(ZSGameBoardTileViewController *)tileView {
	// If there was a selection, deselect it.
	if (selectedTileView) {
		[self deselectTileView];
	}
	
	// Add selection.
	selectedTileView = tileView;
	
	selectedTileView.selected = YES;
	[selectedTileView reloadView];
	
	// Add highlights for similar tiles.
	[self resetSimilarHighlights];
	[self resetErrorHighlights];
	
	[self.selectionChangeDelegate selectedTileChanged];
}

- (void)reselectTile {
	if (selectedTileView) {
		selectedTileView.selected = YES;
		[selectedTileView reloadView];
		
		// Add highlights for similar tiles.
		[self resetSimilarHighlights];
		[self resetErrorHighlights];
		
		[self.selectionChangeDelegate selectedTileChanged];
	}
}

- (void)deselectTileView {
	if (selectedTileView) {
		// Remove all highlights.
		[self removeAllSimilarHighlights];
		[self removeAllErrorHighlights];

		// Remove selection.
		selectedTileView.selected = NO;
		[selectedTileView reloadView];
		
		selectedTileView = nil;
		
		[self.selectionChangeDelegate selectedTileChanged];
	}
}

#pragma mark - Handling Highlights

- (void)removeAllSimilarHighlights {
	for (ZSGameBoardTileViewController *highlightedSimilarTileView in highlightedSimilarTileViews) {
		highlightedSimilarTileView.highlightedSimilar = NO;
		[highlightedSimilarTileView reloadView];
	}
	
	[highlightedSimilarTileViews removeAllObjects];
}

- (void)addSimilarHighlightsForTileView:(ZSGameBoardTileViewController *)tileView {
	if (tileView.tile.guess) {
		for (NSInteger row = 0; row < game.gameBoard.size; row++) {
			for (NSInteger col = 0; col < game.gameBoard.size; col++) {
				ZSGameBoardTileViewController *iteratedTileView = [self getGameBoardTileViewControllerAtRow:row col:col];
				
				if (iteratedTileView.tile.guess == selectedTileView.tile.guess || [iteratedTileView.tile getPencilForGuess:tileView.tile.guess]) {
					iteratedTileView.highlightedSimilar = YES;
					[iteratedTileView reloadView];
					
					[highlightedSimilarTileViews addObject:iteratedTileView];
				}
			}
		}
	}
}

- (void)resetSimilarHighlights {
	[self removeAllSimilarHighlights];
	
	if (selectedTileView) {
		[self addSimilarHighlightsForTileView:selectedTileView];
	}
}

- (void)removeAllErrorHighlights {
	for (ZSGameBoardTileViewController *highlightedErrorTileView in highlightedErrorTileViews) {
		highlightedErrorTileView.highlightedError = NO;
		[highlightedErrorTileView reloadView];
	}
	
	[highlightedErrorTileViews removeAllObjects];
}

- (void)addErrorHighlightsForTileView:(ZSGameBoardTileViewController *)tileView {
	// Get the user's setting for showing errors.
	ZSShowErrorsOption showErrorsOption = [[NSUserDefaults standardUserDefaults] integerForKey:kShowErrorsOptionKey];
	
	// If the user has set errors to never show, there's no need to highlight.
	if (showErrorsOption == ZSShowErrorsOptionNever) {
		return;
	}
	
	// Showing errors for both "logical" and "always" settings will use highlights the same way.
	if (tileView.tile.guess) {
		BOOL selectedTileContainsErrors = NO;
		
		NSArray *rowSet = [game getRowSetForTileAtRow:tileView.tile.row col:tileView.tile.col includeSelf:NO];
		if ([self _getTotalTilesInSet:rowSet withGuess:tileView.tile.guess] > 0) {
			selectedTileContainsErrors = YES;
			
			for (ZSGameTile *tile in rowSet) {
				ZSGameBoardTileViewController *iteratedTileView = [self getGameBoardTileViewControllerAtRow:tile.row col:tile.col];
				iteratedTileView.highlightedError = YES;
				[iteratedTileView reloadView];
				
				[highlightedErrorTileViews addObject:iteratedTileView];
			}
		}
		
		NSArray *colSet = [game getColSetForTileAtRow:tileView.tile.row col:tileView.tile.col includeSelf:NO];
		if ([self _getTotalTilesInSet:colSet withGuess:tileView.tile.guess] > 0) {
			selectedTileContainsErrors = YES;
			
			for (ZSGameTile *tile in colSet) {
				ZSGameBoardTileViewController *iteratedTileView = [self getGameBoardTileViewControllerAtRow:tile.row col:tile.col];
				iteratedTileView.highlightedError = YES;
				[iteratedTileView reloadView];
				
				[highlightedErrorTileViews addObject:iteratedTileView];
			}
		}
		
		NSArray *familySet = [game getFamilySetForTileAtRow:tileView.tile.row col:tileView.tile.col includeSelf:NO];
		if ([self _getTotalTilesInSet:familySet withGuess:tileView.tile.guess] > 0) {
			selectedTileContainsErrors = YES;
			
			for (ZSGameTile *tile in familySet) {
				ZSGameBoardTileViewController *iteratedTileView = [self getGameBoardTileViewControllerAtRow:tile.row col:tile.col];
				iteratedTileView.highlightedError = YES;
				[iteratedTileView reloadView];
				
				[highlightedErrorTileViews addObject:iteratedTileView];
			}
		}
		
		if (selectedTileContainsErrors) {
			tileView.highlightedError = YES;
			
			[highlightedErrorTileViews addObject:tileView];
		}
	}
}

- (NSInteger)_getTotalTilesInSet:(NSArray *)set withGuess:(NSInteger)guess {
	NSInteger totalTiles = 0;
	
	for (ZSGameTile *tile in set) {
		if (tile.guess == guess) {
			++totalTiles;
		}
	}
	
	return totalTiles;
}

- (void)resetErrorHighlights {
	[self removeAllErrorHighlights];
	
	if (selectedTileView) {
		[self addErrorHighlightsForTileView:selectedTileView];
	}
}

- (void)removeAllHintHighlights {
	for (NSInteger row = 0; row < game.gameBoard.size; ++row) {
		for (NSInteger col = 0; col < game.gameBoard.size; ++col) {
			ZSGameBoardTileViewController *tileViewController = [self getGameBoardTileViewControllerAtRow:row col:col];
			
			tileViewController.highlightedHintType = ZSGameBoardTileHintHighlightTypeNone;
			tileViewController.highlightGuessHint = NO;
			
			for (NSInteger i = 0; i < game.gameBoard.size; ++i) {
				tileViewController.highlightPencilHints[i] = ZSGameBoardTilePencilTextTypeNormal;
			}
		}
	}
	
	[self reloadView];
}

#pragma mark - Tile Accessors

- (ZSGameBoardTileViewController *)getGameBoardTileViewControllerAtRow:(NSInteger)row col:(NSInteger)col {
	return [[tileViews objectAtIndex:row] objectAtIndex:col];
}

#pragma mark - ZSGameBoardTileTouchDelegate Implementation

- (void)gameBoardTileWasTouched:(ZSGameBoardTileViewController *)newSelected {
	[self.touchDelegate gameBoardTileWasTouchedInRow:newSelected.tile.row col:newSelected.tile.col];
}

@end
