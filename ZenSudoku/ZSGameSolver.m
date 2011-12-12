//
//  ZSGameSolver.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameSolver.h"
#import "ZSGameController.h"
#import "ZSGame.h"

NSString * const kExceptionPuzzleHasNoSolution = @"kExceptionPuzzleHasNoSolution";
NSString * const kExceptionPuzzleHasMultipleSolutions = @"kExceptionPuzzleHasMultipleSolutions";

@implementation ZSGameSolver

#pragma mark - Object Lifecycle

- (ZSGameSolveResult)solveGame:(ZSGame *)game {
	// Set the size of the puzzle. This also allocates memory.
	[self setSize:game.size];
	
	// Set all the group ids and auto pencils.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			_tiles[row][col] = 0;
			_groupMap[row][col] = [game getGroupIdForTileAtRow:row col:col];
			
			for (NSInteger guess = 0; guess < _size; ++guess) {
				pencils[row][col][guess] = YES;
			}
		}
	}
	
	// Populate the array with answers and auto-pencil as we go.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			if ([game getAnswerForTileAtRow:row col:col]) {
				[self setGuess:[game getAnswerForTileAtRow:row col:col] forX:row y:col];
			}
		}
	}
	
	// Solve the puzzle.
	ZSGameSolveResult solveResults = [self solve];
	
	if (solveResults != ZSGameSolveResultSucceeded) {
		return solveResults;
	}
	
	// Save the solution back into the game.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			[game setAnswer:solutionTiles[row][col] forTileAtRow:row col:col];
		}
	}
	
	// All looks good at this point.
	return ZSGameSolveResultSucceeded;
}

- (ZSGameSolveResult)solveTiles:(NSInteger **)newTiles groupMap:(NSInteger **)newGroupMap size:(NSInteger)newSize {
	// Set the size of the puzzle. This also allocates memory.
	[self setSize:newSize];
	
	// Set all the group ids and auto pencils.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			_tiles[row][col] = 0;
			_groupMap[row][col] = newGroupMap[row][col];
			
			for (NSInteger guess = 0; guess < _size; ++guess) {
				pencils[row][col][guess] = YES;
			}
		}
	}
	
	// Populate the array with answers and auto-pencil as we go.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			if (newTiles[row][col]) {
				[self setGuess:newTiles[row][col] forX:row y:col];
			}
		}
	}
	
	// Solve the puzzle.
	ZSGameSolveResult solveResults = [self solve];
	
	if (solveResults != ZSGameSolveResultSucceeded) {
		return solveResults;
	}
	
	// Save the solution back into the tiles.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			newTiles[row][col] = solutionTiles[row][col];
		}
	}
	
	// All looks good at this point.
	return ZSGameSolveResultSucceeded;
}

- (void)allocComponents {
	[super allocComponents];
	
	solutionTiles = [ZSGameController alloc2DIntGridWithSize:_size];
	pencils = [ZSGameController alloc3DBoolGridWithSize:_size];
}

- (void)deallocComponents {
	[super deallocComponents];
	
	[ZSGameController free2DIntGrid:solutionTiles withSize:_size];
	[ZSGameController free3DBoolGrid:pencils withSize:_size];
}

#pragma mark - Solving

