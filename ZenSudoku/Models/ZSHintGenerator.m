//
//  ZSHintGenerator.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/28/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGenerator.h"

#import "ZSFastGameBoard.h"
#import "ZSGame.h"
#import "ZSBoard.h"
#import "ZSTile.h"

#import "ZSAppDelegate.h"
#import "Flurry.h"

#import "ZSHintGeneratorFixIncorrectGuesses.h"
#import "ZSHintGeneratorFixMissingPencil.h"
#import "ZSHintGeneratorNoHint.h"
#import "ZSHintGeneratorSolveOnlyChoice.h"
#import "ZSHintGeneratorSolveSinglePossibility.h"
#import "ZSHintGeneratorEliminatePencilsNakedSubgroup.h"
#import "ZSHintGeneratorEliminatePencilsHiddenSubgroup.h"
#import "ZSHintGeneratorEliminatePencilsPointingPairs.h"
#import "ZSHintGeneratorEliminatePencilsBoxLineReduction.h"
#import "ZSHintGeneratorEliminatePencilsXWing.h"
#import "ZSHintGeneratorEliminatePencilsFinnedXWing.h"
#import "ZSHintGeneratorEliminatePencilsYWing.h"
#import "ZSHintGeneratorEliminatePencilsChainedYWing.h"
#import "ZSHintGeneratorEliminatePencilsRemotePairs.h"
#import "ZSHintGeneratorEliminatePencilsAvoidableRectangles.h"

@interface ZSHintGenerator () {
	ZSFastGameBoard *_fastGameBoard;
	ZSFastGameBoard *_scratchBoard;
	
	BOOL **_clueIsProvidedInPuzzle;
	
	BOOL _chainMapIsClear;
	ZSChainMapResult **_chainMap;
	NSInteger *_chainPencils;
}

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

- (void)copyGameStateFromGameBoard:(ZSBoard *)board {
	[_fastGameBoard copyGroupMapFromGameBoard:board];
	[_fastGameBoard copyGuessesFromGameBoard:board];
	[_fastGameBoard copyAnswersFromGameBoard:board];
	[_fastGameBoard copyPencilsFromGameBoard:board];
	
	[_scratchBoard copyGroupMapFromGameBoard:board];
	[_scratchBoard copyGuessesFromGameBoard:board];
	[_scratchBoard copyAnswersFromGameBoard:board];
	[_scratchBoard addAutoPencils];
}

#pragma mark - Solving

- (NSArray *)generateHint {
	NSArray *hintCards = nil;
	
	// Fix Incorrect Guesses
	if ((hintCards = [self fixIncorrectGuesses])) {
		return hintCards;
	}
	
	// Only Choice (Scratch Board)
	if ((hintCards = [self solveOnlyChoice])) {
		return hintCards;
	}

	// Single Possibility (Scratch Board)
	if ((hintCards = [self solveSinglePossibility])) {
		return hintCards;
	}
	
	// Fix Missing Pencils
	if ((hintCards = [self fixMissingPencils])) {
		return hintCards;
	}
	
	// Only Choice (User Board)
	if ((hintCards = [self solveOnlyChoiceUserBoard])) {
		return hintCards;
	}
	
	// Single Possibility (User Board)
	if ((hintCards = [self solveSinglePossibilityUserBoard])) {
		return hintCards;
	}
	
	// Naked Pairs
	if ((hintCards = [self eliminatePencilsNakedSubgroupForSize:2])) {
		return hintCards;
	}
	
	// Hidden Pairs
	if ((hintCards = [self eliminatePencilsHiddenSubgroupForSize:2])) {
		return hintCards;
	}
	
	// Pointing Pairs
	if ((hintCards = [self eliminatePencilsPointingPairs])) {
		return hintCards;
	}
	
	// Box Line Reduction
	if ((hintCards = [self eliminatePencilsBoxLineReduction])) {
		return hintCards;
	}
	
	// Naked Triplets
	if ((hintCards = [self eliminatePencilsNakedSubgroupForSize:3])) {
		return hintCards;
	}
	
	// Hidden Triplets
	if ((hintCards = [self eliminatePencilsHiddenSubgroupForSize:3])) {
		return hintCards;
	}
	
	// Naked Quads
	if ((hintCards = [self eliminatePencilsNakedSubgroupForSize:4])) {
		return hintCards;
	}
	
	// Hidden Quads
	if ((hintCards = [self eliminatePencilsHiddenSubgroupForSize:4])) {
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
	
	// Y-Wing
	hintCards = [self eliminatePencilsYWingUseChains:NO];
	
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
	
	/*
	// Chained Y-Wing
	hintCards = [self eliminatePencilsYWingUseChains:YES];

	if (hintCards) {
		return hintCards;
	}
	*/
	
	// Finned Swordfish
	hintCards = [self eliminatePencilsFinnedXWingOfSize:3];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Finned Jellyfish
	hintCards = [self eliminatePencilsFinnedXWingOfSize:4];
	
	if (hintCards) {
		return hintCards;
	}
	
	// Can't solve!!
	hintCards = [self eliminatePencilNoHint];
	[Flurry logEvent:kAnalyticsCheckpointNoHintAvailable];
	
	return hintCards;
}

#pragma mark - Logic Techniques

- (NSArray *)fixIncorrectGuesses {
	ZSHintGeneratorFixIncorrectGuesses *generator = [[ZSHintGeneratorFixIncorrectGuesses alloc] init];
	
	NSInteger totalIncorrect = 0;
	
	// Iterate over all the tiles on the board.
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			if (_fastGameBoard.grid[row][col].guess && _fastGameBoard.grid[row][col].guess != _fastGameBoard.grid[row][col].answer) {
				++totalIncorrect;
				
				ZSHintGeneratorTileInstruction instruction;
				instruction.row = row;
				instruction.col = col;
				instruction.pencil = 0;
				[generator addIncorrectGuess:instruction];
			}
		}
	}
	
	if (totalIncorrect == 0) {
		return nil;
	}
	
	return [generator generateHint];
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

- (NSArray *)solveOnlyChoiceUserBoard {
	// Iterate over all the tiles on the board.
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			// Skip the solved tiles.
			if (_fastGameBoard.grid[row][col].guess) {
				continue;
			}
			
			// If the tile only has one pencil mark, it has to be that answer.
			if (_fastGameBoard.grid[row][col].totalPencils == 1) {
				// Search through the pencils and find the lone YES.
				for (NSInteger guess = 1; guess <= _fastGameBoard.size; ++guess) {
					if (_fastGameBoard.grid[row][col].pencils[guess - 1]) {
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
						[generator setSinglePossibility:(guess + 1) forTileInRow:_scratchBoard.rows[i][j]->row col:_scratchBoard.rows[i][j]->col scope:ZSHintGeneratorTileScopeRow];
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
						[generator setSinglePossibility:(guess + 1) forTileInRow:_scratchBoard.cols[i][j]->row col:_scratchBoard.cols[i][j]->col scope:ZSHintGeneratorTileScopeCol];
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
						[generator setSinglePossibility:(guess + 1) forTileInRow:_scratchBoard.groups[i][j]->row col:_scratchBoard.groups[i][j]->col scope:ZSHintGeneratorTileScopeGroup];
						return [generator generateHint];
					}
				}
			}
		}
	}
	
	return nil;
}

