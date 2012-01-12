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

typedef struct {
	NSInteger size;
	NSInteger *entries;
} ZSNumberSet;

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
	[_solvedGameBoard copyGroupMapFromFastGameBoard:gameBoard];
}

- (void)copyGuessesFromFastGameBoard:(ZSFastGameBoard *)gameBoard {
	// Copy the game board's answers into our guesses.
	[_gameBoard copyGuessesFromFastGameBoard:gameBoard];
	
	// Reset pencils.
	[_gameBoard setAllPencils:NO];
	[_gameBoard addAutoPencils];
}

- (void)copySolutionToFastGameBoard:(ZSFastGameBoard *)gameBoard {
	// Save the solution back into the game board's answers.
	[gameBoard copyGuessesFromFastGameBoard:_gameBoard];
}

- (ZSFastGameBoard *)getGameBoard {
	return _gameBoard;
}

- (ZSFastGameBoard *)getSolvedGameBoard {
	return _solvedGameBoard;
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
	
	NSInteger solved;
	NSInteger pencilsEliminated;
	
	// Start the solve loop.
	while (totalUnsolved) {
		// Only Choice
		solved = [self solveOnlyChoice];
		
		if (solved) {
			totalUnsolved -= solved;
			// NSLog(@"solveOnlyChoice solved: %i", solved);
			continue;
		}
		
		// Single Possibility
		solved = [self solveSinglePossibility];
		
		if (solved) {
			totalUnsolved -= solved;
			// NSLog(@"solveSinglePossibility solved: %i", solved);
			continue;
		}
		
		// Naked Pairs
		pencilsEliminated = [self eliminatePencilsNakedSubgroupForSize:2];
		
		if (pencilsEliminated) {
			// NSLog(@"eliminatePencilsNakedSubgroupForSize:2 pencils eliminated: %i", pencilsEliminated);
			continue;
		}
		
		// Hidden Pairs
		pencilsEliminated = [self eliminatePencilsHiddenSubgroupForSize:2];
		
		if (pencilsEliminated) {
			// NSLog(@"eliminatePencilsHiddenSubgroupForSize:2 pencils eliminated: %i", pencilsEliminated);
			continue;
		}
		
		// Naked Triplets
		pencilsEliminated = [self eliminatePencilsNakedSubgroupForSize:3];
		
		if (pencilsEliminated) {
			// NSLog(@"eliminatePencilsNakedSubgroupForSize:3 pencils eliminated: %i", pencilsEliminated);
			continue;
		}
		
		// Hidden Triplets
		pencilsEliminated = [self eliminatePencilsHiddenSubgroupForSize:3];
		
		if (pencilsEliminated) {
			// NSLog(@"eliminatePencilsHiddenSubgroupForSize:3 pencils eliminated: %i", pencilsEliminated);
			continue;
		}
		
		// Naked Quads
		pencilsEliminated = [self eliminatePencilsNakedSubgroupForSize:4];
		
		if (pencilsEliminated) {
			// NSLog(@"eliminatePencilsNakedSubgroupForSize:4 pencils eliminated: %i", pencilsEliminated);
			continue;
		}
		
		// Hidden Quads
		pencilsEliminated = [self eliminatePencilsHiddenSubgroupForSize:4];
		
		if (pencilsEliminated) {
			// NSLog(@"eliminatePencilsHiddenSubgroupForSize:4 pencils eliminated: %i", pencilsEliminated);
			continue;
		}
		
		// We couldn't use logic to solve the puzzle. Guess we'll have to break and brute force.
		break;
	}
	
	// If we've solved everything, copy the solution into the solution array. Otherwise, brute force will do this.
	if (totalUnsolved) {
		// Brute Force: Last change to solve the puzzle!
		ZSGameSolveResult bruteForceResult = [self solveBruteForce];
		// NSLog(@"solveBruteForce solved: %i", totalUnsolved);
		totalUnsolved = 0;
		
		// If the brute force failed, return the failure.
		if (bruteForceResult != ZSGameSolveResultSucceeded) {
			return bruteForceResult;
		}
	}
	
	// All looks good at this point.
	return ZSGameSolveResultSucceeded;
}

