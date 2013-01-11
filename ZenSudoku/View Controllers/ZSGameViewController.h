//
//  ZSGameViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSFoldedPageViewController.h"

#import "ZSGame.h"
#import "ZSBoardViewController.h"
#import "ZSAnswerOptionViewController.h"
#import "ZSFoldedCornerViewController.h"
#import "ZSFoldedCornerPlusButtonViewController.h"
#import "ZSAnswerOptionsViewController.h"
#import "ZSAnswerOptionsTallViewController.h"

@class ZSTileViewController;
@class ZSGameViewController;
@class ZSHintGenerator;
@class ZSHintButtonViewController;

@protocol ZSHintDelegate <NSObject>

- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController;
- (void)endHintDeck;

@end

@protocol ZSFoldedPageAndPlusButtonViewControllerAnimationDelegate <ZSFoldedPageViewControllerAnimationDelegate>
@optional

- (void)plusButtonStartAnimationDidFinishWithViewController:(ZSGameViewController *)viewController;
- (void)userBeganDraggingFoldedCornerWithViewController:(ZSGameViewController *)viewController;

@end

@protocol ZSDifficultyButtonViewControllerDelegate <ZSFoldedPageViewControllerAnimationDelegate>

- (void)difficultyButtonWasPressedWithViewController:(ZSGameViewController *)viewController;

@end

@protocol ZSMajorGameStateChangeDelegate <NSObject>

- (void)gameWasSolvedWithViewController:(ZSGameViewController *)viewController;

@end

@interface ZSGameViewController : ZSFoldedPageViewController <
	ZSGameStateChangeDelegate,
	ZSFoldedCornerViewControllerTouchDelegate,
	ZSFoldedCornerViewControllerAnimationDelegate,
	ZSFoldedCornerPlusButtonViewControllerAnimationDelegate,
	ZSAnswerOptionsViewControllerTouchDelegate,
	ZSBoardViewControllerTouchDelegate
> {
	ZSHintGenerator *hintGenerator;
	
	UIButton *pencilButton;
	UIButton *undoButton;
	UIButton *autoPencilButton;
	ZSHintButtonViewController *hintButtonViewController;
}

@property (strong) ZSGame *game;

@property (assign) BOOL active;

@property (strong, readonly) ZSBoardViewController *boardViewController;
@property (strong, readonly) ZSAnswerOptionsViewController *gameAnswerOptionsViewController;

@property (assign) BOOL penciling;

@property (assign) BOOL allowsInput;
@property (assign) BOOL solved;

@property (weak) id<ZSHintDelegate> hintDelegate;
@property (weak) id<ZSFoldedPageAndPlusButtonViewControllerAnimationDelegate> animationDelegate;
@property (weak) id<ZSDifficultyButtonViewControllerDelegate> difficultyButtonDelegate;
@property (weak) id<ZSMajorGameStateChangeDelegate> majorGameStateChangeDelegate;

@property (assign, readonly) BOOL actionWasMadeOnPuzzle;

// Construction / Deconstruction
- (id)initWithGame:(ZSGame *)game;
- (void)resetWithGame:(ZSGame *)newGame;

// View Lifecycle
- (void)viewWasPromotedToFront;
- (void)viewWasPushedToBack;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;

- (void)showTapToChangeDifficultyNoticeAnimated:(BOOL)animated;
- (void)hideTapToChangeDifficultyNoticeAnimated:(BOOL)animated;

- (void)setTitle;

// Game Functions
- (void)setAutoPencils;
- (void)solveMostOfThePuzzle;
- (void)completeCoreGameOperation;

@end