- (ZSGameSolveResult)solve {
	// Set up the solve loop.
	NSInteger totalUnsolved = _size * _size;
	
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			if (_tiles[row][col]) {
				--totalUnsolved;
			}
		}
	}
	
	// Start the solve loop.
	while (totalUnsolved) {
		// Only Choice
		NSInteger solvedOnlyChoice = [self solveOnlyChoice];
		
		if (solvedOnlyChoice) {
			totalUnsolved -= solvedOnlyChoice;
			continue;
		}
		
		// Single Possibility
		NSInteger solvedSinglePossibility = [self solveSinglePossibility];
		
		if (solvedSinglePossibility) {
			totalUnsolved -= solvedSinglePossibility;
			continue;
		}
		
		// Hidden Sub-Groups
		NSInteger eliminatedPencilsHiddenSubGroup = [self eliminatePencilsHiddenSubGroup];
		
		if (eliminatedPencilsHiddenSubGroup) {
			continue;
		}
		
		// We couldn't use logic to solve the puzzle. Guess we'll have to break and brute force.
		break;
	}
	
	// If we've solved everything, copy the solution into the solution array. Otherwise, brute force will do this.
	if (totalUnsolved) {
		// Brute Force: Last change to solve the puzzle!
		ZSGameSolveResult bruteForceResult = [self solveBruteForce];
		totalUnsolved = 0;
		
		// If the brute force failed, return the failure.
		if (bruteForceResult != ZSGameSolveResultSucceeded) {
			NSLog(@"bruteForceResult: %i", bruteForceResult);
			return bruteForceResult;
		}
	} else {
		// We managed to solve the puzzle without the need to brute force. Copy the solution into the solution array.
		for (NSInteger i = 0; i < _size; ++i) {
			for (NSInteger j = 0; j < _size; ++j) {
				solutionTiles[i][j] = _tiles[i][j];
			}
		}
	}
	
	// All looks good at this point.
	return ZSGameSolveResultSucceeded;
}

- (void)setGuess:(NSInteger)guess forX:(NSInteger)x y:(NSInteger)y {
	// Set the guess.
	_tiles[x][y] = guess;
	
	// Clear the pencil mark from all influenced cells.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			// Remove the guess from influenced tiles. This includes the target tile, but we'll reset the pencils on it later.
			if (x == row || y == col || _groupMap[row][col] == _groupMap[x][y]) {
				pencils[row][col][_tiles[x][y] - 1] = NO;
			}
		}
	}
	
	// Clear the pencils from this one.
	for (NSInteger i = 0; i < _size; ++i) {
		pencils[x][y][i] = NO;
	}
	
	// Restore the pencil mark for the answer.
	pencils[x][y][guess - 1] = YES;
}

- (NSInteger)solveOnlyChoice {
	NSInteger totalSolved = 0;
	
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			if (_tiles[row][col]) {
				continue;
			}
			
			NSInteger totalPencils = 0;
			NSInteger answer = 0;
			
			for (NSInteger guess = 1; guess <= _size; ++guess) {
				if (pencils[row][col][guess - 1]) {
					++totalPencils;
					answer = guess;
				}
			}
			
			if (totalPencils == 1) {
				[self setGuess:answer forX:row y:col];
				++totalSolved;
			}
		}
	}
	
	return totalSolved;
}

- (NSInteger)solveSinglePossibility {
	NSInteger totalSolved = 0;
	
	// Check the rows for a single possibility.
	for (NSInteger pencil = 0; pencil < _size; ++pencil) {
		for (NSInteger row = 0; row < _size; ++row) {
			NSInteger totalPencilsFound = 0;
			NSInteger lastColFound = 0;
			
			for (NSInteger col = 0; col < _size; ++col) {
				if (!_tiles[row][col] && pencils[row][col][pencil]) {
					++totalPencilsFound;
					lastColFound = col;
				}
			}
			
			if (totalPencilsFound == 1) {
				[self setGuess:(pencil + 1) forX:row y:lastColFound];
				++totalSolved;
			}
		}
	}
	
	// Check the cols for a single possibility.
	for (NSInteger pencil = 0; pencil < _size; ++pencil) {
		for (NSInteger col = 0; col < _size; ++col) {
			NSInteger totalPencilsFound = 0;
			NSInteger lastRowFound = 0;
			
			for (NSInteger row = 0; row < _size; ++row) {
				if (!_tiles[row][col] && pencils[row][col][pencil]) {
					++totalPencilsFound;
					lastRowFound = row;
				}
			}
			
			if (totalPencilsFound == 1) {
				[self setGuess:(pencil + 1) forX:lastRowFound y:col];
				++totalSolved;
			}
		}
	}
	
	// Check the groups for a single possibility.
	for (NSInteger pencil = 0; pencil < _size; ++pencil) {
		for (NSInteger group = 0; group < _size; ++group) {
			NSInteger totalPencilsFound = 0;
			NSInteger lastRowFound = 0;
			NSInteger lastColFound = 0;

			for (NSInteger row = 0; row < _size; ++row) {
				for (NSInteger col = 0; col < _size; ++col) {
					if (!_tiles[row][col] && _groupMap[row][col] == group && pencils[row][col][pencil]) {
						++totalPencilsFound;
						lastRowFound = row;
						lastColFound = col;
					}
				}
			}
			
			if (totalPencilsFound == 1) {
				[self setGuess:(pencil + 1) forX:lastRowFound y:lastColFound];
				++totalSolved;
			}
		}
	}
	
	return totalSolved;
}

