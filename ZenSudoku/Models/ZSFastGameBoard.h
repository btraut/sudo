//
//  ZSFastGameBoard.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/14/11.
//  Copyright (c) 2011 Ten Four Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	NSInteger row;
	NSInteger col;
	NSInteger groupId;
	
    NSInteger guess;
	NSInteger answer;
	
	NSInteger totalPencils;
    BOOL *pencils;
} ZSGameTileStub;

typedef struct {
	ZSGameTileStub **tiles;
	NSInteger totalTiles;
} ZSGameTileList;

@class ZSGameBoard;

@interface ZSFastGameBoard : NSObject

@property (assign) NSInteger size;

@property (assign) ZSGameTileStub **grid;

@property (assign) ZSGameTileStub ***rows;
@property (assign) ZSGameTileStub ***cols;
@property (assign) ZSGameTileStub ***groups;
@property (assign) ZSGameTileStub ***allSets;

@property (assign) NSInteger **totalTilesInRowWithAnswer;
@property (assign) NSInteger **totalTilesInColWithAnswer;
@property (assign) NSInteger **totalTilesInGroupWithAnswer;

@property (assign) NSInteger **totalTilesInRowWithPencil;
@property (assign) NSInteger **totalTilesInColWithPencil;
@property (assign) NSInteger **totalTilesInGroupWithPencil;

// Initialization and Memory Management

- (id)init;
- (id)initWithSize:(NSInteger)size;
- (void)dealloc;

- (void)allocGrid;
- (void)freeGrid;
- (void)allocSetCaches;
- (void)freeSetCaches;

- (void)rebuildRowAndColCaches;
- (void)rebuildGroupCache;
- (void)rebuildAllSetsCache;

// Data Migration

- (void)copyGroupMapFromGameBoard:(ZSGameBoard *)gameBoard;
- (void)copyGuessesFromGameBoard:(ZSGameBoard *)gameBoard;
- (void)copyAnswersFromGameBoard:(ZSGameBoard *)gameBoard;
- (void)copyPencilsFromGameBoard:(ZSGameBoard *)gameBoard;

- (void)copyGroupMapFromFastGameBoard:(ZSFastGameBoard *)gameBoard;
- (void)copyGuessesFromFastGameBoard:(ZSFastGameBoard *)gameBoard;
- (void)copyGuessesFromString:(NSString *)guessesString;
- (void)copyGroupMapFromString:(NSString *)groupMapString;

// String Representations

- (NSString *)getStringRepresentation;

// Setters

- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)clearGuessForTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)clearAllGuesses;

- (void)setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)setAllPencils:(BOOL)isSet;
- (void)setAllPencils:(BOOL)isSet forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addAutoPencils;

// Information Gathering

- (BOOL)tile:(ZSGameTileStub *)tile1 influencesTile:(ZSGameTileStub *)tile2;
- (ZSGameTileList)getAllInfluencedTilesForTile:(ZSGameTileStub *)tile1 includeSelf:(BOOL)includeSelf;
- (ZSGameTileList)getAllInfluencedTilesForTile:(ZSGameTileStub *)tile1 andOtherTile:(ZSGameTileStub *)tile2;

// Validitiy Checks

- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row col:(NSInteger)col;
- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row;
- (BOOL)isGuess:(NSInteger)guess validInCol:(NSInteger)col;
- (BOOL)isGuess:(NSInteger)guess validInGroup:(NSInteger)groupId;

// Debug

- (void)print9x9Grid;
- (void)print9x9PencilGrid;

@end
