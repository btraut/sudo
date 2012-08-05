//
//  ZSGameBookViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSGame.h"
#import "ZSGameViewController.h"
#import "ZSSplashPageViewController.h"
#import "ZSChangeDifficultyRibbonViewController.h"

@class ZSHintViewController;

@interface ZSGameBookViewController : UIViewController <
	ZSHintDelegate,
	ZSFoldedPageViewControllerAnimationDelegate,
	ZSFoldedPageAndPlusButtonViewControllerAnimationDelegate,
	ZSChangeDifficultyRibbonViewControllerDelegate,
	ZSDifficultyButtonViewControllerDelegate,
	ZSMajorGameStateChangeDelegate
>

@property (strong) ZSGameViewController *currentGameViewController;
@property (strong) ZSGameViewController *nextGameViewController;
@property (strong) ZSGameViewController *lastGameViewController;

@property (strong) ZSGameViewController *extraGameViewController;

@property (assign, readonly) BOOL hintsShown;
@property (assign, readonly) BOOL ribbonShown;

- (void)showHint;
- (void)hideHint;

- (void)showChangeDifficultyRibbon;
- (void)hideChangeDifficultyRibbon;

@end
