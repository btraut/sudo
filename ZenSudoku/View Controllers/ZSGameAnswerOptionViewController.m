//
//  ZSGameAnswerOptionViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSGameAnswerOptionViewController.h"
#import "ZSGameAnswerOptionsViewController.h"
#import "ZSGameViewController.h"
#import "UIColor+ColorWithHex.h"

// Tile Color Constants
NSString * const kTextColorAnswerOptionNormal = @"#FF000000";
NSString * const kTextColorAnswerOptionDisabled = @"#22000000";
NSString * const kTextColorAnswerOptionToggledOn = @"#FF000000";
NSString * const kTextColorAnswerOptionToggledOff = @"#77000000";

NSString * const kTextShadowColorAnswerOptionNormal = @"FFFFFFFF";
NSString * const kTextShadowColorAnswerOptionDisabled = @"22FFFFFF";
NSString * const kTextShadowColorAnswerOptionToggledOn = @"FFFFFFFF";
NSString * const kTextShadowColorAnswerOptionToggledOff = @"77FFFFFF";

@interface ZSGameAnswerOptionViewController () {
	UILabel *_labelView;
	UIImageView *_selectionView;
	
	BOOL _previousTouchWasInBounds;
}

@end

@implementation ZSGameAnswerOptionViewController

@synthesize gameAnswerOptionsViewController;
@synthesize gameAnswerOption;
@synthesize selected, enabled, toggled;
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
	_labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
	_labelView.font = [UIFont fontWithName:@"ReklameScript-Regular" size:34.0f];
	_labelView.textAlignment = UITextAlignmentCenter;
	_labelView.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_labelView.lineBreakMode = UILineBreakModeClip;
	_labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionNormal];
	_labelView.backgroundColor = [UIColor clearColor];
	_labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionNormal];
	_labelView.shadowOffset = CGSizeMake(0, 1);
	[self setLabel];
	
	UIImage *selectionImage = [UIImage imageNamed:@"BlueAnswerOptionSelection"];
	_selectionView = [[UIImageView alloc] initWithImage:selectionImage];
	_selectionView.frame = CGRectMake(-4, -4, _selectionView.frame.size.width, _selectionView.frame.size.height);
	_selectionView.alpha = 0.4f;
	_selectionView.hidden = YES;
	
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
	self.view.clipsToBounds = NO;
	
	[self.view addSubview:_selectionView];
	[self.view addSubview:_labelView];
}

- (void)setLabel {
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
			_labelView.text = [NSString stringWithFormat:@"%i", ((NSInteger)gameAnswerOption + 1)];
			break;
		
		default:
			break;
	}
}

- (void)reloadView {
	if (enabled) {
		if (gameAnswerOptionsViewController.gameViewController.penciling) {
			if (toggled) {
				_labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionToggledOn];
				_labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionToggledOn];
			} else {
				_labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionToggledOff];
				_labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionToggledOff];
			}
		} else {
			_labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionNormal];
			_labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionNormal];
		}
	} else {
		_labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionDisabled];
		_labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionDisabled];
	}
	
	_selectionView.hidden = !selected;
}

#pragma mark - Touch Events

- (void)handleTouchEnter {
	if (enabled) {
		[delegate gameAnswerOptionTouchEntered:self];
	}
}

- (void)handleTouchExit {
	if (enabled) {
		[delegate gameAnswerOptionTouchExited:self];
	}
}

- (void)handleTap {
	if (enabled) {
		[delegate gameAnswerOptionTapped:self];
	}
}

@end
