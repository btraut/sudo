//
//  ZSFastGameBoard.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	int row;
	int col;
	int groupId;
	
    int guess;
	
	int totalPencils;
    BOOL *pencils;
} ZSGameTileStub;

@class ZSGameBoard;

@interface ZSFastGameBoard : NSObject {
	int size;
	
	ZSGameTileStub **grid;
	
	ZSGameTileStub ***rows;
	ZSGameTileStub ***cols;
	ZSGameTileStub ***groups;
	ZSGameTileStub ***allSets;
	
	int **rowContainsAnswer;
	int **colContainsAnswer;
	int **groupContainsAnswer;
}

@property (nonatomic, assign) int size;

@property (nonatomic, assign) ZSGameTileStub **grid;

@property (nonatomic, assign) ZSGameTileStub ***rows;
@property (nonatomic, assign) ZSGameTileStub ***cols;
@property (nonatomic, assign) ZSGameTileStub ***groups;
@property (nonatomic, assign) ZSGameTileStub ***allSets;

@property (nonatomic, assign) int **rowContainsAnswer;
@property (nonatomic, assign) int **colContainsAnswer;
@property (nonatomic, assign) int **groupContainsAnswer;

// Initialization and Memory Management

- (id)init;
- (id)initWithSize:(int)size;
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

- (void)copyGroupMapFromFastGameBoard:(ZSFastGameBoard *)gameBoard;
- (void)copyGuessesFromFastGameBoard:(ZSFastGameBoard *)gameBoard;
- (void)copyGuessesFromString:(NSString *)guessesString;
- (void)copyGroupMapFromString:(NSString *)groupMapString;

- (void)copyGuessesToGameBoardAnswers:(ZSGameBoard *)gameBoard;
- (void)copyGuessesToGameBoardGuesses:(ZSGameBoard *)gameBoard;

// Setters

- (void)setGuess:(int)guess forTileAtRow:(int)row col:(int)col;
- (void)clearGuessForTileAtRow:(int)row col:(int)col;
- (void)clearAllGuesses;

- (void)setPencil:(BOOL)isSet forPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col;
- (void)setAllPencils:(BOOL)isSet;
- (void)setAllPencils:(BOOL)isSet forTileAtRow:(int)row col:(int)col;
- (void)clearInfluencedPencilsForTileAtRow:(int)row col:(int)col;
- (void)addAutoPencils;

// Validitiy Checks

- (BOOL)isGuess:(int)guess validInRow:(int)row col:(int)col;
- (BOOL)isGuess:(int)guess validInRow:(int)row;
- (BOOL)isGuess:(int)guess validInCol:(int)col;
- (BOOL)isGuess:(int)guess validInGroup:(int)groupId;

// Debug

- (void)print9x9Grid;
- (void)print9x9PencilGrid;

@end
