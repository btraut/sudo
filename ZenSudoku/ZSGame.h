//
//  ZSGame.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSGameBoard.h"

typedef enum {
	ZSGameDifficultyEasy,
	ZSGameDifficultyMedium,
	ZSGameDifficultyHard,
	ZSGameDifficultyExpert
} ZSGameDifficulty;

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

- (void)tileGuessDidChange:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)tilePencilDidChange:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)gameWasSolved;
- (void)timerDidAdvance;

@end


@class ZSGameHistoryEntry;
@class ZSGameBoard;
@class ZSGameTile;

@interface ZSGame : NSObject <ZSGameBoardDelegate> {
	ZSGameDifficulty difficulty;
	ZSGameBoard *gameBoard;
	
	BOOL recordingHistory;
	
	NSObject<ZSGameDelegate> *delegate;
	
	NSInteger timerCount;
	
	NSInteger totalStrikes;
	
	@private
	
	NSMutableArray *_undoStack;
	NSMutableArray *_redoStack;
	
	NSTimer *_countdownTimer;
}

@property (nonatomic, assign) ZSGameDifficulty difficulty;
@property (nonatomic, strong) ZSGameBoard *gameBoard;

@property (nonatomic, assign) BOOL recordingHistory;

@property (nonatomic, strong) NSObject<ZSGameDelegate> *delegate;

@property (nonatomic, readonly) NSInteger timerCount;

@property (nonatomic, readonly) NSInteger totalStrikes;

// Creation / Initialization

+ (id)emptyStandard9x9Game;

- (id)initWithSize:(NSInteger)size;
- (id)initWithSize:(NSInteger)size answers:(NSInteger **)answers groupMap:(NSInteger **)groupMap;

// Persistant Storage Methods

- (id)initWithDictionaryRepresentation:(NSDictionary *)dict;
- (NSDictionary *)getDictionaryRepresentation;

// Tile Methods

- (NSInteger)getGuessForTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)clearGuessForTileAtRow:(NSInteger)row col:(NSInteger)col;

- (BOOL)getLockedForTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)setLocked:(BOOL)locked forTileAtRow:(NSInteger)row col:(NSInteger)col;

- (BOOL)getPencilForPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)togglePencilForPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;

- (void)guessDidChangeForTile:(ZSGameTile *)tile previousGuess:(NSInteger)previousGuess;
- (void)pencilDidChangeForTile:(ZSGameTile *)tile pencilNumber:(NSInteger)pencilNumber previousSet:(NSInteger)previousSet;

- (NSInteger)getGroupIdForTileAtRow:(NSInteger)row col:(NSInteger)col;

- (ZSGameTile *)getTileAtRow:(NSInteger)row col:(NSInteger)col;
- (NSArray *)getAllInfluencedTilesForTileAtRow:(NSInteger)row col:(NSInteger)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getRowSetForTileAtRow:(NSInteger)row col:(NSInteger)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getColSetForTileAtRow:(NSInteger)row col:(NSInteger)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getFamilySetForTileAtRow:(NSInteger)row col:(NSInteger)col includeSelf:(BOOL)includeSelf;

// Misc Methods

- (BOOL)allowsGuess:(NSInteger)guess;

- (void)solve;
- (BOOL)isSolved;

- (void)addAutoPencils;
- (void)clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col;

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

// Dictionary Keys for Game Preservation / Restoration
extern NSString * const kDictionaryRepresentationGameDifficultyKey;
extern NSString * const kDictionaryRepresentationGameTilesKey;