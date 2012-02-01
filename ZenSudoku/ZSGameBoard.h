//
//  ZSGameBoard.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZSFastGameSolver.h"

@class ZSGameTile;
@class ZSGame;

@protocol ZSGameBoardDelegate <NSObject>

- (void)guessDidChangeForTile:(ZSGameTile *)tile previousGuess:(int)previousGuess;
- (void)pencilDidChangeForTile:(ZSGameTile *)tile pencilNumber:(int)pencilNumber previousSet:(int)previousSet;

@end

@interface ZSGameBoard : NSObject {
	NSObject<ZSGameBoardDelegate> *delegate;
	
	int size;
	
	@private
	
	NSArray *_groupMap;
	NSArray *_tiles;
}

@property (nonatomic, strong) NSObject<ZSGameBoardDelegate> *delegate;
@property (nonatomic, assign) int size;

// Initialization

+ (id)emptyStandard9x9Game;

- (id)initWithSize:(int)size;
- (id)initWithSize:(int)size answers:(int **)answers groupMap:(int **)groupMap;
- (void)createTiles;

- (void)applyAnswersString:(NSString *)answersString;
- (void)applyAnswersArray:(int **)answersArray;
- (void)applyGroupMapArray:(int **)groupMapArray;

- (void)copyGroupMapFromGameBoard:(ZSGameBoard *)gameBoard;
- (void)copyAnswersFromGameBoard:(ZSGameBoard *)gameBoard;
- (void)copyGuessesFromGameBoard:(ZSGameBoard *)gameBoard;

- (void)copyGroupMapFromString:(NSString *)guessesString;
- (void)copyAnswersFromString:(NSString *)guessesString;
- (void)copyGuessesFromString:(NSString *)guessesString;

// Getters

- (ZSGameTile *)getTileAtRow:(int)row col:(int)col;

- (NSArray *)getAllInfluencedTilesForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf;

- (NSArray *)getRowSetForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getColSetForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getFamilySetForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getSetOfInfluencedTileSetsForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf;

- (NSArray *)getTileSetForRow:(int)row;
- (NSArray *)getTileSetForCol:(int)col;
- (NSArray *)getTileSetForGroup:(int)groupId;

// Setters

- (void)setAnswer:(int)answer forTileAtRow:(int)row col:(int)col;
- (void)setAnswer:(int)answer forTileAtRow:(int)row col:(int)col locked:(BOOL)locked;
- (void)clearAnswerForTileAtRow:(int)row col:(int)col;

- (void)setGuess:(int)guess forTileAtRow:(int)row col:(int)col;
- (void)clearGuessForTileAtRow:(int)row col:(int)col;

- (void)setPencil:(BOOL)isSet forPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col;
- (void)setAllPencils:(BOOL)isSet forTileAtRow:(int)row col:(int)col;
- (void)clearInfluencedPencilsForTileAtRow:(int)row col:(int)col;
- (void)addAutoPencils;

- (void)lockGuesses;
- (void)lockTileAtRow:(int)row col:(int)col;

- (ZSGameSolveResult)solve;

// Validitiy Checks

- (BOOL)isGuess:(int)guess validInRow:(int)row col:(int)col;
- (BOOL)isGuess:(int)guess validInRow:(int)row;
- (BOOL)isGuess:(int)guess validInCol:(int)col;
- (BOOL)isGuess:(int)guess validInGroupAtRow:(int)row col:(int)col;

- (BOOL)isAnswer:(int)answer validInRow:(int)row col:(int)col;
- (BOOL)isAnswer:(int)answer validInRow:(int)row;
- (BOOL)isAnswer:(int)answer validInCol:(int)col;
- (BOOL)isAnswer:(int)answer validInGroupAtRow:(int)row col:(int)col;

// Debug

- (void)print9x9PuzzleAnswers;
- (void)print9x9PuzzleGuesses;

@end
