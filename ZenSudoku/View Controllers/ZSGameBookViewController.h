//
//  ZSGameBookViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSGame.h"
#import "ZSGameViewController.h"

@class ZSHintViewController;

@interface ZSGameBookViewController : UIViewController <ZSHintDelegate, ZSMajorGameStateDelegate> {
	ZSGameViewController *currentGameViewController;
	ZSGameViewController *nextGameViewController;
	
	ZSHintViewController *hintViewController;
	
	BOOL hintsShown;
}

@property (nonatomic, strong) ZSGameViewController *currentGameViewController;
@property (nonatomic, strong) ZSGameViewController *nextGameViewController;

- (BOOL)getHintsShown;
- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController;
- (void)endHintDeck;
- (void)showHint;
- (void)hideHint;

- (void)startNewGame;

@end
