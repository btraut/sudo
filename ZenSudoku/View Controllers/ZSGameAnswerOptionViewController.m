//
//  ZSGameAnswerOptionViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameAnswerOptionViewController.h"

@interface ZSGameAnswerOptionViewController () {
	BOOL _previousTouchWasInBounds;
}

@end

@implementation ZSGameAnswerOptionViewController

@synthesize gameAnswerOption, selected, enabled;
@synthesize delegate;

- (id)init {
	self = [super init];
	
	if (self) {
		gameAnswerOption = ZSGameAnswerOption1;
		selected = NO;
		enabled = YES;
	}
	
	return self;
}

- (id)initWithGameAnswerOption:(ZSGameAnswerOption)newGameAnswerOption {
	self = [self init];
	
	if (self) {
		gameAnswerOption = newGameAnswerOption;
	}
	
	return self;
}

#pragma mark - View Lifecycle

- (void)loadView {
	UILabel *theView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
	theView.font = [UIFont fontWithName:@"ReklameScript-Regular" size:34.0f];
	theView.textAlignment = UITextAlignmentCenter;
	theView.backgroundColor = [UIColor clearColor];
	theView.userInteractionEnabled = YES;
	
	self.view = theView;
	
	[self setLabel];
}

- (void)setLabel {
	UILabel *theView = (UILabel *)self.view;
	
	switch (gameAnswerOption) {
		case ZSGameAnswerOption1:
		case ZSGameAnswerOption2:
		case ZSGameAnswerOption3:
		case ZSGameAnswerOption4:
		case ZSGameAnswerOption5:
		case ZSGameAnswerOption6:
		case ZSGameAnswerOption7:
		case ZSGameAnswerOption8:
		case ZSGameAnswerOption9:
			theView.text = [NSString stringWithFormat:@"%i", ((NSInteger)gameAnswerOption + 1)];
			break;
		
		default:
			break;
	}
}

- (void)reloadView {
	UILabel *theView = (UILabel *)self.view;
	
	if (enabled) {
		theView.textColor = [UIColor blackColor];
	} else {
		theView.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	}
}

#pragma mark - Sudoku Stuff

- (void)setSelected:(BOOL)newSelected {
	selected = newSelected;
	
	if (selected) {
		self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.2];
	} else {
		self.view.backgroundColor = [UIColor clearColor];
	}
}

#pragma mark - Touch Events

- (void)handleTouchEnter {
	if (enabled) {
		[(id<ZSGameAnswerOptionTouchDelegate>)delegate gameAnswerOptionTouchEntered:self];
	}
}

- (void)handleTouchExit {
	if (enabled) {
		[(id<ZSGameAnswerOptionTouchDelegate>)delegate gameAnswerOptionTouchExited:self];
	}
}

- (void)handleTap {
	if (enabled) {
		[(id<ZSGameAnswerOptionTouchDelegate>)delegate gameAnswerOptionTapped:self];
	}
}

@end