- (NSArray *)solveSinglePossibilityUserBoard {
	// Iterate over each guess.
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		// Iterate over each row.
		for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
			// If there is only one tile with the current pencil, that's the answer for that tile.
			if (_fastGameBoard.totalTilesInRowWithPencil[i][guess] == 1) {
				// Iterate over the set and find the tile with the matching pencil.
				for (NSInteger j = 0; j < _fastGameBoard.size; ++j) {
					if (!_fastGameBoard.rows[i][j]->guess && _fastGameBoard.rows[i][j]->pencils[guess]) {
						ZSHintGeneratorSolveSinglePossibility *generator = [[ZSHintGeneratorSolveSinglePossibility alloc] init];
						[generator setSinglePossibility:(guess + 1) forTileInRow:_fastGameBoard.rows[i][j]->row col:_fastGameBoard.rows[i][j]->col scope:ZSHintGeneratorTileScopeRow];
						return [generator generateHint];
					}
				}
			}
		}
		
		// Iterate over each col.
		for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
			// If there is only one tile with the current pencil, that's the answer for that tile.
			if (_fastGameBoard.totalTilesInColWithPencil[i][guess] == 1) {
				// Iterate over the set and find the tile with the matching pencil.
				for (NSInteger j = 0; j < _fastGameBoard.size; ++j) {
					if (!_fastGameBoard.cols[i][j]->guess && _fastGameBoard.cols[i][j]->pencils[guess]) {
						ZSHintGeneratorSolveSinglePossibility *generator = [[ZSHintGeneratorSolveSinglePossibility alloc] init];
						[generator setSinglePossibility:(guess + 1) forTileInRow:_fastGameBoard.cols[i][j]->row col:_fastGameBoard.cols[i][j]->col scope:ZSHintGeneratorTileScopeCol];
						return [generator generateHint];
					}
				}
			}
		}
		
		// Iterate over each group.
		for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
			// If there is only one tile with the current pencil, that's the answer for that tile.
			if (_fastGameBoard.totalTilesInGroupWithPencil[i][guess] == 1) {
				// Iterate over the set and find the tile with the matching pencil.
				for (NSInteger j = 0; j < _fastGameBoard.size; ++j) {
					if (!_fastGameBoard.groups[i][j]->guess && _fastGameBoard.groups[i][j]->pencils[guess]) {
						ZSHintGeneratorSolveSinglePossibility *generator = [[ZSHintGeneratorSolveSinglePossibility alloc] init];
						[generator setSinglePossibility:(guess + 1) forTileInRow:_fastGameBoard.groups[i][j]->row col:_fastGameBoard.groups[i][j]->col scope:ZSHintGeneratorTileScopeGroup];
						return [generator generateHint];
					}
				}
			}
		}
	}
	
	return nil;
}

- (NSArray *)eliminatePencilsHiddenSubgroupForSize:(NSInteger)subgroupSize {
	// Initialize a hidden subgroup generator. We may not need it, but it's easier to do this outside the loop.
	ZSHintGeneratorEliminatePencilsHiddenSubgroup *generator = [[ZSHintGeneratorEliminatePencilsHiddenSubgroup alloc] initWithSubgroupSize:subgroupSize];
	
	// Allocate memory used in searching for hidden subgroups. We allocate out of the main loop because
	// allocation is expensive and all iterations of the loop need roughly the same size arrays.
	NSInteger *pencilMap = malloc(_fastGameBoard.size * sizeof(NSInteger));
	NSInteger *combinationMap = malloc(subgroupSize * sizeof(NSInteger));
	ZSTileStub **subgroupMatches = malloc(_fastGameBoard.size * sizeof(ZSTileStub *));
	
	// Iterate over each tile set.
	for (NSInteger setIndex = 0, totalSets = 3 * _fastGameBoard.size; setIndex < totalSets; ++setIndex) {
		// Cache the current set.
		ZSTileStub **currentSet = _fastGameBoard.allSets[setIndex];
		
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
				// Reset the generator.
				[generator resetTilesAndInstructions];
				
				// Keep track of whether or not the hidden subgroup actually allows us to eliminate pencil marks.
				BOOL pencilsEliminated = NO;
				
				// Iterate over all the tiles in the subgroup and eliminate all pencil marks that aren't in the pencil map.
				for (NSInteger subgroupMatchIndex = 0; subgroupMatchIndex < totalTilesWithAnyPencilsInCombination; ++subgroupMatchIndex) {
					for (NSInteger pencilToEliminate = 0; pencilToEliminate < _fastGameBoard.size; ++pencilToEliminate) {
						// Only eliminate pencils that exist outside the subgroup.
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
						
						// Check if the tile contains the current pencil. If so, we can eliminate it.
						if (subgroupMatches[subgroupMatchIndex]->pencils[pencilToEliminate]) {
							pencilsEliminated = YES;

							ZSHintGeneratorTileInstruction instruction;
							instruction.row = subgroupMatches[subgroupMatchIndex]->row;
							instruction.col = subgroupMatches[subgroupMatchIndex]->col;
							instruction.pencil = (pencilToEliminate + 1);
							[generator addPencilToEliminate:instruction];
						}
					}
				}
				
				if (pencilsEliminated) {
					// Set the scope. Warning: this isn't the smartest way to set scope considering allSets could change up the order.
					if (setIndex < _fastGameBoard.size) {
						generator.scope = ZSHintGeneratorTileScopeRow;
					} else if (setIndex < _fastGameBoard.size * 2) {
						generator.scope = ZSHintGeneratorTileScopeCol;
					} else {
						generator.scope = ZSHintGeneratorTileScopeGroup;
					}
					
					// Add all subgroup pencils.
					for (NSInteger currentCombinationIndex = 0; currentCombinationIndex < subgroupSize; ++currentCombinationIndex) {
						[generator addSubgroupPencil:(pencilMap[combinationMap[currentCombinationIndex]] + 1)];
					}
					
					// Add all the tiles in the subgroup.
					for (NSInteger subgroupMatchIndex = 0; subgroupMatchIndex < totalTilesWithAnyPencilsInCombination; ++subgroupMatchIndex) {
						ZSHintGeneratorTileInstruction tile;
						tile.row = subgroupMatches[subgroupMatchIndex]->row;
						tile.col = subgroupMatches[subgroupMatchIndex]->col;
						tile.pencil = 0;
						[generator addSubgroupTile:tile];
					}
					
					// Add all the tiles in the group.
					for (NSInteger innerSetIndex = 0; innerSetIndex < _fastGameBoard.size; ++innerSetIndex) {
						ZSHintGeneratorTileInstruction tile;
						tile.row = currentSet[innerSetIndex]->row;
						tile.col = currentSet[innerSetIndex]->col;
						tile.pencil = 0;
						[generator addGroupTile:tile];
					}
					
					free(subgroupMatches);
					free(combinationMap);
					free(pencilMap);
					
					return [generator generateHint];
				}
			}
		} while ([self setNextCombinationInArray:combinationMap ofLength:subgroupSize totalItems:totalPencilsInSet]);
	}
	
	free(subgroupMatches);
	free(combinationMap);
	free(pencilMap);
	
	return nil;
}

