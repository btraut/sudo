//
//  ZSGameViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGame.h"
#import "ZSGameBoardTileViewController.h"
#import "ZSGameAnswerOptionViewController.h"

@class ZSGameBoardViewController;
@class ZSGameAnswerOptionsViewController;

@interface ZSGameViewController : UIViewController <ZSGameDelegate> {
	ZSGame *game;
	
	ZSGameBoardViewController *gameBoardViewController;
	ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;
	
	UIBarButtonItem *pencilButton;
	BOOL penciling;
	
	UIBarButtonItem *autoPencilButton;
	
	UIBarButtonItem *undoButton;
	UIBarButtonItem *redoButton;
	
	BOOL allowsInput;
}

@property (strong) ZSGame *game;

@property (strong, readonly) ZSGameBoardViewController *gameBoardViewController;
@property (strong, readonly) ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;

@property (strong, readonly) UIBarButtonItem *pencilButton;
@property (assign) BOOL penciling;

@property (assign) BOOL allowsInput;

- (id)initWithGame:(ZSGame *)game;

- (void)setTitle;

- (void)gameBoardTileWasTouchedInRow:(int)row col:(int)col;
- (void)gameAnswerOptionWasTouchedWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;

- (void)setPencilForGameBoardTile:(ZSGameBoardTileViewController *)tileView withAnswerOption:(ZSGameAnswerOptionViewController *)answerOptionView;
- (void)setAnswerForGameBoardTile:(ZSGameBoardTileViewController *)tileView withAnswerOption:(ZSGameAnswerOptionViewController *)answerOptionView;

- (void)setErrors;

- (void)closeButtonWasTouched;
- (void)pencilButtonWasTouched;
- (void)autoPencilButtonWasTouched;
- (void)undoButtonWasTouched;
- (void)redoButtonWasTouched;

- (void)tileGuessDidChange:(int)guess forTileAtRow:(int)row col:(int)col;
- (void)tilePencilDidChange:(BOOL)isSet forPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col;
- (void)timerDidAdvance;
- (void)gameWasSolved;

@end
