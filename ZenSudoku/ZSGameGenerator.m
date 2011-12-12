//
//  ZSGameGenerator.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameGenerator.h"
#import "ZSGameSolver.h"
#import "ZSGameController.h"

@implementation ZSGameGenerator

- (ZSGame *)generateGameWithDifficulty:(ZSGameDifficulty)difficulty {
	/*
	ZSGame *newGame = [ZSGame emptyStandard9x9Game];
	newGame.difficulty = difficulty;
	
	NSInteger puzzle[9][9] = {
		{3, 0, 0, 0, 0, 0, 6, 0, 0},
		{0, 1, 0, 0, 2, 0, 9, 0, 0},
		{0, 0, 0, 0, 9, 0, 0, 0, 4},
		{0, 5, 0, 0, 8, 0, 0, 0, 0},
		{8, 6, 7, 0, 0, 3, 0, 0, 0},
		{0, 0, 2, 1, 4, 6, 0, 0, 0},
		{0, 0, 0, 0, 1, 4, 5, 0, 9},
		{0, 0, 0, 0, 3, 0, 0, 0, 7},
		{0, 2, 0, 7, 0, 0, 0, 0, 0},
	};
	
	for (NSInteger row = 0; row < 9; ++row) {
		for (NSInteger col = 0; col < 9; ++col) {
			ZSGameTile *tempTile = [newGame getTileAtRow:row col:col];
			
			tempTile.answer = puzzle[row][col];
			tempTile.guess = puzzle[row][col];
			tempTile.locked = puzzle[row][col];
		}
	}
	
	[newGame solve];
	
	return newGame;
	*/
	
	ZSGame *game = [self generateStandard9x9Game];
	game.difficulty = difficulty;
	
	return game;
}

- (ZSGame *)generateStandard9x9Game {
	// Build a fresh game.
	ZSGame *newGame = [ZSGame emptyStandard9x9Game];
	
	// Allocate puzzle memory.
	[self setSize:newGame.size];
	
	// Initialize the data.
	for (NSInteger row = 0; row < newGame.size; ++row) {
		for (NSInteger col = 0; col < newGame.size; ++col) {
			ZSGameTile *tile = [newGame getTileAtRow:row col:col];
			_tiles[row][col] = tile.answer;
			_groupMap[row][col] = tile.groupId;
		}
	}
	
	// Build a whole puzzle.
	[self buildPuzzleForX:0 y:0];
	
	// Clone the tiles into a separate grid.
	NSInteger **tilesClone = [ZSGameController alloc2DIntGridWithSize:newGame.size];
	
	// Generate a random string of rows and columns to act as our reduction guide.
	NSInteger *reductionCoords = malloc(_size * _size * sizeof(NSInteger));
	[self populateRandomNumberArray:reductionCoords withSize:(_size * _size)];
	
	// Create a solver to use in the loop.
	ZSGameSolver *gameSolver = [[ZSGameSolver alloc] init];
	
	// As long as it doesn't make the solution ambiguous, keep removing tiles.
	for (NSInteger i = 0, iMax = _size * _size; i < iMax; ++i) {
		NSInteger reductionRow = reductionCoords[i] / _size;
		NSInteger reductionCol = reductionCoords[i] % _size;
		
		// Copy the puzzle to tilesClone. We have to keep doing this because the solver keeps solving it.
		for (NSInteger row = 0; row < newGame.size; ++row) {
			for (NSInteger col = 0; col < newGame.size; ++col) {
				tilesClone[row][col] = _tiles[row][col];
			}
		}
		
		// If the puzzle is still valid, we can poke another hole in it.
		tilesClone[reductionRow][reductionCol] = 0;
		
		// Attempt to solve the puzzle.
		ZSGameSolveResult solveResults = [gameSolver solveTiles:tilesClone groupMap:_groupMap size:_size];
		
		// If no solution is found, we've pushed the puzzle too far and should restore the tile.
		if (solveResults == ZSGameSolveResultSucceeded) {
			_tiles[reductionRow][reductionCol] = 0;
		}
	}
	
	// Save the puzzle data into a fresh game.
	[newGame applyAnswersArray:_tiles];
	[newGame solve];
	
	[ZSGameController free2DIntGrid:tilesClone withSize:newGame.size];
	
	return newGame;
}

- (BOOL)buildPuzzleForX:(NSInteger)x y:(NSInteger)y {
	// If we've already iterated off the end, the puzzle is complete.
	if (y >= _size) {
		return YES;
	}
	
	// If we've iterated off the right side of the puzzle, instead reset to the next row.
	if (x >= _size) {
		return [self buildPuzzleForX:0 y:(y + 1)];
	}
	
	// If the tile is already solved, move on to the next one to the right.
	if (_tiles[x][y] != 0) {
		return [self buildPuzzleForX:(x + 1) y:y];
	}
	
	// Now that we've found an empty spot, loop over all the possible guesses.
	NSInteger *randomGuesses = malloc(_size * sizeof(NSInteger));
	[self populateRandomNumberArray:randomGuesses withSize:_size];
	
	BOOL foundValidGuess = NO;
	
	for (NSInteger i = 0; i < _size; ++i) {
		NSInteger guess = randomGuesses[i] + 1;
		if ([self isGuessValid:guess atX:x y:y]) {
			_tiles[x][y] = guess;
			
			if ([self buildPuzzleForX:(x + 1) y:y]) {
				foundValidGuess = YES;
				break;
			}
		}
	}
	
	free(randomGuesses);
	
	if (foundValidGuess) {
		return YES;
	}
	
	// If none of the guesses worked out, set the guess back to 0 and back out.
	_tiles[x][y] = 0;
	
	return NO;
}

- (void)populateRandomNumberArray:(NSInteger *)array withSize:(NSInteger)arraySize {
	// Populate the array.
	for (NSInteger i = 0; i < arraySize; ++i) {
		array[i] = i;
	}
	
	// Shuffle the array.
	NSInteger temp, target1, target2;
	
	for (NSInteger i = 0, timesToShuffle = arraySize * arraySize; i < timesToShuffle; ++i) {
		target1 = arc4random() % arraySize;
		target2 = arc4random() % arraySize;
		
		temp = array[target1];
		array[target1] = array[target2];
		array[target2] = temp;
	}
}

@end
