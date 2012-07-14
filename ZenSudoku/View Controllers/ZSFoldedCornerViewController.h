//
//  ZSFoldedCornerViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/14/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "ZSFoldedCornerView.h"
#import "ZSPointAnimation.h"

@class ZSFoldedCornerViewController;
@class ZSFoldedCornerPlusButtonViewController;

@protocol ZSFoldedCornerViewControllerTouchDelegate <NSObject>
@optional

- (void)foldedCornerViewController:(ZSFoldedCornerViewController *)viewController touchStartedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions;
- (void)foldedCornerViewController:(ZSFoldedCornerViewController *)viewController touchMovedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions;
- (void)foldedCornerViewController:(ZSFoldedCornerViewController *)viewController touchEndedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions;

@end

@protocol ZSFoldedCornerViewControllerAnimationDelegate <NSObject>
@optional

- (void)pageTurnAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController;
- (void)startFoldAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController;
- (void)sendFoldBackToCornerAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController;
- (void)cornerTugAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController;

@end

@interface ZSFoldedCornerViewController : UIViewController <GLKViewDelegate, ZSFoldedCornerViewHitTestDelegate, ZSPointAnimationDelegate> {
	double H, phi, theta;
	CGPoint cornerTranslation;
	CGSize frameDimensions;
	CGSize foldDimensions;
	
	CGPoint shadowStart;
	CGSize underShadowDimensions;
	CGSize underShadowFoldedPageOffset;
}

@property (weak) id<ZSFoldedCornerViewControllerTouchDelegate> touchDelegate;
@property (weak) id<ZSFoldedCornerViewControllerAnimationDelegate> animationDelegate;

@property (weak) ZSFoldedCornerPlusButtonViewController *plusButtonViewController;

@property (assign) BOOL drawPage;

@property (assign, readonly, getter = getIsAnimating) BOOL isAnimating;

- (void)setPageImage:(UIImage *)image;

- (void)pauseAnimation;
- (void)resumeAnimation;
- (void)resetToStartPosition;
- (void)resetToDefaultPosition;

- (void)pushUpdate;

- (void)animateSendFoldBackToCorner;
- (void)animatePageTurn;
- (void)animatePageTurnSlower;
- (void)animateStartFold;
- (void)animateCornerTug;

@end
