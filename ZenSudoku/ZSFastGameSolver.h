//
//  ZSGameSolver.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSGameCalculator.h"

typedef enum {
	ZSGameSolveResultSucceeded,
	ZSGameSolveResultFailedNoSolution,
	ZSGameSolveResultFailedMultipleSolutions
} ZSGameSolveResult;

@class ZSGame;

@interface ZSGameSolver : NSObject {
	@private
	
	ZSGameBoard *_gameBoard;
	ZSGameBoard *_solvedGameBoard;
}

- (ZSGameSolveResult)solveGameBoard:(ZSGameBoard *)gameBoard;

- (ZSGameSolveResult)solve;

- (NSInteger)solveOnlyChoice;
- (NSInteger)solveSinglePossibility;
- (NSInteger)eliminatePencilsHiddenSubGroup;
- (ZSGameSolveResult)solveBruteForce;

- (ZSGameSolveResult)solveBruteForceForRow:(NSInteger)row col:(NSInteger)col;

@end

extern NSString * const kExceptionPuzzleHasNoSolution;
extern NSString * const kExceptionPuzzleHasMultipleSolutions;
