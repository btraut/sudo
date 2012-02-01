//
//  ZSGame.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSGameBoard.h"
#import "ZSFastGameSolver.h"

typedef enum {
	ZSGameDifficultyEasy,
	ZSGameDifficultyMedium,
	ZSGameDifficultyHard,
	ZSGameDifficultyExpert
} ZSGameDifficulty;

typedef enum {
	ZSGameTypeTraditional,
	ZSGameTypeWordoku,
	ZSGameTypeJigsaw
} ZSGameType;

typedef enum {
	ZSGameAnswerOption1,
	ZSGameAnswerOption2,
	ZSGameAnswerOption3,
	ZSGameAnswerOption4,
	ZSGameAnswerOption5,
	ZSGameAnswerOption6,
	ZSGameAnswerOption7,
	ZSGameAnswerOption8,
	ZSGameAnswerOption9,
	ZSGameAnswerOptionErase
} ZSGameAnswerOption;

typedef enum {
	ZSGameTileAnswerOrderHybrid,
	ZSGameTileAnswerOrderAnswerFirst,
	ZSGameTileAnswerOrderTileFirst
} ZSGameTileAnswerOrder;

typedef enum {
	ZSShowErrorsOptionNever,
	ZSShowErrorsOptionLogical,
	ZSShowErrorsOptionAlways
} ZSShowErrorsOption;


@protocol ZSGameDelegate <NSObject>

- (void)tileGuessDidChange:(int)guess forTileAtRow:(int)row col:(int)col;
- (void)tilePencilDidChange:(BOOL)isSet forPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col;
- (void)guess:(int)guess isErrorForTileAtRow:(int)row col:(int)col;
- (void)gameWasSolved;
- (void)timerDidAdvance;

@end


@class ZSGameHistoryEntry;
@class ZSGameBoard;
@class ZSGameTile;

@interface ZSGame : NSObject <ZSGameBoardDelegate> {
	ZSGameDifficulty difficulty;
	ZSGameType type;
	
	ZSGameBoard *gameBoard;
	
	BOOL recordingHistory;
	
	NSObject<ZSGameDelegate> *delegate;
	
	int timerCount;
	
	int totalStrikes;
	
	@private
	
	NSMutableArray *_undoStack;
	NSMutableArray *_redoStack;
	
	NSTimer *_countdownTimer;
}

@property (nonatomic, assign) ZSGameDifficulty difficulty;
@property (nonatomic, assign) ZSGameType type;

@property (nonatomic, strong) ZSGameBoard *gameBoard;

@property (nonatomic, assign) BOOL recordingHistory;

@property (nonatomic, strong) NSObject<ZSGameDelegate> *delegate;

@property (nonatomic, readonly) int timerCount;

@property (nonatomic, readonly) int totalStrikes;

// Creation / Initialization

+ (id)emptyStandard9x9Game;

- (id)initWithSize:(int)size;
- (id)initWithSize:(int)size answers:(int **)answers groupMap:(int **)groupMap;

- (void)notifyStatisticsOfNewGame;

// Persistant Storage Methods

- (id)initWithDictionaryRepresentation:(NSDictionary *)dict;
- (NSDictionary *)getDictionaryRepresentation;

// Tile Methods

- (int)getGuessForTileAtRow:(int)row col:(int)col;
- (void)setGuess:(int)guess forTileAtRow:(int)row col:(int)col;
- (void)clearGuessForTileAtRow:(int)row col:(int)col;

- (BOOL)getLockedForTileAtRow:(int)row col:(int)col;
- (void)setLocked:(BOOL)locked forTileAtRow:(int)row col:(int)col;

- (BOOL)getPencilForPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col;
- (void)setPencil:(BOOL)isSet forPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col;
- (void)togglePencilForPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col;

- (void)guessDidChangeForTile:(ZSGameTile *)tile previousGuess:(int)previousGuess;
- (void)pencilDidChangeForTile:(ZSGameTile *)tile pencilNumber:(int)pencilNumber previousSet:(int)previousSet;

- (int)getGroupIdForTileAtRow:(int)row col:(int)col;

- (ZSGameTile *)getTileAtRow:(int)row col:(int)col;
- (NSArray *)getAllInfluencedTilesForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getRowSetForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getColSetForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getFamilySetForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf;

// Misc Methods

- (BOOL)allowsGuess:(int)guess;

- (ZSGameSolveResult)solve;
- (BOOL)isSolved;

- (void)addAutoPencils;
- (void)clearInfluencedPencilsForTileAtRow:(int)row col:(int)col;

// Timer Methods

- (void)startGameTimer;
- (void)stopGameTimer;
- (void)advanceGameTimer:(NSTimer *)timer;

// Undo / Redo Helpers

- (void)undo;
- (void)redo;
- (void)addHistoryDescription:(ZSGameHistoryEntry *)undoDescription;
- (void)addUndoStop;

@end

// Game Difficulty Names
extern NSString * const kGameDifficultyNameEasy;
extern NSString * const kGameDifficultyNameMedium;
extern NSString * const kGameDifficultyNameHard;
extern NSString * const kGameDifficultyNameExpert;

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


