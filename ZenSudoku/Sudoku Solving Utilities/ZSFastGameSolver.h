//
//  ZSFastGameSolver.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZSFastGameBoard.h"

typedef enum {
	ZSGameSolveResultSucceeded,
	ZSGameSolveResultFailedNoSolution,
	ZSGameSolveResultFailedMultipleSolutions
} ZSGameSolveResult;

typedef enum {
	ZSChainMapResultUnset,
	ZSChainMapResultLinkedOn,
	ZSChainMapResultLinkedOff,
	ZSChainMapResultLinkedConflicted,
	ZSChainMapResultRelatedOn,
	ZSChainMapResultRelatedOff,
	ZSChainMapResultRelatedConflicted,
	ZSChainMapResultUnrelated
} ZSChainMapResult;

typedef struct {
	NSInteger *slotIndexes;
	NSInteger totalSlotIndexes;
	NSInteger matchIndex;
} ZSXWingSlotMatch;

@class ZSFastGameBoard;

@interface ZSFastGameSolver : NSObject {
	
@private
	ZSFastGameBoard *_gameBoard;
	ZSFastGameBoard *_solvedGameBoard;
	
	BOOL **_clueIsProvidedInPuzzle;
	
	BOOL _chainMapIsClear;
	ZSChainMapResult **_chainMap;
	NSInteger *_chainPencils;
}


- (id)init;
- (id)initWithSize:(NSInteger)size;
- (void)dealloc;

- (void)copyGroupMapFromFastGameBoard:(ZSFastGameBoard *)gameBoard;
- (void)copyGuessesFromFastGameBoard:(ZSFastGameBoard *)gameBoard;

- (void)copySolutionToFastGameBoard:(ZSFastGameBoard *)gameBoard;

- (ZSGameSolveResult)solve;
- (ZSGameSolveResult)solveQuickly;

- (ZSFastGameBoard *)getGameBoard;
- (ZSFastGameBoard *)getSolvedGameBoard;
- (ZSChainMapResult **)getChainMap;

// Logic Techniques
- (NSInteger)solveOnlyChoice;
- (NSInteger)solveSinglePossibility;
- (NSInteger)eliminatePencilsHiddenSubgroupForSize:(NSInteger)size;
- (NSInteger)eliminatePencilsNakedSubgroupForSize:(NSInteger)size;
- (NSInteger)eliminatePencilsPointingPairs;
- (NSInteger)eliminatePencilsBoxLineReduction;
- (NSInteger)eliminatePencilsXWingOfSize:(NSInteger)size;
- (NSInteger)eliminatePencilsXWingRowsOfSize:(NSInteger)size;
- (NSInteger)eliminatePencilsXWingColsOfSize:(NSInteger)size;
- (NSInteger)eliminatePencilsFinnedXWingOfSize:(NSInteger)size;
- (NSInteger)eliminatePencilsFinnedXWingRowsOfSize:(NSInteger)size;
- (NSInteger)eliminatePencilsFinnedXWingColsOfSize:(NSInteger)size;
- (NSInteger)eliminatePencilsYWingUseChains:(BOOL)useChains;
- (NSInteger)eliminatePencilsYWingWithTile1:(ZSGameTileStub *)tile1 tile2:(ZSGameTileStub *)tile2;
- (NSInteger)eliminatePencilsRemotePairs;
- (NSInteger)eliminatePencilsAvoidableRectangles;

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

// Brute Force Solving
- (ZSGameSolveResult)solveBruteForce;
- (ZSGameSolveResult)solveBruteForceForRow:(NSInteger)row col:(NSInteger)col;

@end

extern NSString * const kExceptionPuzzleHasNoSolution;
extern NSString * const kExceptionPuzzleHasMultipleSolutions;
