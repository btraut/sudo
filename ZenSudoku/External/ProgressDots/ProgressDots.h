//
//  ProgressDots.h
//  ZenSudoku
//
//  Created by Brent Traut on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressDots : UIView

@property (nonatomic, assign) NSInteger totalDots;
@property (nonatomic, assign) NSInteger selectedDot;
@property (nonatomic, assign) CGFloat dotOffset;
@property (nonatomic, strong) UIImage *dotImage;
@property (nonatomic, strong) UIImage *selectedDotImage;

@end