#pragma mark - Logic Techniques

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
	
	// Iterate over each tile set.
	for (NSInteger setIndex = 0, totalSets = 3 * _gameBoard.size; setIndex < totalSets; ++setIndex) {
		// Cache the current set.
		ZSGameTileStub **set = _gameBoard.allSets[setIndex];
		
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
	
	return totalSolved;
}

- (NSInteger)eliminatePencilsHiddenSubgroupForSize:(NSInteger)subgroupSize {
	NSInteger totalPencilsEliminated = 0;
	
	// Allocate memory used in searching for hidden subgroups. We allocate out of the main loop because
	// allocation is expensive and all iterations of the loop need roughly the same size arrays.
	NSInteger *pencilMap = malloc(_gameBoard.size * sizeof(NSInteger));
	NSInteger *combinationMap = malloc(subgroupSize * sizeof(NSInteger));
	ZSGameTileStub **subgroupMatches = malloc(_gameBoard.size * sizeof(ZSGameTileStub *));
	
	// Iterate over each tile set.
	for (NSInteger setIndex = 0, totalSets = 3 * _gameBoard.size; setIndex < totalSets; ++setIndex) {
		// Cache the current set.
		ZSGameTileStub **currentSet = _gameBoard.allSets[setIndex];
		
		// Initialize the pencil map. The compinations generated later will be indexes on this array.
		NSInteger totalPencilsInSet = [self initPencilMap:pencilMap forTileSet:currentSet];
		
		// If there are fewer (or equal) pencil marks than the subgroup size, we can quit here.
		if (totalPencilsInSet <= subgroupSize) {
			continue;
		}
		
		// Initialize the combination list.
		[self setFirstCombinationInArray:combinationMap ofLength:subgroupSize totalPencils:totalPencilsInSet];
		
		// Iterate over each combination of pencils.
		do {
			// Keep track of how many tiles match all pencils in the current combination.
			NSInteger totalTilesWithAnyPencilsInCombination = 0;
			
			// Iterate over each tile in the group.
			for (NSInteger tileIndex = 0; tileIndex < _gameBoard.size; ++tileIndex) {
				// Skip solved tiles.
				if (currentSet[tileIndex]->guess) {
					continue;
				}
				
				// If the current tile contains any of the pencil marks in the subgroup, increment the possible subgroup match count and save a reference to the tile.
				for (NSInteger currentCombinationIndex = 0; currentCombinationIndex < subgroupSize; ++currentCombinationIndex) {
					if (currentSet[tileIndex]->pencils[pencilMap[combinationMap[currentCombinationIndex]]]) {
						subgroupMatches[totalTilesWithAnyPencilsInCombination] = currentSet[tileIndex];
						++totalTilesWithAnyPencilsInCombination;
						break;
					}
				}
			}
			
			// If the possible subgroup match count is less than or equal to the subgroup size, we've found a valid subgroup.
			if (totalTilesWithAnyPencilsInCombination && totalTilesWithAnyPencilsInCombination <= subgroupSize) {
				// Iterate over all the tiles in the subgroup and eliminate all pencil marks that aren't in the pencil map.
				for (NSInteger subgroupMatchIndex = 0; subgroupMatchIndex < totalTilesWithAnyPencilsInCombination; ++subgroupMatchIndex) {
					for (NSInteger pencilToEliminate = 0; pencilToEliminate < _gameBoard.size; ++pencilToEliminate) {
						BOOL matchesHiddenPencil = NO;
						
						for (NSInteger currentCombinationIndex = 0; currentCombinationIndex < subgroupSize; ++currentCombinationIndex) {
							if (pencilToEliminate == pencilMap[combinationMap[currentCombinationIndex]]) {
								matchesHiddenPencil = YES;
								break;
							}
						}
						
						if (matchesHiddenPencil) {
							continue;
						}
						
						if (subgroupMatches[subgroupMatchIndex]->pencils[pencilToEliminate]) {
							[_gameBoard setPencil:NO forPencilNumber:(pencilToEliminate + 1) forTileAtRow:subgroupMatches[subgroupMatchIndex]->row col:subgroupMatches[subgroupMatchIndex]->col];
							++totalPencilsEliminated;
						}
					}
				}
			}
		} while ([self setNextCombinationInArray:combinationMap ofLength:subgroupSize totalPencils:totalPencilsInSet]);
	}
	
	free(subgroupMatches);
	free(combinationMap);
	free(pencilMap);
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsNakedSubgroupForSize:(NSInteger)subgroupSize {
	NSInteger totalPencilsEliminated = 0;
	
	// Allocate memory used in searching for hidden subgroups. We allocate out of the main loop because
	// allocation is expensive and all iterations of the loop need roughly the same size arrays.
	NSInteger *pencilMap = malloc(_gameBoard.size * sizeof(NSInteger));
	NSInteger *combinationMap = malloc(subgroupSize * sizeof(NSInteger));
	ZSGameTileStub **subgroupMatches = malloc(_gameBoard.size * sizeof(ZSGameTileStub *));
	
	// Iterate over each tile set.
	for (NSInteger setIndex = 0, totalSets = 3 * _gameBoard.size; setIndex < totalSets; ++setIndex) {
		// Cache the current set.
		ZSGameTileStub **currentSet = _gameBoard.allSets[setIndex];
		
		// Initialize the pencil map. The compinations generated later will be indexes on this array.
		NSInteger totalPencilsInSet = [self initPencilMap:pencilMap forTileSet:currentSet];
		
		// If there are fewer (or equal) pencil marks than the subgroup size, we can quit here.
		if (totalPencilsInSet <= subgroupSize) {
			continue;
		}
		
		// Initialize the combination list.
		[self setFirstCombinationInArray:combinationMap ofLength:subgroupSize totalPencils:totalPencilsInSet];
		
		// Iterate over each combination of pencils.
		do {
			// Keep track of how many tiles match all pencils in the current combination.
			NSInteger totalTilesWithMatchingPencilsInCombination = 0;
			
			// Iterate over each tile in the group.
			for (NSInteger tileIndex = 0; tileIndex < _gameBoard.size; ++tileIndex) {
				// Skip solved tiles.
				if (currentSet[tileIndex]->guess) {
					continue;
				}
				
				// Make sure the tile has all of the pencils.
				BOOL tileHasOnlyMatchingPencils = YES;
				
				// Check all pencils on the current tile.
				for (NSInteger pencilToTest = 0; pencilToTest < _gameBoard.size; ++pencilToTest) {
					// If the tile has the current pencil, make sure it's not one of the possible naked subgroup pencils.
					if (currentSet[tileIndex]->pencils[pencilToTest]) {
						BOOL pencilToTestMatchesSubgroupTarget = NO;
						
						for (NSInteger currentCombinationIndex = 0; currentCombinationIndex < subgroupSize; ++currentCombinationIndex) {
							if (pencilToTest == pencilMap[combinationMap[currentCombinationIndex]]) {
								pencilToTestMatchesSubgroupTarget = YES;
								break;
							}
						}
						
						// If the pencil is one of the naked subgroup pencils, it's okay to continue. Else, this tile cannot be part of a naked subgroup.
						if (pencilToTestMatchesSubgroupTarget) {
							continue;
						} else {
							tileHasOnlyMatchingPencils = NO;
							break;
						}
					}
				}
				
				// If this tile only has pencils that match the possible naked subgroup, save a pointer to it for later.
				if (tileHasOnlyMatchingPencils) {
					subgroupMatches[totalTilesWithMatchingPencilsInCombination] = currentSet[tileIndex];
					++totalTilesWithMatchingPencilsInCombination;
				}
			}
			
			// If the possible subgroup match count is less than or equal to the subgroup size, we've found a valid subgroup.
			if (totalTilesWithMatchingPencilsInCombination && totalTilesWithMatchingPencilsInCombination == subgroupSize) {
				// Iterate over all the tiles in the set (except for those in the subgroup) and eliminate all pencil marks that aren't in the pencil map.
				for (NSInteger setIndex = 0; setIndex < _gameBoard.size; ++setIndex) {
					BOOL tileIsInNakedSubgroup = NO;
					
					for (NSInteger subgroupMatchIndex = 0; subgroupMatchIndex < totalTilesWithMatchingPencilsInCombination; ++subgroupMatchIndex) {
						if (subgroupMatches[subgroupMatchIndex] == currentSet[setIndex]) {
							tileIsInNakedSubgroup = YES;
							break;
						}
					}
					
					if (tileIsInNakedSubgroup) {
						continue;
					}
					
					for (NSInteger currentCombinationIndex = 0; currentCombinationIndex < subgroupSize; ++currentCombinationIndex) {
						NSInteger pencilToEliminate = pencilMap[combinationMap[currentCombinationIndex]];
						
						if (currentSet[setIndex]->pencils[pencilToEliminate]) {
							[_gameBoard setPencil:NO forPencilNumber:(pencilToEliminate + 1) forTileAtRow:currentSet[setIndex]->row col:currentSet[setIndex]->col];
							++totalPencilsEliminated;
						}
					}
				}
			}
		} while ([self setNextCombinationInArray:combinationMap ofLength:subgroupSize totalPencils:totalPencilsInSet]);
	}
	
	free(subgroupMatches);
	free(combinationMap);
	free(pencilMap);
	
	return totalPencilsEliminated;
}

#pragma mark - Logic Technique Helpers

// Populate the pencilMap array with a list of pencils that exist in the given tile set. Return the total number of pencils found.
- (NSInteger)initPencilMap:(NSInteger *)pencilMap forTileSet:(ZSGameTileStub **)set {
	NSInteger totalPencils = 0;
	
	for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
		for (NSInteger tileIndex = 0; tileIndex < _gameBoard.size; ++tileIndex) {
			// If we find this pencil mark in the set, add it to the list of all pencil marks and increment the total.
			// We can also break out of the loop over the tiles and move to the next guess.
			if (!set[tileIndex]->guess && set[tileIndex]->pencils[guess]) {
				pencilMap[totalPencils] = guess;
				++totalPencils;
				break;
			}
		}
	}
	
	return totalPencils;
}

