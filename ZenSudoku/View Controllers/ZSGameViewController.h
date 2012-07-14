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

@class ZSTileViewController;
@class ZSGameViewController;
@class ZSHintGenerator;

@protocol ZSHintDelegate <NSObject>

- (BOOL)getHintsShown;
- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController;
- (void)endHintDeck;

@end

@protocol ZSFoldedPageAndPlusButtonViewControllerAnimationDelegate <ZSFoldedPageViewControllerAnimationDelegate>
@optional

- (void)plusButtonStartAnimationDidFinishWithViewController:(ZSGameViewController *)viewController;

@end

@interface ZSGameViewController : ZSFoldedPageViewController <
	ZSGameStateChangeDelegate,
	ZSFoldedCornerViewControllerTouchDelegate,
	ZSFoldedCornerViewControllerAnimationDelegate,
	ZSFoldedCornerPlusButtonViewControllerAnimationDelegate,
	ZSAnswerOptionsViewControllerTouchDelegate,
	ZSBoardViewControllerTouchDelegate
> {
	ZSGame *game;
	ZSHintGenerator *hintGenerator;
	
	ZSBoardViewController *boardViewController;
	ZSAnswerOptionsViewController *gameAnswerOptionsViewController;
	
	UIButton *pencilButton;
	BOOL penciling;
	
	UIButton *undoButton;
	UIButton *autoPencilButton;
	UIButton *hintButton;
	
	BOOL allowsInput;
	
	UILabel *title;
}

@property (strong) ZSGame *game;

@property (strong, readonly) ZSBoardViewController *boardViewController;
@property (strong, readonly) ZSAnswerOptionsViewController *gameAnswerOptionsViewController;

@property (strong, readonly) UIButton *pencilButton;
@property (assign) BOOL penciling;

@property (assign) BOOL allowsInput;

@property (weak) id<ZSHintDelegate> hintDelegate;
@property (weak) id<ZSFoldedPageAndPlusButtonViewControllerAnimationDelegate> animationDelegate;

// Construction / Deconstruction
- (id)initWithGame:(ZSGame *)game;
- (void)resetWithGame:(ZSGame *)newGame;

// View Lifecycle
- (void)viewWasPromotedToFrontAnimated:(BOOL)animated;
- (void)viewWasPushedToBack;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;

- (void)setTitle;

// Game Functions
- (void)deselectTileView;
- (void)setAutoPencils;
- (void)solveMostOfThePuzzle;
- (void)completeCoreGameOperation;

// Button Handlers
- (void)pencilButtonWasTouched;
- (void)autoPencilButtonWasTouched;
- (void)undoButtonWasTouched;
- (void)redoButtonWasTouched;

- (void)hintButtonWasTouched;
- (void)closeHintButtonWasTouched;

@end
