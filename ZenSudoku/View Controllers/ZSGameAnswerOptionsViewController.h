//
//  ZSGameAnswerOptionsViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"
#import "ZSGameAnswerOptionViewController.h"

@class ZSGame;

@interface ZSGameAnswerOptionsViewController : UIViewController <ZSGameAnswerOptionTouchDelegate> {
	ZSGame *game;
	
	NSObject *delegate;
	
	NSArray *gameAnswerOptionViewControllers;
	UIButton *pencilToggleButton;
	
	ZSGameAnswerOptionViewController *selectedGameAnswerOptionView;
}

+ (id)gameAnswerOptionsViewControllerForGame:(ZSGame *)newGame;

- (id)initWithGame:(ZSGame *)newGame;

- (ZSGameAnswerOptionViewController *)getGameAnswerOptionViewControllerForGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;

- (void)reloadView;

- (void)gameAnswerOptionWasTouched:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;
- (void)selectGameAnswerOptionView:(ZSGameAnswerOptionViewController *)gameAnswerOptionViewController;
- (void)deselectGameAnswerOptionView;

@property (strong) ZSGame *game;

@property (strong) NSObject *delegate;

@property (strong, readonly) NSArray *gameAnswerOptionViewControllers;
@property (strong, readonly) UIButton *pencilToggleButton;

@property (strong, readonly) ZSGameAnswerOptionViewController *selectedGameAnswerOptionView;

@end
