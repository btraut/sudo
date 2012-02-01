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
	NSMutableArray *highlightedTileViews;
}

@property (strong) ZSGame *game;
@property (strong, readonly) NSArray *tileViews;

@property (strong) NSObject *delegate;

@property (strong, readonly) ZSGameBoardTileViewController *selectedTileView;
@property (strong, readonly) NSMutableArray *highlightedTileViews;


+ (id)gameBoardViewControllerForGame:(ZSGame *)game;

- (id)initWithGame:(ZSGame *)game;

- (void)reloadView;
- (ZSGameBoardTileViewController *)getGameBoardTileViewControllerAtRow:(NSInteger)row col:(NSInteger)col;

- (void)gameBoardTileWasTouched:(ZSGameBoardTileViewController *)tileView;

- (void)selectTileView:(ZSGameBoardTileViewController *)tileView;
- (void)deselectTileView;

- (void)removeAllHighlights;
- (void)addHighlightsForTilesInfluencedByTileView:(ZSGameBoardTileViewController *)tileView;
- (void)resetHighlightsForSelectedTile;


@end
