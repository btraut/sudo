//
//  ZSFoldedCornerPlusButtonViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/22/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSFoldedCornerPlusButtonViewController.h"

#import "UIColor+ColorWithHex.h"
#import "UIDevice+Resolutions.h"

NSString * const kTextColorPlusLabel = @"FFC1C1C1";
NSString * const kTextShadowColorPlusLabel = @"66FFFFFF";

@interface ZSFoldedCornerPlusButtonViewController () {
	ZSFoldedCornerPlusButtonState _state;
	ZSFoldedCornerPlusButtonAnimationState _animationState;
	
	BOOL _stateChangeQueued;
	ZSFoldedCornerPlusButtonState _queuedState;
	BOOL _animateQueuedState;
	
	CGFloat _animationFontSizeStart;
	CGFloat _animationFontSizeEnd;
	
	CGFloat _plusButtonFullSize;
	CGFloat _plusButtonSmallSize;
	
	ZSAnimation *_animationHelper;
	
	CGPoint _viewCenter;
}

@end

@implementation ZSFoldedCornerPlusButtonViewController

@synthesize animationDelegate;

- (id)init {
	self = [super init];
	
	if (self) {
		_state = ZSFoldedCornerPlusButtonStateNormal;
		_animationState = ZSFoldedCornerPlusButtonAnimationStateIdle;
		
		_queuedState = ZSFoldedCornerPlusButtonStateNormal;
		_animateQueuedState = NO;
		
		UIDeviceResolution resolution = [UIDevice currentResolution];
		
		switch (resolution) {
			case UIDevice_iPadStandardRes:
			case UIDevice_iPadHiRes:
				_plusButtonFullSize = 27;
				_plusButtonSmallSize = 24;
				break;
				
			default:
				_plusButtonFullSize = 18;
				_plusButtonSmallSize = 16;
				break;
		}
	}
	
	return self;
}

- (void)loadView {
	UIDeviceResolution resolution = [UIDevice currentResolution];
	
	NSString *plusImageName;
	CGRect plusFrame;
	
	switch (resolution) {
		case UIDevice_iPadStandardRes:
		case UIDevice_iPadHiRes:
			plusImageName = @"Plus-iPad.png";
			plusFrame = CGRectMake(710, 16, _plusButtonFullSize, _plusButtonFullSize);
			break;
			
		default:
			plusImageName = @"Plus.png";
			plusFrame = CGRectMake(290, 5, _plusButtonFullSize, _plusButtonFullSize);
			break;
	}
	
	// Create the + button.
	UIImageView *plus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:plusImageName]];
	plus.frame = plusFrame;
	plus.contentMode = UIViewContentModeScaleAspectFit;
	self.view = plus;
}

- (void)viewDidLoad {
	_viewCenter = self.view.center;
	
	_animationHelper = [[ZSAnimation alloc] init];
	_animationHelper.delegate = self;
	
	[super viewDidLoad];
}

- (void)pauseAnimation {
	[_animationHelper pause];
}

- (void)resumeAnimation {
	if (self.isAnimating) {
		[_animationHelper start];
	}
}

- (BOOL)getIsAnimating {
	return _animationState != ZSFoldedCornerPlusButtonAnimationStateIdle;
}

- (void)resetToDefaultPosition {
	[_animationHelper reset];
	
	[self setSize:_plusButtonFullSize];
	
	self.view.hidden = NO;
	
	_state = ZSFoldedCornerPlusButtonStateNormal;
	_animationState = ZSFoldedCornerPlusButtonAnimationStateIdle;
	
	_queuedState = ZSFoldedCornerPlusButtonStateNormal;
	_animateQueuedState = NO;
}

- (void)setState:(ZSFoldedCornerPlusButtonState)state animated:(BOOL)animated {
	_queuedState = state;
	_animateQueuedState = animated;
	
	[self dequeueStateChange];
}

- (void)dequeueStateChange {
	// Only start the next state change if there isn't one happening now.
	if (_animationState != ZSFoldedCornerPlusButtonAnimationStateIdle) {
		return;
	}
	
	// Only start a state change if there's actually a different state to change to.
	if (_queuedState == _state) {
		return;
	}
	
	// Finite state machine, GO!
	switch (_queuedState) {
		case ZSFoldedCornerPlusButtonStateNormal:
			[self changeStateToNormalAnimated:_animateQueuedState];
			break;
			
		case ZSFoldedCornerPlusButtonStateBig:
			[self changeStateToBigAnimated:_animateQueuedState];
			break;
			
		case ZSFoldedCornerPlusButtonStateHidden:
			[self changeStateToHiddenAnimated:_animateQueuedState];
			break;
			
		case ZSFoldedCornerPlusButtonStateStartStage1:
			break;
	}
}

- (void)setSize:(CGFloat)size {
	self.view.frame = CGRectMake(0, 0, size, size);
	self.view.center = _viewCenter;
}