- (NSArray *)eliminatePencilsNakedSubgroupForSize:(NSInteger)subgroupSize {
	// Initialize a naked subgroup generator. We may not need it, but it's easier to do this outside the loop.
	ZSHintGeneratorEliminatePencilsNakedSubgroup *generator = [[ZSHintGeneratorEliminatePencilsNakedSubgroup alloc] initWithSubgroupSize:subgroupSize];
	
	// Allocate memory used in searching for hidden subgroups. We allocate out of the main loop because
	// allocation is expensive and all iterations of the loop need roughly the same size arrays.
	NSInteger *pencilMap = malloc(_fastGameBoard.size * sizeof(NSInteger));
	NSInteger *combinationMap = malloc(subgroupSize * sizeof(NSInteger));
	ZSTileStub **subgroupMatches = malloc(_fastGameBoard.size * sizeof(ZSTileStub *));
	
	// Iterate over each tile set.
	for (NSInteger setIndex = 0, totalSets = 3 * _fastGameBoard.size; setIndex < totalSets; ++setIndex) {
		// Cache the current set.
		ZSTileStub **currentSet = _fastGameBoard.allSets[setIndex];
		
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
				// Reset the generator.
				[generator resetTilesAndInstructions];
				
				// Test if the tiles are in the same row, column, and/or group.
				BOOL tilesAreInSameRow = YES;
				BOOL tilesAreInSameCol = YES;
				BOOL tilesAreInSameGroup = YES;
				
				NSInteger subgroupRow;
				NSInteger subgroupCol;
				NSInteger subgroupGroup;
				
				for (NSInteger subgroupMatchIndex = 0; subgroupMatchIndex < totalTilesWithMatchingPencilsInCombination; ++subgroupMatchIndex) {
					if (subgroupMatchIndex == 0) {
						subgroupRow = subgroupMatches[subgroupMatchIndex]->row;
						subgroupCol = subgroupMatches[subgroupMatchIndex]->col;
						subgroupGroup = subgroupMatches[subgroupMatchIndex]->groupId;
					} else {
						if (tilesAreInSameRow && subgroupMatches[subgroupMatchIndex]->row != subgroupRow) {
							tilesAreInSameRow = NO;
						}
						
						if (tilesAreInSameCol && subgroupMatches[subgroupMatchIndex]->col != subgroupCol) {
							tilesAreInSameCol = NO;
						}
						
						if (tilesAreInSameGroup && subgroupMatches[subgroupMatchIndex]->groupId != subgroupGroup) {
							tilesAreInSameGroup = NO;
						}
					}
				}
				
				// Notify the generator what scope it should consider for possibilities.
				generator.subgroupExistsInSameRow = tilesAreInSameRow;
				generator.subgroupExistsInSameCol = tilesAreInSameCol;
				generator.subgroupExistsInSameGroup = tilesAreInSameGroup;
				
				// Keep track of how many pencils we actually eliminate.
				BOOL pencilsToBeEliminated = NO;
				
				// Make a list of sets to check for similar possibilities.
				ZSTileStub **innerSets[3];
				NSInteger totalInnerSets = 0;
				
				if (tilesAreInSameRow) {
					innerSets[totalInnerSets++] = _fastGameBoard.rows[subgroupRow];
				}
				
				if (tilesAreInSameCol) {
					innerSets[totalInnerSets++] = _fastGameBoard.cols[subgroupCol];
				}
				
				if (tilesAreInSameGroup) {
					innerSets[totalInnerSets++] = _fastGameBoard.groups[subgroupGroup];
				}
				
				BOOL addedFirstInnerSetPencils = NO;
				
				// Loop through all the tiles in all the sets (row, column, and/or group) and look for pencils to eliminate.
				for (NSInteger innerSetIndex = 0; innerSetIndex < totalInnerSets; ++innerSetIndex) {
					ZSTileStub **innerCurrentSet = innerSets[innerSetIndex];
					
					// Make another pass over the same group, this time keeping track of the group tiles and pencils to eliminate.
					for (NSInteger setIndex = 0; setIndex < _fastGameBoard.size; ++setIndex) {
						// Add the tile to the list of group tiles.
						ZSHintGeneratorTileInstruction groupTile;
						groupTile.row = innerCurrentSet[setIndex]->row;
						groupTile.col = innerCurrentSet[setIndex]->col;
						groupTile.pencil = 0;
						[generator addGroupTile:groupTile];
						
						BOOL tileIsInNakedSubgroup = NO;
						
						for (NSInteger subgroupMatchIndex = 0; subgroupMatchIndex < totalTilesWithMatchingPencilsInCombination; ++subgroupMatchIndex) {
							if (subgroupMatches[subgroupMatchIndex] == innerCurrentSet[setIndex]) {
								tileIsInNakedSubgroup = YES;
								break;
							}
						}
						
						if (tileIsInNakedSubgroup) {
							ZSHintGeneratorTileInstruction subGroupTile;
							subGroupTile.row = innerCurrentSet[setIndex]->row;
							subGroupTile.col = innerCurrentSet[setIndex]->col;
							subGroupTile.pencil = 0;
							[generator addSubgroupTile:subGroupTile];
							continue;
						}
						
						// Iterate over each pencil in the subgroup and check for any pencils that we can eliminate.
						for (NSInteger currentCombinationIndex = 0; currentCombinationIndex < subgroupSize; ++currentCombinationIndex) {
							NSInteger pencilToEliminate = pencilMap[combinationMap[currentCombinationIndex]];
							
							if (innerCurrentSet[setIndex]->pencils[pencilToEliminate]) {
								if (
									((tilesAreInSameRow || tilesAreInSameCol) && tilesAreInSameGroup && !addedFirstInnerSetPencils) ||
									!tilesAreInSameGroup
								) {
									pencilsToBeEliminated = YES;
									
									ZSHintGeneratorTileInstruction instruction;
									instruction.row = innerCurrentSet[setIndex]->row;
									instruction.col = innerCurrentSet[setIndex]->col;
									instruction.pencil = (pencilToEliminate + 1);
									[generator addPencilToEliminate:instruction];
								}
							}
						}
					}
					
					addedFirstInnerSetPencils = YES;
				}
				
				if (pencilsToBeEliminated) {
					free(subgroupMatches);
					free(combinationMap);
					free(pencilMap);
					
					return [generator generateHint];
				}
			}
		} while ([self setNextCombinationInArray:combinationMap ofLength:subgroupSize totalItems:totalPencilsInSet]);
	}
	
	free(subgroupMatches);
	free(combinationMap);
	free(pencilMap);
	
	return nil;
}

