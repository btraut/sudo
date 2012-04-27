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
		
		// Create the chain map.
		[self initChainMap];
		[self clearChainMap];
		
		// Create the clue mask.
		[self initClueMask];
		[self clearClueMask];
	}
	
	return self;
}

- (void)dealloc {
	[self deallocClueMask];
	[self deallocChainMap];
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

- (ZSChainMapResult **)getChainMap {
	return _chainMap;
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
			continue;
		}
		
		// Single Possibility
		solved = [self solveSinglePossibility];
		
		if (solved) {
			totalUnsolved -= solved;
			continue;
		}
		
		// Naked Pairs
		pencilsEliminated = [self eliminatePencilsNakedSubgroupForSize:2];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Hidden Pairs
		pencilsEliminated = [self eliminatePencilsHiddenSubgroupForSize:2];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Pointing Pairs
		pencilsEliminated = [self eliminatePencilsPointingPairs];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Box Line Reduction
		pencilsEliminated = [self eliminatePencilsBoxLineReduction];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Naked Triplets
		pencilsEliminated = [self eliminatePencilsNakedSubgroupForSize:3];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Hidden Triplets
		pencilsEliminated = [self eliminatePencilsHiddenSubgroupForSize:3];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Naked Quads
		pencilsEliminated = [self eliminatePencilsNakedSubgroupForSize:4];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Hidden Quads
		pencilsEliminated = [self eliminatePencilsHiddenSubgroupForSize:4];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// X-Wing
		pencilsEliminated = [self eliminatePencilsXWingOfSize:2];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Swordfish
		pencilsEliminated = [self eliminatePencilsXWingOfSize:3];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Jellyfish
		pencilsEliminated = [self eliminatePencilsXWingOfSize:4];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Finned X-Wing
		pencilsEliminated = [self eliminatePencilsFinnedXWingOfSize:2];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Y-Wing
		pencilsEliminated = [self eliminatePencilsYWingUseChains:NO];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Remote Pairs
		pencilsEliminated = [self eliminatePencilsRemotePairs];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Avoidable Rectangles
		pencilsEliminated = [self eliminatePencilsAvoidableRectangles];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Chained Y-Wing
		pencilsEliminated = [self eliminatePencilsYWingUseChains:YES];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Finned Swordfish
		pencilsEliminated = [self eliminatePencilsFinnedXWingOfSize:3];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Finned Jellyfish
		pencilsEliminated = [self eliminatePencilsFinnedXWingOfSize:4];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// We couldn't use logic to solve the puzzle. Guess we'll have to break and brute force.
		break;
	}
	
	// If we've solved everything, copy the solution into the solution array. Otherwise, brute force will do this.
	if (totalUnsolved) {
		// Brute Force: Last change to solve the puzzle!
		ZSGameSolveResult bruteForceResult = [self solveBruteForce];
		
		// If the brute force failed, return the failure.
		if (bruteForceResult != ZSGameSolveResultSucceeded) {
			return bruteForceResult;
		}
	}
	
	// All looks good at this point.
	return ZSGameSolveResultSucceeded;
}

