//
//  ZSHintGenerator.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSHintGenerator.h"

#import "ZSFastGameBoard.h"
#import "ZSGame.h"

#import "ZSHintGeneratorFixIncorrectGuess.h"
#import "ZSHintGeneratorFixMissingPencil.h"
#import "ZSHintGeneratorNoHint.h"
#import "ZSHintGeneratorSolveOnlyChoice.h"
#import "ZSHintGeneratorSolveSinglePossibility.h"


@interface ZSHintGenerator () {
	
@private
	ZSFastGameBoard *_fastGameBoard;
	ZSFastGameBoard *_scratchBoard;
	
	BOOL **_clueIsProvidedInPuzzle;
	
	BOOL _chainMapIsClear;
	ZSChainMapResult **_chainMap;
	NSInteger *_chainPencils;
}

// Logic Techniques
- (NSArray *)fixIncorrectGuesses;

- (NSArray *)solveOnlyChoice;
- (NSArray *)solveSinglePossibility;

- (NSArray *)fixMissingPencils;
 
/*
- (NSArray *)eliminatePencilsHiddenSubgroupForSize:(NSInteger)size;
- (NSArray *)eliminatePencilsNakedSubgroupForSize:(NSInteger)size;
- (NSArray *)eliminatePencilsPointingPairs;
- (NSArray *)eliminatePencilsBoxLineReduction;
- (NSArray *)eliminatePencilsXWingOfSize:(NSInteger)size;
- (NSArray *)eliminatePencilsXWingRowsOfSize:(NSInteger)size;
- (NSArray *)eliminatePencilsXWingColsOfSize:(NSInteger)size;
- (NSArray *)eliminatePencilsFinnedXWingOfSize:(NSInteger)size;
- (NSArray *)eliminatePencilsFinnedXWingRowsOfSize:(NSInteger)size;
- (NSArray *)eliminatePencilsFinnedXWingColsOfSize:(NSInteger)size;
- (NSArray *)eliminatePencilsYWingUseChains:(BOOL)useChains;
- (NSArray *)eliminatePencilsYWingWithTile1:(ZSGameTileStub *)tile1 tile2:(ZSGameTileStub *)tile2;
- (NSArray *)eliminatePencilsRemotePairs;
- (NSArray *)eliminatePencilsAvoidableRectangles;
*/

// Logic Technique Helpers
- (NSInteger)initPencilMap:(NSInteger *)pencilMap forTileSet:(ZSGameTileStub **)set;
- (void)setFirstCombinationInArray:(NSInteger *)comboArray ofLength:(NSInteger)arrayLength totalItems:(NSInteger)itemCount;
- (BOOL)setNextCombinationInArray:(NSInteger *)comboArray ofLength:(NSInteger)arrayLength totalItems:(NSInteger)itemCount;

// Clue Mask Handlers
- (void)initClueMask;
- (void)deallocClueMask;
- (void)clearClueMask;
- (void)copyClueMaskFromGameBoard;
- (void)copyClueMaskFromString:(NSString *)guessesString;
- (void)setClueProvidedInPuzzle:(BOOL)clueProvidedInPuzzle forRow:(NSInteger)row col:(NSInteger)col;

// Chain Map Handlers
- (void)initChainMap;
- (void)deallocChainMap;
- (void)clearChainMap;
- (void)updateChainMapForTile:(ZSGameTileStub *)tile;
- (void)updateChainMapForTile:(ZSGameTileStub *)tile totalPencils:(NSInteger)totalPencils currentLinkOn:(BOOL)currentLinkOn;

@end

@implementation ZSHintGenerator

#pragma mark - Object Lifecycle

- (id)init {
	return [self initWithSize:9];
}

- (id)initWithSize:(NSInteger)size {
	self = [super init];
	
	if (self) {
		// Create some game boards to store the answers.
		_fastGameBoard = [[ZSFastGameBoard alloc] initWithSize:size];
		_scratchBoard = [[ZSFastGameBoard alloc] initWithSize:size];
		
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

- (void)copyGameStateFromGameBoard:(ZSGameBoard *)gameBoard {
	[_fastGameBoard copyGroupMapFromGameBoard:gameBoard];
	[_fastGameBoard copyGuessesFromGameBoard:gameBoard];
	[_fastGameBoard copyAnswersFromGameBoard:gameBoard];
	[_fastGameBoard copyPencilsFromGameBoard:gameBoard];
	
	[_scratchBoard copyGroupMapFromGameBoard:gameBoard];
	[_scratchBoard copyGuessesFromGameBoard:gameBoard];
	[_scratchBoard copyAnswersFromGameBoard:gameBoard];
	[_scratchBoard addAutoPencils];
}

#pragma mark - Solving

- (NSArray *)generateHint {
	NSArray *hintCards = nil;
	
	// Fix Incorrect Guesses
	if ((hintCards = [self fixIncorrectGuesses])) {
		return hintCards;
	}
	
	// Only Choice
	if ((hintCards = [self solveOnlyChoice])) {
		return hintCards;
	}

	// Single Possibility
	if ((hintCards = [self solveSinglePossibility])) {
		return hintCards;
	}
	
	// Fix Missing Pencils
	if ((hintCards = [self fixMissingPencils])) {
		return hintCards;
	}
	
	/*
	// Naked Pairs
	hintCards = [self eliminatePencilsNakedSubgroupForSize:2];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Hidden Pairs
	hintCards = [self eliminatePencilsHiddenSubgroupForSize:2];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Pointing Pairs
	hintCards = [self eliminatePencilsPointingPairs];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Box Line Reduction
	hintCards = [self eliminatePencilsBoxLineReduction];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Naked Triplets
	hintCards = [self eliminatePencilsNakedSubgroupForSize:3];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Hidden Triplets
	hintCards = [self eliminatePencilsHiddenSubgroupForSize:3];
	
	if (hintCards) {
		return hintCards;
	}
	
	// X-Wing
	hintCards = [self eliminatePencilsXWingOfSize:2];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Swordfish
	hintCards = [self eliminatePencilsXWingOfSize:3];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Jellyfish
	hintCards = [self eliminatePencilsXWingOfSize:4];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Finned X-Wing
	hintCards = [self eliminatePencilsFinnedXWingOfSize:2];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Remote Pairs
	hintCards = [self eliminatePencilsRemotePairs];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Avoidable Rectangles
	hintCards = [self eliminatePencilsAvoidableRectangles];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Finned Swordfish
	hintCards = [self eliminatePencilsFinnedXWingOfSize:3];
	
	if (hintCards) {
		return hintCards;
	}
	*/
	
	// Can't solve!!
	ZSHintGeneratorNoHint *generator = [[ZSHintGeneratorNoHint alloc] init];
	hintCards = [generator generateHint];
	
	return hintCards;
}

#pragma mark - Logic Techniques

- (NSArray *)fixIncorrectGuesses {
	// Iterate over all the tiles on the board.
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			if (_fastGameBoard.grid[row][col].guess && _fastGameBoard.grid[row][col].guess != _fastGameBoard.grid[row][col].answer) {
				ZSHintGeneratorFixIncorrectGuess *generator = [[ZSHintGeneratorFixIncorrectGuess alloc] init];
				[generator setIncorrectTileRow:row col:col];
				return [generator generateHint];
			}
		}
	}
	
	return nil;
}