- (NSArray *)eliminatePencilsPointingPairs {
	// Loop over all groups.
	for (NSInteger groupIndex = 0; groupIndex < _fastGameBoard.size; ++groupIndex) {
		// Cache the current group.
		ZSTileStub **currentGroup = _fastGameBoard.groups[groupIndex];
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
					ZSTileStub **rowSet = _fastGameBoard.rows[alignedRow];
					
					ZSHintGeneratorEliminatePencilsPointingPairs *generator = [[ZSHintGeneratorEliminatePencilsPointingPairs alloc] init];
					generator.scope = ZSHintGeneratorTileScopeRow;
					generator.targetPencil = (guess + 1);
					
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						// Add all row tiles.
						ZSHintGeneratorTileInstruction rowTile;
						rowTile.row = rowSet[i]->row;
						rowTile.col = rowSet[i]->col;
						rowTile.pencil = 0;
						[generator addRowOrColTile:rowTile];
						
						// Add all group tiles.
						ZSHintGeneratorTileInstruction groupTile;
						groupTile.row = currentGroup[i]->row;
						groupTile.col = currentGroup[i]->col;
						groupTile.pencil = 0;
						[generator addGroupTile:groupTile];
						
						// If the row tile also exists within the group, add it.
						if (rowSet[i]->groupId == currentGroup[0]->groupId && rowSet[i]->pencils[guess]) {
							ZSHintGeneratorTileInstruction pointingPairTile;
							pointingPairTile.row = rowSet[i]->row;
							pointingPairTile.col = rowSet[i]->col;
							pointingPairTile.pencil = 0;
							[generator addPointingPairTile:pointingPairTile];
						}
					}
					
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						if (rowSet[i]->groupId != currentGroupId) {
							if (rowSet[i]->pencils[guess]) {
								ZSHintGeneratorTileInstruction instruction;
								instruction.row = rowSet[i]->row;
								instruction.col = rowSet[i]->col;
								instruction.pencil = (guess + 1);
								[generator addPencilToEliminate:instruction];
							}
						}
					}
					
					return [generator generateHint];
				}
				
				// If all the pencils found were in the same col, eliminate all possibilities in the rest of that col.
				if (colIsAligned && foundPencils != _fastGameBoard.totalTilesInColWithPencil[alignedCol][guess]) {
					ZSTileStub **colSet = _fastGameBoard.cols[alignedCol];
					
					ZSHintGeneratorEliminatePencilsPointingPairs *generator = [[ZSHintGeneratorEliminatePencilsPointingPairs alloc] init];
					generator.scope = ZSHintGeneratorTileScopeCol;
					generator.targetPencil = (guess + 1);
					
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						// Add all row tiles.
						ZSHintGeneratorTileInstruction colTile;
						colTile.row = colSet[i]->row;
						colTile.col = colSet[i]->col;
						colTile.pencil = 0;
						[generator addRowOrColTile:colTile];
						
						// Add all group tiles.
						ZSHintGeneratorTileInstruction groupTile;
						groupTile.row = currentGroup[i]->row;
						groupTile.col = currentGroup[i]->col;
						groupTile.pencil = 0;
						[generator addGroupTile:groupTile];
						
						// If the row tile also exists within the group, add it.
						if (colSet[i]->groupId == currentGroup[0]->groupId && colSet[i]->pencils[guess]) {
							ZSHintGeneratorTileInstruction pointingPairTile;
							pointingPairTile.row = colSet[i]->row;
							pointingPairTile.col = colSet[i]->col;
							pointingPairTile.pencil = 0;
							[generator addPointingPairTile:pointingPairTile];
						}
					}
					
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						if (colSet[i]->groupId != currentGroupId) {
							if (colSet[i]->pencils[guess]) {
								ZSHintGeneratorTileInstruction instruction;
								instruction.row = colSet[i]->row;
								instruction.col = colSet[i]->col;
								instruction.pencil = (guess + 1);
								[generator addPencilToEliminate:instruction];
							}
						}
					}
					
					return [generator generateHint];
				}
			}
		}
	}
	
	return nil;
}

- (NSArray *)eliminatePencilsBoxLineReduction {
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		// Loop over all rows.
		for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
			if (_fastGameBoard.totalTilesInRowWithPencil[row][guess] && _fastGameBoard.totalTilesInRowWithPencil[row][guess] <= 3) {
				BOOL allPencilsInSameGroup = YES;
				NSInteger totalPencilsFound = 0;
				NSInteger group = 0;
				
				// Check to see if all of the pencils are in the same group.
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
				
				// If all the pencils in this row are in the same group, we can eliminate all other of the same pencil from that group.
				if (allPencilsInSameGroup && _fastGameBoard.totalTilesInGroupWithPencil[group][guess] > totalPencilsFound) {
					ZSHintGeneratorEliminatePencilsBoxLineReduction *generator = [[ZSHintGeneratorEliminatePencilsBoxLineReduction alloc] init];
					
					generator.scope = ZSHintGeneratorTileScopeRow;
					generator.targetPencil = (guess + 1);
					
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						// Add all row tiles.
						ZSHintGeneratorTileInstruction rowTile;
						rowTile.row = _fastGameBoard.rows[row][i]->row;
						rowTile.col = _fastGameBoard.rows[row][i]->col;
						rowTile.pencil = 0;
						[generator addRowOrColTile:rowTile];
						
						// Add all group tiles.
						ZSHintGeneratorTileInstruction groupTile;
						groupTile.row = _fastGameBoard.groups[group][i]->row;
						groupTile.col = _fastGameBoard.groups[group][i]->col;
						groupTile.pencil = 0;
						[generator addGroupTile:groupTile];
						
						// If the row tile also exists within the group, add it.
						if (_fastGameBoard.groups[group][i]->row == row) {
							if (!_fastGameBoard.groups[group][i]->guess && _fastGameBoard.groups[group][i]->pencils[guess]) {
								ZSHintGeneratorTileInstruction boxLineReductionTile;
								boxLineReductionTile.row = _fastGameBoard.groups[group][i]->row;
								boxLineReductionTile.col = _fastGameBoard.groups[group][i]->col;
								boxLineReductionTile.pencil = 0;
								[generator addBoxLineReductionTile:boxLineReductionTile];
							}
							
							continue;
						}
						
						if (!_fastGameBoard.groups[group][i]->guess && _fastGameBoard.groups[group][i]->pencils[guess]) {
							ZSHintGeneratorTileInstruction instruction;
							instruction.row = _fastGameBoard.groups[group][i]->row;
							instruction.col = _fastGameBoard.groups[group][i]->col;
							instruction.pencil = (guess + 1);
							[generator addPencilToEliminate:instruction];
						}
					}
					
					return [generator generateHint];
				}
			}
		}
		
		// Loop over all cols.
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			if (_fastGameBoard.totalTilesInColWithPencil[col][guess] && _fastGameBoard.totalTilesInColWithPencil[col][guess] <= 3) {
				BOOL allPencilsInSameGroup = YES;
				NSInteger totalPencilsFound = 0;
				NSInteger group = 0;
				
				// Check to see if all of the pencils are in the same group.
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
				
				// If all the pencils in this col are in the same group, we can eliminate all other of the same pencil from that group.
				if (allPencilsInSameGroup && _fastGameBoard.totalTilesInGroupWithPencil[group][guess] > totalPencilsFound) {
					ZSHintGeneratorEliminatePencilsBoxLineReduction *generator = [[ZSHintGeneratorEliminatePencilsBoxLineReduction alloc] init];
					
					generator.scope = ZSHintGeneratorTileScopeCol;
					generator.targetPencil = (guess + 1);
					
					for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
						// Add all col tiles.
						ZSHintGeneratorTileInstruction colTile;
						colTile.row = _fastGameBoard.cols[col][i]->row;
						colTile.col = _fastGameBoard.cols[col][i]->col;
						colTile.pencil = 0;
						[generator addRowOrColTile:colTile];
						
						// Add all group tiles.
						ZSHintGeneratorTileInstruction groupTile;
						groupTile.row = _fastGameBoard.groups[group][i]->row;
						groupTile.col = _fastGameBoard.groups[group][i]->col;
						groupTile.pencil = 0;
						[generator addGroupTile:groupTile];
						
						// If the col tile also exists within the group, add it.
						if (_fastGameBoard.groups[group][i]->col == col) {
							if (!_fastGameBoard.groups[group][i]->guess) {
								ZSHintGeneratorTileInstruction boxLineReductionTile;
								boxLineReductionTile.row = _fastGameBoard.groups[group][i]->row;
								boxLineReductionTile.col = _fastGameBoard.groups[group][i]->col;
								boxLineReductionTile.pencil = 0;
								[generator addBoxLineReductionTile:boxLineReductionTile];
							}
							
							continue;
						}
						
						if (!_fastGameBoard.groups[group][i]->guess && _fastGameBoard.groups[group][i]->pencils[guess]) {
							ZSHintGeneratorTileInstruction instruction;
							instruction.row = _fastGameBoard.groups[group][i]->row;
							instruction.col = _fastGameBoard.groups[group][i]->col;
							instruction.pencil = (guess + 1);
							[generator addPencilToEliminate:instruction];
						}
					}
					
					return [generator generateHint];
				}
			}
		}
	}
	
	return nil;
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
	NSArray *hintCards = nil;
	
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
							++totalPencilsEliminated;
						}
					}
				}
				
				// If any pencils were actually eliminated, we know we've found a useful X-Wing and can set up a
				// hint generator.
				if (totalPencilsEliminated) {
					ZSHintGeneratorEliminatePencilsXWing *generator = [[ZSHintGeneratorEliminatePencilsXWing alloc] init];
					
					generator.scope = ZSHintGeneratorTileScopeRow;
					generator.size = size;
					generator.targetPencil = guess + 1;
					
					for (NSInteger i = 0; i < size; ++i) {
						NSInteger XWingTileRow = slotMatches[currentRowIndexes[i]].matchIndex;
						
						for (NSInteger slotIndex = 0; slotIndex < size; ++slotIndex) {
							NSInteger XWingTileCol = slotsInRowGroup[slotIndex];
							
							if (_fastGameBoard.grid[XWingTileRow][XWingTileCol].pencils[guess]) {
								ZSHintGeneratorTileInstruction XWingTile;
								XWingTile.row = XWingTileRow;
								XWingTile.col = XWingTileCol;
								XWingTile.pencil = 0;
								[generator addXWingTile:XWingTile];
							}
						}
					}
					
					for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
						// Skip the rows in the group.
						if (rowExistsInRowGroup[row]) {
							continue;
						}
						
						for (NSInteger slotIndex = 0; slotIndex < size; ++slotIndex) {
							NSInteger col = slotsInRowGroup[slotIndex];
							
							if (_fastGameBoard.grid[row][col].pencils[guess]) {
								ZSHintGeneratorTileInstruction instruction;
								instruction.row = row;
								instruction.col = col;
								instruction.pencil = (guess + 1);
								[generator addPencilToEliminate:instruction];
							}
						}
					}
					
					hintCards = [generator generateHint];
				}
			}
			
			// If we successfully eliminated tiles using an X-Wing, we can stop here.
			if (totalPencilsEliminated) {
				break;
			}
		} while ([self setNextCombinationInArray:currentRowIndexes ofLength:size totalItems:totalRowMatches]);
		
		// If we successfully eliminated tiles using an X-Wing, we can stop here.
		if (totalPencilsEliminated) {
			break;
		}
	}
	
	free(rowExistsInRowGroup);
	free(slotExistsInRowGroup);
	free(slotsInRowGroup);
	free(currentRowIndexes);
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return hintCards;
}