- (ZSGameSolveResult)solveQuickly {
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
			continue;
		}
		
		// Single Possibility
		solved = [self solveSinglePossibility];
		
		if (solved) {
			totalUnsolved -= solved;
			continue;
		}
		
		// Naked Pairs
		pencilsEliminated = [self eliminatePencilsNakedSubgroupForSize:2];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Hidden Pairs
		pencilsEliminated = [self eliminatePencilsHiddenSubgroupForSize:2];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Pointing Pairs
		pencilsEliminated = [self eliminatePencilsPointingPairs];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Box Line Reduction
		pencilsEliminated = [self eliminatePencilsBoxLineReduction];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Naked Triplets
		pencilsEliminated = [self eliminatePencilsNakedSubgroupForSize:3];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Hidden Triplets
		pencilsEliminated = [self eliminatePencilsHiddenSubgroupForSize:3];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// X-Wing
		pencilsEliminated = [self eliminatePencilsXWingOfSize:2];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Swordfish
		pencilsEliminated = [self eliminatePencilsXWingOfSize:3];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Jellyfish
		pencilsEliminated = [self eliminatePencilsXWingOfSize:4];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Finned X-Wing
		pencilsEliminated = [self eliminatePencilsFinnedXWingOfSize:2];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Remote Pairs
		pencilsEliminated = [self eliminatePencilsRemotePairs];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Avoidable Rectangles
		pencilsEliminated = [self eliminatePencilsAvoidableRectangles];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// Finned Swordfish
		pencilsEliminated = [self eliminatePencilsFinnedXWingOfSize:3];
		
		if (pencilsEliminated) {
			continue;
		}
		
		// We couldn't use logic to solve the puzzle. Guess we'll have to break and brute force.
		break;
	}
	
	// If we've solved everything, copy the solution into the solution array. Otherwise, brute force will do this.
	if (totalUnsolved) {
		// Brute Force: Last change to solve the puzzle!
		ZSGameSolveResult bruteForceResult = [self solveBruteForce];
		
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
	
	// Iterate over each guess.
	for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
		// Iterate over each row.
		for (NSInteger i = 0; i < _gameBoard.size; ++i) {
			// If there is only one tile with the current pencil, that's the answer for that tile.
			if (_gameBoard.totalTilesInRowWithPencil[i][guess] == 1) {
				// Iterate over the set and find the tile with the matching pencil.
				for (NSInteger j = 0; j < _gameBoard.size; ++j) {
					if (!_gameBoard.rows[i][j]->guess && _gameBoard.rows[i][j]->pencils[guess]) {
						[_gameBoard setGuess:(guess + 1) forTileAtRow:_gameBoard.rows[i][j]->row col:_gameBoard.rows[i][j]->col];
						[_gameBoard clearInfluencedPencilsForTileAtRow:_gameBoard.rows[i][j]->row col:_gameBoard.rows[i][j]->col];
						++totalSolved;
					}
				}
			}
		}
		
		// Iterate over each col.
		for (NSInteger i = 0; i < _gameBoard.size; ++i) {
			// If there is only one tile with the current pencil, that's the answer for that tile.
			if (_gameBoard.totalTilesInColWithPencil[i][guess] == 1) {
				// Iterate over the set and find the tile with the matching pencil.
				for (NSInteger j = 0; j < _gameBoard.size; ++j) {
					if (!_gameBoard.cols[i][j]->guess && _gameBoard.cols[i][j]->pencils[guess]) {
						[_gameBoard setGuess:(guess + 1) forTileAtRow:_gameBoard.cols[i][j]->row col:_gameBoard.cols[i][j]->col];
						[_gameBoard clearInfluencedPencilsForTileAtRow:_gameBoard.cols[i][j]->row col:_gameBoard.cols[i][j]->col];
						++totalSolved;
					}
				}
			}
		}
		
		// Iterate over each group.
		for (NSInteger i = 0; i < _gameBoard.size; ++i) {
			// If there is only one tile with the current pencil, that's the answer for that tile.
			if (_gameBoard.totalTilesInGroupWithPencil[i][guess] == 1) {
				// Iterate over the set and find the tile with the matching pencil.
				for (NSInteger j = 0; j < _gameBoard.size; ++j) {
					if (!_gameBoard.groups[i][j]->guess && _gameBoard.groups[i][j]->pencils[guess]) {
						[_gameBoard setGuess:(guess + 1) forTileAtRow:_gameBoard.groups[i][j]->row col:_gameBoard.groups[i][j]->col];
						[_gameBoard clearInfluencedPencilsForTileAtRow:_gameBoard.groups[i][j]->row col:_gameBoard.groups[i][j]->col];
						++totalSolved;
					}
				}
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
		[self setFirstCombinationInArray:combinationMap ofLength:subgroupSize totalItems:totalPencilsInSet];
		
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
		} while ([self setNextCombinationInArray:combinationMap ofLength:subgroupSize totalItems:totalPencilsInSet]);
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
		[self setFirstCombinationInArray:combinationMap ofLength:subgroupSize totalItems:totalPencilsInSet];
		
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
		} while ([self setNextCombinationInArray:combinationMap ofLength:subgroupSize totalItems:totalPencilsInSet]);
	}
	
	free(subgroupMatches);
	free(combinationMap);
	free(pencilMap);
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsPointingPairs {
	NSInteger totalPencilsEliminated = 0;
	
	// Loop over all groups.
	for (NSInteger groupIndex = 0; groupIndex < _gameBoard.size; ++groupIndex) {
		// Cache the current group.
		ZSGameTileStub **currentGroup = _gameBoard.groups[groupIndex];
		NSInteger currentGroupId = _gameBoard.groups[groupIndex][0]->groupId;
		
		// Loop over all guesses.
		for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
			// If the group has already solved this guess, continue.
			if (_gameBoard.totalTilesInGroupWithAnswer[groupIndex][guess]) {
				continue;
			}
			
			// If more than 3 tiles in the group have that pencil mark, they can't possibly be in a line.
			if (_gameBoard.totalTilesInGroupWithPencil[groupIndex][guess] > 3) {
				continue;
			}
			
			// Keep track of the row and column of all existing pencils of the current guess.
			NSInteger foundPencils = 0;
			NSInteger alignedRow = 0;
			NSInteger alignedCol = 0;
			BOOL rowIsAligned = YES;
			BOOL colIsAligned = YES;
			
			// Loop over the members in the group.
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				if (currentGroup[i]->pencils[guess]) {
					if (foundPencils == 0) {
						alignedRow = currentGroup[i]->row;
						alignedCol = currentGroup[i]->col;
					} else {
						if (currentGroup[i]->row != alignedRow) {
							rowIsAligned = NO;
						}
						
						if (currentGroup[i]->col != alignedCol) {
							colIsAligned = NO;
						}
					}
					
					++foundPencils;
				}
			}
			
			// If we found pencils, there's a chance we get to eliminate possibilities.
			if (foundPencils) {
				// If all the pencils found were in the same row, eliminate all possibilities in the rest of that row.
				if (rowIsAligned && foundPencils != _gameBoard.totalTilesInRowWithPencil[alignedRow][guess]) {
					ZSGameTileStub **rowSet = _gameBoard.rows[alignedRow];
					
					for (NSInteger i = 0; i < _gameBoard.size; ++i) {
						if (rowSet[i]->groupId != currentGroupId) {
							if (rowSet[i]->pencils[guess]) {
								[_gameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:rowSet[i]->row col:rowSet[i]->col];
								++totalPencilsEliminated;
							}
						}
					}
				}
				
				// If all the pencils found were in the same col, eliminate all possibilities in the rest of that col.
				if (colIsAligned && foundPencils != _gameBoard.totalTilesInColWithPencil[alignedCol][guess]) {
					ZSGameTileStub **colSet = _gameBoard.cols[alignedCol];
					
					for (NSInteger i = 0; i < _gameBoard.size; ++i) {
						if (colSet[i]->groupId != currentGroupId) {
							if (colSet[i]->pencils[guess]) {
								[_gameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:colSet[i]->row col:colSet[i]->col];
								++totalPencilsEliminated;
							}
						}
					}
				}
			}
		}
	}
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsBoxLineReduction {
	NSInteger totalPencilsEliminated = 0;
	
	for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
		for (NSInteger row = 0; row < _gameBoard.size; ++row) {
			if (_gameBoard.totalTilesInRowWithPencil[row][guess] && _gameBoard.totalTilesInRowWithPencil[row][guess] <= 3) {
				BOOL allPencilsInSameGroup = YES;
				NSInteger totalPencilsFound = 0;
				NSInteger group = 0;
				
				for (NSInteger i = 0; i < _gameBoard.size; ++i) {
					if (!_gameBoard.rows[row][i]->guess && _gameBoard.rows[row][i]->pencils[guess]) {
						if (totalPencilsFound) {
							if (_gameBoard.rows[row][i]->groupId != group) {
								allPencilsInSameGroup = NO;
								break;
							}
						} else {
							group = _gameBoard.rows[row][i]->groupId;
						}
						
						++totalPencilsFound;
					}
				}
				
				if (allPencilsInSameGroup) {
					for (NSInteger i = 0; i < _gameBoard.size; ++i) {
						if (_gameBoard.groups[group][i]->row == row) {
							continue;
						}
						
						if (!_gameBoard.groups[group][i]->guess && _gameBoard.groups[group][i]->pencils[guess]) {
							[_gameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:_gameBoard.groups[group][i]->row col:_gameBoard.groups[group][i]->col];
							++totalPencilsEliminated;
						}
					}
				}
			}
		}
		
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			if (_gameBoard.totalTilesInColWithPencil[col][guess] && _gameBoard.totalTilesInColWithPencil[col][guess] <= 3) {
				BOOL allPencilsInSameGroup = YES;
				NSInteger totalPencilsFound = 0;
				NSInteger group = 0;
				
				for (NSInteger i = 0; i < _gameBoard.size; ++i) {
					if (!_gameBoard.cols[col][i]->guess && _gameBoard.cols[col][i]->pencils[guess]) {
						if (totalPencilsFound) {
							if (_gameBoard.cols[col][i]->groupId != group) {
								allPencilsInSameGroup = NO;
								break;
							}
						} else {
							group = _gameBoard.cols[col][i]->groupId;
						}
						
						++totalPencilsFound;
					}
				}
				
				if (allPencilsInSameGroup) {
					for (NSInteger i = 0; i < _gameBoard.size; ++i) {
						if (_gameBoard.groups[group][i]->col == col) {
							continue;
						}
						
						if (!_gameBoard.groups[group][i]->guess && _gameBoard.groups[group][i]->pencils[guess]) {
							[_gameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:_gameBoard.groups[group][i]->row col:_gameBoard.groups[group][i]->col];
							++totalPencilsEliminated;
						}
					}
				}
			}
		}
	}
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsXWingOfSize:(NSInteger)size {
	NSInteger pencilsEliminated = 0;
	
	pencilsEliminated += [self eliminatePencilsXWingRowsOfSize:size];
	pencilsEliminated += [self eliminatePencilsXWingColsOfSize:size];
	
	return pencilsEliminated;
}