// Returns the the first combination.
- (void)setFirstCombinationInArray:(NSInteger *)comboArray ofLength:(NSInteger)arrayLength totalPencils:(NSInteger)itemCount {
	// Make sure we have enough unique items to fill the array.
	assert(arrayLength <= itemCount);
	
	for (NSInteger i = 0; i < arrayLength; i++) {
		comboArray[i] = i;
	}
}

// Provides the next the next combination in the sequence. Returns false if there are no more combinations.
- (BOOL)setNextCombinationInArray:(NSInteger *)comboArray ofLength:(NSInteger)arrayLength totalPencils:(NSInteger)itemCount {
	// Increment the last array element. If it overflows, then increment the next-to-last element, etc.
	for (NSInteger index = arrayLength - 1; index >= 0; index--) {
		NSInteger maxValueForIndex = itemCount - (arrayLength - index);
		
		// Make sure we're not about to exceed the max value for the current index.
		if (comboArray[index] < maxValueForIndex) {
			comboArray[index] += 1;
			
			// Initialize the rest of the array.
			for (NSInteger initIndex = index + 1; initIndex < arrayLength; initIndex++) {
				comboArray[initIndex] = comboArray[initIndex - 1] + 1;
			}
			
			return YES;
		}
	}
	
	return NO;
}

