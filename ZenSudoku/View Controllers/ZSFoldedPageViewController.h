//
//  ZSFoldedPageViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 7/9/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSFoldedCornerViewController.h"

@class ZSFoldedPageViewController;

@protocol ZSFoldedPageViewControllerAnimationDelegate <NSObject>
@optional

- (void)pageTurnAnimationDidFinishWithViewController:(ZSFoldedPageViewController *)viewController;
- (void)startFoldAnimationDidFinishWithViewController:(ZSFoldedPageViewController *)viewController;
- (void)sendFoldBackToCornerAnimationDidFinishWithViewController:(ZSFoldedPageViewController *)viewController;
- (void)cornerTugAnimationDidFinishWithViewController:(ZSFoldedPageViewController *)viewController;

@end

@interface ZSFoldedPageViewController : UIViewController <ZSFoldedCornerViewControllerTouchDelegate, ZSFoldedCornerViewControllerAnimationDelegate>

@property (weak) id<ZSFoldedPageViewControllerAnimationDelegate> animationDelegate;

@property (strong, readonly) UIView *innerView;
@property (strong) UIImage *innerViewImage;

@property (strong, readonly) ZSFoldedCornerViewController *foldedCornerViewController;
@property (assign) BOOL foldedCornerVisibleOnLoad;

@property (assign) BOOL needsScreenshotUpdate;
@property (assign) BOOL forceScreenshotUpdateOnDrag;

- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;

- (UIImage *)getScreenshotImage;
- (void)updateScreenshotSynchronous:(BOOL)synchronous;
- (void)setScreenshotVisible:(BOOL)visible;

- (void)turnPage;

- (void)foldedCornerRestoredToDefaultPoint;

@end
