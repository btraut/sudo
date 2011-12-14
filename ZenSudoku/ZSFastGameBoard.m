//
//  ZSFastGameBoard.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSFastGameBoard.h"

NSInteger standard9x9GroupMap[9][9] = {
	{0, 0, 0, 1, 1, 1, 2, 2, 2},
	{0, 0, 0, 1, 1, 1, 2, 2, 2},
	{0, 0, 0, 1, 1, 1, 2, 2, 2},
	{3, 3, 3, 4, 4, 4, 5, 5, 5},
	{3, 3, 3, 4, 4, 4, 5, 5, 5},
	{3, 3, 3, 4, 4, 4, 5, 5, 5},
	{6, 6, 6, 7, 7, 7, 8, 8, 8},
	{6, 6, 6, 7, 7, 7, 8, 8, 8},
	{6, 6, 6, 7, 7, 7, 8, 8, 8},
};

@implementation ZSFastGameBoard

#pragma mark - Initialization and Memory Management

- (id)init {
	return [self initWithSize:9];
}

- (id)initWithSize:(NSInteger)newSize {
	self = [super init];
	
	if (self) {
		size = newSize;
		
		[self allocGrid];
		[self allocGroupCache];
		[self allocSetCaches];
	}
	
	return self;
}

- (void)dealloc {
	[self freeSetCaches];
	[self freeGroupCache];
	[self freeGrid];
}

- (void)allocGrid {
	grid = malloc(size * sizeof(ZSGameTileStub *));
	
	for (NSInteger i = 0; i < size; ++i) {
		grid[i] = malloc(size * sizeof(ZSGameTileStub));
		
		for (NSInteger j = 0; i < size; ++j) {
			grid[i][j].pencils = malloc(size * sizeof(BOOL));
		}
	}
}

- (void)freeGrid {
	for (NSInteger i = 0; i < size; ++i) {
		for (NSInteger j = 0; i < size; ++j) {
			free(grid[i][j].pencils);
		}
		
		free(grid[i]);
	}
	
	free(grid);
}

- (void)allocGroupCache {
	groupCache = malloc(size * sizeof(ZSGameTileStub *));
}

- (void)freeGroupCache {
	free(groupCache);
}

- (void)allocSetCaches {
	rowContainsAnswer = malloc(size * sizeof(BOOL *));
	colContainsAnswer = malloc(size * sizeof(BOOL *));
	groupContainsAnswer = malloc(size * sizeof(BOOL *));
	
	for (NSInteger i = 0; i < size; ++i) {
		rowContainsAnswer[i] = malloc(size * sizeof(BOOL));
		colContainsAnswer[i] = malloc(size * sizeof(BOOL));
		groupContainsAnswer[i] = malloc(size * sizeof(BOOL));
	}
}

- (void)freeSetCaches {
	for (NSInteger i = 0; i < size; ++i) {
		free(rowContainsAnswer[i]);
		free(colContainsAnswer[i]);
		free(groupContainsAnswer[i]);
	}
	
	free(rowContainsAnswer);
	free(colContainsAnswer);
	free(groupContainsAnswer);
}

#pragma mark - Data Migration

- (void)loadStandard9x9GroupMap {
	NSInteger *totalTilesInGroupCache = malloc(size * sizeof(NSInteger));
	
	for (NSInteger i = 0; i < size; ++i) {
		totalTilesInGroupCache[0] = 0;
	}
	
	for (NSInteger row = 0; row < 9; ++row) {
		for (NSInteger col = 0; col < 9; ++col) {
			NSInteger groupId = standard9x9GroupMap[row][col];
			
			grid[row][col].groupId = groupId;
			
			groupCache[groupId][totalTilesInGroupCache[standard9x9GroupMap[row][col]]] = grid[row][col];
			++totalTilesInGroupCache[standard9x9GroupMap[row][col]];
		}
	}
}

- (void)copyGuessesFromGrid:(ZSGameTileStub **)sourceGrid {
	for (NSInteger row = 0; row < 9; ++row) {
		for (NSInteger col = 0; col < 9; ++col) {
			[self setGuess:sourceGrid[row][col].guess forTileAtRow:row col:col];
		}
	}
}

#pragma mark - Setters

- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	grid[row][col].guess = guess;
	
	BOOL isSet = (BOOL)guess;
	
	rowContainsAnswer[row][guess - 1] = isSet;
	colContainsAnswer[col][guess - 1] = isSet;
	groupContainsAnswer[grid[row][col].groupId][guess - 1] = isSet;
}

- (void)clearGuessForTileAtRow:(NSInteger)row col:(NSInteger)col {
	[self setGuess:0 forTileAtRow:row col:col];
}

- (void)setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	grid[row][col].pencils[pencilNumber - 1] = isSet;
}

- (void)setAllPencils:(BOOL)isSet {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			[self setAllPencils:isSet forTileAtRow:row col:col];
		}
	}
}

- (void)setAllPencils:(BOOL)isSet forTileAtRow:(NSInteger)row col:(NSInteger)col {
	for (NSInteger i = 1; i <= size; ++i) {
		[self setPencil:isSet forPencilNumber:i forTileAtRow:row col:col];
	}
}

- (void)clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col {
	NSInteger guess = grid[row][col].guess;
	
	ZSGameTileStub *tile = &grid[row][col];
	
	for (NSInteger i = 0; i < size; ++i) {
		[self setPencil:NO forPencilNumber:guess forTileAtRow:tile->row col:i];
	}
	
	for (NSInteger i = 0; i < size; ++i) {
		[self setPencil:NO forPencilNumber:guess forTileAtRow:i col:tile->col];
	}
	
	for (NSInteger i = 0; i < size; ++i) {
		[self setPencil:NO forPencilNumber:guess forTileAtRow:groupCache[tile->groupId][i].row col:groupCache[tile->groupId][i].col];
	}
}

- (void)addAutoPencils {
	[self setAllPencils:NO];
	
	for (NSInteger guess = 1; guess <= size; ++guess) {
		for (NSInteger row = 0; row < size; ++row) {
			BOOL validInRow = [self isGuess:guess validInRow:row];
			
			for (NSInteger i = 0; i < size; ++i) {
				if (validInRow) {
					[self setPencil:YES forPencilNumber:guess forTileAtRow:row col:i];
				}
			}
		}

		for (NSInteger col = 0; col < size; ++col) {
			BOOL validInCol = [self isGuess:guess validInCol:col];
			
			for (NSInteger i = 0; i < size; ++i) {
				if (validInCol) {
					[self setPencil:YES forPencilNumber:guess forTileAtRow:i col:col];
				}
			}
		}

		for (NSInteger groupId = 0; groupId < size; ++groupId) {
			BOOL validInGroup = [self isGuess:guess validInGroup:groupId];
			ZSGameTileStub *group = groupCache[guess - 1];
			
			for (NSInteger i = 0; i < size; ++i) {
				if (validInGroup) {
					[self setPencil:YES forPencilNumber:guess forTileAtRow:group[i].row col:group[i].col];
				}
			}
		}
	}
}

#pragma mark - Validitiy Checks

- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row col:(NSInteger)col {
	BOOL validInRow = [self isGuess:guess validInRow:row];
	BOOL validInCol = [self isGuess:guess validInCol:col];
	BOOL validInGroup = [self isGuess:guess validInGroup:grid[row][col].groupId];
	
	return validInRow && validInCol && validInGroup;
}

- (BOOL)isGuess:(NSInteger)guess validInRow:(NSInteger)row {
	return !rowContainsAnswer[row][guess - 1];
}

- (BOOL)isGuess:(NSInteger)guess validInCol:(NSInteger)col {
	return !colContainsAnswer[col][guess - 1];
}

- (BOOL)isGuess:(NSInteger)guess validInGroup:(NSInteger)groupId {
	return !groupContainsAnswer[groupId][guess - 1];
}

#pragma mark - Debug

- (void)print9x9Grid {
	NSLog(@" ");
	for (NSInteger row = 0; row < 9; ++row) {
		NSLog(@" %i %i %i | %i %i %i | %i %i %i", grid[row][0].guess, grid[row][1].guess, grid[row][2].guess, grid[row][3].guess,
			  grid[row][4].guess, grid[row][5].guess, grid[row][6].guess, grid[row][7].guess, grid[row][8].guess);
		
		if (row == 2 || row == 5) {
			NSLog(@"-------+-------+-------");
		}
	}
	NSLog(@" ");
}

@end