- (NSArray *)eliminatePencilsXWingColsOfSize:(NSInteger)size {
	NSArray *hintCards = nil;
	
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
							++totalPencilsEliminated;
						}
					}
				}
				
				// If any pencils were actually eliminated, we know we've found a useful X-Wing and can set up a
				// hint generator.
				if (totalPencilsEliminated) {
					ZSHintGeneratorEliminatePencilsXWing *generator = [[ZSHintGeneratorEliminatePencilsXWing alloc] init];
					
					generator.scope = ZSHintGeneratorTileScopeCol;
					generator.size = size;
					generator.targetPencil = guess + 1;
					
					for (NSInteger i = 0; i < size; ++i) {
						NSInteger XWingTileCol = slotMatches[currentColIndexes[i]].matchIndex;
						
						for (NSInteger slotIndex = 0; slotIndex < size; ++slotIndex) {
							NSInteger XWingTileRow = slotsInColGroup[slotIndex];
							
							if (_fastGameBoard.grid[XWingTileRow][XWingTileCol].pencils[guess]) {
								ZSHintGeneratorTileInstruction XWingTile;
								XWingTile.row = XWingTileRow;
								XWingTile.col = XWingTileCol;
								XWingTile.pencil = 0;
								[generator addXWingTile:XWingTile];
							}
						}
					}
					
					// Finally, loop over all the rows and eliminate penils in each column.
					for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
						// Skip the rows in the group.
						if (colExistsInColGroup[col]) {
							continue;
						}
						
						for (NSInteger slotIndex = 0; slotIndex < size; ++slotIndex) {
							NSInteger row = slotsInColGroup[slotIndex];
							
							if (_fastGameBoard.grid[row][col].pencils[guess]) {
								ZSHintGeneratorTileInstruction instruction;
								instruction.row = row;
								instruction.col = col;
								instruction.pencil = (guess + 1);
								[generator addPencilToEliminate:instruction];
							}
						}
					}
					
					hintCards = [generator generateHint];
				}
			}
			
			// If we successfully eliminated tiles using an X-Wing, we can stop here.
			if (totalPencilsEliminated) {
				break;
			}
		} while ([self setNextCombinationInArray:currentColIndexes ofLength:size totalItems:totalColMatches]);
		
		// If we successfully eliminated tiles using an X-Wing, we can stop here.
		if (totalPencilsEliminated) {
			break;
		}
	}
	
	free(colExistsInColGroup);
	free(slotExistsInColGroup);
	free(slotsInColGroup);
	free(currentColIndexes);
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return hintCards;
}

- (NSArray *)eliminatePencilsFinnedXWingOfSize:(NSInteger)size {
	NSArray *hintCards = nil;
	
	hintCards = [self eliminatePencilsFinnedXWingRowsOfSize:size];
	
	if (hintCards) {
		return hintCards;
	}
	
	hintCards = [self eliminatePencilsFinnedXWingColsOfSize:size];
	
	if (hintCards) {
		return hintCards;
	}
	
	return hintCards;
}

- (NSArray *)eliminatePencilsFinnedXWingRowsOfSize:(NSInteger)size {
	NSArray *hintCards = nil;
	
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
								++totalPencilsEliminated;
							}
						}
					}
					
					if (totalPencilsEliminated) {
						ZSHintGeneratorEliminatePencilsFinnedXWing *generator = [[ZSHintGeneratorEliminatePencilsFinnedXWing alloc] init];
						
						// Set up the basic settings.
						generator.scope = ZSHintGeneratorTileScopeRow;
						generator.size = size;
						generator.targetPencil = guess + 1;
						
						// Add X-Wing tiles.
						for (NSInteger i = 0; i < (size - 1); ++i) {
							for (NSInteger j = 0; j < slotMatches[currentRowIndexes[i]].totalSlotIndexes; ++j) {
								ZSHintGeneratorTileInstruction finnedXWingTile;
								finnedXWingTile.row = slotMatches[currentRowIndexes[i]].matchIndex;
								finnedXWingTile.col = slotMatches[currentRowIndexes[i]].slotIndexes[j];
								finnedXWingTile.pencil = 0;
								[generator addFinnedXWingTile:finnedXWingTile];
							}
						}
						
						// Add fin tiles.
						for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
							if (_fastGameBoard.grid[row][col].pencils[guess]) {
								if (slotExistsInRowGroup[col]) {
									ZSHintGeneratorTileInstruction finnedXWingTile;
									finnedXWingTile.row = row;
									finnedXWingTile.col = col;
									finnedXWingTile.pencil = 0;
									[generator addFinnedXWingTile:finnedXWingTile];
								} else {
									ZSHintGeneratorTileInstruction finnedXWingTile;
									finnedXWingTile.row = row;
									finnedXWingTile.col = col;
									finnedXWingTile.pencil = 0;
									[generator addFinTile:finnedXWingTile];
								}
							}
						}
						
						// Add fin group tiles.
						for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
							ZSHintGeneratorTileInstruction finnedXWingTile;
							finnedXWingTile.row = _fastGameBoard.groups[firstDeviantPencilGroupId][i]->row;
							finnedXWingTile.col = _fastGameBoard.groups[firstDeviantPencilGroupId][i]->col;
							finnedXWingTile.pencil = 0;
							[generator addFinGroupTile:finnedXWingTile];
						}
						
						// Add the pencils to eliminate.
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
									ZSHintGeneratorTileInstruction finnedXWingTile;
									finnedXWingTile.row = _fastGameBoard.groups[firstDeviantPencilGroupId][i]->row;
									finnedXWingTile.col = col;
									finnedXWingTile.pencil = (guess + 1);
									[generator addPencilToEliminate:finnedXWingTile];
								}
							}
						}
						
						hintCards = [generator generateHint];
					}
				}
				
				// If we successfully eliminated tiles using an X-Wing, we can stop here.
				if (totalPencilsEliminated) {
					break;
				}
			}
			
			// If we successfully eliminated tiles using an X-Wing, we can stop here.
			if (totalPencilsEliminated) {
				break;
			}
		} while ([self setNextCombinationInArray:currentRowIndexes ofLength:(size - 1) totalItems:totalRowMatches]);
		
		// If we successfully eliminated tiles using an X-Wing, we can stop here.
		if (totalPencilsEliminated) {
			break;
		}
	}
	
	free(rowExistsInRowGroup);
	free(slotExistsInRowGroup);
	free(slotsInRowGroup);
	free(currentRowIndexes);
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return hintCards;
}

