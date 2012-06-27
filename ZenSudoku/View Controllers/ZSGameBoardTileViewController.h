//
//  ZSGameBoardTileViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSGameTile;
@class ZSGameBoardTileViewController;

typedef enum {
	ZSGameBoardTileTextTypeAnswer,
	ZSGameBoardTileTextTypeGuess,
	ZSGameBoardTileTextTypeGuessSelected,
	ZSGameBoardTileTextTypeGuessFingerDown,
	ZSGameBoardTileTextTypeGuessError,
	ZSGameBoardTileTextTypeGuessErrorSelected,
	ZSGameBoardTileTextTypeHighlightHintA,
	ZSGameBoardTileTextTypeHighlightHintB
} ZSGameBoardTileTextType;

typedef enum {
	ZSGameBoardTilePencilTextTypeNormal,
	ZSGameBoardTilePencilTextTypeHighlightHintA,
	ZSGameBoardTilePencilTextTypeHighlightHintB
} ZSGameBoardTilePencilTextType;

typedef enum {
	ZSGameBoardTileBackgroundTypeDefault,
	ZSGameBoardTileBackgroundTypeSelected,
	ZSGameBoardTileBackgroundTypeSimilarPencil,
    ZSGameBoardTileBackgroundTypeSimilarAnswer,
    ZSGameBoardTileBackgroundTypeSimilarError,
    ZSGameBoardTileBackgroundTypeSimilarErrorGroup,
    ZSGameBoardTileBackgroundTypeOtherError,
	ZSGameBoardTileBackgroundTypeHighlightHintA,
	ZSGameBoardTileBackgroundTypeHighlightHintB,
	ZSGameBoardTileBackgroundTypeHighlightHintC,
	ZSGameBoardTileBackgroundTypeHighlightHintD
} ZSGameBoardTileBackgroundType;

typedef enum {
	ZSGameBoardTileHintHighlightTypeNone,
	ZSGameBoardTileHintHighlightTypeA,
	ZSGameBoardTileHintHighlightTypeB,
	ZSGameBoardTileHintHighlightTypeC,
	ZSGameBoardTileHintHighlightTypeD
} ZSGameBoardTileHintHighlightType;

typedef enum {
	ZSGameBoardTileTextHintHighlightTypeNone,
	ZSGameBoardTileTextHintHighlightTypeA,
	ZSGameBoardTileTextHintHighlightTypeB
} ZSGameBoardTileTextHintHighlightType;

typedef enum {
	ZSGameBoardTilePencilTextHintHighlightTypeNone,
	ZSGameBoardTilePencilTextHintHighlightTypeA,
	ZSGameBoardTilePencilTextHintHighlightTypeB
} ZSGameBoardTilePencilTextHintHighlightType;

@protocol ZSGameBoardTileViewControllerTouchDelegate <NSObject>

- (void)gameBoardTileWasTouched:(ZSGameBoardTileViewController *)tileView;

@end

@interface ZSGameBoardTileViewController : UIViewController {
    ZSGameBoardTileTextType textType;
    ZSGameBoardTileBackgroundType backgroundType;
    
	BOOL ghosted;
	NSInteger ghostedValue;
	BOOL selected;
	BOOL error;
	BOOL highlightedSimilar;
	BOOL highlightedError;
	
	ZSGameBoardTileHintHighlightType highlightedHintType;
	ZSGameBoardTileTextHintHighlightType highlightGuessHint;
	ZSGameBoardTilePencilTextType *highlightPencilHints;
	
	NSArray *pencilViews;
	UILabel *guessView;
}

@property (weak) ZSGameTile *tile;
@property (weak) id<ZSGameBoardTileViewControllerTouchDelegate> touchDelegate;

@property (assign) ZSGameBoardTileTextType textType;
@property (assign) ZSGameBoardTileBackgroundType backgroundType;

@property (assign) BOOL ghosted;
@property (assign) NSInteger ghostedValue;
@property (assign) BOOL selected;
@property (assign) BOOL highlightedSimilar;
@property (assign) BOOL highlightedError;
@property (assign) BOOL error;

@property (assign) ZSGameBoardTileHintHighlightType highlightedHintType;
@property (assign) ZSGameBoardTileTextHintHighlightType highlightGuessHint;
@property (assign) ZSGameBoardTilePencilTextType *highlightPencilHints;

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
extern NSString * const kTextColorGuessFingerDown;
extern NSString * const kTextColorError;
extern NSString * const kTextColorErrorSelected;

extern NSString * const kTextShadowColorGuess;
extern NSString * const kTextShadowColorGuessSelected;
extern NSString * const kTextShadowColorGuessFingerDown;

extern NSString * const kTileColorDefault;
extern NSString * const kTileColorSelected;
extern NSString * const kTileColorHighlightSimilarAnswer;
extern NSString * const kTileColorHighlightSimilarPencil;
extern NSString * const kTileColorSimilarError;
extern NSString * const kTileColorSimilarErrorGroup;
extern NSString * const kTileColorOtherError;
