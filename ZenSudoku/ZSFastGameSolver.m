//
//  ZSFastGameSolver.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSFastGameSolver.h"
#import "ZSFastGameBoard.h"

NSString * const kExceptionPuzzleHasNoSolution = @"kExceptionPuzzleHasNoSolution";
NSString * const kExceptionPuzzleHasMultipleSolutions = @"kExceptionPuzzleHasMultipleSolutions";

@implementation ZSFastGameSolver

#pragma mark - Object Lifecycle

- (id)init {
	return [self initWithSize:9];
}

- (id)initWithSize:(NSInteger)size {
	self = [super init];
	
	if (self) {
		// Create some game boards to store the answers.
		_gameBoard = [[ZSFastGameBoard alloc] initWithSize:size];
		_solvedGameBoard = [[ZSFastGameBoard alloc] initWithSize:size];
	}
	
	return self;
}

- (void)copyGroupMapFromFastGameBoard:(ZSFastGameBoard *)gameBoard {
	// Set all the group ids from the game board.
	[_gameBoard copyGroupMapFromFastGameBoard:gameBoard];
	// [_solvedGameBoard copyGroupMapFromFastGameBoard:gameBoard];
}

- (void)copyGuessesFromFastGameBoard:(ZSFastGameBoard *)gameBoard {
	// Copy the game board's answers into our guesses.
	[_gameBoard copyGuessesFromFastGameBoard:gameBoard];
	[_gameBoard addAutoPencils];
}

- (void)copySolutionToFastGameBoard:(ZSFastGameBoard *)gameBoard {
	// Save the solution back into the game board's answers.
	[gameBoard copyGuessesFromFastGameBoard:_solvedGameBoard];
}

#pragma mark - Solving

- (ZSGameSolveResult)solve {
	// Set up the solve loop.
	NSInteger totalUnsolved = _gameBoard.size * _gameBoard.size;
	
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			if (_gameBoard.grid[row][col].guess) {
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
//			NSLog(@"solveOnlyChoice solved: %i", solvedOnlyChoice);
			continue;
		}
		
		// Single Possibility
		NSInteger solvedSinglePossibility = [self solveSinglePossibility];
		
		if (solvedSinglePossibility) {
			totalUnsolved -= solvedSinglePossibility;
//			NSLog(@"solveSinglePossibility solved: %i", solvedSinglePossibility);
			continue;
		}
		
//		// Hidden Sub-Groups
//		NSInteger eliminatedPencilsHiddenSubGroup = [self eliminatePencilsHiddenSubGroup];
//		
//		if (eliminatedPencilsHiddenSubGroup) {
//			continue;
//		}
		
		// We couldn't use logic to solve the puzzle. Guess we'll have to break and brute force.
		break;
	}
	
	// If we've solved everything, copy the solution into the solution array. Otherwise, brute force will do this.
	if (totalUnsolved) {
		// Brute Force: Last change to solve the puzzle!
		ZSGameSolveResult bruteForceResult = [self solveBruteForce];
//		NSLog(@"solveBruteForce solved: %i", totalUnsolved);
		totalUnsolved = 0;
		
		// If the brute force failed, return the failure.
		if (bruteForceResult != ZSGameSolveResultSucceeded) {
			return bruteForceResult;
		}
	} else {
		// We managed to solve the puzzle without the need to brute force. Copy the solution into the solution array.
		[_solvedGameBoard copyGuessesFromFastGameBoard:_gameBoard];
	}
	
	// All looks good at this point.
	return ZSGameSolveResultSucceeded;
}

- (NSInteger)solveOnlyChoice {
	NSInteger totalSolved = 0;
	
	// Iterate over all the tiles on the board.
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			// Skip the solved tiles.
			if (_gameBoard.grid[row][col].guess) {
				continue;
			}
			
			// If the tile only has one pencil mark, it has to be that answer.
			if (_gameBoard.grid[row][col].totalPencils == 1) {
				// Search through the pencils and find the lone YES.
				for (NSInteger guess = 1; guess <= _gameBoard.size; ++guess) {
					if (_gameBoard.grid[row][col].pencils[guess - 1]) {
						[_gameBoard setGuess:guess forTileAtRow:row col:col];
						[_gameBoard clearInfluencedPencilsForTileAtRow:row col:col];
						++totalSolved;
						break;
					}
				}
			}
		}
	}
	
	return totalSolved;
}

