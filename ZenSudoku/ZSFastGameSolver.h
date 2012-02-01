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

@class ZSFastGameBoard;

@interface ZSFastGameSolver : NSObject {
	@private
	
	ZSFastGameBoard *_gameBoard;
	ZSFastGameBoard *_solvedGameBoard;
}

- (id)init;
- (id)initWithSize:(int)size;

- (void)copyGroupMapFromFastGameBoard:(ZSFastGameBoard *)gameBoard;
- (void)copyGuessesFromFastGameBoard:(ZSFastGameBoard *)gameBoard;

- (void)copyGroupMapFromGameBoard:(ZSGameBoard *)gameBoard;
- (void)copyGuessesFromGameBoard:(ZSGameBoard *)gameBoard;

- (void)copySolutionToFastGameBoard:(ZSFastGameBoard *)gameBoard;
- (void)copySolutionToGameBoard:(ZSGameBoard *)gameBoard;

- (ZSGameSolveResult)solve;

- (ZSFastGameBoard *)getGameBoard;
- (ZSFastGameBoard *)getSolvedGameBoard;

// Logic Techniques
- (int)solveOnlyChoice;
- (int)solveSinglePossibility;
- (int)eliminatePencilsHiddenSubgroupForSize:(int)size;
- (int)eliminatePencilsNakedSubgroupForSize:(int)size;

// Logic Technique Helpers
- (int)initPencilMap:(int *)pencilMap forTileSet:(ZSGameTileStub **)set;
- (void)setFirstCombinationInArray:(int *)comboArray ofLength:(int)arrayLength totalPencils:(int)itemCount;
- (BOOL)setNextCombinationInArray:(int *)comboArray ofLength:(int)arrayLength totalPencils:(int)itemCount;
- (int)getNumberOfTilesInSet:(ZSGameTileStub **)set withTotalPencilsEqualToOrGreaterThan:(int)totalPencilLimit;

// Brute Force Solving
- (ZSGameSolveResult)solveBruteForce;
- (ZSGameSolveResult)solveBruteForceForRow:(int)row col:(int)col;

@end

extern NSString * const kExceptionPuzzleHasNoSolution;
extern NSString * const kExceptionPuzzleHasMultipleSolutions;
