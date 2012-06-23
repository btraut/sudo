//
//  ZSFoldedCornerPlusButtonViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

@protocol ZSFoldedCornerPlusButtonViewControllerAnimationDelegate <NSObject>

- (void)foldedCornerPlusButtonStartAnimationFinished;

@end

@interface ZSFoldedCornerPlusButtonViewController : UIViewController <ZSAnimationDelegate>

- (void)setState:(ZSFoldedCornerPlusButtonState)state animated:(BOOL)animated;

@property (weak) id<ZSFoldedCornerPlusButtonViewControllerAnimationDelegate> animationDelegate;

@end

extern NSString * const kTextColorPlusLabel;
extern NSString * const kTextShadowColorPlusLabel;
