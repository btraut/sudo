//
//  ZSAnswerOptionViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSAnswerOptionViewController.h"
#import "ZSAnswerOptionsViewController.h"
#import "ZSGameViewController.h"
#import "UIColor+ColorWithHex.h"
#import "UIDevice+Resolutions.h"

// Tile Color Constants
NSString * const kTextColorAnswerOptionNormal = @"#FF000000";
NSString * const kTextColorAnswerOptionDisabled = @"#22000000";
NSString * const kTextColorAnswerOptionToggledOn = @"#FF000000";
NSString * const kTextColorAnswerOptionToggledOff = @"#77000000";

NSString * const kTextShadowColorAnswerOptionNormal = @"FFFFFFFF";
NSString * const kTextShadowColorAnswerOptionDisabled = @"22FFFFFF";
NSString * const kTextShadowColorAnswerOptionToggledOn = @"FFFFFFFF";
NSString * const kTextShadowColorAnswerOptionToggledOff = @"77FFFFFF";

@interface ZSAnswerOptionViewController () {
	BOOL _previousTouchWasInBounds;
}

@end

@implementation ZSAnswerOptionViewController

@synthesize gameAnswerOptionsViewController;
@synthesize gameAnswerOption;
@synthesize selected, enabled, toggled;
@synthesize delegate;
@synthesize labelView;
@synthesize selectionView;

- (id)init {
	self = [super init];
	
	if (self) {
		gameAnswerOption = ZSAnswerOption1;
		selected = NO;
		enabled = YES;
	}
	
	return self;
}

- (id)initWithGameAnswerOption:(ZSAnswerOption)newGameAnswerOption {
	self = [self init];
	
	if (self) {
		gameAnswerOption = newGameAnswerOption;
	}
	
	return self;
}

#pragma mark - View Lifecycle

- (void)loadView {
	UIDeviceResolution resolution = [UIDevice currentResolution];
	bool isiPad = (resolution == UIDevice_iPadStandardRes || resolution == UIDevice_iPadHiRes);
	
	if (isiPad) {
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
	} else {
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
	}
	
	self.view.clipsToBounds = NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self _buildButton];
}

- (void)_buildButton {
	UIDeviceResolution resolution = [UIDevice currentResolution];
	bool isiPad = (resolution == UIDevice_iPadStandardRes || resolution == UIDevice_iPadHiRes);
	
	CGFloat labelFontSize = isiPad ? 64 : 34;
	CGFloat labelShadowSize = isiPad ? 2 : 1;

	self.labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	self.labelView.font = [UIFont fontWithName:@"ReklameScript-Regular" size:labelFontSize];
	self.labelView.textAlignment = NSTextAlignmentCenter;
	self.labelView.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	self.labelView.lineBreakMode = NSLineBreakByClipping;
	self.labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionNormal];
	self.labelView.backgroundColor = [UIColor clearColor];
	self.labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionNormal];
	self.labelView.shadowOffset = CGSizeMake(0, labelShadowSize);
	[self setLabel];
	
	NSString *selectionImageName = isiPad ? @"BlueAnswerOptionSelection-iPad" : @"BlueAnswerOptionSelection";
	
	UIImage *selectionImage = [UIImage imageNamed:selectionImageName];
	self.selectionView = [[UIImageView alloc] initWithImage:selectionImage];
	
	if (isiPad) {
		self.selectionView.frame = CGRectMake(-2, -10, self.selectionView.frame.size.width, self.selectionView.frame.size.height);
	} else {
		self.selectionView.frame = CGRectMake(-4, -4, self.selectionView.frame.size.width, self.selectionView.frame.size.height);
	}
	
	self.selectionView.alpha = 0.4f;
	self.selectionView.hidden = YES;
	
	[self.view addSubview:self.selectionView];
	[self.view addSubview:self.labelView];
}

- (void)setLabel {
	switch (gameAnswerOption) {
		case ZSAnswerOption1:
		case ZSAnswerOption2:
		case ZSAnswerOption3:
		case ZSAnswerOption4:
		case ZSAnswerOption5:
		case ZSAnswerOption6:
		case ZSAnswerOption7:
		case ZSAnswerOption8:
		case ZSAnswerOption9:
			self.labelView.text = [NSString stringWithFormat:@"%li", ((NSInteger)self.gameAnswerOption + 1)];
			break;
		
		default:
			break;
	}
}

- (void)reloadView {
	if (self.enabled) {
		if (self.gameAnswerOptionsViewController.gameViewController.penciling) {
			if (toggled) {
				self.labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionToggledOn];
				self.labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionToggledOn];
			} else {
				self.labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionToggledOff];
				self.labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionToggledOff];
			}
		} else {
			self.labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionNormal];
			self.labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionNormal];
		}
	} else {
		self.labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionDisabled];
		self.labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionDisabled];
	}
	
	self.selectionView.hidden = !selected;
}

#pragma mark - Touch Events

- (void)handleTouchEnter {
	if (self.enabled) {
		[self.delegate gameAnswerOptionTouchEntered:self];
	}
}

- (void)handleTouchExit {
	if (self.enabled) {
		[self.delegate gameAnswerOptionTouchExited:self];
	}
}

- (void)handleTap {
	if (self.enabled) {
		[self.delegate gameAnswerOptionTapped:self];
	}
}

@end
