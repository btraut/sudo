//
//  UIHintButtonViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIHintButtonViewController : UIViewController

@property (strong) UIButton *button;

@property (assign, readonly) BOOL pulsing;

- (void)startPulsing;
- (void)stopPulsing;

@end
