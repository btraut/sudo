//
//  ZSBoardViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSBoardViewController.h"
#import "ZSTileViewController.h"
#import "ZSGameViewController.h"
#import "ZSGame.h"
#import "ZSBoard.h"
#import "ZSTile.h"
#import "ZSAppDelegate.h"

@implementation ZSBoardViewController

@synthesize game, tileViews;
@synthesize touchDelegate;
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
	
	for (NSInteger row = 0; row < game.board.size; row++) {
		for (NSInteger col = 0; col < game.board.size; col++) {
			ZSTileViewController *tileViewController = [[tileViews objectAtIndex:row] objectAtIndex:col];
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
	
	for (NSInteger row = 0; row < game.board.size; row++) {
		NSInteger xOffset = 3;
		
		NSMutableArray *rowTiles = [NSMutableArray array];
		
		for (NSInteger col = 0; col < game.board.size; col++) {
			ZSTileViewController *tileViewController = [[ZSTileViewController alloc] initWithTile:[game getTileAtRow:row col:col]];
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
	for (NSInteger row = 0; row < game.board.size; row++) {
		for (NSInteger col = 0; col < game.board.size; col++) {
			[[self getTileViewControllerAtRow:row col:col] reloadView];
		}
	}
}

#pragma mark - Selection

- (void)selectTileView:(ZSTileViewController *)tileView {
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
}

- (void)reselectTileView {
	if (selectedTileView) {
		// Set selection.
		selectedTileView.selected = YES;
		[selectedTileView reloadView];
		
		// Add highlights for similar tiles.
		[self resetSimilarHighlights];
		[self resetErrorHighlights];
	}
}

- (void)deselectTileView {
	if (selectedTileView) {
		// Remove selection.
		selectedTileView.selected = NO;
		[selectedTileView reloadView];
		
		selectedTileView = nil;
		
		// Remove all highlights.
		[self removeAllSimilarHighlights];
		[self removeAllErrorHighlights];
	}
}

#pragma mark - Handling Highlights

- (void)removeAllSimilarHighlights {
	for (ZSTileViewController *highlightedSimilarTileView in highlightedSimilarTileViews) {
		highlightedSimilarTileView.highlightedSimilar = NO;
		[highlightedSimilarTileView reloadView];
	}
	
	[highlightedSimilarTileViews removeAllObjects];
}

- (void)addSimilarHighlightsForTileView:(ZSTileViewController *)tileView {
	if (tileView.tile.guess) {
		for (NSInteger row = 0; row < game.board.size; row++) {
			for (NSInteger col = 0; col < game.board.size; col++) {
				ZSTileViewController *iteratedTileView = [self getTileViewControllerAtRow:row col:col];
				
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
	for (ZSTileViewController *highlightedErrorTileView in highlightedErrorTileViews) {
		highlightedErrorTileView.highlightedError = NO;
		[highlightedErrorTileView reloadView];
	}
	
	[highlightedErrorTileViews removeAllObjects];
}

- (void)addErrorHighlightsForTileView:(ZSTileViewController *)tileView {
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
			
			for (ZSTile *tile in rowSet) {
				ZSTileViewController *iteratedTileView = [self getTileViewControllerAtRow:tile.row col:tile.col];
				iteratedTileView.highlightedError = YES;
				[iteratedTileView reloadView];
				
				[highlightedErrorTileViews addObject:iteratedTileView];
			}
		}
		
		NSArray *colSet = [game getColSetForTileAtRow:tileView.tile.row col:tileView.tile.col includeSelf:NO];
		if ([self _getTotalTilesInSet:colSet withGuess:tileView.tile.guess] > 0) {
			selectedTileContainsErrors = YES;
			
			for (ZSTile *tile in colSet) {
				ZSTileViewController *iteratedTileView = [self getTileViewControllerAtRow:tile.row col:tile.col];
				iteratedTileView.highlightedError = YES;
				[iteratedTileView reloadView];
				
				[highlightedErrorTileViews addObject:iteratedTileView];
			}
		}
		
		NSArray *familySet = [game getFamilySetForTileAtRow:tileView.tile.row col:tileView.tile.col includeSelf:NO];
		if ([self _getTotalTilesInSet:familySet withGuess:tileView.tile.guess] > 0) {
			selectedTileContainsErrors = YES;
			
			for (ZSTile *tile in familySet) {
				ZSTileViewController *iteratedTileView = [self getTileViewControllerAtRow:tile.row col:tile.col];
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
	
	for (ZSTile *tile in set) {
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
	for (NSInteger row = 0; row < game.board.size; ++row) {
		for (NSInteger col = 0; col < game.board.size; ++col) {
			ZSTileViewController *tileViewController = [self getTileViewControllerAtRow:row col:col];
			
			tileViewController.highlightedHintType = ZSTileHintHighlightTypeNone;
			tileViewController.highlightGuessHint = NO;
			
			for (NSInteger i = 0; i < game.board.size; ++i) {
				tileViewController.highlightPencilHints[i] = ZSTilePencilTextTypeNormal;
			}
		}
	}
	
	[self reloadView];
}

#pragma mark - Tile Accessors

- (ZSTileViewController *)getTileViewControllerAtRow:(NSInteger)row col:(NSInteger)col {
	return [[tileViews objectAtIndex:row] objectAtIndex:col];
}

#pragma mark - ZSTileTouchDelegate Implementation

- (void)tileWasTouched:(ZSTileViewController *)newSelected {
	[self.touchDelegate tileWasTouchedInRow:newSelected.tile.row col:newSelected.tile.col];
}

@end