- (NSInteger)solveSinglePossibility {
	NSInteger totalSolved = 0;
	
	// Make a list of all tile sets in the game.
	ZSGameTileStub ***sets = malloc(3 * _gameBoard.size * sizeof(ZSGameTileStub **));
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		sets[3 * i + 0] = _gameBoard.rows[i];
		sets[3 * i + 1] = _gameBoard.cols[i];
		sets[3 * i + 2] = _gameBoard.groups[i];
	}
	
	// Iterate over each tile set.
	for (NSInteger setIndex = 0, totalSets = 3 * _gameBoard.size; setIndex < totalSets; ++setIndex) {
		ZSGameTileStub **set = sets[setIndex];
		
		// Iterate over each guess.
		for (NSInteger guess = 1; guess <= _gameBoard.size; ++guess) {
			// Keep track of how many instances of the target pencil are found in the set.
			NSInteger totalPencilsFound = 0;
			ZSGameTileStub *lastTileFound = NULL;
			
			// Iterate over the tiles in the set making note of the occurrances of the target pencil.
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				if (!set[i]->guess && set[i]->pencils[guess - 1]) {
					++totalPencilsFound;
					lastTileFound = set[i];
				}
			}
			
			// If only one tile in the set contained the target pencil, it has to be that answer.
			if (totalPencilsFound == 1) {
				[_gameBoard setGuess:guess forTileAtRow:lastTileFound->row col:lastTileFound->col];
				[_gameBoard clearInfluencedPencilsForTileAtRow:lastTileFound->row col:lastTileFound->col];
				++totalSolved;
			}
		}
	}
	
	free(sets);
	
	return totalSolved;
}

- (NSInteger)eliminatePencilsHiddenSubGroup {
	// Start by searching for a tile with no answer.
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			if (!_gameBoard.grid[row][col].guess) {
				
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
	return [self solveBruteForceForRow:0 col:0];
}

- (ZSGameSolveResult)solveBruteForceForRow:(NSInteger)row col:(NSInteger)col {
	// If we've already iterated off the end, the puzzle is complete.
	if (col >= _gameBoard.size) {
		// Copy the solution.
		[_solvedGameBoard copyGuessesFromFastGameBoard:_gameBoard];
		
		return ZSGameSolveResultSucceeded;
	}
	
	// If we've iterated off the right side of the puzzle, instead reset to the next row.
	if (row >= _gameBoard.size) {
		return [self solveBruteForceForRow:0 col:(col + 1)];
	}
	
	// If the tile is already solved, move on to the next one to the right.
	if (_gameBoard.grid[row][col].guess) {
		return [self solveBruteForceForRow:(row + 1) col:col];
	}
	
	// Now that we've found an empty spot, loop over all the possible guesses.
	ZSGameSolveResult localSolutions = ZSGameSolveResultFailedNoSolution;
	
	for (NSInteger guess = 1; guess <= _gameBoard.size; ++guess) {
		if ([_gameBoard isGuess:guess validInRow:row col:col]) {
			[_gameBoard setGuess:guess forTileAtRow:row col:col];
			
			ZSGameSolveResult nextSolutions = [self solveBruteForceForRow:(row + 1) col:col];
			
			if (nextSolutions == ZSGameSolveResultFailedMultipleSolutions) {
				return ZSGameSolveResultFailedMultipleSolutions;
			}
			
			if (nextSolutions == ZSGameSolveResultSucceeded) {
				if (localSolutions == ZSGameSolveResultSucceeded) {
					return ZSGameSolveResultFailedMultipleSolutions;
				}
				
				localSolutions = ZSGameSolveResultSucceeded;
			}
			
			[_gameBoard clearGuessForTileAtRow:row col:col];
		}
	}
	
	if (localSolutions == ZSGameSolveResultSucceeded) {
		return ZSGameSolveResultSucceeded;
	}
	
	return ZSGameSolveResultFailedNoSolution;
}
 
@end