- (NSInteger)getNumberOfTilesInSet:(ZSGameTileStub **)set withTotalPencilsEqualToOrGreaterThan:(NSInteger)totalPencilLimit {
	// Create a bit map of all pencils in the group.
	NSInteger totalTiles = 0;
	
	// Iterate over all tiles in the set.
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		// Count the number of pencils in the current tile.
		NSInteger totalPencils = 0;
		
		// Iterate over each guess.
		for (NSInteger guess = 1; guess <= _gameBoard.size; ++guess) {
			NSInteger totalPencils = 0;

			if (!set[i]->guess && set[i]->pencils[guess - 1]) {
				++totalPencils;
			}
		}
		
		// Keep count of the number of tiles that equal or exceed the limit.
		if (totalPencils >= totalPencilLimit) {
			++totalTiles;
		}
	}
	
	return totalTiles;
}

#pragma mark - Brute Force Solving

- (ZSGameSolveResult)solveBruteForce {
	// Begin the recursive brute force algorithm.
	ZSGameSolveResult result = [self solveBruteForceForRow:0 col:0];
	
	// If a unique solution was found, copy the solution to the main game board.
	if (result == ZSGameSolveResultSucceeded) {
		[_gameBoard copyGuessesFromFastGameBoard:_solvedGameBoard];
	}
	
	// Return the result.
	return result;
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
