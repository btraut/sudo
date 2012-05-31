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

@class ZSGameViewController;

@interface ZSGameAnswerOptionsViewController : UIViewController <ZSGameAnswerOptionTouchDelegate> {
	ZSGameViewController *gameViewController;
	
	NSObject *delegate;
	
	NSArray *gameAnswerOptionViewControllers;
	UIButton *pencilToggleButton;
	
	ZSGameAnswerOptionViewController *selectedGameAnswerOptionView;
}

- (id)initWithGameViewController:(ZSGameViewController *)newGameViewController;

- (ZSGameAnswerOptionViewController *)getGameAnswerOptionViewControllerForGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;

- (void)reloadView;

- (void)gameAnswerOptionTouchEntered:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTouchExited:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTapped:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;

- (void)selectGameAnswerOptionView:(ZSGameAnswerOptionViewController *)gameAnswerOptionViewController;
- (void)deselectGameAnswerOptionView;

@property (strong) ZSGameViewController *gameViewController;

@property (strong) NSObject *delegate;

@property (strong, readonly) NSArray *gameAnswerOptionViewControllers;
@property (strong, readonly) UIButton *pencilToggleButton;

@property (strong, readonly) ZSGameAnswerOptionViewController *selectedGameAnswerOptionView;

@end