- (NSArray *)fixMissingPencils {
	ZSHintGeneratorFixMissingPencil *generator = [[ZSHintGeneratorFixMissingPencil alloc] initWithSize:_fastGameBoard.size];
	
	NSInteger totalTilesWithPencils = 0;
	NSInteger totalTilesWithNoPencils = 0;
	NSInteger totalTilesWithMissingPencils = 0;
	
	// Iterate over all the tiles on the board.
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			if (!_fastGameBoard.grid[row][col].guess) {
				// Keep track if there are no pencils marked.
				if (_fastGameBoard.grid[row][col].totalPencils) {
					++totalTilesWithPencils;
					
					// Keep track if a tile has pencils but is missing the correct one.
					if (!_fastGameBoard.grid[row][col].pencils[_fastGameBoard.grid[row][col].answer - 1]) {
						++totalTilesWithMissingPencils;
						[generator addMissingPencil:_fastGameBoard.grid[row][col].answer forTileAtRow:row col:col];
					}
				} else {
					++totalTilesWithNoPencils;
					
					// Get a list of possible pencils for the tile.
					for (NSInteger guess = 1; guess <= _fastGameBoard.size; ++guess) {
						if ([_fastGameBoard isGuess:guess validInRow:row col:col]) {
							[generator addPencil:guess forTileAtRow:row col:col];
						}
					}
				}
			}
		}
	}
	
	[generator setTotalTilesWithPencils:totalTilesWithPencils];
	
	if (totalTilesWithNoPencils || totalTilesWithMissingPencils) {
		return [generator generateHint];
	}
	
	return nil;
}

- (NSArray *)solveOnlyChoice {
	// Iterate over all the tiles on the board.
	for (NSInteger row = 0; row < _scratchBoard.size; ++row) {
		for (NSInteger col = 0; col < _scratchBoard.size; ++col) {
			// Skip the solved tiles.
			if (_scratchBoard.grid[row][col].guess) {
				continue;
			}
			
			// If the tile only has one pencil mark, it has to be that answer.
			if (_scratchBoard.grid[row][col].totalPencils == 1) {
				// Search through the pencils and find the lone YES.
				for (NSInteger guess = 1; guess <= _scratchBoard.size; ++guess) {
					if (_scratchBoard.grid[row][col].pencils[guess - 1]) {
						ZSHintGeneratorSolveOnlyChoice *generator = [[ZSHintGeneratorSolveOnlyChoice alloc] init];
						[generator setOnlyChoice:guess forTileInRow:row col:col];
						return [generator generateHint];
					}
				}
			}
		}
	}
	
	return nil;
}

