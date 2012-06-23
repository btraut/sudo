//
//  ZSHintViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSGameViewController;

@interface ZSHintViewController : UIViewController

- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController;

@end
