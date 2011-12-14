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
#import "ZSGameBoard.h"
#import "ZSGameTile.h"

NSString * const kExceptionPuzzleHasNoSolution = @"kExceptionPuzzleHasNoSolution";
NSString * const kExceptionPuzzleHasMultipleSolutions = @"kExceptionPuzzleHasMultipleSolutions";

@implementation ZSGameSolver

#pragma mark - Object Lifecycle

- (ZSGameSolveResult)solveGameBoard:(ZSGameBoard *)gameBoard {
	if (!_gameBoard || _gameBoard.size != gameBoard.size) {
		// Create some game boards to store the answers.
		_gameBoard = [[ZSGameBoard alloc] initWithSize:gameBoard.size];
		_solvedGameBoard = [[ZSGameBoard alloc] initWithSize:gameBoard.size];
	}
	
	// Set all the group ids from the game board.
	[_gameBoard copyGroupMapFromGameBoard:gameBoard];
	[_solvedGameBoard copyGroupMapFromGameBoard:gameBoard];
	
	// Copy the game board's answers into our guesses.
	for (NSInteger row = 0; row < gameBoard.size; ++row) {
		for (NSInteger col = 0; col < gameBoard.size; ++col) {
			[_gameBoard getTileAtRow:row col:col].guess = [gameBoard getTileAtRow:row col:col].answer;
		}
	}
	
	// Copy the guesses from the game board and add our own pencils.
	[_gameBoard addAutoPencils];
	
	// Solve the puzzle.
	ZSGameSolveResult solveResults = [self solve];
	
	if (solveResults != ZSGameSolveResultSucceeded) {
		return solveResults;
	}
	
	// Save the solution back into the game board's answers.
	for (NSInteger row = 0; row < gameBoard.size; ++row) {
		for (NSInteger col = 0; col < gameBoard.size; ++col) {
			[gameBoard getTileAtRow:row col:col].answer = [_solvedGameBoard getTileAtRow:row col:col].guess;
		}
	}
	
	// All looks good at this point.
	return ZSGameSolveResultSucceeded;
}

#pragma mark - Solving

- (ZSGameSolveResult)solve {
	// Set up the solve loop.
	NSInteger totalUnsolved = _gameBoard.size * _gameBoard.size;
	
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			if ([_gameBoard getTileAtRow:row col:col].answer) {
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
		totalUnsolved = 0;
		
		// If the brute force failed, return the failure.
		if (bruteForceResult != ZSGameSolveResultSucceeded) {
			return bruteForceResult;
		}
	} else {
		// We managed to solve the puzzle without the need to brute force. Copy the solution into the solution array.
		[_solvedGameBoard copyAnswersFromGameBoard:_gameBoard];
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
			if ([_gameBoard getTileAtRow:row col:col].guess) {
				continue;
			}
			
			// Keep track of how many pencil marks the tile has.
			NSInteger totalPencils = 0;
			NSInteger answer = 0;
			
			for (NSInteger guess = 1; guess <= _gameBoard.size; ++guess) {
				if ([[_gameBoard getTileAtRow:row col:col] getPencilForGuess:guess]) {
					++totalPencils;
					answer = guess;
				}
			}
			
			// If the tile only has one pencil mark, it has to be that answer.
			if (totalPencils == 1) {
				[_gameBoard setGuess:answer forTileAtRow:row col:col];
				[_gameBoard clearInfluencedPencilsForTileAtRow:row col:col];
				++totalSolved;
			}
		}
	}
	
	return totalSolved;
}

- (NSInteger)solveSinglePossibility {
	NSInteger totalSolved = 0;
	
	// Make a list of all tile sets in the game.
	NSMutableArray *sets = [NSMutableArray array];
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		[sets addObject:[_gameBoard getTileSetForRow:i]];
		[sets addObject:[_gameBoard getTileSetForCol:i]];
		[sets addObject:[_gameBoard getTileSetForGroup:i]];
	}
	
	// Iterate over each tile set.
	for (NSArray *set in sets) {
		// Iterate over each guess.
		for (NSInteger guess = 1; guess <= _gameBoard.size; ++guess) {
			// Keep track of how many instances of the target pencil are found in the set.
			NSInteger totalPencilsFound = 0;
			ZSGameTile *lastTileFound = nil;
			
			// Iterate over the tiles in the set making note of the occurrances of the target pencil.
			for (ZSGameTile *tile in set) {
				if (!tile.guess && [tile getPencilForGuess:guess]) {
					totalPencilsFound++;
					lastTileFound = tile;
				}
			}
			
			// If only one tile in the set contained the target pencil, it has to be that answer.
			if (totalPencilsFound == 1) {
				[_gameBoard setGuess:guess forTileAtRow:lastTileFound.row col:lastTileFound.col];
				[_gameBoard clearInfluencedPencilsForTileAtRow:lastTileFound.row col:lastTileFound.col];
				++totalSolved;
			}
		}
	}
	
	return totalSolved;
}

- (NSInteger)eliminatePencilsHiddenSubGroup {
	// Start by searching for a tile with no answer.
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			if (![_gameBoard getTileAtRow:row col:col].answer) {
				
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
		[_solvedGameBoard copyGuessesFromGameBoard:_gameBoard];
		
		return ZSGameSolveResultSucceeded;
	}
	
	// If we've iterated off the right side of the puzzle, instead reset to the next row.
	if (row >= _gameBoard.size) {
		return [self solveBruteForceForRow:0 col:(col + 1)];
	}
	
	// If the tile is already solved, move on to the next one to the right.
	if ([_gameBoard getTileAtRow:row col:col].guess) {
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
