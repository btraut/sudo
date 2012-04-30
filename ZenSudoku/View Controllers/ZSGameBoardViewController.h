//
//  ZSGameBoardViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"
#import "ZSGameBoardTileViewController.h"

@interface ZSGameBoardViewController : UIViewController <ZSGameBoardTileTouchDelegate> {
	ZSGame *game;
	NSArray *tileViews;
	
	NSObject *delegate;
	
	ZSGameBoardTileViewController *selectedTileView;
	NSMutableArray *highlightedSimilarTileViews;
	NSMutableArray *highlightedErrorTileViews;
}

@property (strong) ZSGame *game;
@property (strong, readonly) NSArray *tileViews;

@property (strong) NSObject *delegate;

@property (strong, readonly) ZSGameBoardTileViewController *selectedTileView;
@property (strong, readonly) NSMutableArray *highlightedSimilarTileViews;


// View Lifecycle
+ (id)gameBoardViewControllerForGame:(ZSGame *)game;

- (id)initWithGame:(ZSGame *)game;

// Board Changes
- (void)reloadView;

- (void)selectTileView:(ZSGameBoardTileViewController *)tileView;
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
