//
//  ZSPointAnimation.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/18/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZSAnimation.h"

@protocol ZSPointAnimationDelegate <NSObject>

- (void)animationAdvanced:(CGPoint)point progress:(float)progress;
- (void)animationDidFinish;

@end

@interface ZSPointAnimation : NSObject <ZSAnimationDelegate>

@property (weak) id<ZSPointAnimationDelegate> delegate;

@property (assign) NSTimeInterval duration;
@property (assign) ZSAnimationTimingFunction timingFunction;

@property (assign) BOOL passProgressThrough;

@property (assign) CGPoint startPoint;
@property (assign) CGPoint endPoint;

- (void)start;
- (void)pause;
- (void)reset;

@end
