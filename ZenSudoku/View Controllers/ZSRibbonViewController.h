//
//  ZSRibbonViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 7/16/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSGame.h"

@protocol ZSRibbonViewControllerDelegate <NSObject>

- (void)difficultyWasSelected:(ZSGameDifficulty)difficulty;

@end

@interface ZSRibbonViewController : UIViewController

@property (weak) id<ZSRibbonViewControllerDelegate> delegate;

@end
