//
//  ZSAnimation.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/18/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ZSAnimationTimingFunctionLinear,
	ZSAnimationTimingFunctionEaseIn,
	ZSAnimationTimingFunctionEaseOut,
	ZSAnimationTimingFunctionEaseInOut
} ZSAnimationTimingFunction;

@protocol ZSAnimationDelegate <NSObject>

- (void)animationAdvanced:(float)progress;
- (void)animationDidFinish;

@end

@interface ZSAnimation : NSObject

@property (weak) id<ZSAnimationDelegate> delegate;

@property (assign) NSTimeInterval duration;
@property (assign) ZSAnimationTimingFunction timingFunction;

@property (assign, readonly) BOOL isAnimating;

- (void)start;
- (void)pause;
- (void)reset;

@end