- (NSArray *)eliminatePencilsFinnedXWingColsOfSize:(NSInteger)size {
	NSArray *hintCards = nil;
	
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
								++totalPencilsEliminated;
							}
						}
					}
					
					if (totalPencilsEliminated) {
						ZSHintGeneratorEliminatePencilsFinnedXWing *generator = [[ZSHintGeneratorEliminatePencilsFinnedXWing alloc] init];
						
						// Set up the basic settings.
						generator.scope = ZSHintGeneratorTileScopeCol;
						generator.size = size;
						generator.targetPencil = guess + 1;
						
						// Add all X-Wing tiles.
						for (NSInteger i = 0; i < (size - 1); ++i) {
							for (NSInteger j = 0; j < slotMatches[currentColIndexes[i]].totalSlotIndexes; ++j) {
								ZSHintGeneratorTileInstruction finnedXWingTile;
								finnedXWingTile.row = slotMatches[currentColIndexes[i]].slotIndexes[j];
								finnedXWingTile.col = slotMatches[currentColIndexes[i]].matchIndex;
								finnedXWingTile.pencil = 0;
								[generator addFinnedXWingTile:finnedXWingTile];
							}
						}
						
						// Add fin tiles.
						for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
							if (_fastGameBoard.grid[row][col].pencils[guess]) {
								if (slotExistsInColGroup[row]) {
									ZSHintGeneratorTileInstruction finnedXWingTile;
									finnedXWingTile.row = row;
									finnedXWingTile.col = col;
									finnedXWingTile.pencil = 0;
									[generator addFinnedXWingTile:finnedXWingTile];
								} else {
									ZSHintGeneratorTileInstruction finnedXWingTile;
									finnedXWingTile.row = row;
									finnedXWingTile.col = col;
									finnedXWingTile.pencil = 0;
									[generator addFinTile:finnedXWingTile];
								}
							}
						}
						
						// Add fin group tiles.
						for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
							ZSHintGeneratorTileInstruction finnedXWingTile;
							finnedXWingTile.row = _fastGameBoard.groups[firstDeviantPencilGroupId][i]->row;
							finnedXWingTile.col = _fastGameBoard.groups[firstDeviantPencilGroupId][i]->col;
							finnedXWingTile.pencil = 0;
							[generator addFinGroupTile:finnedXWingTile];
						}
						
						// Add the pencils to eliminate.
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
									ZSHintGeneratorTileInstruction finnedXWingTile;
									finnedXWingTile.row = row;
									finnedXWingTile.col = _fastGameBoard.groups[firstDeviantPencilGroupId][i]->col;
									finnedXWingTile.pencil = (guess + 1);
									[generator addPencilToEliminate:finnedXWingTile];
								}
							}
						}
						
						hintCards = [generator generateHint];
					}
				}
				
				// If we successfully eliminated tiles using an X-Wing, we can stop here.
				if (totalPencilsEliminated) {
					break;
				}
			}
			
			// If we successfully eliminated tiles using an X-Wing, we can stop here.
			if (totalPencilsEliminated) {
				break;
			}
		} while ([self setNextCombinationInArray:currentColIndexes ofLength:(size - 1) totalItems:totalColMatches]);
		
		// If we successfully eliminated tiles using an X-Wing, we can stop here.
		if (totalPencilsEliminated) {
			break;
		}
	}
	
	free(colExistsInColGroup);
	free(slotExistsInColGroup);
	free(slotsInColGroup);
	free(currentColIndexes);
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(slotMatches[i].slotIndexes);
	}
	
	free(slotMatches);
	
	return hintCards;
}

- (NSArray *)eliminatePencilsYWingUseChains:(BOOL)useChains {
	NSArray *hintCards = nil;
	
	ZSTileList tileList;

	tileList.tiles = malloc(_fastGameBoard.size * _fastGameBoard.size * sizeof(ZSTileStub *));
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
		ZSTileStub *tile1 = tileList.tiles[yWingGroupIndexes[0]];
		ZSTileStub *tile2 = tileList.tiles[yWingGroupIndexes[1]];
		ZSTileStub *tile3 = tileList.tiles[yWingGroupIndexes[2]];
		
		// It's possible that we've eliminated pencils by the time we've gotten here. Make sure all 3 candidates still have 2 pencils each.
		if (tile1->totalPencils != 2 || tile2->totalPencils != 2 || tile3->totalPencils != 2) {
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
		
		// We have a proper Y-Wing group! For each proper pivot, eliminate pencil marks.
		if (tile1Influences == 2) {
			hintCards = [self eliminatePencilsYWingWithTile1:tile2 tile2:tile3 hinge:tile1 usingChainMap:useChains];
		}
		
		if (hintCards) {
			break;
		}
		
		if (tile2Influences == 2) {
			hintCards = [self eliminatePencilsYWingWithTile1:tile1 tile2:tile3 hinge:tile2 usingChainMap:useChains];
		}
		
		if (hintCards) {
			break;
		}
		
		if (tile3Influences == 2) {
			hintCards = [self eliminatePencilsYWingWithTile1:tile1 tile2:tile2 hinge:tile3 usingChainMap:useChains];
		}
		
		if (hintCards) {
			break;
		}
	} while ([self setNextCombinationInArray:yWingGroupIndexes ofLength:3 totalItems:tileList.totalTiles]);
	
	free(pencilMap);
	free(tileList.tiles);
	
	return hintCards;
}

