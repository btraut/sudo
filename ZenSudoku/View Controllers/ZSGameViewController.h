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
#import "ZSFoldedCornerViewController.h"

@class ZSGameBoardViewController;
@class ZSGameAnswerOptionsViewController;
@class ZSGameViewController;
@class ZSHintGenerator;

@protocol ZSHintDelegate <NSObject>

- (BOOL)getHintsShown;
- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController;
- (void)endHintDeck;

@end

@protocol ZSMajorGameStateDelegate <NSObject>

- (void)startNewGame;

@end

@interface ZSGameViewController : UIViewController <ZSGameDelegate, ZSFoldedCornerGLViewControllerTouchDelegate> {
	ZSGame *game;
	ZSHintGenerator *hintGenerator;
	
	ZSGameBoardViewController *gameBoardViewController;
	ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;
	
	ZSFoldedCornerViewController *foldedCornerViewController;
	
	UIButton *pencilButton;
	BOOL penciling;
	
	UIButton *autoPencilButton;
	UIButton *hintButton;
	
	UIBarButtonItem *undoButton;
	UIBarButtonItem *redoButton;
	
	BOOL allowsInput;
	
	UILabel *title;
}

@property (strong) ZSGame *game;

@property (strong, readonly) ZSGameBoardViewController *gameBoardViewController;
@property (strong, readonly) ZSGameAnswerOptionsViewController *gameAnswerOptionsViewController;

@property (strong, readonly) ZSFoldedCornerViewController *foldedCornerViewController;

@property (strong, readonly) UIButton *pencilButton;
@property (assign) BOOL penciling;

@property (assign) BOOL allowsInput;

@property (weak) id<ZSHintDelegate> hintDelegate;
@property (weak) id<ZSMajorGameStateDelegate> majorGameStateDelegate;

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

- (void)startPageFold;

@end
