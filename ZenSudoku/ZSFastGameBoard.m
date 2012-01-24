//
//  ZSFastGameBoard.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSFastGameBoard.h"
#import "ZSGameBoard.h"
#import "ZSGameTile.h"

@implementation ZSFastGameBoard

@synthesize size;
@synthesize grid;
@synthesize rows, cols, groups, allSets;
@synthesize rowContainsAnswer, colContainsAnswer, groupContainsAnswer;

#pragma mark - Initialization and Memory Management

- (id)init {
	return [self initWithSize:9];
}

- (id)initWithSize:(NSInteger)newSize {
	self = [super init];
	
	if (self) {
		size = newSize;
		
		[self allocGrid];
		[self allocSetCaches];
		
		[self rebuildRowAndColCaches];
	}
	
	return self;
}

- (void)rebuildRowAndColCaches {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			// Add the tile to row and col caches.
			rows[row][col] = &grid[row][col];
			cols[col][row] = &grid[row][col];
		}
	}
}

- (void)rebuildGroupCache {
	NSInteger *totalTilesInEachGroup = malloc(size * sizeof(NSInteger));
	
	for (NSInteger i = 0; i < size; ++i) {
		totalTilesInEachGroup[i] = 0;
	}
	
	for (NSInteger row = 0; row < 9; ++row) {
		for (NSInteger col = 0; col < 9; ++col) {
			// Get the groupId on the standard group map.
			NSInteger groupId = grid[row][col].groupId;
			
			// Add the tile to the group cache.
			groups[groupId][totalTilesInEachGroup[groupId]] = &grid[row][col];
			++totalTilesInEachGroup[groupId];
		}
	}
	
	free(totalTilesInEachGroup);
	
	[self rebuildAllSetsCache];
}

- (void)rebuildAllSetsCache {
	for (NSInteger i = 0; i < size; ++i) {
		allSets[i] = rows[i];
	}
	
	for (NSInteger i = 0; i < size; ++i) {
		allSets[size + i] = cols[i];
	}
	
	for (NSInteger i = 0; i < size; ++i) {
		allSets[(2 * size) + i] = groups[i];
	}
}

- (void)dealloc {
	[self freeSetCaches];
	[self freeGrid];
}

- (void)allocGrid {
	grid = malloc(size * sizeof(ZSGameTileStub *));
	
	for (NSInteger i = 0; i < size; ++i) {
		grid[i] = malloc(size * sizeof(ZSGameTileStub));
		
		for (NSInteger j = 0; j < size; ++j) {
			grid[i][j].row = i;
			grid[i][j].col = j;
			grid[i][j].groupId = 0;
			
			grid[i][j].guess = 0;
			
			grid[i][j].totalPencils = 0;
			grid[i][j].pencils = malloc(size * sizeof(BOOL));
			
			for (NSInteger p = 0; p < size; ++p) {
				grid[i][j].pencils[p] = NO;
			}
		}
	}
}

- (void)freeGrid {
	for (NSInteger i = 0; i < size; ++i) {
		for (NSInteger j = 0; j < size; ++j) {
			free(grid[i][j].pencils);
		}
		
		free(grid[i]);
	}
	
	free(grid);
}

- (void)allocSetCaches {
	rows = malloc(size * sizeof(ZSGameTileStub **));
	cols = malloc(size * sizeof(ZSGameTileStub **));
	groups = malloc(size * sizeof(ZSGameTileStub **));
	allSets = malloc(3 * size * sizeof(ZSGameTileStub **));
	
	rowContainsAnswer = malloc(size * sizeof(NSInteger *));
	colContainsAnswer = malloc(size * sizeof(NSInteger *));
	groupContainsAnswer = malloc(size * sizeof(NSInteger *));
	
	for (NSInteger i = 0; i < size; ++i) {
		rows[i] = malloc(size * sizeof(ZSGameTileStub *));
		cols[i] = malloc(size * sizeof(ZSGameTileStub *));
		groups[i] = malloc(size * sizeof(ZSGameTileStub *));
		
		rowContainsAnswer[i] = malloc(size * sizeof(NSInteger));
		colContainsAnswer[i] = malloc(size * sizeof(NSInteger));
		groupContainsAnswer[i] = malloc(size * sizeof(NSInteger));
		
		for (NSInteger j = 0; j < size; ++j) {
			rowContainsAnswer[i][j] = 0;
			colContainsAnswer[i][j] = 0;
			groupContainsAnswer[i][j] = 0;
		}
	}
}

- (void)freeSetCaches {
	for (NSInteger i = 0; i < size; ++i) {
		free(rowContainsAnswer[i]);
		free(colContainsAnswer[i]);
		free(groupContainsAnswer[i]);
		
		free(rows[i]);
		free(cols[i]);
		free(groups[i]);
	}
	
	free(rowContainsAnswer);
	free(colContainsAnswer);
	free(groupContainsAnswer);

	free(rows);
	free(cols);
	free(groups);
	free(allSets);
}

#pragma mark - Data Migration

- (void)copyGroupMapFromFastGameBoard:(ZSFastGameBoard *)gameBoard {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			grid[row][col].groupId = gameBoard.grid[row][col].groupId;
		}
	}
	
	[self rebuildGroupCache];
}

