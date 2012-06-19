//
//  ZSGameAnswerOptionViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"

@class ZSGameAnswerOptionViewController;
@class ZSGameAnswerOptionsViewController;

@protocol ZSGameAnswerOptionTouchDelegate <NSObject>

- (void)gameAnswerOptionTouchEntered:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTouchExited:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTapped:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;

@end

@interface ZSGameAnswerOptionViewController : UIViewController {
	ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;
	
	ZSGameAnswerOption gameAnswerOption;
	BOOL selected;
	BOOL enabled;
	BOOL toggled;
}

@property (nonatomic, strong) ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;

@property (assign) ZSGameAnswerOption gameAnswerOption;

@property (assign) BOOL selected;
@property (assign) BOOL enabled;
@property (assign) BOOL toggled;

@property (weak) id<ZSGameAnswerOptionTouchDelegate> delegate;

- (id)initWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;
- (void)setLabel;

- (void)reloadView;

- (void)setSelected:(BOOL)selected;

- (void)handleTouchEnter;
- (void)handleTouchExit;
- (void)handleTap;

@end
