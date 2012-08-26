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

@property (strong, readonly) ZSGameViewController *currentGameViewController;
@property (strong, readonly) ZSGameViewController *nextGameViewController;
@property (strong, readonly) ZSGameViewController *lastGameViewController;

@property (assign, readonly) BOOL hintsShown;
@property (assign, readonly) BOOL ribbonShown;

- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;

- (void)showHint;
- (void)hideHint;

- (void)showChangeDifficultyRibbon;
- (void)hideChangeDifficultyRibbon;

@end
