//
//  ZSAnswerOptionTallViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 9/17/12.
//
//

#import "ZSAnswerOptionTallViewController.h"
#import "UIColor+ColorWithHex.h"

@interface ZSAnswerOptionTallViewController ()

@end

@implementation ZSAnswerOptionTallViewController

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
	self.view.clipsToBounds = NO;
}

- (void)_buildButton {
	self.labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	self.labelView.font = [UIFont fontWithName:@"ReklameScript-Regular" size:44.0f];
	self.labelView.textAlignment = NSTextAlignmentCenter;
	self.labelView.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	self.labelView.lineBreakMode = NSLineBreakByClipping;
	self.labelView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswerOptionNormal];
	self.labelView.backgroundColor = [UIColor clearColor];
	self.labelView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorAnswerOptionNormal];
	self.labelView.shadowOffset = CGSizeMake(0, 1);
	[self setLabel];
	
	UIImage *selectionImage = [UIImage imageNamed:@"BlueAnswerOptionSelection-Tall"];
	self.selectionView = [[UIImageView alloc] initWithImage:selectionImage];
	self.selectionView.frame = CGRectMake(0, -5, self.selectionView.frame.size.width, self.selectionView.frame.size.height);
	self.selectionView.alpha = 0.4f;
	self.selectionView.hidden = YES;
	
	[self.view addSubview:self.selectionView];
	[self.view addSubview:self.labelView];
}

@end
