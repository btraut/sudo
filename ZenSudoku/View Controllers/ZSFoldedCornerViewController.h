//
//  ZSFoldedCornerViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/14/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "ZSFoldedCornerGLView.h"
#import "ZSPointAnimation.h"

@class ZSFoldedCornerPlusButtonViewController;

@protocol ZSFoldedCornerGLViewControllerTouchDelegate <NSObject>

- (void)foldedCornerTouchStartedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions;
- (void)foldedCornerTouchMovedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions;
- (void)foldedCornerTouchEndedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions;
- (void)foldedCornerRestoredToDefaultPoint;
- (void)pageTurnAnimationDidFinish;
- (void)startFoldAnimationDidFinish;

@end

@interface ZSFoldedCornerViewController : UIViewController <GLKViewDelegate, ZSFoldedCornerGLHitTestDelegate, ZSPointAnimationDelegate> {
	double H, phi, theta;
	CGPoint cornerTranslation;
	CGSize frameDimensions;
	CGSize foldDimensions;
	
	CGPoint shadowStart;
	CGSize underShadowDimensions;
	CGSize underShadowFoldedPageOffset;
}

@property (weak) id<ZSFoldedCornerGLViewControllerTouchDelegate> touchDelegate;

@property (weak) ZSFoldedCornerPlusButtonViewController *plusButtonViewController;

@property (assign) BOOL drawPage;
@property (assign) BOOL needsScreenshotUpdate;

@property (assign) BOOL useTranslucentPaper;

- (void)setPageImage:(UIImage *)image;

- (void)resetToStartPosition;
- (void)resetToDefaultPosition;

- (void)pushUpdate;

- (void)animateSendFoldBackToCorner;
- (void)animatePageTurn;
- (void)animateStartFold;
- (void)animateCornerTug;

@end