- (NSArray *)eliminatePencilsYWingWithTile1:(ZSTileStub *)tile1 tile2:(ZSTileStub *)tile2 hinge:(ZSTileStub *)hinge usingChainMap:(BOOL)usingChainMap {
	NSArray *hintCards = nil;
	
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
	ZSTileList tileList = [_fastGameBoard getAllInfluencedTilesForTile:tile1 andOtherTile:tile2];
	
	for (NSInteger i = 0; i < tileList.totalTiles; ++i) {
		if (tileList.tiles[i] == tile1 || tileList.tiles[i] == tile2) {
			continue;
		}
		
		if (tileList.tiles[i]->pencils[commonPencil]) {
			++totalPencilsEliminated;
		}
	}
	
	if (totalPencilsEliminated) {
		if (usingChainMap) {
			ZSHintGeneratorEliminatePencilsChainedYWing *generator = [[ZSHintGeneratorEliminatePencilsChainedYWing alloc] init];
			
			ZSHintGeneratorTileInstruction hingeInstruction;
			hingeInstruction.row = hinge->row;
			hingeInstruction.col = hinge->col;
			hingeInstruction.pencil = 0;
			generator.hingeTile = hingeInstruction;
			
			BOOL alreadyFoundFirstPencil = NO;
			
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
				if (_fastGameBoard.rows[hinge->row][hinge->col]->pencils[i]) {
					if (alreadyFoundFirstPencil) {
						generator.hingePencil2 = i + 1;
					} else {
						generator.hingePencil1 = i + 1;
						alreadyFoundFirstPencil = YES;
					}
				}
			}
			
			ZSHintGeneratorTileInstruction pincer1Instruction;
			pincer1Instruction.row = tile1->row;
			pincer1Instruction.col = tile1->col;
			pincer1Instruction.pencil = 0;
			generator.pincer1 = pincer1Instruction;
			
			ZSHintGeneratorTileInstruction pincer2Instruction;
			pincer2Instruction.row = tile2->row;
			pincer2Instruction.col = tile2->col;
			pincer2Instruction.pencil = 0;
			generator.pincer2 = pincer2Instruction;
			
			generator.targetPencil = (commonPencil + 1);
			
			for (NSInteger i = 0; i < tileList.totalTiles; ++i) {
				if (tileList.tiles[i] == tile1 || tileList.tiles[i] == tile2) {
					continue;
				}
				
				if (tileList.tiles[i]->pencils[commonPencil]) {
					ZSHintGeneratorTileInstruction eliminateInstruction;
					eliminateInstruction.row = tileList.tiles[i]->row;
					eliminateInstruction.col = tileList.tiles[i]->col;
					eliminateInstruction.pencil = (commonPencil + 1);
					[generator addPencilToEliminate:eliminateInstruction];
				}
			}
			
			hintCards = [generator generateHint];
		} else {
			ZSHintGeneratorEliminatePencilsYWing *generator = [[ZSHintGeneratorEliminatePencilsYWing alloc] init];
			
			ZSHintGeneratorTileInstruction hingeInstruction;
			hingeInstruction.row = hinge->row;
			hingeInstruction.col = hinge->col;
			hingeInstruction.pencil = 0;
			generator.hingeTile = hingeInstruction;
			
			BOOL alreadyFoundFirstPencil = NO;
			
			for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
				if (_fastGameBoard.rows[hinge->row][hinge->col]->pencils[i]) {
					if (alreadyFoundFirstPencil) {
						generator.hingePencil2 = i + 1;
					} else {
						generator.hingePencil1 = i + 1;
						alreadyFoundFirstPencil = YES;
					}
				}
			}
			
			ZSHintGeneratorTileInstruction pincer1Instruction;
			pincer1Instruction.row = tile1->row;
			pincer1Instruction.col = tile1->col;
			pincer1Instruction.pencil = 0;
			generator.pincer1 = pincer1Instruction;
			
			ZSHintGeneratorTileInstruction pincer2Instruction;
			pincer2Instruction.row = tile2->row;
			pincer2Instruction.col = tile2->col;
			pincer2Instruction.pencil = 0;
			generator.pincer2 = pincer2Instruction;
			
			generator.targetPencil = (commonPencil + 1);
			
			for (NSInteger i = 0; i < tileList.totalTiles; ++i) {
				if (tileList.tiles[i] == tile1 || tileList.tiles[i] == tile2) {
					continue;
				}
				
				if (tileList.tiles[i]->pencils[commonPencil]) {
					ZSHintGeneratorTileInstruction eliminateInstruction;
					eliminateInstruction.row = tileList.tiles[i]->row;
					eliminateInstruction.col = tileList.tiles[i]->col;
					eliminateInstruction.pencil = (commonPencil + 1);
					[generator addPencilToEliminate:eliminateInstruction];
				}
			}
			
			hintCards = [generator generateHint];
		}
	}
	
	free(tileList.tiles);
	
	return hintCards;
}

- (NSArray *)eliminatePencilsRemotePairs {
	NSArray *hintCards = nil;
	
	NSInteger totalPencilsEliminated = 0;
	
	BOOL **investigatedTiles = malloc(_fastGameBoard.size * sizeof(BOOL *));
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		investigatedTiles[i] = malloc(_fastGameBoard.size * sizeof(BOOL));
		
		for (NSInteger j = 0; j < _fastGameBoard.size; ++j) {
			investigatedTiles[i][j] = NO;
		}
	}
	
	// Loop over all the tiles and look for those with only two pencils.
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			ZSTileStub *currentTile = &_fastGameBoard.grid[row][col];
			
			// Skip any tiles that have already been part of a chain.
			if (investigatedTiles[row][col]) {
				continue;
			}
			
			investigatedTiles[row][col] = YES;
			
			// Only tiles with exactly 2 pencils can be part of remote pairs. If this one is, 
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
						ZSTileStub *targetTile = &_fastGameBoard.grid[chainMapRow][chainMapCol];
						
						switch (_chainMap[chainMapRow][chainMapCol]) {
							case ZSChainMapResultRelatedConflicted:
								
								if (targetTile->pencils[firstPencil]) {
									++totalPencilsEliminated;
								}
								
								if (targetTile->pencils[secondPencil]) {
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

				if (totalPencilsEliminated) {
					ZSHintGeneratorEliminatePencilsRemotePairs *generator = [[ZSHintGeneratorEliminatePencilsRemotePairs alloc] init];
					
					generator.chainPencil1 = (firstPencil + 1);
					generator.chainPencil2 = (secondPencil + 1);
					
					for (NSInteger chainMapRow = 0; chainMapRow < _fastGameBoard.size; ++chainMapRow) {
						for (NSInteger chainMapCol = 0; chainMapCol < _fastGameBoard.size; ++chainMapCol) {
							ZSTileStub *targetTile = &_fastGameBoard.grid[chainMapRow][chainMapCol];
							
							switch (_chainMap[chainMapRow][chainMapCol]) {
								case ZSChainMapResultRelatedConflicted:
									
									if (targetTile->pencils[firstPencil]) {
										ZSHintGeneratorTileInstruction eliminateInstruction;
										eliminateInstruction.row = targetTile->row;
										eliminateInstruction.col = targetTile->col;
										eliminateInstruction.pencil = (firstPencil + 1);
										[generator addPencilToEliminate:eliminateInstruction];
									}
									
									if (targetTile->pencils[secondPencil]) {
										ZSHintGeneratorTileInstruction eliminateInstruction;
										eliminateInstruction.row = targetTile->row;
										eliminateInstruction.col = targetTile->col;
										eliminateInstruction.pencil = (secondPencil + 1);
										[generator addPencilToEliminate:eliminateInstruction];
									}
									
									break;

								case ZSChainMapResultLinkedOn: {
									ZSHintGeneratorTileInstruction evenInstruction;
									evenInstruction.row = targetTile->row;
									evenInstruction.col = targetTile->col;
									evenInstruction.pencil = 0;
									[generator addEvenChainLink:evenInstruction];
								}
									break;
								
								case ZSChainMapResultLinkedOff: {
									ZSHintGeneratorTileInstruction oddInstruction;
									oddInstruction.row = targetTile->row;
									oddInstruction.col = targetTile->col;
									oddInstruction.pencil = 0;
									[generator addOddChainLink:oddInstruction];
								}
									break;
								
								default:
									break;
							}
						}
					}
					
					hintCards = [generator generateHint];
					
					break;
				}
			}
			
			if (totalPencilsEliminated) {
				break;
			}
		}
		
		if (totalPencilsEliminated) {
			break;
		}
	}
	
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		free(investigatedTiles[i]);
	}
	
	free(investigatedTiles);
	
	return hintCards;
}

