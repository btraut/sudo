//
//  ZSBoardViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"
#import "ZSTileViewController.h"

@class ZSGameViewController;

@protocol ZSBoardViewControllerTouchDelegate <NSObject>

- (void)gameBoardTileWasTouchedInRow:(NSInteger)row col:(NSInteger)col;

@end

@protocol ZSBoardViewControllerSelectionChangeDelegate <NSObject>

- (void)selectedTileChanged;

@end

@interface ZSBoardViewController : UIViewController <ZSTileViewControllerTouchDelegate> {
	NSArray *tileViews;
	
	ZSTileViewController *selectedTileView;
	NSMutableArray *highlightedSimilarTileViews;
	NSMutableArray *highlightedErrorTileViews;
}

@property (weak) ZSGame *game;
@property (strong, readonly) NSArray *tileViews;

@property (weak) id<ZSBoardViewControllerTouchDelegate> touchDelegate;
@property (weak) id<ZSBoardViewControllerSelectionChangeDelegate> selectionChangeDelegate;

@property (strong, readonly) ZSTileViewController *selectedTileView;
@property (strong, readonly) NSMutableArray *highlightedSimilarTileViews;

// Construction / Deconstruction
- (id)initWithGame:(ZSGame *)game;
- (void)resetWithGame:(ZSGame *)newGame;

// View Lifecycle
- (void)reloadView;

// Selection
- (void)selectTileView:(ZSTileViewController *)tileView;
- (void)reselectTileView;
- (void)deselectTileView;

// Handling Highlights
- (void)removeAllSimilarHighlights;
- (void)addSimilarHighlightsForTileView:(ZSTileViewController *)tileView;
- (void)resetSimilarHighlights;

- (void)removeAllErrorHighlights;
- (void)addErrorHighlightsForTileView:(ZSTileViewController *)tileView;
- (void)resetErrorHighlights;

- (void)removeAllHintHighlights;

// Tile Accessors
- (ZSTileViewController *)getGameBoardTileViewControllerAtRow:(NSInteger)row col:(NSInteger)col;

@end
