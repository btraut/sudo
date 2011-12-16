//
//  ZSFastGameBoard.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	NSInteger row;
	NSInteger col;
	NSInteger groupId;
	
    NSInteger guess;
	
	NSInteger totalPencils;
    BOOL *pencils;
} ZSGameTileStub;

@class ZSGameBoard;

@interface ZSFastGameBoard : NSObject {
	NSInteger size;
	
	ZSGameTileStub **grid;
	
	ZSGameTileStub ***rows;
	ZSGameTileStub ***cols;
	ZSGameTileStub ***groups;
	
	BOOL **rowContainsAnswer;
	BOOL **colContainsAnswer;
	BOOL **groupContainsAnswer;
}

@property (nonatomic, assign) NSInteger size;

@property (nonatomic, assign) ZSGameTileStub **grid;

@property (nonatomic, assign) ZSGameTileStub ***rows;
@property (nonatomic, assign) ZSGameTileStub ***cols;
@property (nonatomic, assign) ZSGameTileStub ***groups;

@property (nonatomic, assign) BOOL **rowContainsAnswer;
@property (nonatomic, assign) BOOL **colContainsAnswer;
@property (nonatomic, assign) BOOL **groupContainsAnswer;

// Initialization and Memory Management

- (id)init;
- (id)initWithSize:(NSInteger)size;
- (void)dealloc;

- (void)allocGrid;
- (void)freeGrid;
- (void)allocSetCaches;
- (void)freeSetCaches;

- (void)rebuildRowAndSetCaches;
- (void)rebuildGroupCache;

// Data Migration

- (void)copyGroupMapFromGameBoard:(ZSGameBoard *)gameBoard;

- (void)copyGroupMapFromFastGameBoard:(ZSFastGameBoard *)gameBoard;
- (void)copyGuessesFromFastGameBoard:(ZSFastGameBoard *)gameBoard;

- (void)copyGuessesToGameBoardAnswers:(ZSGameBoard *)gameBoard;
- (void)copyGuessesToGameBoardGuesses:(ZSGameBoard *)gameBoard;

// Setters

- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)clearGuessForTileAtRow:(NSInteger)row col:(NSInteger)col;

- (void)setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)setAllPencils:(BOOL)isSet;
- (void)setAllPencils:(BOOL)isSet forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addAutoPencils;

// Validitiy Checks

- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row col:(NSInteger)col;
- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row;
- (BOOL)isGuess:(NSInteger)guess validInCol:(NSInteger)col;
- (BOOL)isGuess:(NSInteger)guess validInGroup:(NSInteger)groupId;

// Debug

- (void)print9x9Grid;

@end
