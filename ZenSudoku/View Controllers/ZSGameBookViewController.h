//
//  ZSGameBookViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSGame.h"
#import "ZSGameViewController.h"
#import "ZSSplashPageViewController.h"

@class ZSHintViewController;

@interface ZSGameBookViewController : UIViewController <ZSHintDelegate, ZSFoldedPageViewControllerAnimationDelegate, ZSFoldedPageAndPlusButtonViewControllerAnimationDelegate> {
	ZSHintViewController *hintViewController;
	
	BOOL hintsShown;
}

@property (strong) ZSGameViewController *currentGameViewController;
@property (strong) ZSGameViewController *nextGameViewController;
@property (strong) ZSGameViewController *tempGameViewController;

- (void)showHint;
- (void)hideHint;

@end
