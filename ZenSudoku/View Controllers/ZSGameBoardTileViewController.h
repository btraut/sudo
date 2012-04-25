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

typedef enum {
	ZSGameBoardTileTextTypeAnswer,
	ZSGameBoardTileTextTypeGuess,
	ZSGameBoardTileTextTypeGuessSelected,
	ZSGameBoardTileTextTypeGuessError,
	ZSGameBoardTileTextTypeGuessErrorSelected,
} ZSGameBoardTileTextType;

typedef enum {
	ZSGameBoardTileBackgroundTypeDefault,
	ZSGameBoardTileBackgroundTypeSelected,
	ZSGameBoardTileBackgroundTypeSimilarPencil,
    ZSGameBoardTileBackgroundTypeSimilarAnswer,
    ZSGameBoardTileBackgroundTypeSimilarError,
    ZSGameBoardTileBackgroundTypeSimilarErrorGroup,
    ZSGameBoardTileBackgroundTypeOtherError
} ZSGameBoardTileBackgroundType;

@protocol ZSGameBoardTileTouchDelegate <NSObject>

- (void)gameBoardTileWasTouched:(ZSGameBoardTileViewController *)tileView;

@end

@interface ZSGameBoardTileViewController : UIViewController {
	ZSGameTile *tile;
	NSObject *delegate;
	
    ZSGameBoardTileTextType textType;
    ZSGameBoardTileBackgroundType backgroundType;
    
	BOOL selected;
	BOOL error;
	BOOL highlightedSimilar;
	BOOL highlightedError;
	
	NSArray *pencilViews;
	UILabel *guessView;
}

@property (strong) ZSGameTile *tile;
@property (strong) NSObject *delegate;

@property (assign) ZSGameBoardTileTextType textType;
@property (assign) ZSGameBoardTileBackgroundType backgroundType;

@property (nonatomic, assign) BOOL selected;
@property (assign) BOOL highlightedSimilar;
@property (assign) BOOL highlightedError;
@property (assign) BOOL error;

@property (strong) NSArray *pencilViews;
@property (strong) UILabel *guessView;

- (id)initWithTile:(ZSGameTile *)newTile;

- (void)handleTap;

- (void)reloadView;
- (void)reloadTextAndBackgroundType;

- (void)showGuess;
- (void)hideGuess;

@end

// Tile Color Constants
extern NSString * const kTextColorAnswer;
extern NSString * const kTextColorGuess;
extern NSString * const kTextColorGuessSelected;
extern NSString * const kTextColorError;
extern NSString * const kTextColorErrorSelected;

extern NSString * const kTextShadowColorGuess;
extern NSString * const kTextShadowColorGuessSelected;

extern NSString * const kTileColorDefault;
extern NSString * const kTileColorSelected;
extern NSString * const kTileColorHighlightSimilarAnswer;
extern NSString * const kTileColorHighlightSimilarPencil;
extern NSString * const kTileColorSimilarError;
extern NSString * const kTileColorSimilarErrorGroup;
extern NSString * const kTileColorOtherError;