- (NSInteger)eliminatePencilsXWingRowsOfSize:(NSInteger)size {
	NSInteger totalPencilsEliminated = 0;
	
	// Initialize the slot matches.
	ZSXWingSlotMatch *slotMatches = malloc(_gameBoard.size * sizeof(ZSXWingSlotMatch));
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		slotMatches[i].slotIndexes = malloc(size * sizeof(NSInteger));
	}
	
	// Init memory for use in the loop.
	NSInteger *currentRowIndexes = malloc(_gameBoard.size * sizeof(NSInteger));
	NSInteger *slotsInRowGroup = malloc(_gameBoard.size * sizeof(NSInteger));
	BOOL *slotExistsInRowGroup = malloc(_gameBoard.size * sizeof(BOOL));
	BOOL *rowExistsInRowGroup = malloc(_gameBoard.size * sizeof(BOOL));
	
	for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
		// Keep track of how many rows have exactly two of the current pencil.
		NSInteger totalRowMatches = 0;
		
		// Clear out the slot matches objects.
		for (NSInteger i = 0; i < _gameBoard.size; ++i) {
			slotMatches[i].totalSlotIndexes = 0;
		}
		
		// Find all the rows that contain 2 tiles with the current pencil mark and put them in a slot match object.
		for (NSInteger row = 0; row < _gameBoard.size; ++row) {
			if (_gameBoard.totalTilesInRowWithPencil[row][guess] >= 2 && _gameBoard.totalTilesInRowWithPencil[row][guess] <= size) {
				// We have a row that fits. First, figure out which tiles contain the pencil.
				for (NSInteger j = 0; j < _gameBoard.size; ++j) {
					if (_gameBoard.rows[row][j]->pencils[guess]) {
						slotMatches[totalRowMatches].slotIndexes[slotMatches[totalRowMatches].totalSlotIndexes] = _gameBoard.rows[row][j]->col;
						++slotMatches[totalRowMatches].totalSlotIndexes;
					}
				}
				
				// Note the current row.
				slotMatches[totalRowMatches].matchIndex = row;
				
				++totalRowMatches;
			}
		}
		
		// It takes at least two matching rows to form an X-Wing of any size.
		if (totalRowMatches < size) {
			continue;
		}
		
		// Initialize the array of row combinations.
		[self setFirstCombinationInArray:currentRowIndexes ofLength:size totalItems:totalRowMatches];
		
		// Loop over all the possible combinations of row groups of the specified size.
		do {
			// Initialize the bool cache of slots for this match group.
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				slotExistsInRowGroup[i] = NO;
			}
			
			// Mark all the columns that have slot matches.
			for (NSInteger i = 0; i < size; ++i) {
				for (NSInteger j = 0; j < slotMatches[currentRowIndexes[i]].totalSlotIndexes; ++j) {
					slotExistsInRowGroup[slotMatches[currentRowIndexes[i]].slotIndexes[j]] = YES;
				}
			}
			
			// Count the total slots in this row group.
			NSInteger totalSlots = 0;
			
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				if (slotExistsInRowGroup[i]) {
					slotsInRowGroup[totalSlots] = i;
					++totalSlots;
				}
			}
			
			// If the number of slots in the group is equivalent to the group size, we have an X-Wing!
			if (totalSlots == size) {
				// Initialize the bool cache of rows in this row group.
				for (NSInteger i = 0; i < _gameBoard.size; ++i) {
					rowExistsInRowGroup[i] = NO;
				}
				
				// Mark all the rows in this row group.
				for (NSInteger i = 0; i < size; ++i) {
					rowExistsInRowGroup[slotMatches[currentRowIndexes[i]].matchIndex] = YES;
				}
				
				// Finally, loop over all the rows and eliminate penils in each column.
				for (NSInteger row = 0; row < _gameBoard.size; ++row) {
					// Skip the rows in the group.
					if (rowExistsInRowGroup[row]) {
						continue;
					}
					
					// Loop over all the columns in the match and eliminate pencils.
					for (NSInteger slotIndex = 0; slotIndex < size; ++slotIndex) {
						NSInteger col = slotsInRowGroup[slotIndex];
						
						if (_gameBoard.grid[row][col].pencils[guess]) {
							[_gameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:row col:col];
							++totalPencilsEliminated;
						}
					}
				}
			}
		} while ([self setNextCombinationInArray:currentRowIndexes ofLength:size totalItems:totalRowMatches]);
	}
	
	free(rowExistsInRowGroup);
	free(slotExistsInRowGroup);
	free(slotsInRowGroup);
	free(currentRowIndexes);
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsXWingColsOfSize:(NSInteger)size {
	NSInteger totalPencilsEliminated = 0;
	
	// Initialize the slot matches.
	ZSXWingSlotMatch *slotMatches = malloc(_gameBoard.size * sizeof(ZSXWingSlotMatch));
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		slotMatches[i].slotIndexes = malloc(size * sizeof(NSInteger));
	}
	
	// Init memory for use in the loop.
	NSInteger *currentColIndexes = malloc(_gameBoard.size * sizeof(NSInteger));
	NSInteger *slotsInColGroup = malloc(_gameBoard.size * sizeof(NSInteger));
	BOOL *slotExistsInColGroup = malloc(_gameBoard.size * sizeof(BOOL));
	BOOL *colExistsInColGroup = malloc(_gameBoard.size * sizeof(BOOL));
	
	for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
		// Keep track of how many cols have exactly two of the current pencil.
		NSInteger totalColMatches = 0;
		
		// Clear out the slot matches objects.
		for (NSInteger i = 0; i < _gameBoard.size; ++i) {
			slotMatches[i].totalSlotIndexes = 0;
		}
		
		// Find all the rows that contain 2 tiles with the current pencil mark and put them in a slot match object.
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			if (_gameBoard.totalTilesInColWithPencil[col][guess] >= 2 && _gameBoard.totalTilesInColWithPencil[col][guess] <= size) {
				// We have a row that fits. First, figure out which tiles contain the pencil.
				for (NSInteger j = 0; j < _gameBoard.size; ++j) {
					if (_gameBoard.cols[col][j]->pencils[guess]) {
						slotMatches[totalColMatches].slotIndexes[slotMatches[totalColMatches].totalSlotIndexes] = _gameBoard.cols[col][j]->row;
						++slotMatches[totalColMatches].totalSlotIndexes;
					}
				}
				
				// Note the current row.
				slotMatches[totalColMatches].matchIndex = col;
				
				++totalColMatches;
			}
		}
		
		// It takes at least two matching rows to form an X-Wing of any size.
		if (totalColMatches < size) {
			continue;
		}
		
		// Initialize the array of row combinations.
		[self setFirstCombinationInArray:currentColIndexes ofLength:size totalItems:totalColMatches];
		
		// Loop over all the possible combinations of row groups of the specified size.
		do {
			// Initialize the bool cache of slots for this match group.
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				slotExistsInColGroup[i] = NO;
			}
			
			// Mark all the rows that have slot matches.
			for (NSInteger i = 0; i < size; ++i) {
				for (NSInteger j = 0; j < slotMatches[currentColIndexes[i]].totalSlotIndexes; ++j) {
					slotExistsInColGroup[slotMatches[currentColIndexes[i]].slotIndexes[j]] = YES;
				}
			}
			
			// Count the total slots in this row group.
			NSInteger totalSlots = 0;
			
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				if (slotExistsInColGroup[i]) {
					slotsInColGroup[totalSlots] = i;
					++totalSlots;
				}
			}
			
			// If the number of slots in the group is equivalent to the group size, we have an X-Wing!
			if (totalSlots == size) {
				// Initialize the bool cache of rows in this row group.
				for (NSInteger i = 0; i < _gameBoard.size; ++i) {
					colExistsInColGroup[i] = NO;
				}
				
				// Mark all the rows in this row group.
				for (NSInteger i = 0; i < size; ++i) {
					colExistsInColGroup[slotMatches[currentColIndexes[i]].matchIndex] = YES;
				}
				
				// Finally, loop over all the rows and eliminate penils in each column.
				for (NSInteger col = 0; col < _gameBoard.size; ++col) {
					// Skip the rows in the group.
					if (colExistsInColGroup[col]) {
						continue;
					}
					
					// Loop over all the columns in the match and eliminate pencils.
					for (NSInteger slotIndex = 0; slotIndex < size; ++slotIndex) {
						NSInteger row = slotsInColGroup[slotIndex];
						
						if (_gameBoard.grid[row][col].pencils[guess]) {
							[_gameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:row col:col];
							++totalPencilsEliminated;
						}
					}
				}
			}
		} while ([self setNextCombinationInArray:currentColIndexes ofLength:size totalItems:totalColMatches]);
	}
	
	free(colExistsInColGroup);
	free(slotExistsInColGroup);
	free(slotsInColGroup);
	free(currentColIndexes);
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsFinnedXWingOfSize:(NSInteger)size {
	NSInteger pencilsEliminated = 0;
	
	pencilsEliminated += [self eliminatePencilsFinnedXWingRowsOfSize:size];
	pencilsEliminated += [self eliminatePencilsFinnedXWingColsOfSize:size];
	
	return pencilsEliminated;
}

