//
//  ZSAnswerOptionsViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"
#import "ZSAnswerOptionViewController.h"

@class ZSGameViewController;
@class ZSPanBetweenSubviewsGestureRecognizer;

@protocol ZSAnswerOptionsViewControllerTouchDelegate <NSObject>

- (void)gameAnswerOptionTouchEnteredWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption;
- (void)gameAnswerOptionTouchExitedWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption;
- (void)gameAnswerOptionTappedWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption;

@end

@interface ZSAnswerOptionsViewController : UIViewController <ZSAnswerOptionTouchDelegate> {
	NSArray *gameAnswerOptionViewControllers;
	UIButton *pencilToggleButton;
}

- (id)initWithGameViewController:(ZSGameViewController *)newGameViewController;

- (ZSAnswerOptionViewController *)getGameAnswerOptionViewControllerForGameAnswerOption:(ZSAnswerOption)gameAnswerOption;

- (void)reloadView;

- (void)gameAnswerOptionTouchEntered:(ZSAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTouchExited:(ZSAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTapped:(ZSAnswerOptionViewController *)gameAnswerOptionView;

- (void)selectGameAnswerOptionView:(ZSAnswerOptionViewController *)gameAnswerOptionViewController;
- (void)deselectGameAnswerOptionView;

- (void)pan:(ZSPanBetweenSubviewsGestureRecognizer *)sender;

@property (weak) ZSGameViewController *gameViewController;

@property (weak) id<ZSAnswerOptionsViewControllerTouchDelegate> touchDelegate;

@property (strong, readonly) NSArray *gameAnswerOptionViewControllers;
@property (strong, readonly) UIButton *pencilToggleButton;

@property (weak, readonly) ZSAnswerOptionViewController *selectedGameAnswerOptionView;

@end
