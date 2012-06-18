//
//  ZSPointAnimation.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZSAnimation.h"

@protocol ZSPointAnimationDelegate <NSObject>

- (void)animationAdvanced:(CGPoint)point progress:(float)progress;
- (void)animationDidFinish;

@end

@interface ZSPointAnimation : NSObject <ZSAnimationDelegate>

@property (nonatomic, strong) NSObject<ZSPointAnimationDelegate> *delegate;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) ZSAnimationTimingFunction timingFunction;

@property (nonatomic, assign) BOOL passProgressThrough;

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

- (void)start;
- (void)pause;
- (void)reset;

@end