- (NSInteger)eliminatePencilsFinnedXWingRowsOfSize:(NSInteger)size {
	NSInteger totalPencilsEliminated = 0;
	
	// Initialize the slot matches.
	ZSXWingSlotMatch *slotMatches = malloc(_gameBoard.size * sizeof(ZSXWingSlotMatch));
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		slotMatches[i].slotIndexes = malloc(_gameBoard.size * sizeof(NSInteger));
	}
	
	// Init memory for use in the loop.
	NSInteger *currentRowIndexes = malloc(_gameBoard.size * sizeof(NSInteger));
	NSInteger *slotsInRowGroup = malloc(_gameBoard.size * sizeof(NSInteger));
	BOOL *slotExistsInRowGroup = malloc(_gameBoard.size * sizeof(BOOL));
	BOOL *rowExistsInRowGroup = malloc(_gameBoard.size * sizeof(BOOL));
	
	for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
		// Keep track of how many rows have exactly two of the current pencil.
		NSInteger totalRowMatches = 0;
		
		// Clear out the slot matches objects.
		for (NSInteger i = 0; i < _gameBoard.size; ++i) {
			slotMatches[i].totalSlotIndexes = 0;
		}
		
		// Find all the rows that contain 2 tiles with the current pencil mark and put them in a slot match object.
		for (NSInteger row = 0; row < _gameBoard.size; ++row) {
			if (_gameBoard.totalTilesInRowWithPencil[row][guess] >= 2) {
				// We have a row that fits. First, figure out which tiles contain the pencil.
				for (NSInteger j = 0; j < _gameBoard.size; ++j) {
					if (_gameBoard.rows[row][j]->pencils[guess]) {
						slotMatches[totalRowMatches].slotIndexes[slotMatches[totalRowMatches].totalSlotIndexes] = _gameBoard.rows[row][j]->col;
						++slotMatches[totalRowMatches].totalSlotIndexes;
					}
				}
				
				// Note the current row.
				slotMatches[totalRowMatches].matchIndex = row;
				
				++totalRowMatches;
			}
		}
		
		// We need to start with at least (size - 1) rows.
		if (totalRowMatches < size - 1) {
			continue;
		}
		
		// Initialize the array of row combinations.
		[self setFirstCombinationInArray:currentRowIndexes ofLength:(size - 1) totalItems:totalRowMatches];
		
		// Loop over all the possible combinations of row groups of the specified size.
		do {
			// Make sure each of the chosen rows contains <= size matches.
			BOOL chosenRowsAreAdequateSize = YES;
			
			for (NSInteger i = 0; i < (size - 1); ++i) {
				if (slotMatches[currentRowIndexes[i]].totalSlotIndexes > size) {
					chosenRowsAreAdequateSize = NO;
				}
			}
			
			if (!chosenRowsAreAdequateSize) {
				continue;
			}
			
			// Initialize the bool cache of slots for this match group.
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				slotExistsInRowGroup[i] = NO;
			}
			
			// Mark all the columns that have slot matches.
			for (NSInteger i = 0; i < (size - 1); ++i) {
				for (NSInteger j = 0; j < slotMatches[currentRowIndexes[i]].totalSlotIndexes; ++j) {
					slotExistsInRowGroup[slotMatches[currentRowIndexes[i]].slotIndexes[j]] = YES;
				}
			}
			
			// Count the total slots in this row group.
			NSInteger totalSlots = 0;
			
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				if (slotExistsInRowGroup[i]) {
					slotsInRowGroup[totalSlots] = i;
					++totalSlots;
				}
			}
			
			// If the total number of slots is > size, the chosen rows do not make up a partial group.
			if (totalSlots > size) {
				continue;
			}
			
			// The chosen rows form a partial X-Wing group. Loop over the remaining rows and check if any of them can function as the fin.
			for (NSInteger rowMatchIndex = 0; rowMatchIndex < totalRowMatches; ++rowMatchIndex) {
				// Make sure the current row isn't already part of the partial group.
				BOOL currentRowMatchIsPartOfPartialGroup = NO;
				
				for (NSInteger i = 0; i < (size - 1); ++i) {
					if (currentRowIndexes[i] == rowMatchIndex) {
						currentRowMatchIsPartOfPartialGroup = YES;
						break;
					}
				}
				
				if (currentRowMatchIsPartOfPartialGroup) {
					continue;
				}
				
				// Cache the row number of the potential final row in the partial X-Wing group.
				NSInteger row = slotMatches[rowMatchIndex].matchIndex;
				
				// The current rowMatchIndex is valid so far. Check to see how many slots it satisfies.
				NSInteger totalDeviantPencilGroups = 0;
				NSInteger firstDeviantPencilGroupId = 0;
				
				for (NSInteger col = 0; col < _gameBoard.size; ++col) {
					if (_gameBoard.grid[row][col].pencils[guess] && !slotExistsInRowGroup[col]) {
						NSInteger groupIdOfCurrentCol = _gameBoard.grid[row][col].groupId;
						
						if (totalDeviantPencilGroups) {
							if (groupIdOfCurrentCol != firstDeviantPencilGroupId) {
								++totalDeviantPencilGroups;
							}
						} else {
							firstDeviantPencilGroupId = groupIdOfCurrentCol;
							++totalDeviantPencilGroups;
						}
					}
					
					if (totalDeviantPencilGroups > 1) {
						break;
					}
				}
				
				// If all the deviant pencil groups belong to the same group, we found our fin!
				if (totalDeviantPencilGroups == 1) {
					// For all tiles that intersect the deviant group and any columns in the slot matches, eliminate the current pencil.
					for (NSInteger i = 0; i < _gameBoard.size; ++i) {
						for (NSInteger j = 0; j < size; ++j) {
							NSInteger col = slotsInRowGroup[j];
							
							// If the current tile is not in a slot column, skip it.
							if (_gameBoard.groups[firstDeviantPencilGroupId][i]->col != col) {
								continue;
							}
							
							// Make sure we're not eliminating tiles from the final row of the X-Wing group.
							if (_gameBoard.groups[firstDeviantPencilGroupId][i]->row == row) {
								continue;
							}
							
							// Make sure we're not eliminating tiles from any of the other rows in the X-Wing group.
							BOOL currentTileRowExistsInXWingRowGroup = NO;
							
							for (NSInteger k = 0; k < (size - 1); ++k) {
								if (_gameBoard.groups[firstDeviantPencilGroupId][i]->row == slotMatches[currentRowIndexes[k]].matchIndex) {
									currentTileRowExistsInXWingRowGroup = YES;
								}
							}
							
							if (currentTileRowExistsInXWingRowGroup) {
								continue;
							}
							
							// Assuming we've found a tile that 
							if (_gameBoard.groups[firstDeviantPencilGroupId][i]->pencils[guess]) {
								[_gameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:_gameBoard.groups[firstDeviantPencilGroupId][i]->row col:col];
								++totalPencilsEliminated;
							}
						}
					}
				}
			}
		} while ([self setNextCombinationInArray:currentRowIndexes ofLength:(size - 1) totalItems:totalRowMatches]);
	}
	
	free(rowExistsInRowGroup);
	free(slotExistsInRowGroup);
	free(slotsInRowGroup);
	free(currentRowIndexes);
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsFinnedXWingColsOfSize:(NSInteger)size {
	NSInteger totalPencilsEliminated = 0;
	
	// Initialize the slot matches.
	ZSXWingSlotMatch *slotMatches = malloc(_gameBoard.size * sizeof(ZSXWingSlotMatch));
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		slotMatches[i].slotIndexes = malloc(_gameBoard.size * sizeof(NSInteger));
	}
	
	// Init memory for use in the loop.
	NSInteger *currentColIndexes = malloc(_gameBoard.size * sizeof(NSInteger));
	NSInteger *slotsInColGroup = malloc(_gameBoard.size * sizeof(NSInteger));
	BOOL *slotExistsInColGroup = malloc(_gameBoard.size * sizeof(BOOL));
	BOOL *colExistsInColGroup = malloc(_gameBoard.size * sizeof(BOOL));
	
	for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
		// Keep track of how many cols have exactly two of the current pencil.
		NSInteger totalColMatches = 0;
		
		// Clear out the slot matches objects.
		for (NSInteger i = 0; i < _gameBoard.size; ++i) {
			slotMatches[i].totalSlotIndexes = 0;
		}
		
		// Find all the cols that contain 2 tiles with the current pencil mark and put them in a slot match object.
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			if (_gameBoard.totalTilesInColWithPencil[col][guess] >= 2) {
				// We have a col that fits. First, figure out which tiles contain the pencil.
				for (NSInteger j = 0; j < _gameBoard.size; ++j) {
					if (_gameBoard.cols[col][j]->pencils[guess]) {
						slotMatches[totalColMatches].slotIndexes[slotMatches[totalColMatches].totalSlotIndexes] = _gameBoard.cols[col][j]->row;
						++slotMatches[totalColMatches].totalSlotIndexes;
					}
				}
				
				// Note the current col.
				slotMatches[totalColMatches].matchIndex = col;
				
				++totalColMatches;
			}
		}
		
		// We need to start with at least (size - 1) cols.
		if (totalColMatches < size - 1) {
			continue;
		}
		
		// Initialize the array of col combinations.
		[self setFirstCombinationInArray:currentColIndexes ofLength:(size - 1) totalItems:totalColMatches];
		
		// Loop over all the possible combinations of col groups of the specified size.
		do {
			// Make sure each of the chosen cols contains <= size matches.
			BOOL chosenColsAreAdequateSize = YES;
			
			for (NSInteger i = 0; i < (size - 1); ++i) {
				if (slotMatches[currentColIndexes[i]].totalSlotIndexes > size) {
					chosenColsAreAdequateSize = NO;
				}
			}
			
			if (!chosenColsAreAdequateSize) {
				continue;
			}
			
			// Initialize the bool cache of slots for this match group.
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				slotExistsInColGroup[i] = NO;
			}
			
			// Mark all the rows that have slot matches.
			for (NSInteger i = 0; i < (size - 1); ++i) {
				for (NSInteger j = 0; j < slotMatches[currentColIndexes[i]].totalSlotIndexes; ++j) {
					slotExistsInColGroup[slotMatches[currentColIndexes[i]].slotIndexes[j]] = YES;
				}
			}
			
			// Count the total slots in this col group.
			NSInteger totalSlots = 0;
			
			for (NSInteger i = 0; i < _gameBoard.size; ++i) {
				if (slotExistsInColGroup[i]) {
					slotsInColGroup[totalSlots] = i;
					++totalSlots;
				}
			}
			
			// If the total number of slots is > size, the chosen cols do not make up a partial group.
			if (totalSlots > size) {
				continue;
			}
			
			// The chosen cols form a partial X-Wing group. Loop over the remaining cols and check if any of them can function as the fin.
			for (NSInteger colMatchIndex = 0; colMatchIndex < totalColMatches; ++colMatchIndex) {
				// Make sure the current col isn't already part of the partial group.
				BOOL currentColMatchIsPartOfPartialGroup = NO;
				
				for (NSInteger i = 0; i < (size - 1); ++i) {
					if (currentColIndexes[i] == colMatchIndex) {
						currentColMatchIsPartOfPartialGroup = YES;
						break;
					}
				}
				
				if (currentColMatchIsPartOfPartialGroup) {
					continue;
				}
				
				// Cache the col number of the potential final col in the partial X-Wing group.
				NSInteger col = slotMatches[colMatchIndex].matchIndex;
				
				// The current colMatchIndex is valid so far. Check to see how many slots it satisfies.
				NSInteger totalDeviantPencilGroups = 0;
				NSInteger firstDeviantPencilGroupId = 0;
				
				for (NSInteger row = 0; row < _gameBoard.size; ++row) {
					if (_gameBoard.grid[row][col].pencils[guess] && !slotExistsInColGroup[row]) {
						NSInteger groupIdOfCurrentRow = _gameBoard.grid[row][col].groupId;
						
						if (totalDeviantPencilGroups) {
							if (groupIdOfCurrentRow != firstDeviantPencilGroupId) {
								++totalDeviantPencilGroups;
							}
						} else {
							firstDeviantPencilGroupId = groupIdOfCurrentRow;
							++totalDeviantPencilGroups;
						}
					}
					
					if (totalDeviantPencilGroups > 1) {
						break;
					}
				}
				
				// If all the deviant pencil groups belong to the same group, we found our fin!
				if (totalDeviantPencilGroups == 1) {
					// For all tiles that intersect the deviant group and any rows in the slot matches, eliminate the current pencil.
					for (NSInteger i = 0; i < _gameBoard.size; ++i) {
						for (NSInteger j = 0; j < size; ++j) {
							NSInteger row = slotsInColGroup[j];
							
							// If the current tile is not in a slot row, skip it.
							if (_gameBoard.groups[firstDeviantPencilGroupId][i]->row != row) {
								continue;
							}
							
							// Make sure we're not eliminating tiles from the final col of the X-Wing group.
							if (_gameBoard.groups[firstDeviantPencilGroupId][i]->col == col) {
								continue;
							}
							
							// Make sure we're not eliminating tiles from any of the other cols in the X-Wing group.
							BOOL currentTileColExistsInXWingColGroup = NO;
							
							for (NSInteger k = 0; k < (size - 1); ++k) {
								if (_gameBoard.groups[firstDeviantPencilGroupId][i]->col == slotMatches[currentColIndexes[k]].matchIndex) {
									currentTileColExistsInXWingColGroup = YES;
								}
							}
							
							if (currentTileColExistsInXWingColGroup) {
								continue;
							}
							
							// Assuming we've found a tile that 
							if (_gameBoard.groups[firstDeviantPencilGroupId][i]->pencils[guess]) {
								[_gameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:row col:_gameBoard.groups[firstDeviantPencilGroupId][i]->col];
								++totalPencilsEliminated;
							}
						}
					}
				}
			}
		} while ([self setNextCombinationInArray:currentColIndexes ofLength:(size - 1) totalItems:totalColMatches]);
	}
	
	free(colExistsInColGroup);
	free(slotExistsInColGroup);
	free(slotsInColGroup);
	free(currentColIndexes);
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsYWingUseChains:(BOOL)useChains {
	NSInteger totalPencilsEliminated = 0;
	
	ZSGameTileList tileList;

	tileList.tiles = malloc(_gameBoard.size * _gameBoard.size * sizeof(ZSGameTileStub *));
	tileList.totalTiles = 0;
	
	// Make a list of all the tiles that have 2 pencils.
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			if (_gameBoard.grid[row][col].totalPencils == 2) {
				tileList.tiles[tileList.totalTiles] = &_gameBoard.grid[row][col];
				++tileList.totalTiles;
			}
		}
	}
	
	// If there aren't 3 or more tiles, there can't be a Y-Wing.
	if (tileList.totalTiles < 3) {
		return 0;
	}
	
	NSInteger *yWingGroupIndexes = malloc(3 * sizeof(NSInteger));
	BOOL *pencilMap = malloc(_gameBoard.size * sizeof(BOOL));
	
	// Initialize the array of row combinations.
	[self setFirstCombinationInArray:yWingGroupIndexes ofLength:3 totalItems:tileList.totalTiles];
	
	// Loop over all the possible combinations of 2-pencil tiles.
	do {
		ZSGameTileStub *tile1 = tileList.tiles[yWingGroupIndexes[0]];
		ZSGameTileStub *tile2 = tileList.tiles[yWingGroupIndexes[1]];
		ZSGameTileStub *tile3 = tileList.tiles[yWingGroupIndexes[2]];
		
		// It's possible that we've eliminated pencils by the time we've gotten here. Make sure all 3 candidates still have 2 pencils each.
		if (tile1->totalPencils != 2 || tile2->totalPencils != 2 || tile3->totalPencils != 2) {
			continue;
		}
		
		// Check which tiles influence each other. This will help determine which (if any) is the pivot.
		NSInteger tile1Influences = 0;
		NSInteger tile2Influences = 0;
		NSInteger tile3Influences = 0;
		
		if (useChains) {
			[self updateChainMapForTile:tile1];
			
			if (_chainMap[tile2->row][tile2->col] == ZSChainMapResultRelatedOff && _chainMap[tile3->row][tile3->col] == ZSChainMapResultRelatedOff) {
				tile1Influences = 2;
				tile2Influences = tile2Influences == 0 ? 1 : 2;
				tile3Influences = tile3Influences == 0 ? 1 : 2;
			}
			
			[self updateChainMapForTile:tile2];
			
			if (_chainMap[tile1->row][tile1->col] == ZSChainMapResultRelatedOff && _chainMap[tile3->row][tile3->col] == ZSChainMapResultRelatedOff) {
				tile1Influences = tile1Influences == 0 ? 1 : 2;
				tile2Influences = 2;
				tile3Influences = tile3Influences == 0 ? 1 : 2;
			}
			
			[self updateChainMapForTile:tile3];
			
			if (_chainMap[tile1->row][tile1->col] == ZSChainMapResultRelatedOff && _chainMap[tile2->row][tile2->col] == ZSChainMapResultRelatedOff) {
				tile1Influences = tile1Influences == 0 ? 1 : 2;
				tile2Influences = tile2Influences == 0 ? 1 : 2;
				tile3Influences = 2;
			}
		} else {
			if ([_gameBoard tile:tile1 influencesTile:tile2]) {
				++tile1Influences;
				++tile2Influences;
			}
			
			if ([_gameBoard tile:tile1 influencesTile:tile3]) {
				++tile1Influences;
				++tile3Influences;
			}
			
			if ([_gameBoard tile:tile2 influencesTile:tile3]) {
				++tile2Influences;
				++tile3Influences;
			}
		}
		
		// If any of the tiles are stranded, we can continue.
		if (tile1Influences == 0 || tile2Influences == 0 || tile3Influences == 0) {
			continue;
		}
		
		// There needs to be at least one pivot.
		if (tile1Influences != 2 && tile2Influences != 2 && tile3Influences != 2) {
			continue;
		}
		
		// Map the pencils in all the tiles.
		for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
			pencilMap[guess] = (tile1->pencils[guess] || tile2->pencils[guess] || tile3->pencils[guess]);
		}
		
		// Count the pencils in all the tiles.
		NSInteger totalPencilsInGroup = 0;
		
		for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
			if (pencilMap[guess]) {
				++totalPencilsInGroup;
			}
		}
		
		if (totalPencilsInGroup != 3) {
			continue;
		}
		
		// Make sure all 3 tiles have different pencil marks (AB, AC, and BC).
		BOOL tile1SameAsTile2 = YES;
		BOOL tile1SameAsTile3 = YES;
		BOOL tile2SameAsTile3 = YES;
		
		for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
			if (tile1->pencils[guess] && !tile2->pencils[guess]) {
				tile1SameAsTile2 = NO;
			}
			
			if (tile1->pencils[guess] && !tile3->pencils[guess]) {
				tile1SameAsTile3 = NO;
			}
			
			if (tile2->pencils[guess] && !tile3->pencils[guess]) {
				tile2SameAsTile3 = NO;
			}
		}
		
		if (tile1SameAsTile2 || tile1SameAsTile3 || tile2SameAsTile3) {
			continue;
		}
		
		// We have a proper Y-Wing group! For each proper pivot, eliminate pencil marks.
		if (tile1Influences == 2) {
			totalPencilsEliminated += [self eliminatePencilsYWingWithTile1:tile2 tile2:tile3];
		}
		
		if (tile2Influences == 2) {
			totalPencilsEliminated += [self eliminatePencilsYWingWithTile1:tile1 tile2:tile3];
		}
		
		if (tile3Influences == 2) {
			totalPencilsEliminated += [self eliminatePencilsYWingWithTile1:tile1 tile2:tile2];
		}
	} while ([self setNextCombinationInArray:yWingGroupIndexes ofLength:3 totalItems:tileList.totalTiles]);
	
	free(pencilMap);
	free(tileList.tiles);
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsYWingWithTile1:(ZSGameTileStub *)tile1 tile2:(ZSGameTileStub *)tile2 {
	NSInteger totalPencilsEliminated = 0;
	
	// It's possible that we've eliminated pencils by the time we've gotten here. Make sure all 3 candidates still have 2 pencils each.
	if (tile1->totalPencils != 2 || tile2->totalPencils != 2) {
		return 0;
	}
	
	// Figure out which pencil we're eliminating.
	NSInteger commonPencil = 0;
	
	for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
		if (tile1->pencils[guess] && tile2->pencils[guess]) {
			commonPencil = guess;
			break;
		}
	}
	
	// Loop over all of the tiles influenced by both and search for instances of those pencils.
	ZSGameTileList tileList = [_gameBoard getAllInfluencedTilesForTile:tile1 andOtherTile:tile2];
	
	for (NSInteger i = 0; i < tileList.totalTiles; ++i) {
		if (tileList.tiles[i] == tile1 || tileList.tiles[i] == tile2) {
			continue;
		}
		
		if (tileList.tiles[i]->pencils[commonPencil]) {
			[_gameBoard setPencil:NO forPencilNumber:(commonPencil + 1) forTileAtRow:tileList.tiles[i]->row col:tileList.tiles[i]->col];
			++totalPencilsEliminated;
		}
	}
	
	free(tileList.tiles);
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsRemotePairs {
	NSInteger totalPencilsEliminated = 0;
	
	BOOL **investigatedTiles = malloc(_gameBoard.size * sizeof(BOOL *));
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		investigatedTiles[i] = malloc(_gameBoard.size * sizeof(BOOL));
		
		for (NSInteger j = 0; j < _gameBoard.size; ++j) {
			investigatedTiles[i][j] = NO;
		}
	}
	
	// Find all the cols that contain 2 tiles with the current pencil mark and put them in a slot match object.
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			ZSGameTileStub *currentTile = &_gameBoard.grid[row][col];
			
			if (investigatedTiles[row][col]) {
				continue;
			}
			
			investigatedTiles[row][col] = YES;
			
			if (currentTile->totalPencils == 2) {
				NSInteger firstPencil = 0;
				NSInteger secondPencil = 0;
				NSInteger pencilsIdentified = 0;
				
				for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
					if (currentTile->pencils[guess]) {
						if (pencilsIdentified) {
							secondPencil = guess;
						} else {
							firstPencil = guess;
						}
						
						++pencilsIdentified;
					}
				}
				
				[self updateChainMapForTile:currentTile];
				
				for (NSInteger chainMapRow = 0; chainMapRow < _gameBoard.size; ++chainMapRow) {
					for (NSInteger chainMapCol = 0; chainMapCol < _gameBoard.size; ++chainMapCol) {
						ZSGameTileStub *targetTile = &_gameBoard.grid[chainMapRow][chainMapCol];
						
						switch (_chainMap[chainMapRow][chainMapCol]) {
							case ZSChainMapResultRelatedConflicted:
								
								if (targetTile->pencils[firstPencil]) {
									[_gameBoard setPencil:NO forPencilNumber:(firstPencil + 1) forTileAtRow:targetTile->row col:targetTile->col];
									++totalPencilsEliminated;
								}
								
								if (targetTile->pencils[secondPencil]) {
									[_gameBoard setPencil:NO forPencilNumber:(secondPencil + 1) forTileAtRow:targetTile->row col:targetTile->col];
									++totalPencilsEliminated;
								}
								
								break;
								
							case ZSChainMapResultLinkedOn:
							case ZSChainMapResultLinkedOff:
								investigatedTiles[row][col] = YES;
								break;
								
							default:
								break;
						}
					}
				}
			}
		}
	}
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		free(investigatedTiles[i]);
	}
	
	free(investigatedTiles);
	
	return totalPencilsEliminated;
}