- (NSArray *)eliminatePencilsAvoidableRectangles {
	NSArray *hintCards = nil;
	
	// Iterate over all tiles.
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			ZSTileStub *currentTile = &_fastGameBoard.grid[row][col];
			
			// Only choose tiles that has a guess set by the user.
			if (currentTile->guess && !_clueIsProvidedInPuzzle[row][col]) {
				// Iterate over all guesses.
				for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
					// Because we're looking for another non-diagonal corner of the rectangle, skip over guesses that match the chosen tile's.
					if (currentTile->guess == (guess + 1)) {
						continue;
					}
					
					// If the chosen tile shares a row and column each with one guess matching our second chosen guess, we have 3 corners of the rectangle.
					if (_fastGameBoard.totalTilesInRowWithAnswer[row][guess] == 1 && _fastGameBoard.totalTilesInColWithAnswer[col][guess] == 1) {
						NSInteger otherRowIndex = 0;
						NSInteger otherColIndex = 0;
						
						// Determine the other column that makes up the rectangle.
						for (otherColIndex = 0; otherColIndex < _fastGameBoard.size; ++otherColIndex) {
							if (_fastGameBoard.grid[row][otherColIndex].guess == (guess + 1)) {
								break;
							}
						}
						
						// Determine the other row that makes up the rectangle.
						for (otherRowIndex = 0; otherRowIndex < _fastGameBoard.size; ++otherRowIndex) {
							if (_fastGameBoard.grid[otherRowIndex][col].guess == (guess + 1)) {
								break;
							}
						}
						
						// All 3 corners with guesses must be set by the user.
						if (_clueIsProvidedInPuzzle[row][otherColIndex] || _clueIsProvidedInPuzzle[otherRowIndex][col]) {
							continue;
						}
						
						// Now we need to keep track of how many groups the rectangle spans. It must span only two groups.
						NSInteger rectangleCornersInTargetTilesGroup = 0;
						
						if (_fastGameBoard.grid[row][otherColIndex].groupId == currentTile->groupId) {
							++rectangleCornersInTargetTilesGroup;
						}
						
						if (_fastGameBoard.grid[otherRowIndex][col].groupId == currentTile->groupId) {
							++rectangleCornersInTargetTilesGroup;
						}
						
						// If rectangleCornersInTargetTilesGroup, it means the rectangle spans 4 groups instead of 2.
						if (rectangleCornersInTargetTilesGroup != 1) {
							continue;
						}
						
						if (_fastGameBoard.grid[otherRowIndex][otherColIndex].pencils[(currentTile->guess - 1)]) {
							[_fastGameBoard setPencil:NO forPencilNumber:currentTile->guess forTileAtRow:otherRowIndex col:otherColIndex];
							
							ZSHintGeneratorEliminatePencilsAvoidableRectangles *generator = [[ZSHintGeneratorEliminatePencilsAvoidableRectangles alloc] init];
							
							ZSHintGeneratorTileInstruction hingeInstruction;
							hingeInstruction.row = currentTile->row;
							hingeInstruction.col = currentTile->col;
							hingeInstruction.pencil = 0;
							generator.hingeTile = hingeInstruction;
							
							ZSHintGeneratorTileInstruction pincer1Instruction;
							pincer1Instruction.row = otherRowIndex;
							pincer1Instruction.col = currentTile->col;
							pincer1Instruction.pencil = 0;
							generator.pincer1 = pincer1Instruction;
							
							ZSHintGeneratorTileInstruction pincer2Instruction;
							pincer2Instruction.row = currentTile->row;
							pincer2Instruction.col = otherColIndex;
							pincer2Instruction.pencil = 0;
							generator.pincer2 = pincer2Instruction;
							
							ZSHintGeneratorTileInstruction eliminateInstruction;
							eliminateInstruction.row = otherRowIndex;
							eliminateInstruction.col = otherColIndex;
							eliminateInstruction.pencil = currentTile->guess;
							generator.eliminateInstruction = eliminateInstruction;
							
							generator.impossibleAnswer = currentTile->guess;
							generator.diagonalAnswer = _fastGameBoard.grid[otherRowIndex][currentTile->col].guess;
							
							hintCards = [generator generateHint];
						}
					}
				}
			}
		}
	}
 
	return hintCards;
}

- (NSArray *)eliminatePencilNoHint {
	ZSHintGeneratorNoHint *generator = [[ZSHintGeneratorNoHint alloc] init];
	
	NSInteger totalPencils = 0;
	
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			if (_fastGameBoard.grid[row][col].guess) {
				continue;
			}
			
			for (NSInteger pencil = 0; pencil < _fastGameBoard.size; ++pencil) {
				if (pencil == _fastGameBoard.grid[row][col].answer) {
					continue;
				}
				
				if (_fastGameBoard.grid[row][col].pencils[pencil]) {
					++totalPencils;
				}
			}
		}
	}
	
	NSInteger randomPencil = arc4random() % totalPencils;
	NSInteger currentPencil = 0;
	BOOL pencilFound = NO;
	
	for (NSInteger row = 0; !pencilFound && row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; !pencilFound && col < _fastGameBoard.size; ++col) {
			if (_fastGameBoard.grid[row][col].guess) {
				continue;
			}
			
			for (NSInteger pencil = 0; !pencilFound && pencil < _fastGameBoard.size; ++pencil) {
				if (pencil + 1 == _fastGameBoard.grid[row][col].answer) {
					continue;
				}
				
				if (_fastGameBoard.grid[row][col].pencils[pencil]) {
					if (randomPencil == currentPencil) {
						ZSHintGeneratorTileInstruction eliminateInstruction;
						eliminateInstruction.row = row;
						eliminateInstruction.col = col;
						eliminateInstruction.pencil = (pencil + 1);
						generator.randomEliminateInstruction = eliminateInstruction;
						
						pencilFound = YES;
					}

					++currentPencil;
				}
			}
		}
	}
	
	return [generator generateHint];
}

#pragma mark - Logic Technique Helpers

// Populate the pencilMap array with a list of pencils that exist in the given tile set. Return the total number of pencils found.
- (NSInteger)initPencilMap:(NSInteger *)pencilMap forTileSet:(ZSTileStub **)set {
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

- (void)copyClueMaskFromGameBoard:(ZSBoard *)board {
	for (NSInteger row = 0; row < _fastGameBoard.size; ++row) {
		for (NSInteger col = 0; col < _fastGameBoard.size; ++col) {
			_clueIsProvidedInPuzzle[row][col] = [board getTileAtRow:row col:col].locked;
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

- (void)updateChainMapForTile:(ZSTileStub *)tile {
	if (!_chainMapIsClear) {
		[self clearChainMap];
	}
	
	NSInteger totalPencils = 0;
	
	// The start of the chain was passed to us in this method. Now we need to note which pencil marks are present in that tile.
	for (NSInteger guess = 0; guess < _fastGameBoard.size; ++guess) {
		if (tile->pencils[guess]) {
			_chainPencils[totalPencils] = guess;
			++totalPencils;
		}
	}
	
	// Mark the tile as the start of the chain.
	_chainMap[tile->row][tile->col] = ZSChainMapResultLinkedOn;
	
	[self updateChainMapForTile:tile totalPencils:totalPencils currentLinkOn:YES];
	
	_chainMapIsClear = NO;
}

- (void)updateChainMapForTile:(ZSTileStub *)tile totalPencils:(NSInteger)totalPencils currentLinkOn:(BOOL)currentLinkOn {
	for (NSInteger i = 0; i < _fastGameBoard.size; ++i) {
		ZSTileStub *currentTile = _fastGameBoard.rows[tile->row][i];
		
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
		ZSTileStub *currentTile = _fastGameBoard.cols[tile->col][i];
		
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
		ZSTileStub *currentTile = _fastGameBoard.groups[groupId][i];
		
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
