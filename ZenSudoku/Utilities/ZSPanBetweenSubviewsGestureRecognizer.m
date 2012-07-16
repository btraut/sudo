//
//  ZSPanBetweenSubviewsGestureRecognizer.m
//  ZenSudoku
//
//  Created by Brent Traut on 7/12/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSPanBetweenSubviewsGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface ZSPanBetweenSubviewsGestureRecognizer () {
	NSMutableArray *_subviews;
}

@end

@implementation ZSPanBetweenSubviewsGestureRecognizer

@synthesize selectedSubviewIndex = _selectedSubviewIndex;

- (id)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	
	if (self) {
		_subviews = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)addSubview:(UIView *)subview {
	[_subviews addObject:subview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
	[super touchesBegan:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self.view];
	
	self.state = UIGestureRecognizerStateBegan;

    for (NSInteger i = 0; i < [_subviews count]; i++) {
		UIView *currentSubview = [_subviews objectAtIndex:i];
		
		if (CGRectContainsPoint(currentSubview.frame, location)) {
			_selectedSubviewIndex = i;
			return;
		}
	}
	
	_selectedSubviewIndex = -1;
	self.state = UIGestureRecognizerStatePossible;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self.view];
	
    for (NSInteger i = 0; i < [_subviews count]; i++) {
		UIView *currentSubview = [_subviews objectAtIndex:i];
		
		if (CGRectContainsPoint(currentSubview.frame, location)) {
			_selectedSubviewIndex = i;
			return;
		}
	}
	
	_selectedSubviewIndex = -1;
	self.state = UIGestureRecognizerStatePossible;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self.view];
	
    for (NSInteger i = 0; i < [_subviews count]; i++) {
		UIView *currentSubview = [_subviews objectAtIndex:i];
		
		if (CGRectContainsPoint(currentSubview.frame, location)) {
			_selectedSubviewIndex = i;
			return;
		}
	}
	
	_selectedSubviewIndex = -1;
	self.state = UIGestureRecognizerStatePossible;
}

@end
