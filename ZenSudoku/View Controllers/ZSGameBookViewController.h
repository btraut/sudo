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

@class ZSHintViewController;

@interface ZSGameBookViewController : UIViewController <ZSHintDelegate, ZSMajorGameStateDelegate> {
	ZSHintViewController *hintViewController;
	
	BOOL hintsShown;
}

@property (strong) ZSGameViewController *currentGameViewController;
@property (strong) ZSGameViewController *nextGameViewController;
@property (strong) ZSGameViewController *tempGameViewController;

- (BOOL)getHintsShown;
- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController;
- (void)endHintDeck;
- (void)showHint;
- (void)hideHint;

- (void)startNewGame;

@end
