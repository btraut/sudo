//
//  ZSPointAnimation.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/18/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import "ZSPointAnimation.h"

@interface ZSPointAnimation() {
	BOOL _animationStarted;
	ZSAnimation *_animation;
}

@end

@implementation ZSPointAnimation

@synthesize delegate = _delegate;

@synthesize duration = _duration;
@synthesize timingFunction = _timingFunction;

@synthesize passProgressThrough = _passProgressThrough;

@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;

- (id)init {
	self = [super init];
	
	if (self) {
		_animationStarted = NO;
		
		_animation = [[ZSAnimation alloc] init];
		_animation.delegate = self;
	}
	
	return self;
}

- (void)start {
	if (!_animationStarted) {
		_animationStarted = YES;
		
		_animation.duration = _duration;
		_animation.timingFunction = _timingFunction;
	}
	
	[_animation start];
}

- (void)pause {
	[_animation pause];
}

- (void)reset {
	_animationStarted = NO;
	[_animation reset];
}

- (void)animationAdvanced:(float)progress {
	[_delegate animationAdvanced:CGPointMake(_startPoint.x + (_endPoint.x - _startPoint.x) * progress, _startPoint.y + (_endPoint.y - _startPoint.y) * progress) progress:progress];
}

- (void)animationDidFinish {
	[self reset];
	[_delegate animationDidFinish];
}

@end
