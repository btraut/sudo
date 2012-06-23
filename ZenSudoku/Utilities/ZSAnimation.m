//
//  ZSAnimation.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/18/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import "ZSAnimation.h"

#import <QuartzCore/QuartzCore.h>

@interface ZSAnimation()

@property (strong) CADisplayLink *_displayLink;

@property (assign) BOOL _startTimeSet; 
@property (strong) NSDate *_startTime; 

@end

@implementation ZSAnimation

@synthesize delegate;
@synthesize duration, timingFunction;
@synthesize isAnimating;

@synthesize _displayLink;
@synthesize _startTimeSet, _startTime;

- (id)init {
	self = [super init];
	
	if (self) {
		_startTimeSet = NO;
		
		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_animationAdvanced:)];
		_displayLink.frameInterval = 2;
		_displayLink.paused = YES;
	}
	
	return self;
}

- (void)start {
	if (!_startTimeSet) {
		_startTime = [NSDate date];
		
		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
	
	isAnimating = YES;
	_displayLink.paused = NO;
}

- (void)pause {
	isAnimating = NO;
	_displayLink.paused = YES;
}

- (void)reset {
	[self pause];
	
	_startTimeSet = NO;
	[_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)_animationAdvanced:(CADisplayLink *)sender {
	if (self.isAnimating) {
		NSDate *now = [NSDate date];
		
		NSTimeInterval elapsedTime = [now timeIntervalSinceDate:_startTime];
		
		float unweightedPercentComplete = (elapsedTime / self.duration);
		float percentComplete = [self _getPercentCompleteForRatio:unweightedPercentComplete];
		
		if (percentComplete > 1 || unweightedPercentComplete > 1) {
			unweightedPercentComplete = 1;
			percentComplete = 1;
		}
		
		[self.delegate animationAdvanced:percentComplete];
		
		if (unweightedPercentComplete == 1) {
			[self reset];
			[self.delegate animationDidFinish];
		}
	}
}

- (float)_getPercentCompleteForRatio:(float)ratio {
	switch (self.timingFunction) {
		case ZSAnimationTimingFunctionLinear:
			return [self _linear:ratio];
			break;
			
		case ZSAnimationTimingFunctionEaseIn:
			return [self _easeIn:ratio];
			break;
			
		case ZSAnimationTimingFunctionEaseOut:
			return [self _easeOut:ratio];
			break;
			
		case ZSAnimationTimingFunctionEaseInOut:
		default:
			return [self _easeInOut:ratio];
			break;
	};
}

- (float)_linear:(float)ratio {
	return ratio;
}

- (float)_easeIn:(float)ratio {
	return ratio * ratio;
}

- (float)_easeOut:(float)ratio {
	return -ratio * (ratio - 2);
}

- (float)_easeInOut:(float)ratio {
	ratio *= 2;
	
	if (ratio < 1) {
		return 0.5 * ratio * ratio;
	}
	
	ratio--;
	
	return -0.5 * (ratio * (ratio - 2) - 1);
}

@end
