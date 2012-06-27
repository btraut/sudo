//
//  ZSGameViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"
#import "ZSGameBoardViewController.h"
#import "ZSGameAnswerOptionViewController.h"
#import "ZSFoldedCornerViewController.h"
#import "ZSFoldedCornerPlusButtonViewController.h"
#import "ZSGameAnswerOptionsViewController.h"

@class ZSGameBoardTileViewController;
@class ZSGameViewController;
@class ZSHintGenerator;
@class ZSFoldedPageViewController;

@protocol ZSHintDelegate <NSObject>

- (BOOL)getHintsShown;
- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController;
- (void)endHintDeck;

@end

@protocol ZSMajorGameStateDelegate <NSObject>

- (void)startNewGame;
- (void)frontViewControllerFinishedDisplaying;

@end

@interface ZSGameViewController : UIViewController <
	ZSGameStateChangeDelegate,
	ZSFoldedCornerGLViewControllerTouchDelegate,
	ZSFoldedCornerPlusButtonViewControllerAnimationDelegate,
	ZSGameAnswerOptionsViewControllerTouchDelegate,
	ZSGameBoardViewControllerTouchDelegate,
	ZSGameBoardViewControllerSelectionChangeDelegate
> {
	ZSGame *game;
	ZSHintGenerator *hintGenerator;
	
	ZSGameBoardViewController *gameBoardViewController;
	ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;
	
	ZSFoldedCornerViewController *foldedCornerViewController;
	
	UIButton *pencilButton;
	BOOL penciling;
	
	UIButton *undoButton;
	UIButton *autoPencilButton;
	UIButton *hintButton;
	
	BOOL allowsInput;
	
	UILabel *title;
}

@property (strong) ZSGame *game;

@property (strong, readonly) ZSGameBoardViewController *gameBoardViewController;
@property (strong, readonly) ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;

@property (strong, readonly) ZSFoldedCornerViewController *foldedCornerViewController;
@property (assign) BOOL foldedCornerVisibleOnLoad;

@property (strong, readonly) ZSFoldedPageViewController *foldedPageViewController;

@property (strong, readonly) UIButton *pencilButton;
@property (assign) BOOL penciling;

@property (assign) BOOL allowsInput;

@property (weak) id<ZSHintDelegate> hintDelegate;
@property (weak) id<ZSMajorGameStateDelegate> majorGameStateDelegate;

// Construction / Deconstruction
- (id)initWithGame:(ZSGame *)game;
- (void)resetWithGame:(ZSGame *)newGame;

// View Lifecycle
- (void)viewWasPromotedToFrontAnimated:(BOOL)animated;

- (void)setTitle;

- (UIImage *)getScreenshotImage;

// Game Functions
- (void)setAutoPencils;

// Button Handlers
- (void)pencilButtonWasTouched;
- (void)autoPencilButtonWasTouched;
- (void)undoButtonWasTouched;
- (void)redoButtonWasTouched;

- (void)hintButtonWasTouched;
- (void)closeHintButtonWasTouched;

@end
