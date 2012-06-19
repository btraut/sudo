//
//  ZSGameBoard.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSGameTile;
@class ZSGame;

@protocol ZSGameBoardDelegate <NSObject>

- (void)guessDidChangeForTile:(ZSGameTile *)tile previousGuess:(NSInteger)previousGuess;
- (void)pencilDidChangeForTile:(ZSGameTile *)tile pencilNumber:(NSInteger)pencilNumber previousSet:(NSInteger)previousSet;

@end

@interface ZSGameBoard : NSObject

@property (weak) id<ZSGameBoardDelegate> delegate;
@property (assign) NSInteger size;

// Initialization

+ (id)emptyStandard9x9Game;

- (id)initWithSize:(NSInteger)size;
- (id)initWithSize:(NSInteger)size answers:(NSInteger **)answers groupMap:(NSInteger **)groupMap;
- (void)createTiles;

- (void)applyAnswersString:(NSString *)answersString;
- (void)applyAnswersArray:(NSInteger **)answersArray;
- (void)applyGroupMapArray:(NSInteger **)groupMapArray;

- (void)copyGroupMapFromGameBoard:(ZSGameBoard *)gameBoard;
- (void)copyAnswersFromGameBoard:(ZSGameBoard *)gameBoard;
- (void)copyGuessesFromGameBoard:(ZSGameBoard *)gameBoard;

- (void)copyGroupMapFromString:(NSString *)guessesString;
- (void)copyAnswersFromString:(NSString *)guessesString;
- (void)copyGuessesFromString:(NSString *)guessesString;

// Getters

- (ZSGameTile *)getTileAtRow:(NSInteger)row col:(NSInteger)col;

- (NSArray *)getAllInfluencedTilesForTileAtRow:(NSInteger)row col:(NSInteger)col includeSelf:(BOOL)includeSelf;

- (NSArray *)getRowSetForTileAtRow:(NSInteger)row col:(NSInteger)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getColSetForTileAtRow:(NSInteger)row col:(NSInteger)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getFamilySetForTileAtRow:(NSInteger)row col:(NSInteger)col includeSelf:(BOOL)includeSelf;
- (NSArray *)getSetOfInfluencedTileSetsForTileAtRow:(NSInteger)row col:(NSInteger)col includeSelf:(BOOL)includeSelf;

- (NSArray *)getTileSetForRow:(NSInteger)row;
- (NSArray *)getTileSetForCol:(NSInteger)col;
- (NSArray *)getTileSetForGroup:(NSInteger)groupId;

// Setters

- (void)setAnswer:(NSInteger)answer forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)setAnswer:(NSInteger)answer forTileAtRow:(NSInteger)row col:(NSInteger)col locked:(BOOL)locked;
- (void)clearAnswerForTileAtRow:(NSInteger)row col:(NSInteger)col;

- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)clearGuessForTileAtRow:(NSInteger)row col:(NSInteger)col;

- (void)setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)setAllPencils:(BOOL)isSet forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addAutoPencils;

- (void)lockGuesses;
- (void)lockTileAtRow:(NSInteger)row col:(NSInteger)col;

// Validitiy Checks

- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row col:(NSInteger)col;
- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row;
- (BOOL)isGuess:(NSInteger)guess validInCol:(NSInteger)col;
- (BOOL)isGuess:(NSInteger)guess validInGroupAtRow:(NSInteger)row col:(NSInteger)col;

- (BOOL)isAnswer:(NSInteger)answer validInRow:(NSInteger)row col:(NSInteger)col;
- (BOOL)isAnswer:(NSInteger)answer validInRow:(NSInteger)row;
- (BOOL)isAnswer:(NSInteger)answer validInCol:(NSInteger)col;
- (BOOL)isAnswer:(NSInteger)answer validInGroupAtRow:(NSInteger)row col:(NSInteger)col;

// Debug

- (void)print9x9PuzzleAnswers;
- (void)print9x9PuzzleGuesses;

@end