- (NSInteger)eliminatePencilsAvoidableRectangles {
	NSInteger totalPencilsEliminated = 0;
	
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			ZSGameTileStub *currentTile = &_gameBoard.grid[row][col];
			
			if (currentTile->guess && !_clueIsProvidedInPuzzle[row][col]) {
				for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
					if (currentTile->guess == (guess + 1)) {
						continue;
					}
					
					if (_gameBoard.totalTilesInRowWithAnswer[row][guess] == 1 && _gameBoard.totalTilesInColWithAnswer[col][guess] == 1) {
						NSInteger otherRowIndex = 0;
						NSInteger otherColIndex = 0;
						
						for (otherColIndex = 0; otherColIndex < _gameBoard.size; ++otherColIndex) {
							if (_gameBoard.grid[row][otherColIndex].guess == (guess + 1)) {
								break;
							}
						}
						
						for (otherRowIndex = 0; otherRowIndex < _gameBoard.size; ++otherRowIndex) {
							if (_gameBoard.grid[otherRowIndex][col].guess == (guess + 1)) {
								break;
							}
						}
						
						if (_clueIsProvidedInPuzzle[row][otherColIndex] || _clueIsProvidedInPuzzle[otherRowIndex][col]) {
							continue;
						}
						
						NSInteger rectangleCornersInTargetTilesGroup = 0;
						
						if (_gameBoard.grid[row][otherColIndex].groupId == currentTile->groupId) {
							++rectangleCornersInTargetTilesGroup;
						}
						
						if (_gameBoard.grid[otherRowIndex][col].groupId == currentTile->groupId) {
							++rectangleCornersInTargetTilesGroup;
						}
						
						if (rectangleCornersInTargetTilesGroup != 1) {
							continue;
						}
						
						if (_gameBoard.grid[otherRowIndex][otherColIndex].pencils[(currentTile->guess - 1)]) {
							[_gameBoard setPencil:NO forPencilNumber:currentTile->guess forTileAtRow:otherRowIndex col:otherColIndex];
							++totalPencilsEliminated;
						}
						
						if (_gameBoard.grid[otherRowIndex][otherColIndex].pencils[guess]) {
							[_gameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:otherRowIndex col:otherColIndex];
							++totalPencilsEliminated;
						}
					}
				}
			}
		}
	}
	
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
- (void)setFirstCombinationInArray:(NSInteger *)comboArray ofLength:(NSInteger)arrayLength totalItems:(NSInteger)itemCount {
	// Make sure we have enough unique items to fill the array.
	assert(arrayLength <= itemCount);
	
	for (NSInteger i = 0; i < arrayLength; i++) {
		comboArray[i] = i;
	}
}

