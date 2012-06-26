//
//  ZSGameBoardViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"
#import "ZSGameBoardTileViewController.h"

@class ZSGameViewController;

@interface ZSGameBoardViewController : UIViewController <ZSGameBoardTileTouchDelegate> {
	NSArray *tileViews;
	
	ZSGameBoardTileViewController *selectedTileView;
	NSMutableArray *highlightedSimilarTileViews;
	NSMutableArray *highlightedErrorTileViews;
}

@property (weak) ZSGame *game;
@property (strong, readonly) NSArray *tileViews;

@property (weak) ZSGameViewController *delegate;

@property (strong, readonly) ZSGameBoardTileViewController *selectedTileView;
@property (strong, readonly) NSMutableArray *highlightedSimilarTileViews;


// View Lifecycle
+ (id)gameBoardViewControllerForGame:(ZSGame *)game;

- (id)initWithGame:(ZSGame *)game;

- (void)resetWithGame:(ZSGame *)newGame;

// Board Changes
- (void)reloadView;

- (void)selectTileView:(ZSGameBoardTileViewController *)tileView;
- (void)reselectTile;
- (void)deselectTileView;

// Handling Highlights
- (void)removeAllSimilarHighlights;
- (void)addSimilarHighlightsForTileView:(ZSGameBoardTileViewController *)tileView;
- (void)resetSimilarHighlights;

- (void)removeAllErrorHighlights;
- (void)addErrorHighlightsForTileView:(ZSGameBoardTileViewController *)tileView;
- (void)resetErrorHighlights;

- (void)removeAllHintHighlights;

- (NSInteger)_getTotalTilesInSet:(NSArray *)set withGuess:(NSInteger)guess;

// Tile Accessors
- (ZSGameBoardTileViewController *)getGameBoardTileViewControllerAtRow:(NSInteger)row col:(NSInteger)col;

// Delegate Responsibilities
- (void)gameBoardTileWasTouched:(ZSGameBoardTileViewController *)tileView;

@end
