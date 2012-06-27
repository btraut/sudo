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

@protocol ZSGameBoardViewControllerTouchDelegate <NSObject>

- (void)gameBoardTileWasTouchedInRow:(NSInteger)row col:(NSInteger)col;

@end

@protocol ZSGameBoardViewControllerSelectionChangeDelegate <NSObject>

- (void)selectedTileChanged;

@end

@interface ZSGameBoardViewController : UIViewController <ZSGameBoardTileViewControllerTouchDelegate> {
	NSArray *tileViews;
	
	ZSGameBoardTileViewController *selectedTileView;
	NSMutableArray *highlightedSimilarTileViews;
	NSMutableArray *highlightedErrorTileViews;
}

@property (weak) ZSGame *game;
@property (strong, readonly) NSArray *tileViews;

@property (weak) id<ZSGameBoardViewControllerTouchDelegate> touchDelegate;
@property (weak) id<ZSGameBoardViewControllerSelectionChangeDelegate> selectionChangeDelegate;

@property (strong, readonly) ZSGameBoardTileViewController *selectedTileView;
@property (strong, readonly) NSMutableArray *highlightedSimilarTileViews;

// Construction / Deconstruction
- (id)initWithGame:(ZSGame *)game;
- (void)resetWithGame:(ZSGame *)newGame;

// View Lifecycle
- (void)reloadView;

// Selection
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

// Tile Accessors
- (ZSGameBoardTileViewController *)getGameBoardTileViewControllerAtRow:(NSInteger)row col:(NSInteger)col;

@end
