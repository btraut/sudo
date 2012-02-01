//
//  ZSGameBoardViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameBoardViewController.h"
#import "ZSGameBoardTileViewController.h"
#import "ZSGameViewController.h"
#import "ZSGame.h"
#import "ZSGameBoard.h"
#import "ZSGameTile.h"

@implementation ZSGameBoardViewController

@synthesize game, tileViews;
@synthesize delegate;
@synthesize selectedTileView, highlightedTileViews;

+ (id)gameBoardViewControllerForGame:(ZSGame *)game {
	return [[ZSGameBoardViewController alloc] initWithGame:game];
}

- (id)init {
	self = [super init];
	
	if (self) {
		selectedTileView = nil;
		highlightedTileViews = [NSMutableArray array];
	}
	
	return self;
}

- (id)initWithGame:(ZSGame *)newGame {
	self = [self init];
	
	if (self) {
		// Initialize member vars.
		game = newGame;
		
		selectedTileView = nil;
		highlightedTileViews = [NSMutableArray array];
	}
	
	return self;
}

#pragma mark - View Lifecycle

- (void)loadView {
	self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"board.png"]];
	self.view.frame = CGRectMake(0, 0, 302, 302);
	self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Build the tiles.
	NSMutableArray *rows = [NSMutableArray array];
	int yOffset = 2;
	
	for (int row = 0; row < game.gameBoard.size; row++) {
		int xOffset = 2;
		
		NSMutableArray *rowTiles = [NSMutableArray array];
		
		for (int col = 0; col < game.gameBoard.size; col++) {
			ZSGameBoardTileViewController *tileViewController = [[ZSGameBoardTileViewController alloc] initWithTile:[game getTileAtRow:row col:col]];
			tileViewController.view.frame = CGRectMake(xOffset, yOffset, tileViewController.view.frame.size.width, tileViewController.view.frame.size.height);
			tileViewController.delegate = self;
			
			[self.view addSubview:tileViewController.view];
			[rowTiles addObject:tileViewController];
			
			xOffset += (col % 3 == 2) ? 34 : 33;
		}
		
		[rows addObject:[NSArray arrayWithArray:rowTiles]];
		
		yOffset += (row % 3 == 2) ? 34 : 33;
	}
	
	tileViews = [NSArray arrayWithArray:rows];
	
	[self reloadView];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

#pragma mark - Board Changes

- (void)reloadView {
	for (int row = 0; row < game.gameBoard.size; row++) {
		for (int col = 0; col < game.gameBoard.size; col++) {
			[[self getGameBoardTileViewControllerAtRow:row col:col] reloadView];
		}
	}
}

- (void)selectTileView:(ZSGameBoardTileViewController *)tileView {
	// If there was a selection, deselect it.
	if (selectedTileView) {
		[self deselectTileView];
	}
	
	// Add selection.
	selectedTileView = tileView;
	
	selectedTileView.selected = YES;
	[selectedTileView reloadView];
	
	// Add highlights.
	[self addHighlightsForTilesInfluencedByTileView:selectedTileView];
}

- (void)deselectTileView {
	if (selectedTileView) {
		// Remove all highlights.
		[self removeAllHighlights];
		
		[highlightedTileViews removeAllObjects];

		// Remove selection.
		selectedTileView.selected = NO;
		[selectedTileView reloadView];
		
		selectedTileView = nil;
	}
}

- (void)removeAllHighlights {
	for (ZSGameBoardTileViewController *highlightedTileView in highlightedTileViews) {
		highlightedTileView.highlighted = NO;
		[highlightedTileView reloadView];
	}
}

- (void)addHighlightsForTilesInfluencedByTileView:(ZSGameBoardTileViewController *)tileView {
	if (tileView.tile.guess) {
		for (int row = 0; row < game.gameBoard.size; row++) {
			for (int col = 0; col < game.gameBoard.size; col++) {
				ZSGameBoardTileViewController *iteratedTileView = [self getGameBoardTileViewControllerAtRow:row col:col];
				
				if (iteratedTileView.tile.guess == selectedTileView.tile.guess || [iteratedTileView.tile getPencilForGuess:tileView.tile.guess]) {
					iteratedTileView.highlighted = YES;
					[iteratedTileView reloadView];
					
					[highlightedTileViews addObject:iteratedTileView];
				}
			}
		}
	}
}

- (void)resetHighlightsForSelectedTile {
	if (selectedTileView) {
		[self removeAllHighlights];
		[self addHighlightsForTilesInfluencedByTileView:selectedTileView];
	}
}

#pragma mark - Tile Accessors

- (ZSGameBoardTileViewController *)getGameBoardTileViewControllerAtRow:(int)row col:(int)col {
	return [[tileViews objectAtIndex:row] objectAtIndex:col];
}

#pragma mark - Delegate Responsibilities

- (void)gameBoardTileWasTouched:(ZSGameBoardTileViewController *)newSelected {
	[(ZSGameViewController *)delegate gameBoardTileWasTouchedInRow:newSelected.tile.row col:newSelected.tile.col];
}

@end
