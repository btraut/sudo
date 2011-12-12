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

@protocol ZSGameAnswerOptionTouchDelegate <NSObject>

- (void)gameAnswerOptionWasTouched:(ZSGameAnswerOptionViewController *)gameAnswerOptionView;

@end

@interface ZSGameAnswerOptionViewController : UIViewController {
	ZSGameAnswerOption gameAnswerOption;
	BOOL selected;
	BOOL enabled;
	
	NSObject *delegate;
}

@property (assign) ZSGameAnswerOption gameAnswerOption;
@property (assign, readonly) BOOL selected;
@property (assign) BOOL enabled;

@property (strong) NSObject *delegate;

- (id)initWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;
- (void)setLabel;

- (void)reloadView;

- (void)setSelected:(BOOL)selected;

@end
