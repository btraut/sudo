//
//  ZSTileViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSTile;
@class ZSTileViewController;

typedef enum {
	ZSTileTextTypeAnswer,
	ZSTileTextTypeGuess,
	ZSTileTextTypeGuessSelected,
	ZSTileTextTypeGuessFingerDown,
	ZSTileTextTypeGuessError,
	ZSTileTextTypeGuessErrorSelected,
	ZSTileTextTypeHighlightHintA,
	ZSTileTextTypeHighlightHintB
} ZSTileTextType;

typedef enum {
	ZSTilePencilTextTypeNormal,
	ZSTilePencilTextTypeHighlightHintA,
	ZSTilePencilTextTypeHighlightHintB
} ZSTilePencilTextType;

typedef enum {
	ZSTileBackgroundTypeDefault,
	ZSTileBackgroundTypeSelected,
	ZSTileBackgroundTypeSimilarPencil,
    ZSTileBackgroundTypeSimilarAnswer,
    ZSTileBackgroundTypeSimilarError,
    ZSTileBackgroundTypeSimilarErrorGroup,
    ZSTileBackgroundTypeOtherError,
	ZSTileBackgroundTypeHighlightHintA,
	ZSTileBackgroundTypeHighlightHintB,
	ZSTileBackgroundTypeHighlightHintC,
	ZSTileBackgroundTypeHighlightHintD
} ZSTileBackgroundType;

typedef enum {
	ZSTileHintHighlightTypeNone,
	ZSTileHintHighlightTypeA,
	ZSTileHintHighlightTypeB,
	ZSTileHintHighlightTypeC,
	ZSTileHintHighlightTypeD
} ZSTileHintHighlightType;

typedef enum {
	ZSTileTextHintHighlightTypeNone,
	ZSTileTextHintHighlightTypeA,
	ZSTileTextHintHighlightTypeB
} ZSTileTextHintHighlightType;

typedef enum {
	ZSTilePencilTextHintHighlightTypeNone,
	ZSTilePencilTextHintHighlightTypeA,
	ZSTilePencilTextHintHighlightTypeB
} ZSTilePencilTextHintHighlightType;

@protocol ZSTileViewControllerTouchDelegate <NSObject>

- (void)gameBoardTileWasTouched:(ZSTileViewController *)tileView;

@end

@interface ZSTileViewController : UIViewController {
    ZSTileTextType textType;
    ZSTileBackgroundType backgroundType;
    
	BOOL ghosted;
	NSInteger ghostedValue;
	BOOL selected;
	BOOL error;
	BOOL highlightedSimilar;
	BOOL highlightedError;
	
	ZSTileHintHighlightType highlightedHintType;
	ZSTileTextHintHighlightType highlightGuessHint;
	ZSTilePencilTextType *highlightPencilHints;
	
	NSArray *pencilViews;
	UILabel *guessView;
}

@property (weak) ZSTile *tile;
@property (weak) id<ZSTileViewControllerTouchDelegate> touchDelegate;

@property (assign) ZSTileTextType textType;
@property (assign) ZSTileBackgroundType backgroundType;

@property (assign) BOOL ghosted;
@property (assign) NSInteger ghostedValue;
@property (assign) BOOL selected;
@property (assign) BOOL highlightedSimilar;
@property (assign) BOOL highlightedError;
@property (assign) BOOL error;

@property (assign) ZSTileHintHighlightType highlightedHintType;
@property (assign) ZSTileTextHintHighlightType highlightGuessHint;
@property (assign) ZSTilePencilTextType *highlightPencilHints;

- (id)initWithTile:(ZSTile *)newTile;

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
