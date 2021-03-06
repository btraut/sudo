//
//  ZSGame.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSBoard.h"

typedef enum {
	ZSGameDifficultyEasy,
	ZSGameDifficultyModerate,
	ZSGameDifficultyChallenging,
	ZSGameDifficultyDiabolical,
	ZSGameDifficultyInsane
} ZSGameDifficulty;

typedef enum {
	ZSGameTypeTraditional,
	ZSGameTypeWordoku,
	ZSGameTypeJigsaw
} ZSGameType;

typedef enum {
	ZSAnswerOption1,
	ZSAnswerOption2,
	ZSAnswerOption3,
	ZSAnswerOption4,
	ZSAnswerOption5,
	ZSAnswerOption6,
	ZSAnswerOption7,
	ZSAnswerOption8,
	ZSAnswerOption9
} ZSAnswerOption;

typedef enum {
	ZSShowErrorsOptionNever,
	ZSShowErrorsOptionLogical,
	ZSShowErrorsOptionAlways
} ZSShowErrorsOption;


@protocol ZSGameStateChangeDelegate <NSObject>

- (void)tileGuessDidChange:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)tilePencilDidChange:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)guess:(NSInteger)guess isErrorForTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)gameWasSolved;
- (void)timerDidAdvance;

@end


@class ZSHistoryEntry;
@class ZSBoard;
@class ZSTile;

@interface ZSGame : NSObject <ZSBoardDelegate, NSCoding>

@property (assign) ZSGameDifficulty difficulty;
@property (assign) ZSGameType type;

@property (strong) ZSBoard *board;

@property (assign) BOOL recordingHistory;

@property (weak) id<ZSGameStateChangeDelegate> stateChangeDelegate;

@property (assign, readonly) NSInteger timerCount;
@property (assign, readonly) NSInteger totalStrikes;
@property (assign) NSInteger totalHints;

// Creation / Initialization

+ (id)emptyStandard9x9Game;

- (id)initWithSize:(NSInteger)size;

- (void)notifyStatisticsOfNewGame;

// Tile Methods

- (NSInteger)getGuessForTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)clearGuessForTileAtRow:(NSInteger)row col:(NSInteger)col;

- (BOOL)getPencilForPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)togglePencilForPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;

- (void)guessDidChangeForTile:(ZSTile *)tile previousGuess:(NSInteger)previousGuess;
- (void)pencilDidChangeForTile:(ZSTile *)tile pencilNumber:(NSInteger)pencilNumber previousSet:(NSInteger)previousSet;

// Misc Methods

- (BOOL)allowsGuess:(NSInteger)guess;

- (BOOL)isSolved;

- (void)addAutoPencils;
- (void)clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col;

// Timer Methods

- (void)startGameTimer;
- (void)stopGameTimer;
- (void)advanceGameTimer:(NSTimer *)timer;

// Undo / Redo Helpers

- (void)undo;
- (void)undoAndPlaceOntoRedoStack:(BOOL)placeOntoRedoStack;
- (void)redo;
- (void)addHistoryDescription:(ZSHistoryEntry *)undoDescription;
- (void)startGenericUndoStop;
- (void)stopGenericUndoStop;
- (void)addUndoStop;

@end

// Game Difficulty Names
extern NSString * const kGameDifficultyNameEasy;
extern NSString * const kGameDifficultyNameModerate;
extern NSString * const kGameDifficultyNameChallenging;
extern NSString * const kGameDifficultyNameDiabolical;
extern NSString * const kGameDifficultyNameInsane;

// Game Type Names
extern NSString * const kGameTypeNameTraditional;
extern NSString * const kGameTypeNameWordoku;
extern NSString * const kGameTypeNameJigsaw;

// Dictionary Keys for Game Preservation / Restoration
extern NSString * const kDictionaryRepresentationGameSizeKey;
extern NSString * const kDictionaryRepresentationGameDifficultyKey;
extern NSString * const kDictionaryRepresentationGameTypeKey;

extern NSString * const kDictionaryRepresentationGameTilesKey;

extern NSString * const kDictionaryRepresentationGameTimerCountKey;
extern NSString * const kDictionaryRepresentationGameTotalStrikesKey;

extern NSString * const kDictionaryRepresentationGameUndoStackKey;
extern NSString * const kDictionaryRepresentationGameRedoStackKey;


