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
- (id)initWithSize:(NSInteger)size;

- (void)copyGroupMapFromFastGameBoard:(ZSFastGameBoard *)gameBoard;
- (void)copyGuessesFromFastGameBoard:(ZSFastGameBoard *)gameBoard;

- (void)copySolutionToFastGameBoard:(ZSFastGameBoard *)gameBoard;

- (ZSGameSolveResult)solve;

- (ZSFastGameBoard *)getGameBoard;
- (ZSFastGameBoard *)getSolvedGameBoard;

// Logic Techniques
- (NSInteger)solveOnlyChoice;
- (NSInteger)solveSinglePossibility;
- (NSInteger)eliminatePencilsHiddenSubgroupForSize:(NSInteger)size;

// Logic Technique Helpers
- (NSInteger)initPencilMap:(NSInteger *)pencilMap forTileSet:(ZSGameTileStub **)set;
- (void)setFirstCombinationInArray:(NSInteger *)comboArray ofLength:(NSInteger)arrayLength totalPencils:(NSInteger)itemCount;
- (BOOL)setNextCombinationInArray:(NSInteger *)comboArray ofLength:(NSInteger)arrayLength totalPencils:(NSInteger)itemCount;
- (NSInteger)getNumberOfTilesInSet:(ZSGameTileStub **)set withTotalPencilsEqualToOrGreaterThan:(NSInteger)totalPencilLimit;

// Brute Force Solving
- (ZSGameSolveResult)solveBruteForce;
- (ZSGameSolveResult)solveBruteForceForRow:(NSInteger)row col:(NSInteger)col;

@end

extern NSString * const kExceptionPuzzleHasNoSolution;
extern NSString * const kExceptionPuzzleHasMultipleSolutions;