- (NSArray *)solveSinglePossibility {
	// Iterate over each guess.
	for (NSInteger guess = 0; guess < _scratchBoard.size; ++guess) {
		// Iterate over each row.
		for (NSInteger i = 0; i < _scratchBoard.size; ++i) {
			// If there is only one tile with the current pencil, that's the answer for that tile.
			if (_scratchBoard.totalTilesInRowWithPencil[i][guess] == 1) {
				// Iterate over the set and find the tile with the matching pencil.
				for (NSInteger j = 0; j < _scratchBoard.size; ++j) {
					if (!_scratchBoard.rows[i][j]->guess && _scratchBoard.rows[i][j]->pencils[guess]) {
						ZSHintGeneratorSolveSinglePossibility *generator = [[ZSHintGeneratorSolveSinglePossibility alloc] init];
						[generator setSinglePossibility:(guess + 1) forTileInRow:_scratchBoard.rows[i][j]->row col:_scratchBoard.rows[i][j]->col scope:ZSHintGeneratorSolveSinglePossibilityScopeRow];
						return [generator generateHint];
					}
				}
			}
		}
		
		// Iterate over each col.
		for (NSInteger i = 0; i < _scratchBoard.size; ++i) {
			// If there is only one tile with the current pencil, that's the answer for that tile.
			if (_scratchBoard.totalTilesInColWithPencil[i][guess] == 1) {
				// Iterate over the set and find the tile with the matching pencil.
				for (NSInteger j = 0; j < _scratchBoard.size; ++j) {
					if (!_scratchBoard.cols[i][j]->guess && _scratchBoard.cols[i][j]->pencils[guess]) {
						ZSHintGeneratorSolveSinglePossibility *generator = [[ZSHintGeneratorSolveSinglePossibility alloc] init];
						[generator setSinglePossibility:(guess + 1) forTileInRow:_scratchBoard.cols[i][j]->row col:_scratchBoard.cols[i][j]->col scope:ZSHintGeneratorSolveSinglePossibilityScopeCol];
						return [generator generateHint];
					}
				}
			}
		}
		
		// Iterate over each group.
		for (NSInteger i = 0; i < _scratchBoard.size; ++i) {
			// If there is only one tile with the current pencil, that's the answer for that tile.
			if (_scratchBoard.totalTilesInGroupWithPencil[i][guess] == 1) {
				// Iterate over the set and find the tile with the matching pencil.
				for (NSInteger j = 0; j < _scratchBoard.size; ++j) {
					if (!_scratchBoard.groups[i][j]->guess && _scratchBoard.groups[i][j]->pencils[guess]) {
						ZSHintGeneratorSolveSinglePossibility *generator = [[ZSHintGeneratorSolveSinglePossibility alloc] init];
						[generator setSinglePossibility:(guess + 1) forTileInRow:_scratchBoard.groups[i][j]->row col:_scratchBoard.groups[i][j]->col scope:ZSHintGeneratorSolveSinglePossibilityScopeGroup];
						return [generator generateHint];
					}
				}
			}
		}
	}
	
	return nil;
}

