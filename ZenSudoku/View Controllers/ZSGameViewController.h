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
@class ZSGameViewController;
@class ZSHintGenerator;

@protocol ZSHintDelegate <NSObject>

- (BOOL)getHintsShown;
- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController;
- (void)endHintDeck;

@end

@interface ZSGameViewController : UIViewController <ZSGameDelegate> {
	ZSGame *game;
	ZSHintGenerator *hintGenerator;
	
	ZSGameBoardViewController *gameBoardViewController;
	ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;
	
	UIButton *pencilButton;
	BOOL penciling;
	
	UIButton *autoPencilButton;
	UIButton *hintButton;
	
	UIBarButtonItem *undoButton;
	UIBarButtonItem *redoButton;
	
	BOOL allowsInput;
	
	UILabel *title;
	
	NSObject<ZSHintDelegate> *hintDelegate;
}

@property (strong) ZSGame *game;

@property (strong, readonly) ZSGameBoardViewController *gameBoardViewController;
@property (strong, readonly) ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;

@property (strong, readonly) UIButton *pencilButton;
@property (assign) BOOL penciling;

@property (assign) BOOL allowsInput;

@property (strong) NSObject<ZSHintDelegate> *hintDelegate;

- (id)initWithGame:(ZSGame *)game;

- (void)setTitle;

- (void)gameBoardTileWasTouchedInRow:(NSInteger)row col:(NSInteger)col;

- (void)gameAnswerOptionTouchEnteredWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;
- (void)gameAnswerOptionTouchExitedWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;
- (void)gameAnswerOptionTappedWithGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption;

- (void)setPencilForGameBoardTile:(ZSGameBoardTileViewController *)tileView withAnswerOption:(ZSGameAnswerOptionViewController *)answerOptionView;
- (void)setAnswerForGameBoardTile:(ZSGameBoardTileViewController *)tileView withAnswerOption:(ZSGameAnswerOptionViewController *)answerOptionView;

- (void)setErrors;

- (void)closeButtonWasTouched;
- (void)pencilButtonWasTouched;
- (void)autoPencilButtonWasTouched;
- (void)undoButtonWasTouched;
- (void)redoButtonWasTouched;

- (void)hintButtonWasTouched;
- (void)closeHintButtonWasTouched;

- (void)setAutoPencils;

- (void)tileGuessDidChange:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)tilePencilDidChange:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)timerDidAdvance;
- (void)gameWasSolved;

@end