// Provides the next the next combination in the sequence. Returns false if there are no more combinations.
- (BOOL)setNextCombinationInArray:(NSInteger *)comboArray ofLength:(NSInteger)arrayLength totalItems:(NSInteger)itemCount {
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

#pragma mark - Clue Mask Handlers

- (void)initClueMask {
	_clueIsProvidedInPuzzle = malloc(_gameBoard.size * sizeof(BOOL *));
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		_clueIsProvidedInPuzzle[i] = malloc(_gameBoard.size * sizeof(BOOL));
	}
}

- (void)deallocClueMask {
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		free(_clueIsProvidedInPuzzle[i]);
	}
	
	free(_clueIsProvidedInPuzzle);
}

- (void)clearClueMask {
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			_clueIsProvidedInPuzzle[row][col] = NO;
		}
	}
}

- (void)copyClueMaskFromGameBoard {
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			_clueIsProvidedInPuzzle[row][col] = (_gameBoard.grid[row][col].guess) == 0 ? NO : YES;
		}
	}
}

- (void)copyClueMaskFromString:(NSString *)guessesString {
	NSInteger currentRow = 0;
	NSInteger currentCol = 0;
	
	for (NSInteger i = 0, l = guessesString.length; i < l; ++i) {
		unichar currentChar = [guessesString characterAtIndex:i];
		
		switch (currentChar) {
			case '.':
			case '0':
				_clueIsProvidedInPuzzle[currentRow][currentCol] = NO;
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
				_clueIsProvidedInPuzzle[currentRow][currentCol] = YES;
				break;
				
			default:
				continue;
		}
		
		if (++currentCol >= _gameBoard.size) {
			currentCol -= _gameBoard.size;
			++currentRow;
		}
		
		if (currentRow == _gameBoard.size) {
			break;
		}
	}
}

