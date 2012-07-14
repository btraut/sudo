//
//  ZSFoldedCornerPlusButtonViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/22/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSAnimation.h"

typedef enum {
	ZSFoldedCornerPlusButtonStateNormal,
	ZSFoldedCornerPlusButtonStateBig,
	ZSFoldedCornerPlusButtonStateStartStage1,
	ZSFoldedCornerPlusButtonStateHidden
} ZSFoldedCornerPlusButtonState;

typedef enum {
	ZSFoldedCornerPlusButtonAnimationStateIdle,
	ZSFoldedCornerPlusButtonAnimationStateAnimatingNormalToBig,
	ZSFoldedCornerPlusButtonAnimationStateAnimatingBigToNormal,
	ZSFoldedCornerPlusButtonAnimationStateAnimatingEnd,
	ZSFoldedCornerPlusButtonAnimationStateAnimatingStartStage1,
	ZSFoldedCornerPlusButtonAnimationStateAnimatingStartStage2
} ZSFoldedCornerPlusButtonAnimationState;

@class ZSFoldedCornerPlusButtonViewController;

@protocol ZSFoldedCornerPlusButtonViewControllerAnimationDelegate <NSObject>
@optional

- (void)foldedCornerPlusButtonStartAnimationFinishedWithViewController:(ZSFoldedCornerPlusButtonViewController *)viewController;

@end

@interface ZSFoldedCornerPlusButtonViewController : UIViewController <ZSAnimationDelegate>

@property (weak) id<ZSFoldedCornerPlusButtonViewControllerAnimationDelegate> animationDelegate;

@property (assign, readonly, getter = getIsAnimating) BOOL isAnimating;

- (void)pauseAnimation;
- (void)resumeAnimation;
- (void)resetToDefaultPosition;

- (void)setState:(ZSFoldedCornerPlusButtonState)state animated:(BOOL)animated;

@end

extern NSString * const kTextColorPlusLabel;
extern NSString * const kTextShadowColorPlusLabel;
