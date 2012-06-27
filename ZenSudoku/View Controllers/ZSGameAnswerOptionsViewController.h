//
//  ZSGameAnswerOptionsViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"
#import "ZSGameAnswerOptionViewController.h"

@class ZSGameViewController;

@protocol ZSGameAnswerOptionsViewControllerTouchDelegate <NSObject>

- (void)gameAnswerOptionTouchEnteredWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;
- (void)gameAnswerOptionTouchExitedWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;
- (void)gameAnswerOptionTappedWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;

@end

@interface ZSGameAnswerOptionsViewController : UIViewController <ZSGameAnswerOptionTouchDelegate> {
	NSArray *gameAnswerOptionViewControllers;
	UIButton *pencilToggleButton;
}

- (id)initWithGameViewController:(ZSGameViewController *)newGameViewController;

- (ZSGameAnswerOptionViewController *)getGameAnswerOptionViewControllerForGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;

- (void)reloadView;

- (void)gameAnswerOptionTouchEntered:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTouchExited:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTapped:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;

- (void)selectGameAnswerOptionView:(ZSGameAnswerOptionViewController *)gameAnswerOptionViewController;
- (void)deselectGameAnswerOptionView;

@property (weak) ZSGameViewController *gameViewController;

@property (weak) id<ZSGameAnswerOptionsViewControllerTouchDelegate> touchDelegate;

@property (strong, readonly) NSArray *gameAnswerOptionViewControllers;
@property (strong, readonly) UIButton *pencilToggleButton;

@property (weak, readonly) ZSGameAnswerOptionViewController *selectedGameAnswerOptionView;

@end
