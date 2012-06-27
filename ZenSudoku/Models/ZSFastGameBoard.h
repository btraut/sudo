//
//  ZSFastGameBoard.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/14/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
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
} ZSTileStub;

typedef struct {
	ZSTileStub **tiles;
	NSInteger totalTiles;
} ZSTileList;

@class ZSBoard;

@interface ZSFastGameBoard : NSObject

@property (assign) NSInteger size;

@property (assign) ZSTileStub **grid;

@property (assign) ZSTileStub ***rows;
@property (assign) ZSTileStub ***cols;
@property (assign) ZSTileStub ***groups;
@property (assign) ZSTileStub ***allSets;

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

- (void)copyGroupMapFromGameBoard:(ZSBoard *)gameBoard;
- (void)copyGuessesFromGameBoard:(ZSBoard *)gameBoard;
- (void)copyAnswersFromGameBoard:(ZSBoard *)gameBoard;
- (void)copyPencilsFromGameBoard:(ZSBoard *)gameBoard;

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

- (BOOL)tile:(ZSTileStub *)tile1 influencesTile:(ZSTileStub *)tile2;
- (ZSTileList)getAllInfluencedTilesForTile:(ZSTileStub *)tile1 includeSelf:(BOOL)includeSelf;
- (ZSTileList)getAllInfluencedTilesForTile:(ZSTileStub *)tile1 andOtherTile:(ZSTileStub *)tile2;

// Validitiy Checks

- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row col:(NSInteger)col;
- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row;
- (BOOL)isGuess:(NSInteger)guess validInCol:(NSInteger)col;
- (BOOL)isGuess:(NSInteger)guess validInGroup:(NSInteger)groupId;

// Debug

- (void)print9x9Grid;
- (void)print9x9PencilGrid;

@end