- (NSInteger)eliminatePencilsHiddenSubGroup {
	// Start by searching for a tile with no answer.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			if (!_tiles[row][col]) {
				
				// Okay, we've found an empty tile.
				
				// Create a list of combinations for the tile. Iterate over the list of combinations.
				
				// Loop over the row, col, and group separately looking for n (the size of the combinations) cells that contain the same numbers as the combincation.
				
				// If n (or fewer) matches are found, eliminate all other pencils from those matches.
				
			}
		}
	}
	
	return 0;
}

- (ZSGameSolveResult)solveBruteForce {
	// Begin the recursive brute force algorithm.
	return [self solveForX:0 y:0];
}

- (ZSGameSolveResult)solveForX:(NSInteger)x y:(NSInteger)y {
	// If we've already iterated off the end, the puzzle is complete.
	if (y >= _size) {
		// Copy the solution.
		for (NSInteger i = 0; i < _size; ++i) {
			for (NSInteger j = 0; j < _size; ++j) {
				solutionTiles[i][j] = _tiles[i][j];
			}
		}
		
		return ZSGameSolveResultSucceeded;
	}
	
	// If we've iterated off the right side of the puzzle, instead reset to the next row.
	if (x >= _size) {
		return [self solveForX:0 y:(y + 1)];
	}
	
	// If the tile is already solved, move on to the next one to the right.
	if (_tiles[x][y] != 0) {
		return [self solveForX:(x + 1) y:y];
	}
	
	// Now that we've found an empty spot, loop over all the possible guesses.
	ZSGameSolveResult localSolutions = ZSGameSolveResultFailedNoSolution;
	
	for (NSInteger guess = 1; guess <= _size; ++guess) {
		if ([self isGuessValid:guess atX:x y:y]) {
			_tiles[x][y] = guess;
			
			ZSGameSolveResult nextSolutions = [self solveForX:(x + 1) y:y];
			
			if (nextSolutions == ZSGameSolveResultFailedMultipleSolutions) {
				return ZSGameSolveResultFailedMultipleSolutions;
			}
			
			if (nextSolutions == ZSGameSolveResultSucceeded) {
				if (localSolutions == ZSGameSolveResultSucceeded) {
					return ZSGameSolveResultFailedMultipleSolutions;
				}
				
				localSolutions = ZSGameSolveResultSucceeded;
			}
			
			_tiles[x][y] = 0;
		}
	}
	
	if (localSolutions == ZSGameSolveResultSucceeded) {
		return ZSGameSolveResultSucceeded;
	}
	
	return ZSGameSolveResultFailedNoSolution;
}
 
#pragma mark - Querying

- (NSInteger)getTotalAnswers {
	NSInteger totalAnswers = 0;
	
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			if (_tiles[row][col]) {
				++totalAnswers;
			}
		}
	}
	
	return totalAnswers;
}

- (NSInteger)getTotalDigits {
	NSInteger totalDigits = 0;
	
	// Create an array of digit counts.
	NSInteger *digitMap = malloc((_size + 1) * sizeof(NSInteger));
	
	for (NSInteger i = 0; i <= _size; ++i) {
		digitMap[i] = 0;
	}
	
	// Loop over the tiles and populate the digit counts.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			++digitMap[_tiles[row][col]];
		}
	}
	
	// Count the number of digits that contain 1 or more result.
	for (NSInteger i = 1; i <= _size; ++i) {
		if (digitMap[i]) {
			++totalDigits;
		}
	}
	
	// Clean up.
	free(digitMap);
	
	return totalDigits;
}

@end
