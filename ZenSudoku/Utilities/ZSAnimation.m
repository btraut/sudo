//
//  ZSAnimation.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/18/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSAnimation.h"

#import <QuartzCore/QuartzCore.h>

@interface ZSAnimation()

@property (strong) CADisplayLink *displayLink;

@property (strong) NSDate *startTime; 
@property (assign) NSTimeInterval timeElapsedBeforePause;

@end

@implementation ZSAnimation

@synthesize delegate;
@synthesize duration, timingFunction;

@synthesize displayLink = _displayLink;
@synthesize state = _state;
@synthesize startTime = _startTime;
@synthesize timeElapsedBeforePause = _timeElapsedBeforePause;

- (id)init {
	self = [super init];
	
	if (self) {
		_state = ZSAnimationStateIdle;
		
		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_animationAdvanced:)];
		_displayLink.frameInterval = 2;
		_displayLink.paused = YES;
	}
	
	return self;
}

- (void)start {
	if (self.state == ZSAnimationStateAnimating) {
		return;
	}
	
	self.startTime = [NSDate date];
	
	if (self.state == ZSAnimationStateIdle) {
		self.timeElapsedBeforePause = 0;
		
		[self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
	
	self.displayLink.paused = NO;
	
	_state = ZSAnimationStateAnimating;
}

- (void)pause {
	if (self.state == ZSAnimationStatePaused || self.state == ZSAnimationStateIdle) {
		return;
	}
	
	NSDate *now = [NSDate date];
	NSTimeInterval elapsedTime = [now timeIntervalSinceDate:self.startTime];
	self.timeElapsedBeforePause += elapsedTime;
	
	self.displayLink.paused = YES;
	
	_state = ZSAnimationStatePaused;
}

- (void)reset {
	if (self.state == ZSAnimationStateIdle) {
		return;
	}
	
	[self pause];
	
	[self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	_state = ZSAnimationStateIdle;
}

- (void)_animationAdvanced:(CADisplayLink *)sender {
	if (self.state == ZSAnimationStateAnimating) {
		NSDate *now = [NSDate date];
		NSTimeInterval elapsedTime = [now timeIntervalSinceDate:self.startTime];
		elapsedTime += self.timeElapsedBeforePause;
		
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
