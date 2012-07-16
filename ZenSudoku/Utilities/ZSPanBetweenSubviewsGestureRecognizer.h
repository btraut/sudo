//
//  ZSPanBetweenSubviewsGestureRecognizer.h
//  ZenSudoku
//
//  Created by Brent Traut on 7/12/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSPanBetweenSubviewsGestureRecognizer : UIPanGestureRecognizer

@property (assign, readonly) NSInteger selectedSubviewIndex;

- (void)addSubview:(UIView *)subview;

@end