/*
- (NSArray *)eliminatePencilsHiddenSubgroupForSize:(NSInteger)subgroupSize {
	NSInteger totalPencilsEliminated = 0;
	
	// Allocate memory used in searching for hidden subgroups. We allocate out of the main loop because
	// allocation is expensive and all iterations of the loop need roughly the same size arrays.
	NSInteger *pencilMap = malloc(_fastGameBoard.size * sizeof(NSInteger));
	NSInteger *combinationMap = malloc(subgroupSize * sizeof(NSInteger));
	ZSGameTileStub **subgroupMatches = malloc(_fastGameBoard.size * sizeof(ZSGameTileStub *));
	
	// Iterate over each tile set.
	for (NSInteger setIndex = 0, totalSets = 3 * _fastGameBoard.size; setIndex < totalSets; ++setIndex) {
		// Cache the current set.
		ZSGameTileStub **currentSet = _fastGameBoard.allSets[setIndex];
		
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
			for (NSInteger tileIndex = 0; tileIndex < _fastGameBoard.size; ++tileIndex) {
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
					for (NSInteger pencilToEliminate = 0; pencilToEliminate < _fastGameBoard.size; ++pencilToEliminate) {
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
							[_fastGameBoard setPencil:NO forPencilNumber:(pencilToEliminate + 1) forTileAtRow:subgroupMatches[subgroupMatchIndex]->row col:subgroupMatches[subgroupMatchIndex]->col];
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

- (NSArray *)eliminatePencilsNakedSubgroupForSize:(NSInteger)subgroupSize {
	NSInteger totalPencilsEliminated = 0;
	
	// Allocate memory used in searching for hidden subgroups. We allocate out of the main loop because
	// allocation is expensive and all iterations of the loop need roughly the same size arrays.
	NSInteger *pencilMap = malloc(_fastGameBoard.size * sizeof(NSInteger));
	NSInteger *combinationMap = malloc(subgroupSize * sizeof(NSInteger));
	ZSGameTileStub **subgroupMatches = malloc(_fastGameBoard.size * sizeof(ZSGameTileStub *));
	
	// Iterate over each tile set.
	for (NSInteger setIndex = 0, totalSets = 3 * _fastGameBoard.size; setIndex < totalSets; ++setIndex) {
		// Cache the current set.
		ZSGameTileStub **currentSet = _fastGameBoard.allSets[setIndex];
		
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
			for (NSInteger tileIndex = 0; tileIndex < _fastGameBoard.size; ++tileIndex) {
				// Skip solved tiles.
				if (currentSet[tileIndex]->guess) {
					continue;
				}
				
				// Make sure the tile has all of the pencils.
				BOOL tileHasOnlyMatchingPencils = YES;
				
				// Check all pencils on the current tile.
				for (NSInteger pencilToTest = 0; pencilToTest < _fastGameBoard.size; ++pencilToTest) {
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
				for (NSInteger setIndex = 0; setIndex < _fastGameBoard.size; ++setIndex) {
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
							[_fastGameBoard setPencil:NO forPencilNumber:(pencilToEliminate + 1) forTileAtRow:currentSet[setIndex]->row col:currentSet[setIndex]->col];
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

- (NSArray *)eliminatePencilsPointingPairs {
	NSInteger totalPencilsEliminated = 0;
	
	// Loop over all groups.
	for (NSInteger groupIndex = 0; groupIndex < _fastGameBoard.size; ++groupIndex) {
		// Cache the current group.
		ZSGameTileStub **currentGroup = _fastGameBoard.groups[groupIndex];
		NSInteger currentGroupId = _fastGameBoard.groups[groupIndex][0]->groupId;
		
		// Loop over all guesses.
		for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
			// If the group has already solved this guess, continue.
			if (_fastGameBoard.totalTilesInGroupWithAnswer[groupIndex][guess]) {
				continue;
			}
			
			// If more than 3 tiles in the group have that pencil mark, they can't possibly be in a line.
			if (_fastGameBoard.totalTilesInGroupWithPencil[groupIndex][guess] > 3) {
				continue;
			}
			
			// Keep track of the row and column of all existing pencils of the current guess.
			NSInteger foundPencils = 0;
			NSInteger alignedRow = 0;
			NSInteger alignedCol = 0;
			BOOL rowIsAligned = YES;
			BOOL colIsAligned = YES;
			
			// Loop over the members in the group.
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
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
				if (rowIsAligned && foundPencils != _fastGameBoard.totalTilesInRowWithPencil[alignedRow][guess]) {
					ZSGameTileStub **rowSet = _fastGameBoard.rows[alignedRow];
					
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						if (rowSet[i]->groupId != currentGroupId) {
							if (rowSet[i]->pencils[guess]) {
								[_fastGameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:rowSet[i]->row col:rowSet[i]->col];
								++totalPencilsEliminated;
							}
						}
					}
				}
				
				// If all the pencils found were in the same col, eliminate all possibilities in the rest of that col.
				if (colIsAligned && foundPencils != _fastGameBoard.totalTilesInColWithPencil[alignedCol][guess]) {
					ZSGameTileStub **colSet = _fastGameBoard.cols[alignedCol];
					
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						if (colSet[i]->groupId != currentGroupId) {
							if (colSet[i]->pencils[guess]) {
								[_fastGameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:colSet[i]->row col:colSet[i]->col];
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

- (NSArray *)eliminatePencilsBoxLineReduction {
	NSInteger totalPencilsEliminated = 0;
	
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
			if (_fastGameBoard.totalTilesInRowWithPencil[row][guess] && _fastGameBoard.totalTilesInRowWithPencil[row][guess] <= 3) {
				BOOL allPencilsInSameGroup = YES;
				NSInteger totalPencilsFound = 0;
				NSInteger group = 0;
				
				for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
					if (!_fastGameBoard.rows[row][i]->guess && _fastGameBoard.rows[row][i]->pencils[guess]) {
						if (totalPencilsFound) {
							if (_fastGameBoard.rows[row][i]->groupId != group) {
								allPencilsInSameGroup = NO;
								break;
							}
						} else {
							group = _fastGameBoard.rows[row][i]->groupId;
						}
						
						++totalPencilsFound;
					}
				}
				
				if (allPencilsInSameGroup) {
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						if (_fastGameBoard.groups[group][i]->row == row) {
							continue;
						}
						
						if (!_fastGameBoard.groups[group][i]->guess && _fastGameBoard.groups[group][i]->pencils[guess]) {
							[_fastGameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:_fastGameBoard.groups[group][i]->row col:_fastGameBoard.groups[group][i]->col];
							++totalPencilsEliminated;
						}
					}
				}
			}
		}
		
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			if (_fastGameBoard.totalTilesInColWithPencil[col][guess] && _fastGameBoard.totalTilesInColWithPencil[col][guess] <= 3) {
				BOOL allPencilsInSameGroup = YES;
				NSInteger totalPencilsFound = 0;
				NSInteger group = 0;
				
				for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
					if (!_fastGameBoard.cols[col][i]->guess && _fastGameBoard.cols[col][i]->pencils[guess]) {
						if (totalPencilsFound) {
							if (_fastGameBoard.cols[col][i]->groupId != group) {
								allPencilsInSameGroup = NO;
								break;
							}
						} else {
							group = _fastGameBoard.cols[col][i]->groupId;
						}
						
						++totalPencilsFound;
					}
				}
				
				if (allPencilsInSameGroup) {
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						if (_fastGameBoard.groups[group][i]->col == col) {
							continue;
						}
						
						if (!_fastGameBoard.groups[group][i]->guess && _fastGameBoard.groups[group][i]->pencils[guess]) {
							[_fastGameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:_fastGameBoard.groups[group][i]->row col:_fastGameBoard.groups[group][i]->col];
							++totalPencilsEliminated;
						}
					}
				}
			}
		}
	}
	
	return totalPencilsEliminated;
}

- (NSArray *)eliminatePencilsXWingOfSize:(NSInteger)size {
	NSArray *hintCards = nil;
	
	hintCards = [self eliminatePencilsXWingRowsOfSize:size];
	
	if (hintCards) {
		return hintCards;
	}
	
	hintCards = [self eliminatePencilsXWingColsOfSize:size];
	
	if (hintCards) {
		return hintCards;
	}
	
	return hintCards;
}

- (NSArray *)eliminatePencilsXWingRowsOfSize:(NSInteger)size {
	NSInteger totalPencilsEliminated = 0;
	
	// Initialize the slot matches.
	ZSXWingSlotMatch *slotMatches = malloc(_fastGameBoard.size * sizeof(ZSXWingSlotMatch));
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		slotMatches[i].slotIndexes = malloc(size * sizeof(NSInteger));
	}
	
	// Init memory for use in the loop.
	NSInteger *currentRowIndexes = malloc(_fastGameBoard.size * sizeof(NSInteger));
	NSInteger *slotsInRowGroup = malloc(_fastGameBoard.size * sizeof(NSInteger));
	BOOL *slotExistsInRowGroup = malloc(_fastGameBoard.size * sizeof(BOOL));
	BOOL *rowExistsInRowGroup = malloc(_fastGameBoard.size * sizeof(BOOL));
	
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		// Keep track of how many rows have exactly two of the current pencil.
		NSInteger totalRowMatches = 0;
		
		// Clear out the slot matches objects.
		for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
			slotMatches[i].totalSlotIndexes = 0;
		}
		
		// Find all the rows that contain 2 tiles with the current pencil mark and put them in a slot match object.
		for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
			if (_fastGameBoard.totalTilesInRowWithPencil[row][guess] >= 2 && _fastGameBoard.totalTilesInRowWithPencil[row][guess] <= size) {
				// We have a row that fits. First, figure out which tiles contain the pencil.
				for (NSInteger j = 0; j < _fastGameBoard.size; ++j) {
					if (_fastGameBoard.rows[row][j]->pencils[guess]) {
						slotMatches[totalRowMatches].slotIndexes[slotMatches[totalRowMatches].totalSlotIndexes] = _fastGameBoard.rows[row][j]->col;
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
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
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
			
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
				if (slotExistsInRowGroup[i]) {
					slotsInRowGroup[totalSlots] = i;
					++totalSlots;
				}
			}
			
			// If the number of slots in the group is equivalent to the group size, we have an X-Wing!
			if (totalSlots == size) {
				// Initialize the bool cache of rows in this row group.
				for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
					rowExistsInRowGroup[i] = NO;
				}
				
				// Mark all the rows in this row group.
				for (NSInteger i = 0; i < size; ++i) {
					rowExistsInRowGroup[slotMatches[currentRowIndexes[i]].matchIndex] = YES;
				}
				
				// Finally, loop over all the rows and eliminate penils in each column.
				for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
					// Skip the rows in the group.
					if (rowExistsInRowGroup[row]) {
						continue;
					}
					
					// Loop over all the columns in the match and eliminate pencils.
					for (NSInteger slotIndex = 0; slotIndex < size; ++slotIndex) {
						NSInteger col = slotsInRowGroup[slotIndex];
						
						if (_fastGameBoard.grid[row][col].pencils[guess]) {
							[_fastGameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:row col:col];
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
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return totalPencilsEliminated;
}

- (NSArray *)eliminatePencilsXWingColsOfSize:(NSInteger)size {
	NSInteger totalPencilsEliminated = 0;
	
	// Initialize the slot matches.
	ZSXWingSlotMatch *slotMatches = malloc(_fastGameBoard.size * sizeof(ZSXWingSlotMatch));
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		slotMatches[i].slotIndexes = malloc(size * sizeof(NSInteger));
	}
	
	// Init memory for use in the loop.
	NSInteger *currentColIndexes = malloc(_fastGameBoard.size * sizeof(NSInteger));
	NSInteger *slotsInColGroup = malloc(_fastGameBoard.size * sizeof(NSInteger));
	BOOL *slotExistsInColGroup = malloc(_fastGameBoard.size * sizeof(BOOL));
	BOOL *colExistsInColGroup = malloc(_fastGameBoard.size * sizeof(BOOL));
	
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		// Keep track of how many cols have exactly two of the current pencil.
		NSInteger totalColMatches = 0;
		
		// Clear out the slot matches objects.
		for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
			slotMatches[i].totalSlotIndexes = 0;
		}
		
		// Find all the rows that contain 2 tiles with the current pencil mark and put them in a slot match object.
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			if (_fastGameBoard.totalTilesInColWithPencil[col][guess] >= 2 && _fastGameBoard.totalTilesInColWithPencil[col][guess] <= size) {
				// We have a row that fits. First, figure out which tiles contain the pencil.
				for (NSInteger j = 0; j < _fastGameBoard.size; ++j) {
					if (_fastGameBoard.cols[col][j]->pencils[guess]) {
						slotMatches[totalColMatches].slotIndexes[slotMatches[totalColMatches].totalSlotIndexes] = _fastGameBoard.cols[col][j]->row;
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
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
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
			
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
				if (slotExistsInColGroup[i]) {
					slotsInColGroup[totalSlots] = i;
					++totalSlots;
				}
			}
			
			// If the number of slots in the group is equivalent to the group size, we have an X-Wing!
			if (totalSlots == size) {
				// Initialize the bool cache of rows in this row group.
				for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
					colExistsInColGroup[i] = NO;
				}
				
				// Mark all the rows in this row group.
				for (NSInteger i = 0; i < size; ++i) {
					colExistsInColGroup[slotMatches[currentColIndexes[i]].matchIndex] = YES;
				}
				
				// Finally, loop over all the rows and eliminate penils in each column.
				for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
					// Skip the rows in the group.
					if (colExistsInColGroup[col]) {
						continue;
					}
					
					// Loop over all the columns in the match and eliminate pencils.
					for (NSInteger slotIndex = 0; slotIndex < size; ++slotIndex) {
						NSInteger row = slotsInColGroup[slotIndex];
						
						if (_fastGameBoard.grid[row][col].pencils[guess]) {
							[_fastGameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:row col:col];
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
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return totalPencilsEliminated;
}

- (NSArray *)eliminatePencilsFinnedXWingOfSize:(NSInteger)size {
	NSInteger pencilsEliminated = 0;
	
	pencilsEliminated += [self eliminatePencilsFinnedXWingRowsOfSize:size];
	pencilsEliminated += [self eliminatePencilsFinnedXWingColsOfSize:size];
	
	return pencilsEliminated;
}

- (NSArray *)eliminatePencilsFinnedXWingRowsOfSize:(NSInteger)size {
	NSInteger totalPencilsEliminated = 0;
	
	// Initialize the slot matches.
	ZSXWingSlotMatch *slotMatches = malloc(_fastGameBoard.size * sizeof(ZSXWingSlotMatch));
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		slotMatches[i].slotIndexes = malloc(_fastGameBoard.size * sizeof(NSInteger));
	}
	
	// Init memory for use in the loop.
	NSInteger *currentRowIndexes = malloc(_fastGameBoard.size * sizeof(NSInteger));
	NSInteger *slotsInRowGroup = malloc(_fastGameBoard.size * sizeof(NSInteger));
	BOOL *slotExistsInRowGroup = malloc(_fastGameBoard.size * sizeof(BOOL));
	BOOL *rowExistsInRowGroup = malloc(_fastGameBoard.size * sizeof(BOOL));
	
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		// Keep track of how many rows have exactly two of the current pencil.
		NSInteger totalRowMatches = 0;
		
		// Clear out the slot matches objects.
		for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
			slotMatches[i].totalSlotIndexes = 0;
		}
		
		// Find all the rows that contain 2 tiles with the current pencil mark and put them in a slot match object.
		for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
			if (_fastGameBoard.totalTilesInRowWithPencil[row][guess] >= 2) {
				// We have a row that fits. First, figure out which tiles contain the pencil.
				for (NSInteger j = 0; j < _fastGameBoard.size; ++j) {
					if (_fastGameBoard.rows[row][j]->pencils[guess]) {
						slotMatches[totalRowMatches].slotIndexes[slotMatches[totalRowMatches].totalSlotIndexes] = _fastGameBoard.rows[row][j]->col;
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
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
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
			
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
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
				
				for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
					if (_fastGameBoard.grid[row][col].pencils[guess] && !slotExistsInRowGroup[col]) {
						NSInteger groupIdOfCurrentCol = _fastGameBoard.grid[row][col].groupId;
						
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
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						for (NSInteger j = 0; j < size; ++j) {
							NSInteger col = slotsInRowGroup[j];
							
							// If the current tile is not in a slot column, skip it.
							if (_fastGameBoard.groups[firstDeviantPencilGroupId][i]->col != col) {
								continue;
							}
							
							// Make sure we're not eliminating tiles from the final row of the X-Wing group.
							if (_fastGameBoard.groups[firstDeviantPencilGroupId][i]->row == row) {
								continue;
							}
							
							// Make sure we're not eliminating tiles from any of the other rows in the X-Wing group.
							BOOL currentTileRowExistsInXWingRowGroup = NO;
							
							for (NSInteger k = 0; k < (size - 1); ++k) {
								if (_fastGameBoard.groups[firstDeviantPencilGroupId][i]->row == slotMatches[currentRowIndexes[k]].matchIndex) {
									currentTileRowExistsInXWingRowGroup = YES;
								}
							}
							
							if (currentTileRowExistsInXWingRowGroup) {
								continue;
							}
							
							// Assuming we've found a tile that 
							if (_fastGameBoard.groups[firstDeviantPencilGroupId][i]->pencils[guess]) {
								[_fastGameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:_fastGameBoard.groups[firstDeviantPencilGroupId][i]->row col:col];
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
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return totalPencilsEliminated;
}

- (NSArray *)eliminatePencilsFinnedXWingColsOfSize:(NSInteger)size {
	NSInteger totalPencilsEliminated = 0;
	
	// Initialize the slot matches.
	ZSXWingSlotMatch *slotMatches = malloc(_fastGameBoard.size * sizeof(ZSXWingSlotMatch));
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		slotMatches[i].slotIndexes = malloc(_fastGameBoard.size * sizeof(NSInteger));
	}
	
	// Init memory for use in the loop.
	NSInteger *currentColIndexes = malloc(_fastGameBoard.size * sizeof(NSInteger));
	NSInteger *slotsInColGroup = malloc(_fastGameBoard.size * sizeof(NSInteger));
	BOOL *slotExistsInColGroup = malloc(_fastGameBoard.size * sizeof(BOOL));
	BOOL *colExistsInColGroup = malloc(_fastGameBoard.size * sizeof(BOOL));
	
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		// Keep track of how many cols have exactly two of the current pencil.
		NSInteger totalColMatches = 0;
		
		// Clear out the slot matches objects.
		for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
			slotMatches[i].totalSlotIndexes = 0;
		}
		
		// Find all the cols that contain 2 tiles with the current pencil mark and put them in a slot match object.
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			if (_fastGameBoard.totalTilesInColWithPencil[col][guess] >= 2) {
				// We have a col that fits. First, figure out which tiles contain the pencil.
				for (NSInteger j = 0; j < _fastGameBoard.size; ++j) {
					if (_fastGameBoard.cols[col][j]->pencils[guess]) {
						slotMatches[totalColMatches].slotIndexes[slotMatches[totalColMatches].totalSlotIndexes] = _fastGameBoard.cols[col][j]->row;
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
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
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
			
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
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
				
				for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
					if (_fastGameBoard.grid[row][col].pencils[guess] && !slotExistsInColGroup[row]) {
						NSInteger groupIdOfCurrentRow = _fastGameBoard.grid[row][col].groupId;
						
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
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						for (NSInteger j = 0; j < size; ++j) {
							NSInteger row = slotsInColGroup[j];
							
							// If the current tile is not in a slot row, skip it.
							if (_fastGameBoard.groups[firstDeviantPencilGroupId][i]->row != row) {
								continue;
							}
							
							// Make sure we're not eliminating tiles from the final col of the X-Wing group.
							if (_fastGameBoard.groups[firstDeviantPencilGroupId][i]->col == col) {
								continue;
							}
							
							// Make sure we're not eliminating tiles from any of the other cols in the X-Wing group.
							BOOL currentTileColExistsInXWingColGroup = NO;
							
							for (NSInteger k = 0; k < (size - 1); ++k) {
								if (_fastGameBoard.groups[firstDeviantPencilGroupId][i]->col == slotMatches[currentColIndexes[k]].matchIndex) {
									currentTileColExistsInXWingColGroup = YES;
								}
							}
							
							if (currentTileColExistsInXWingColGroup) {
								continue;
							}
							
							// Assuming we've found a tile that 
							if (_fastGameBoard.groups[firstDeviantPencilGroupId][i]->pencils[guess]) {
								[_fastGameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:row col:_fastGameBoard.groups[firstDeviantPencilGroupId][i]->col];
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
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return totalPencilsEliminated;
}

- (NSArray *)eliminatePencilsYWingUseChains:(BOOL)useChains {
	NSInteger totalPencilsEliminated = 0;
	
	ZSGameTileList tileList;

	tileList.tiles = malloc(_fastGameBoard.size * _fastGameBoard.size * sizeof(ZSGameTileStub *));
	tileList.totalTiles = 0;
	
	// Make a list of all the tiles that have 2 pencils.
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			if (_fastGameBoard.grid[row][col].totalPencils == 2) {
				tileList.tiles[tileList.totalTiles] = &_fastGameBoard.grid[row][col];
				++tileList.totalTiles;
			}
		}
	}
	
	// If there aren't 3 or more tiles, there can't be a Y-Wing.
	if (tileList.totalTiles < 3) {
		return 0;
	}
	
	NSInteger *yWingGroupIndexes = malloc(3 * sizeof(NSInteger));
	BOOL *pencilMap = malloc(_fastGameBoard.size * sizeof(BOOL));
	
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
			if ([_fastGameBoard tile:tile1 influencesTile:tile2]) {
				++tile1Influences;
				++tile2Influences;
			}
			
			if ([_fastGameBoard tile:tile1 influencesTile:tile3]) {
				++tile1Influences;
				++tile3Influences;
			}
			
			if ([_fastGameBoard tile:tile2 influencesTile:tile3]) {
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
		for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
			pencilMap[guess] = (tile1->pencils[guess] || tile2->pencils[guess] || tile3->pencils[guess]);
		}
		
		// Count the pencils in all the tiles.
		NSInteger totalPencilsInGroup = 0;
		
		for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
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
		
		for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
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

- (NSArray *)eliminatePencilsYWingWithTile1:(ZSGameTileStub *)tile1 tile2:(ZSGameTileStub *)tile2 {
	NSInteger totalPencilsEliminated = 0;
	
	// It's possible that we've eliminated pencils by the time we've gotten here. Make sure all 3 candidates still have 2 pencils each.
	if (tile1->totalPencils != 2 || tile2->totalPencils != 2) {
		return 0;
	}
	
	// Figure out which pencil we're eliminating.
	NSInteger commonPencil = 0;
	
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		if (tile1->pencils[guess] && tile2->pencils[guess]) {
			commonPencil = guess;
			break;
		}
	}
	
	// Loop over all of the tiles influenced by both and search for instances of those pencils.
	ZSGameTileList tileList = [_fastGameBoard getAllInfluencedTilesForTile:tile1 andOtherTile:tile2];
	
	for (NSInteger i = 0; i < tileList.totalTiles; ++i) {
		if (tileList.tiles[i] == tile1 || tileList.tiles[i] == tile2) {
			continue;
		}
		
		if (tileList.tiles[i]->pencils[commonPencil]) {
			[_fastGameBoard setPencil:NO forPencilNumber:(commonPencil + 1) forTileAtRow:tileList.tiles[i]->row col:tileList.tiles[i]->col];
			++totalPencilsEliminated;
		}
	}
	
	free(tileList.tiles);
	
	return totalPencilsEliminated;
}

- (NSArray *)eliminatePencilsRemotePairs {
	NSInteger totalPencilsEliminated = 0;
	
	BOOL **investigatedTiles = malloc(_fastGameBoard.size * sizeof(BOOL *));
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		investigatedTiles[i] = malloc(_fastGameBoard.size * sizeof(BOOL));
		
		for (NSInteger j = 0; j < _fastGameBoard.size; ++j) {
			investigatedTiles[i][j] = NO;
		}
	}
	
	// Find all the cols that contain 2 tiles with the current pencil mark and put them in a slot match object.
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			ZSGameTileStub *currentTile = &_fastGameBoard.grid[row][col];
			
			if (investigatedTiles[row][col]) {
				continue;
			}
			
			investigatedTiles[row][col] = YES;
			
			if (currentTile->totalPencils == 2) {
				NSInteger firstPencil = 0;
				NSInteger secondPencil = 0;
				NSInteger pencilsIdentified = 0;
				
				for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
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
				
				for (NSInteger chainMapRow = 0; chainMapRow < _fastGameBoard.size; ++chainMapRow) {
					for (NSInteger chainMapCol = 0; chainMapCol < _fastGameBoard.size; ++chainMapCol) {
						ZSGameTileStub *targetTile = &_fastGameBoard.grid[chainMapRow][chainMapCol];
						
						switch (_chainMap[chainMapRow][chainMapCol]) {
							case ZSChainMapResultRelatedConflicted:
								
								if (targetTile->pencils[firstPencil]) {
									[_fastGameBoard setPencil:NO forPencilNumber:(firstPencil + 1) forTileAtRow:targetTile->row col:targetTile->col];
									++totalPencilsEliminated;
								}
								
								if (targetTile->pencils[secondPencil]) {
									[_fastGameBoard setPencil:NO forPencilNumber:(secondPencil + 1) forTileAtRow:targetTile->row col:targetTile->col];
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
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(investigatedTiles[i]);
	}
	
	free(investigatedTiles);
	
	return totalPencilsEliminated;
}

- (NSArray *)eliminatePencilsAvoidableRectangles {
	NSInteger totalPencilsEliminated = 0;
	
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			ZSGameTileStub *currentTile = &_fastGameBoard.grid[row][col];
			
			if (currentTile->guess && !_clueIsProvidedInPuzzle[row][col]) {
				for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
					if (currentTile->guess == (guess + 1)) {
						continue;
					}
					
					if (_fastGameBoard.totalTilesInRowWithAnswer[row][guess] == 1 && _fastGameBoard.totalTilesInColWithAnswer[col][guess] == 1) {
						NSInteger otherRowIndex = 0;
						NSInteger otherColIndex = 0;
						
						for (otherColIndex = 0; otherColIndex < _fastGameBoard.size; ++otherColIndex) {
							if (_fastGameBoard.grid[row][otherColIndex].guess == (guess + 1)) {
								break;
							}
						}
						
						for (otherRowIndex = 0; otherRowIndex < _fastGameBoard.size; ++otherRowIndex) {
							if (_fastGameBoard.grid[otherRowIndex][col].guess == (guess + 1)) {
								break;
							}
						}
						
						if (_clueIsProvidedInPuzzle[row][otherColIndex] || _clueIsProvidedInPuzzle[otherRowIndex][col]) {
							continue;
						}
						
						NSInteger rectangleCornersInTargetTilesGroup = 0;
						
						if (_fastGameBoard.grid[row][otherColIndex].groupId == currentTile->groupId) {
							++rectangleCornersInTargetTilesGroup;
						}
						
						if (_fastGameBoard.grid[otherRowIndex][col].groupId == currentTile->groupId) {
							++rectangleCornersInTargetTilesGroup;
						}
						
						if (rectangleCornersInTargetTilesGroup != 1) {
							continue;
						}
						
						if (_fastGameBoard.grid[otherRowIndex][otherColIndex].pencils[(currentTile->guess - 1)]) {
							[_fastGameBoard setPencil:NO forPencilNumber:currentTile->guess forTileAtRow:otherRowIndex col:otherColIndex];
							++totalPencilsEliminated;
						}
						
						if (_fastGameBoard.grid[otherRowIndex][otherColIndex].pencils[guess]) {
							[_fastGameBoard setPencil:NO forPencilNumber:(guess + 1) forTileAtRow:otherRowIndex col:otherColIndex];
							++totalPencilsEliminated;
						}
					}
				}
			}
		}
	}
	
	return totalPencilsEliminated;
}
*/

