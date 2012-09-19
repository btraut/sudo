//
//  ZSAnswerOptionViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"

@class ZSAnswerOptionViewController;
@class ZSAnswerOptionsViewController;

@protocol ZSAnswerOptionTouchDelegate <NSObject>

- (void)gameAnswerOptionTouchEntered:(ZSAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTouchExited:(ZSAnswerOptionViewController *)gameAnswerOptionView;
- (void)gameAnswerOptionTapped:(ZSAnswerOptionViewController *)gameAnswerOptionView;

@end

@interface ZSAnswerOptionViewController : UIViewController

@property (weak) ZSAnswerOptionsViewController *gameAnswerOptionsViewController;

@property (assign) ZSAnswerOption gameAnswerOption;

@property (assign) BOOL selected;
@property (assign) BOOL enabled;
@property (assign) BOOL toggled;

@property (weak) id<ZSAnswerOptionTouchDelegate> delegate;

@property (strong) UILabel *labelView;
@property (strong) UIImageView *selectionView;

- (id)initWithGameAnswerOption:(ZSAnswerOption)gameAnswerOption;
- (void)setLabel;

- (void)reloadView;

- (void)setSelected:(BOOL)selected;

- (void)handleTouchEnter;
- (void)handleTouchExit;
- (void)handleTap;

@end

extern NSString * const kTextColorAnswerOptionNormal;
extern NSString * const kTextColorAnswerOptionDisabled;
extern NSString * const kTextColorAnswerOptionToggledOn;
extern NSString * const kTextColorAnswerOptionToggledOff;

extern NSString * const kTextShadowColorAnswerOptionNormal;
extern NSString * const kTextShadowColorAnswerOptionDisabled;
extern NSString * const kTextShadowColorAnswerOptionToggledOn;
extern NSString * const kTextShadowColorAnswerOptionToggledOff;
