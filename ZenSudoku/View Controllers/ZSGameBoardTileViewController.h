//
//  ZSGameBoardTileViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSGameTile;
@class ZSGameBoardTileViewController;
@class FontLabel;

@protocol ZSGameBoardTileTouchDelegate <NSObject>

- (void)gameBoardTileWasTouched:(ZSGameBoardTileViewController *)tileView;

@end

@interface ZSGameBoardTileViewController : UIViewController {
	ZSGameTile *tile;
	NSObject *delegate;
	
	BOOL selected;
	BOOL highlighted;
	BOOL incorrect;
	
	NSArray *pencilViews;
	FontLabel *guessView;
}

@property (strong) ZSGameTile *tile;
@property (strong) NSObject *delegate;

@property (nonatomic, assign) BOOL selected;
@property (assign) BOOL highlighted;
@property (assign) BOOL incorrect;

@property (strong) NSArray *pencilViews;
@property (strong) UILabel *guessView;

- (id)initWithTile:(ZSGameTile *)newTile;

- (void)handleTap;

- (void)reloadView;

@end

// Tile Color Constants
extern NSString * const kTextColorAnswer;
extern NSString * const kTextColorGuess;
extern NSString * const kTextColorError;

extern NSString * const kTileColorNormal;
extern NSString * const kTileColorSelected;
extern NSString * const kTileColorHighlightAnswer;
extern NSString * const kTileColorHighlightPencil;
extern NSString * const kTileColorError;
extern NSString * const kTileColorErrorSelected;