- (void)copyGuessesFromFastGameBoard:(ZSFastGameBoard *)gameBoard {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			[self setGuess:gameBoard.grid[row][col].guess forTileAtRow:row col:col];
		}
	}
}

- (void)copyGroupMapFromGameBoard:(ZSGameBoard *)gameBoard {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			grid[row][col].groupId = [gameBoard getTileAtRow:row col:col].groupId;
		}
	}
	
	[self rebuildGroupCache];
}

- (void)copyGuessesFromGameBoard:(ZSGameBoard *)gameBoard {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			[self setGuess:[gameBoard getTileAtRow:row col:col].guess forTileAtRow:row col:col];
		}
	}
}

- (void)copyGuessesFromString:(NSString *)guessesString {
	NSInteger currentRow = 0;
	NSInteger currentCol = 0;
	
	NSInteger intEquivalent;
	
	for (NSInteger i = 0, l = guessesString.length; i < l; ++i) {
		unichar currentChar = [guessesString characterAtIndex:i];
		
		switch (currentChar) {
			case '.':
			case '0':
				[self clearGuessForTileAtRow:currentRow col:currentCol];
				break;
				
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				intEquivalent = (NSInteger)currentChar - 48;
				[self setGuess:intEquivalent forTileAtRow:currentRow col:currentCol];
				break;
				
			default:
				continue;
		}
		
		if (++currentCol >= size) {
			currentCol -= size;
			++currentRow;
		}
		
		if (currentRow == size) {
			break;
		}
	}
}

- (void)copyGroupMapFromString:(NSString *)groupMapString {
	NSInteger currentRow = 0;
	NSInteger currentCol = 0;
	
	NSInteger intEquivalent;
	
	for (NSInteger i = 0, l = groupMapString.length; i < l; ++i) {
		unichar currentChar = [groupMapString characterAtIndex:i];
		
		switch (currentChar) {
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				intEquivalent = (NSInteger)currentChar - 48;
				grid[currentRow][currentCol].groupId = intEquivalent;
				break;
				
			default:
				continue;
		}
		
		if (++currentCol >= size) {
			currentCol -= size;
			++currentRow;
		}
		
		if (currentRow == size) {
			break;
		}
	}
	
	[self rebuildGroupCache];
}

- (void)copyGuessesToGameBoardAnswers:(ZSGameBoard *)gameBoard {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			[gameBoard setAnswer:grid[row][col].guess forTileAtRow:row col:col];
		}
	}
}

- (void)copyGuessesToGameBoardGuesses:(ZSGameBoard *)gameBoard {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			[gameBoard setGuess:grid[row][col].guess forTileAtRow:row col:col];
		}
	}
}

#pragma mark - Setters

- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	NSInteger formerGuess = grid[row][col].guess;
	grid[row][col].guess = guess;
	
	[self setAllPencils:NO forTileAtRow:row col:col];
	
	if (formerGuess) {
		--rowContainsAnswer[row][formerGuess - 1];
		--colContainsAnswer[col][formerGuess - 1];
		--groupContainsAnswer[grid[row][col].groupId][formerGuess - 1];
	}
	
	if (guess) {
		++rowContainsAnswer[row][guess - 1];
		++colContainsAnswer[col][guess - 1];
		++groupContainsAnswer[grid[row][col].groupId][guess - 1];
	}
}

- (void)clearGuessForTileAtRow:(NSInteger)row col:(NSInteger)col {
	[self setGuess:0 forTileAtRow:row col:col];
}

- (void)clearAllGuesses {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			[self clearGuessForTileAtRow:row col:col];
		}
	}
}

- (void)setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	if (!grid[row][col].pencils[pencilNumber - 1] && isSet) {
		grid[row][col].totalPencils++;
	} else if (grid[row][col].pencils[pencilNumber - 1] && !isSet) {
		grid[row][col].totalPencils--;
	}
	
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
		[self setPencil:NO forPencilNumber:guess forTileAtRow:groups[tile->groupId][i]->row col:groups[tile->groupId][i]->col];
	}
}

- (void)addAutoPencils {
	[self setAllPencils:NO];
	
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			// Skip the ones with answers.
			if (grid[row][col].guess) {
				continue;
			}
			
			// For each possible guess, check to see if it is valid in that tile.
			for (NSInteger guess = 1; guess <= size; ++guess) {
				if ([self isGuess:guess validInRow:row col:col]) {
					[self setPencil:YES forPencilNumber:guess forTileAtRow:row col:col];
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

- (void)print9x9PencilGrid {
	NSLog(@" ");
	for (NSInteger row = 0; row < 9; ++row) {
		NSMutableString *rowString = [NSMutableString string];
		
		for (NSInteger col = 0; col < 9; ++col) {
			for (NSInteger pencil = 0; pencil < 9; ++pencil) {
				if (grid[row][col].pencils[pencil]) {
					[rowString appendString:[NSString stringWithFormat:@"%i", (pencil + 1)]];
				} else {
					[rowString appendString:@"."];
				}
			}
			
			[rowString appendString:@" "];
			
			if (col == 2 || col == 5) {
				[rowString appendString:@"| "];
			}
		}
		
		NSLog(@"%@", rowString);
		
		if (row == 2 || row == 5) {
			NSLog(@"------------------------------+-------------------------------+------------------------------");
		}
	}
	NSLog(@" ");
}

@end