- (void)changeStateToNormalAnimated:(BOOL)animated {
	ZSFoldedCornerPlusButtonState formerState = _state;
	
	if (animated) {
		if (formerState == ZSFoldedCornerPlusButtonStateBig) {
			_state = ZSFoldedCornerPlusButtonStateNormal;
			_animationState = ZSFoldedCornerPlusButtonAnimationStateAnimatingBigToNormal;
			
			_animationFontSizeStart = self.view.frame.size.width;
			_animationFontSizeEnd = _plusButtonSmallSize;
			
			_animationHelper.duration = 0.3f;
			_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseIn;
			
			[_animationHelper start];
		} else if (formerState == ZSFoldedCornerPlusButtonStateHidden) {
			_state = ZSFoldedCornerPlusButtonStateStartStage1;
			_animationState = ZSFoldedCornerPlusButtonAnimationStateAnimatingStartStage1;
			
			_animationFontSizeStart = 0.1f;
			_animationFontSizeEnd = _plusButtonFullSize;
			
			[self setSize:0.1f];
			self.view.hidden = NO;
			
			_animationHelper.duration = 0.15f;
			_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseIn;
			
			[_animationHelper start];
		} else if (formerState == ZSFoldedCornerPlusButtonStateStartStage1) {
			_state = ZSFoldedCornerPlusButtonStateNormal;
			_animationState = ZSFoldedCornerPlusButtonAnimationStateAnimatingStartStage2;
			
			_animationFontSizeStart = self.view.frame.size.width;
			_animationFontSizeEnd = _plusButtonSmallSize;
			
			_animationHelper.duration = 0.15f;
			_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseIn;
			
			[_animationHelper start];
		}
	} else {
		_state = ZSFoldedCornerPlusButtonStateNormal;
		
		self.view.hidden = NO;
		[self setSize:_plusButtonSmallSize];
	}
}

- (void)changeStateToBigAnimated:(BOOL)animated {
	_state = ZSFoldedCornerPlusButtonStateBig;
	
	if (animated) {
		_animationState = ZSFoldedCornerPlusButtonAnimationStateAnimatingNormalToBig;
		
		_animationFontSizeStart = self.view.frame.size.width;
		_animationFontSizeEnd = _plusButtonFullSize;
		
		_animationHelper.duration = 0.3f;
		_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseIn;
		
		[_animationHelper start];
	} else {
		self.view.hidden = NO;
		[self setSize:20.0f];
	}
}

- (void)changeStateToHiddenAnimated:(BOOL)animated {
	_state = ZSFoldedCornerPlusButtonStateHidden;
	
	if (animated) {
		_animationState = ZSFoldedCornerPlusButtonAnimationStateAnimatingEnd;
		
		_animationFontSizeStart = self.view.frame.size.width;
		_animationFontSizeEnd = 0.1f;
		
		_animationHelper.duration = 0.2f;
		_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseIn;
		
		[_animationHelper start];
	} else {
		self.view.hidden = YES;
		[self setSize:0.1f];
	}
}

- (void)changeStateToHiddenAnimationEnded {
	self.view.hidden = YES;
}

- (void)animationAdvanced:(float)progress {
	CGFloat fontSize = _animationFontSizeStart + (_animationFontSizeEnd - _animationFontSizeStart) * progress;
	NSInteger roundedFontSize = (fontSize * 10);
	fontSize = (CGFloat)roundedFontSize / 10;
	
	[self setSize:fontSize];
}

- (void)animationDidFinish {
	ZSFoldedCornerPlusButtonAnimationState previousAnimationState = _animationState;
	_animationState = ZSFoldedCornerPlusButtonAnimationStateIdle;
	
	BOOL dequeue = YES;
	
	switch (previousAnimationState) {
		case ZSFoldedCornerPlusButtonAnimationStateAnimatingNormalToBig:
			break;
			
		case ZSFoldedCornerPlusButtonAnimationStateAnimatingBigToNormal:
			break;
			
		case ZSFoldedCornerPlusButtonAnimationStateAnimatingEnd:
			[self changeStateToHiddenAnimationEnded];
			break;
			
		case ZSFoldedCornerPlusButtonAnimationStateAnimatingStartStage1:
			_animationState = ZSFoldedCornerPlusButtonAnimationStateAnimatingStartStage1;
			[self changeStateToNormalAnimated:YES];
			dequeue = NO;
			break;
			
		case ZSFoldedCornerPlusButtonAnimationStateAnimatingStartStage2:
			if ([self.animationDelegate respondsToSelector: @selector(foldedCornerPlusButtonStartAnimationFinishedWithViewController:)]) {
				[self.animationDelegate foldedCornerPlusButtonStartAnimationFinishedWithViewController:self];
			}
			break;
			
		case ZSFoldedCornerPlusButtonAnimationStateIdle:
			break;
	}
	
	if (dequeue) {
		[self dequeueStateChange];
	}
}

@end