- (void)setClueProvidedInPuzzle:(BOOL)clueProvidedInPuzzle forRow:(NSInteger)row col:(NSInteger)col {
	_clueIsProvidedInPuzzle[row][col] = clueProvidedInPuzzle;
}

#pragma mark - Chain Map Handlers

- (void)initChainMap {
	_chainPencils = malloc(_gameBoard.size * sizeof(NSInteger));
	
	_chainMap = malloc(_gameBoard.size * sizeof(ZSChainMapResult *));
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		_chainMap[i] = malloc(_gameBoard.size * sizeof(ZSChainMapResult));
	}
}

- (void)deallocChainMap {
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		free(_chainMap[i]);
	}
	
	free(_chainMap);
	
	free(_chainPencils);
}

- (void)clearChainMap {
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			_chainMap[row][col] = ZSChainMapResultUnset;
		}
	}
	
	_chainMapIsClear = YES;
}

- (void)updateChainMapForTile:(ZSGameTileStub *)tile {
	if (!_chainMapIsClear) {
		[self clearChainMap];
	}
	
	NSInteger totalPencils = 0;
	
	for (NSInteger guess = 0; guess < _gameBoard.size; ++guess) {
		if (tile->pencils[guess]) {
			_chainPencils[totalPencils] = guess;
			++totalPencils;
		}
	}
	
	_chainMap[tile->row][tile->col] = ZSChainMapResultLinkedOn;
	
	[self updateChainMapForTile:tile totalPencils:totalPencils currentLinkOn:YES];
	
	_chainMapIsClear = NO;
}