#pragma mark - Logic Technique Helpers

// Populate the pencilMap array with a list of pencils that exist in the given tile set. Return the total number of pencils found.
- (NSInteger)initPencilMap:(NSInteger *)pencilMap forTileSet:(ZSGameTileStub **)set {
	NSInteger totalPencils = 0;
	
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		for (NSInteger tileIndex = 0; tileIndex < _fastGameBoard.size; ++tileIndex) {
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
	_clueIsProvidedInPuzzle = malloc(_fastGameBoard.size * sizeof(BOOL *));
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		_clueIsProvidedInPuzzle[i] = malloc(_fastGameBoard.size * sizeof(BOOL));
	}
}

- (void)deallocClueMask {
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(_clueIsProvidedInPuzzle[i]);
	}
	
	free(_clueIsProvidedInPuzzle);
}

- (void)clearClueMask {
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			_clueIsProvidedInPuzzle[row][col] = NO;
		}
	}
}

- (void)copyClueMaskFromGameBoard {
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			_clueIsProvidedInPuzzle[row][col] = (_fastGameBoard.grid[row][col].guess) == 0 ? NO : YES;
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
		
		if (++currentCol >= _fastGameBoard.size) {
			currentCol -= _fastGameBoard.size;
			++currentRow;
		}
		
		if (currentRow == _fastGameBoard.size) {
			break;
		}
	}
}

- (void)setClueProvidedInPuzzle:(BOOL)clueProvidedInPuzzle forRow:(NSInteger)row col:(NSInteger)col {
	_clueIsProvidedInPuzzle[row][col] = clueProvidedInPuzzle;
}

#pragma mark - Chain Map Handlers

- (void)initChainMap {
	_chainPencils = malloc(_fastGameBoard.size * sizeof(NSInteger));
	
	_chainMap = malloc(_fastGameBoard.size * sizeof(ZSChainMapResult *));
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		_chainMap[i] = malloc(_fastGameBoard.size * sizeof(ZSChainMapResult));
	}
}

- (void)deallocChainMap {
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(_chainMap[i]);
	}
	
	free(_chainMap);
	
	free(_chainPencils);
}

- (void)clearChainMap {
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
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
	
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
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
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		ZSGameTileStub *currentTile = _fastGameBoard.rows[tile->row][i];
		
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
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		ZSGameTileStub *currentTile = _fastGameBoard.cols[tile->col][i];
		
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
	
	NSInteger groupId = _fastGameBoard.grid[tile->row][tile->col].groupId;
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		ZSGameTileStub *currentTile = _fastGameBoard.groups[groupId][i];
		
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

@end
