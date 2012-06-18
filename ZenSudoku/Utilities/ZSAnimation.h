//
//  ZSAnimation.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

@property (nonatomic, strong) NSObject<ZSAnimationDelegate> *delegate;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) ZSAnimationTimingFunction timingFunction;

@property (nonatomic, assign, readonly) BOOL isAnimating;

- (void)start;
- (void)pause;
- (void)reset;

@end