- (void)updateChainMapForTile:(ZSGameTileStub *)tile totalPencils:(NSInteger)totalPencils currentLinkOn:(BOOL)currentLinkOn {
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		ZSGameTileStub *currentTile = _gameBoard.rows[tile->row][i];
		
		if (currentTile == tile) {
			continue;
		}
		
		if (currentTile->guess) {
			continue;
		}
		
		BOOL allMatchingPencils = YES;
		BOOL anyMatchingPencils = NO;
		
		for (NSInteger pencilIndex = 0; pencilIndex < totalPencils; ++pencilIndex) {
			if (currentTile->pencils[_chainPencils[pencilIndex]]) {
				anyMatchingPencils = YES;
			} else {
				allMatchingPencils = NO;
			}
		}
		
		if (currentTile->totalPencils != totalPencils) {
			allMatchingPencils = NO;
		}
		
		if (allMatchingPencils) {
			if (_chainMap[currentTile->row][currentTile->col] == ZSChainMapResultUnset) {
				_chainMap[currentTile->row][currentTile->col] = currentLinkOn ? ZSChainMapResultLinkedOff : ZSChainMapResultLinkedOn;
				[self updateChainMapForTile:currentTile totalPencils:totalPencils currentLinkOn:!currentLinkOn];
			} else if (_chainMap[currentTile->row][currentTile->col] == (currentLinkOn ? ZSChainMapResultLinkedOn : ZSChainMapResultLinkedOff)) {
				_chainMap[currentTile->row][currentTile->col] = ZSChainMapResultLinkedConflicted;
			}
		} else if (anyMatchingPencils) {
			if (_chainMap[currentTile->row][currentTile->col] == ZSChainMapResultUnset) {
				_chainMap[currentTile->row][currentTile->col] = currentLinkOn ? ZSChainMapResultRelatedOff : ZSChainMapResultRelatedOn;
			} else if (_chainMap[currentTile->row][currentTile->col] == (currentLinkOn ? ZSChainMapResultRelatedOn : ZSChainMapResultRelatedOff)) {
				_chainMap[currentTile->row][currentTile->col] = ZSChainMapResultRelatedConflicted;
			}
		} else {
			if (_chainMap[currentTile->row][currentTile->col] == ZSChainMapResultUnset) {
				_chainMap[currentTile->row][currentTile->col] = ZSChainMapResultUnrelated;
			}
		}
	}
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		ZSGameTileStub *currentTile = _gameBoard.cols[tile->col][i];
		
		if (currentTile->guess) {
			continue;
		}
		
		if (_chainMap[currentTile->row][currentTile->col] != ZSChainMapResultUnset) {
			continue;
		}
		
		BOOL allMatchingPencils = YES;
		BOOL anyMatchingPencils = NO;
		
		for (NSInteger pencilIndex = 0; pencilIndex < totalPencils; ++pencilIndex) {
			if (currentTile->pencils[_chainPencils[pencilIndex]]) {
				anyMatchingPencils = YES;
			} else {
				allMatchingPencils = NO;
			}
		}
		
		if (currentTile->totalPencils != totalPencils) {
			allMatchingPencils = NO;
		}
		
		if (allMatchingPencils) {
			_chainMap[currentTile->row][currentTile->col] = currentLinkOn ? ZSChainMapResultLinkedOff : ZSChainMapResultLinkedOn;
			[self updateChainMapForTile:currentTile totalPencils:totalPencils currentLinkOn:!currentLinkOn];
		} else if (anyMatchingPencils) {
			_chainMap[currentTile->row][currentTile->col] = currentLinkOn ? ZSChainMapResultRelatedOff : ZSChainMapResultRelatedOn;
		} else {
			_chainMap[currentTile->row][currentTile->col] = ZSChainMapResultUnrelated;
		}
	}
	
	NSInteger groupId = _gameBoard.grid[tile->row][tile->col].groupId;
	
	for (NSInteger i = 0; i < _gameBoard.size; ++i) {
		ZSGameTileStub *currentTile = _gameBoard.groups[groupId][i];
		
		if (currentTile->guess) {
			continue;
		}
		
		if (_chainMap[currentTile->row][currentTile->col] != ZSChainMapResultUnset) {
			continue;
		}
		
		BOOL allMatchingPencils = YES;
		BOOL anyMatchingPencils = NO;
		
		for (NSInteger pencilIndex = 0; pencilIndex < totalPencils; ++pencilIndex) {
			if (currentTile->pencils[_chainPencils[pencilIndex]]) {
				anyMatchingPencils = YES;
			} else {
				allMatchingPencils = NO;
			}
		}
		
		if (currentTile->totalPencils != totalPencils) {
			allMatchingPencils = NO;
		}
		
		if (allMatchingPencils) {
			_chainMap[currentTile->row][currentTile->col] = currentLinkOn ? ZSChainMapResultLinkedOff : ZSChainMapResultLinkedOn;
			[self updateChainMapForTile:currentTile totalPencils:totalPencils currentLinkOn:!currentLinkOn];
		} else if (anyMatchingPencils) {
			_chainMap[currentTile->row][currentTile->col] = currentLinkOn ? ZSChainMapResultRelatedOff : ZSChainMapResultRelatedOn;
		} else {
			_chainMap[currentTile->row][currentTile->col] = ZSChainMapResultUnrelated;
		}
	}
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
